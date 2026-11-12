# Reads the 80-byte header of Bitcoin block H from two public explorers, checks it, starts the five
# mainnet nodes, waits until they are synced with the network, then starts mining.
param([switch]$DryRun)
Set-Location $PSScriptRoot
$s = @{}; Get-Content .\m0-settings.bat | Where-Object { $_ -match '^set (\w+)=(.*)$' } | ForEach-Object { $null = $_ -match '^set (\w+)=(.*)$'; $s[$Matches[1]] = $Matches[2].Trim() }
$DATA = $s.DATA; $H = [int]$s.HEIGHT;
if ($DryRun) { $DATA = "C:\CoinSeries\mainnet-dryrun"; $H = 974000 }
$THREADS = if ($s.THREADS -eq '%NUMBER_OF_PROCESSORS%') { $env:NUMBER_OF_PROCESSORS } else { $s.THREADS }
New-Item -ItemType Directory -Force $DATA | Out-Null
$log = Join-Path $DATA "start-log.txt"
function Log($m) { $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') $m"; Write-Host $line; Add-Content $log $line }
function Get-Header($h) {
  foreach ($base in @("https://mempool.space/api", "https://blockstream.info/api")) {
    try {
      $hash = (Invoke-RestMethod "$base/block-height/$h" -TimeoutSec 20).ToString().Trim()
      $hdr = (Invoke-RestMethod "$base/block/$hash/header" -TimeoutSec 20).ToString().Trim()
      if ($hdr.Length -eq 160) { return @{hash=$hash; header=$hdr; src=$base} }
    } catch { }
  }
  return $null
}
function SHA256d-Hex($hex) {
  $b = [byte[]]::new($hex.Length/2); for ($i=0; $i -lt $b.Length; $i++) { $b[$i] = [Convert]::ToByte($hex.Substring(2*$i,2),16) }
  $sha = [Security.Cryptography.SHA256]::Create(); $d = $sha.ComputeHash($sha.ComputeHash($b)); [Array]::Reverse($d)
  -join ($d | ForEach-Object { $_.ToString('x2') })
}
if (-not (Test-Path $s.SNAPSHOT)) {
  Log "The claim snapshot is missing: $($s.SNAPSHOT)"
  Log "Download utxo-840000.dat (about 9.8 GB) and put it there, then run this again. See README (Windows quick start)."
  exit 1
}
Log "reading Bitcoin block $H"
while ($true) {
  $r = Get-Header $H
  if ($r) {
    if ((SHA256d-Hex $r.header) -ne $r.hash) { Log "header does not match its hash ($($r.src)), retrying"; Start-Sleep 30; continue }
    break
  }
  Start-Sleep 30
}
Log "block H found: $($r.hash) from $($r.src)"
Set-Content (Join-Path $DATA "beacon-header.txt") $r.header
$args0 = @("-datadir=$DATA", "-chain=main", "-beaconheader=$($r.header)", "-claimsnapshot=$($s.SNAPSHOT)")
if ($s.SEED) { $args0 += "-addnode=$($s.SEED)" }
foreach ($c in "half","quarter","dime","nickel","cent") {
  Start-Process -FilePath .\bitcoind.exe -WindowStyle Minimized -ArgumentList ($args0 + "-coin=$c")
}
Log "nodes started, waiting until ready"
$addr = @{}
foreach ($c in "half","quarter","dime","nickel","cent") {
  for ($i = 0; $i -lt 360; $i++) { $n = & .\bitcoin-cli.exe "-datadir=$DATA" -chain=main "-coin=$c" getblockcount 2>$null; if ($LASTEXITCODE -eq 0) { break }; Start-Sleep 5 }
  & .\bitcoin-cli.exe "-datadir=$DATA" -chain=main "-coin=$c" createwallet w 2>$null | Out-Null
  & .\bitcoin-cli.exe "-datadir=$DATA" -chain=main "-coin=$c" loadwallet w 2>$null | Out-Null
  $f = Join-Path $DATA "address-$c.txt"
  if (!(Test-Path $f) -or (Get-Item $f).Length -lt 10) { (& .\bitcoin-cli.exe "-datadir=$DATA" -chain=main "-coin=$c" getnewaddress).Trim() | Set-Content $f }
  $addr[$c] = (Get-Content $f).Trim()
  Log "$c ready, reward address $($addr[$c])"
}
if ($DryRun) {
  Log "DRY RUN OK - stopping dry-run nodes (no mining)"
  foreach ($c in "half","quarter","dime","nickel","cent") { & .\bitcoin-cli.exe "-datadir=$DATA" -chain=main "-coin=$c" stop 2>$null | Out-Null }
  exit 0
}
# Wait until the nodes are connected and synced, so mining builds on the current chain.
if ($s.SEED) {
  Log "connecting to $($s.SEED) and downloading the chain (can take a few minutes)"
  $ok = $false
  for ($i = 0; $i -lt 360; $i++) {
    $all = $true
    foreach ($c in "half","quarter","dime","nickel","cent") {
      $raw = & .\bitcoin-cli.exe "-datadir=$DATA" -chain=main "-coin=$c" getblockchaininfo 2>$null
      $info = if ($raw) { ($raw -join "`n") | ConvertFrom-Json } else { $null }
      $peers = [int](& .\bitcoin-cli.exe "-datadir=$DATA" -chain=main "-coin=$c" getconnectioncount 2>$null)
      if (-not $info -or $peers -lt 1 -or $info.headers -lt 1 -or $info.blocks -lt $info.headers) { $all = $false }
    }
    if ($all) { $ok = $true; break }
    Start-Sleep 10
  }
  if ($ok) { $n = & .\bitcoin-cli.exe "-datadir=$DATA" -chain=main -coin=half getblockcount; Log "synced: $n blocks" }
  else { Log "WARNING: could not sync with $($s.SEED) within 60 minutes. Check the internet connection; mining starts anyway." }
}
$minerArgs = @("--chain","main","--datadir",$DATA,"--threads",$THREADS)
foreach ($c in "half","quarter","dime","nickel","cent") { $minerArgs += @("--coin", "$c=$($addr[$c])") }
Start-Process -FilePath cmd.exe -WindowStyle Minimized -ArgumentList ("/c cs-miner.exe " + ($minerArgs -join ' ') + " >> `"$DATA\mining-log.txt`" 2>&1")
Log "mining started with $THREADS threads. Next: m2-protect-wallets.bat (password + backup)"
