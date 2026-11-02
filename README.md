# Bitcoin Coin Series — mainnet launch announcement

Unofficial experimental project, not affiliated with Bitcoin or Bitcoin Core. No sale, no premine, no developer allocation. Coins have no promised value.

Five independent chains with Bitcoin's transaction system and a supply multiplied by 2, 4, 10, 20 and 100:

| Coin | Ticker | Multiplier |
| --- | --- | --- |
| Bitcoin Half | BTCH | 2 |
| Bitcoin Quarter | BTCQ | 4 |
| Bitcoin Dime | BTCD | 10 |
| Bitcoin Nickel | BTCN | 20 |
| Bitcoin Cent | BTCC | 100 |

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

Issuer: Sento Daimon (pen name). The issuer's mining reward addresses will be published after launch.

## Windows quick start

1. Put `utxo-840000.dat` (Bitcoin Core assumeutxo snapshot of block 840,000, about 9.8 GB) in `C:\CoinSeries\snapshot\` (or edit `SNAPSHOT` in `m0-settings.bat`).
2. Run `m1-start-mainnet.bat`. It waits for Bitcoin block 974800, checks its header, starts the five nodes and mines with all CPU threads.
3. After it has started, run `m2-protect-wallets.bat` to set a wallet password and save backups.
4. `m3-status.bat` shows heights, connections and balances; `m4-stop-mainnet.bat` stops everything.

Windows SmartScreen may warn because the files are not code-signed: "More info" -> "Run anyway".
Do not click inside the black node windows (it pauses them; press Esc to resume).

## Licenses

Bitcoin Core: MIT License. RandomX: BSD 3-Clause License. Coin Series changes: MIT License.
