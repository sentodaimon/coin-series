# Linux: build and mine

Tested on Ubuntu 24.04 (x86-64). The Windows kit is not needed on Linux.

## 1. Build

```bash
sudo apt install build-essential cmake pkg-config git libevent-dev libboost-dev libsqlite3-dev

git clone https://github.com/sentodaimon/coin-series
git clone --branch v31.1 --depth 1 https://github.com/bitcoin/bitcoin
cd bitcoin
git apply ../coin-series/patches/*.patch
git clone https://github.com/tevador/RandomX src/randomx
git -C src/randomx checkout 7607fb2faed24d5a679e139a9828d194bbc644a4

cmake -B build -DBUILD_GUI=OFF -DENABLE_IPC=OFF -DWITH_ZMQ=OFF -DBUILD_TESTS=OFF -DBUILD_BENCH=OFF
cmake --build build -j"$(nproc)" --target bitcoind bitcoin-cli

# merged miner
g++ -O2 -std=c++20 contrib/coinseries/miner/cs-miner.cpp -Isrc/randomx/src -Isrc/univalue/include \
    build/src/univalue/libunivalue.a build/lib/librandomx.a -lpthread -o build/bin/cs-miner
```

## 2. Snapshot

Get the Bitcoin Core UTXO snapshot of block 840,000 (about 9.8 GB; torrent or direct link in the README) and save it as `~/coinseries/utxo-840000.dat`. The node checks its hash (`a2a5521b…8f96`) and refuses to start if it does not match.

## 3. Start the five nodes

The mainnet starts from the header of Bitcoin block 974,800 (hash `00000000000000000000604cc2a86a91a1cb07c387f57f70efbc4a861a74dd23`). You can check the header below against any Bitcoin node or block explorer.

```bash
B=~/bitcoin/build/bin
D=~/coinseries
H=0060f82418d42ca7d368e73714c565b6b0ebaf98996d461d61cf01000000000000000000222c9f6657a8e0174d53ca2c1bcd6e7bb97c89e680e80cf9cc58236894093fc029abed6aace501177bcd83bb
for c in half quarter dime nickel cent; do
  $B/bitcoind -daemon -chain=main -coin=$c -datadir=$D -beaconheader=$H \
    -claimsnapshot=$D/utxo-840000.dat -addnode=coinseries.duckdns.org
done
```

The first start verifies the snapshot (several minutes). Each coin keeps its data in its own folder under `~/coinseries`.

## 4. Wallets and mining

```bash
cli() { $B/bitcoin-cli -chain=main -coin=$1 -datadir=$D "${@:2}"; }
for c in half quarter dime nickel cent; do cli $c -rpcwait createwallet w >/dev/null; done
A() { cli $1 -rpcwallet=w getnewaddress; }
$B/cs-miner --chain main --datadir $D --threads "$(nproc)" \
  --coin half=$(A half) --coin quarter=$(A quarter) --coin dime=$(A dime) \
  --coin nickel=$(A nickel) --coin cent=$(A cent)
```

Wait until all five nodes have caught up (`cli half getblockchaininfo`: `blocks` equals `headers`) before mining. Fast mode needs about 2.1 GB of memory; add `--light` to use about 256 MB at lower speed.

Wallet use (balance, send, backup, restore): see `docs/wallet-guide.md`.
