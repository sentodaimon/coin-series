# Bitcoin Coin Series — mainnet running

Unofficial experimental project, not affiliated with Bitcoin or Bitcoin Core. No sale, no premine, no developer allocation. Coins have no promised value.

Five independent chains with Bitcoin's transaction system and a supply multiplied by 2, 4, 10, 20 and 100:

| Coin | Ticker | Multiplier |
| --- | --- | --- |
| Bitcoin Half | BTCH | 2 |
| Bitcoin Quarter | BTCQ | 4 |
| Bitcoin Dime | BTCD | 10 |
| Bitcoin Nickel | BTCN | 20 |
| Bitcoin Cent | BTCC | 100 |

## Mainnet status

- Launched 2026-11-06. Bitcoin block 974800 (hash `00000000000000000000604cc2a86a91a1cb07c387f57f70efbc4a861a74dd23`) was found at 10:25 UTC; the first Coin Series blocks followed at 10:33 UTC.
- Anyone can join and mine. There is no permission, registration or fee.
- Announcement and discussion: https://bitcointalk.org/index.php?topic=5599778.0

## Join the network

Public node (all five chains on one host):

| Coin | Address |
| --- | --- |
| Half | `coinseries.duckdns.org:21302` |
| Quarter | `coinseries.duckdns.org:21304` |
| Dime | `coinseries.duckdns.org:21310` |
| Nickel | `coinseries.duckdns.org:21320` |
| Cent | `coinseries.duckdns.org:21400` |

- Windows kit: `m0-settings.bat` already has `SEED=coinseries.duckdns.org`; each chain connects on its own port.
- A node that is already running: `bitcoin-cli -datadir=C:\CoinSeries\mainnet -chain=main -coin=half addnode coinseries.duckdns.org:21302 add` (repeat for each coin with its port).
- If you can, open the same TCP ports on your own router so that others can connect to you too.

## Fair start

- Mainnet genesis is derived from **Bitcoin block 974800** (not yet mined when this release was published).
- Nobody, including the issuer, can mine before that block exists: each chain's genesis contains its hash.
- Start a node with `-beaconheader=<80-byte header of Bitcoin block 974800>`; the Windows kit fetches and checks it automatically.

## Rules in short

- Proof of work: RandomX version 1, merged mining of all five chains with one computation.
- Block every 10 minutes, difficulty adjusted every block, stall relief after 1 hour without a block.
- Start difficulty: 1,000,000 hashes per block.
- Rewards continue Bitcoin's schedule from height 840,000, times the multiplier.
- Bitcoin holders at block 840,000 can claim the multiplied amount with their own keys (BIP-322 or legacy signed message). Claims never move bitcoin.
- Signatures carry a chain identifier: transactions cannot be replayed between chains or to Bitcoin.

Full specification: `docs/spec.md`. Whitepaper: `docs/whitepaper.md` (Korean: `docs/whitepaper-ko.md`). Manual: `docs/manual.md`.

## Source

Bitcoin Core v31.1 plus patches `patches/0001` … `0011` applied in order, with RandomX commit `7607fb2faed24d5a679e139a9828d194bbc644a4` placed in `src/randomx`. MIT License (Bitcoin Core), BSD 3-Clause (RandomX).

## Testnet results (7-day public testnet, started 2026-10-31)

- Bitcoin block H = 973949, five chains merged-mined, average block interval 10.2 minutes over the first 79 blocks.
- Claim snapshot (Bitcoin Core `utxo-840000.dat`, hash a2a5521b…8f96) verified by the node.
- Second-node sync, claim lookup and claim rejection without proof tested.

## Issuer

Sento Daimon (pen name). The issuer mines like everyone else; its mining reward addresses:

| Coin | Address |
| --- | --- |
| Half | `hf1qehjpwg78vpeenph2c007up5jletumup5cja4rd` |
| Quarter | `qt1q9g0yvmdm5nppuxdnu3432enscgmkd80355h3tm` |
| Dime | `dm1qls7vqs4vd3l46245yrcak36xt5qfzqd50z8wst` |
| Nickel | `nk1qjhuh7pus4anfd7k40lpdf9q8znjykdc5rs4vry` |
| Cent | `ct1qq7stl076rkh9ayp5lk58cratx4xf9gyvu8n06l` |

## Windows quick start

1. Download this repository (Code -> Download ZIP) and copy its `windows` folder to `C:\CoinSeries\` (any folder works).
2. Download the claim snapshot `utxo-840000.dat` (Bitcoin Core UTXO snapshot of block 840,000, about 9.8 GB) and put it in `C:\CoinSeries\snapshot\`.
   - Torrent: `magnet:?xt=urn:btih:596c26cc709e213fdfec997183ff67067241440c&dn=utxo-840000.dat&tr=udp%3A%2F%2Ftracker.bitcoin.sprovoost.nl%3A6969`
   - Or direct download: `https://lopp.net/download/utxo-snapshot-height-840000.dat` (rename it to `utxo-840000.dat`).
   - The source does not matter: the node computes the snapshot's UTXO hash and starts only if it equals the value fixed in Bitcoin Core (`a2a5521b…8f96`).
   - Other location or file name (for example a drive with more space): edit the `DATA` and `SNAPSHOT` lines in `m0-settings.bat`. All m-scripts read `DATA` from there. Keep at least 25 GB free on that drive.
   - Or extract it yourself from a synced Bitcoin Core node: `bitcoin-cli -rpcclienttimeout=0 -named dumptxoutset utxo-840000.dat rollback=840000`.
3. Run `m1-start-mainnet.bat`. It checks the header of Bitcoin block 974800, starts the five nodes, connects to `coinseries.duckdns.org` (set in `m0-settings.bat`), waits until the chain is downloaded and starts mining with all CPU threads. The first start verifies the snapshot (about 10 minutes on a laptop).
4. After it has started, run `m2-protect-wallets.bat` to set a wallet password and save backups (to the `DATA` folder name plus `-backup`, by default `C:\CoinSeries\mainnet-backup`).
5. `m3-status.bat` shows heights, connections and balances; `m4-stop-mainnet.bat` stops everything.
6. Optional: open TCP ports 21302, 21304, 21310, 21320 and 21400 on your router so that other nodes can connect to you.

Mining rewards can be spent after 100 blocks (about 17 hours).

Windows SmartScreen may warn because the files are not code-signed: "More info" -> "Run anyway".
Do not click inside the black node windows (it pauses them; press Esc to resume).

## Licenses

Bitcoin Core: MIT License. RandomX: BSD 3-Clause License. Coin Series changes: MIT License.
