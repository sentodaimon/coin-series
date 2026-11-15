#!/usr/bin/env bash
# End-to-end: claims whose proofs are signed by an ordinary Bitcoin Core wallet via PSBT
# (no private key ever given to the Coin Series node). Address types: P2PKH, P2SH-P2WPKH, P2WPKH, P2TR.
set -uo pipefail
# Usage: tools/psbt_claim_test.sh <build/bin>
BIN=${1:-build/bin}
TOOL="$(dirname "$0")/cs_claim_psbt.py"
BTCDIR=$(mktemp -d); CSDIR=$(mktemp -d); WORK=$(mktemp -d)
FAIL=0
pass() { echo "PASS  $*"; }
fail() { echo "FAIL  $*"; FAIL=1; }
btc() { "$BIN/bitcoin-cli" -datadir="$BTCDIR" -regtest "$@"; }
cs() { local c=$1; shift; "$BIN/bitcoin-cli" -datadir="$CSDIR" -coin=$c -regtest "$@"; }
cleanup() { btc stop >/dev/null 2>&1; for c in half quarter dime nickel cent; do cs $c stop >/dev/null 2>&1; done; sleep 3; rm -rf "$BTCDIR" "$CSDIR" "$WORK"; }
trap cleanup EXIT
J() { python3 -c "import sys,json;d=json.load(sys.stdin);print($1)"; }

"$BIN/bitcoind" -datadir="$BTCDIR" -regtest -daemon -listen=0 -fallbackfee=0.0001 >/dev/null
btc -rpcwait createwallet miner >/dev/null
MINER=$(btc -rpcwallet=miner getnewaddress)
btc generatetoaddress 110 "$MINER" >/dev/null
# The holder's own wallet: an ordinary descriptor wallet with one address of each type.
btc createwallet holder >/dev/null
TYPES=(legacy p2sh-segwit bech32 bech32m)
declare -A ADDR TXID VOUT
for t in "${TYPES[@]}"; do
  ADDR[$t]=$(btc -rpcwallet=holder getnewaddress "" $t)
  T=$(btc -rpcwallet=miner sendtoaddress "${ADDR[$t]}" 1)
  TXID[$t]=$T
  VOUT[$t]=$(btc -rpcwallet=miner gettransaction "$T" true true | python3 -c "
import sys,json; d=json.load(sys.stdin); print([o['n'] for o in d['decoded']['vout'] if o['scriptPubKey'].get('address')=='${ADDR[$t]}'][0])")
done
btc generatetoaddress 1 "$MINER" >/dev/null
DUMP=$(btc dumptxoutset "$BTCDIR/snap.dat" latest)
HASH=$(echo "$DUMP" | J "d['txoutset_hash']")

for c in half quarter dime nickel cent; do
  "$BIN/bitcoind" -datadir="$CSDIR" -coin=$c -regtest -daemon -listen=0 -fallbackfee=0.0001 \
     -claimsnapshot="$BTCDIR/snap.dat" -claimsnapshothash="$HASH" >/dev/null
done
sleep 5
declare -A RCV MULT=([half]=2 [quarter]=4 [dime]=10 [nickel]=20 [cent]=100)
for c in half quarter dime nickel cent; do
  cs $c -rpcwait createwallet w >/dev/null
  RCV[$c]=$(cs $c getnewaddress)
  cs $c generatetoaddress 101 "${RCV[$c]}" >/dev/null
done

for t in "${TYPES[@]}"; do
  for c in half quarter dime nickel cent; do
    AMT=$(python3 -c "print(${MULT[$c]}*1 - 0.001)")
    C=$(cs $c createclaim "[{\"txid\":\"${TXID[$t]}\",\"vout\":${VOUT[$t]}}]" "[{\"${RCV[$c]}\":$AMT}]")
    HEX=$(echo "$C" | J "d['hex']")
    echo "$C" | python3 -c "import sys,json; sys.stdout.write(json.load(sys.stdin)['message'])" > "$WORK/msg.txt"
    PSBT=$(python3 "$TOOL" psbt "$WORK/msg.txt" "${ADDR[$t]}")
    SIGNED=$(btc -rpcwallet=holder walletprocesspsbt "$PSBT" true DEFAULT true)
    if [[ $(echo "$SIGNED" | J "d['complete']") != True ]]; then fail "$t/$c: wallet did not complete the PSBT"; continue; fi
    PROOF=$(python3 "$TOOL" proof "$(echo "$SIGNED" | J "d['psbt']")")
    P=$(cs $c addclaimproof "$HEX" 0 "$PROOF" 2>&1) || { fail "$t/$c addclaimproof: $P"; continue; }
    R=$(cs $c sendrawtransaction "$P" 2>&1) && pass "$t claimed on $c with a wallet-signed PSBT proof" || fail "$t/$c send: $R"
  done
done
for c in half quarter dime nickel cent; do cs $c generatetoaddress 1 "${RCV[$c]}" >/dev/null; done
for c in half quarter dime nickel cent; do
  N=$(cs $c getclaimable "${TXID[bech32m]}" "${VOUT[bech32m]}" | J "d['claimed']")
  [[ $N == True ]] && pass "$c: claim confirmed in a block" || fail "$c: not claimed"
done
echo
[[ $FAIL == 0 ]] && echo "ALL PASSED" || echo "SOME FAILED"
