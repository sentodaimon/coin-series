Set-Location $PSScriptRoot
$s = @{}; Get-Content .\m0-settings.bat | Where-Object { $_ -match '^set (\w+)=(.*)$' } | ForEach-Object { $null = $_ -match '^set (\w+)=(.*)$'; $s[$Matches[1]] = $Matches[2].Trim() }
$DATA = $s.DATA; $BK = "$DATA-backup"
New-Item -ItemType Directory -Force $BK | Out-Null
$p1 = Read-Host "Wallet password" -AsSecureString
$p2 = Read-Host "Same password again" -AsSecureString
$a = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p1))
$b = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p2))
if ($a -ne $b -or $a.Length -lt 8) { Write-Host "Passwords differ or shorter than 8 characters. Nothing changed."; exit 1 }
foreach ($c in "half","quarter","dime","nickel","cent") {
  $r = & .\bitcoin-cli.exe "-datadir=$DATA" -chain=main "-coin=$c" -rpcwallet=w encryptwallet $a 2>&1 | Out-String
  Write-Host "$c : $($r.Trim())"
  & .\bitcoin-cli.exe "-datadir=$DATA" -chain=main "-coin=$c" -rpcwallet=w backupwallet "$BK\$c-wallet.dat" 2>&1 | Out-Null
  if (Test-Path "$BK\$c-wallet.dat") { Write-Host "$c : backup saved" } else { Write-Host "$c : BACKUP FAILED" }
}
$a = $null; $b = $null
Write-Host "Done. Copy the folder $BK to a USB stick and keep it with the password paper."
