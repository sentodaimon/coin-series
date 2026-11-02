# Bitcoin Coin Series — Consensus Specification

Version: draft 1 (development). Reference implementation: Bitcoin Core v31.1 with the Coin Series changes.
Values marked **(placeholder)** are fixed before launch; values marked **(undecided)** await a decision.

## 1. Chains

| Chain | Name (`-coin=`) | Ticker | Multiplier m | Merge slot | P2P port main / test / regtest | RPC port main / test / regtest | Bech32 prefix main / test / regtest |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Bitcoin Half | half | BTCH | 2 | 0 | 21302 / 22302 / 23302 | 21202 / 22202 / 23202 | hf / thf / rhf |
| Bitcoin Quarter | quarter | BTCQ | 4 | 1 | 21304 / 22304 / 23304 | 21204 / 22204 / 23204 | qt / tqt / rqt |
| Bitcoin Dime | dime | BTCD | 10 | 2 | 21310 / 22310 / 23310 | 21210 / 22210 / 23210 | dm / tdm / rdm |
| Bitcoin Nickel | nickel | BTCN | 20 | 3 | 21320 / 22320 / 23320 | 21220 / 22220 / 23220 | nk / tnk / rnk |
| Bitcoin Cent | cent | BTCC | 100 | 4 | 21400 / 22400 / 23400 | 21300 / 22300 / 23300 | ct / tct / rct |

- Environment is selected with `-chain=main|test|regtest`. Without `-coin` the software runs original Bitcoin (regression testing only).
- All ports are below 32768, outside the temporary port ranges of Windows (49152–65535) and Linux (32768–60999).
- Base58 version bytes (P2PKH / P2SH / WIF), main: Half 40/100/168 (H/h), Quarter 58/120/186 (Q/q), Dime 30/90/158 (D/d), Nickel 53/112/181 (N/n), Cent 28/87/156 (C/c). Test: 130–134 / 135–139 / 200–204. Regtest: 140–144 / 145–149 / 210–214 (in chain order).
- Network magic: first 4 bytes of `SHA256("coin-series/<name>/<mainnet|testnet|regtest>")`.
- Data directory: `<datadir>/<name>`, `<name>-testnet`, `<name>-regtest`. The claim snapshot is shared: `<datadir>/snapshot/utxo-840000.dat`.
- All Bitcoin rules (BIP34, BIP65, BIP66, CSV, SegWit, Taproot) are active from height 1. No checkpoints, minimum chain work, assumed-valid block, DNS seeds or fixed seeds.

## 2. Supply

- Block reward at height h ≥ 1: `(50 × COIN × m) >> floor((840000 + h) / 210000)`, zero when the shift is 64 or more. The genesis block pays nothing.
  - Height 1–209,999: 3.125 × m; 210,000–419,999: 1.5625 × m; and so on.
- Money limit per chain: `21,000,000 × COIN × m` (Bitcoin: 21,000,000 × COIN). Every output value and every sum must be within it.
- Total mined + nominal claimable (19,687,503.125 × m) stays below the limit for every chain (margin 0.02–0.03 coins).

## 3. Block header

| Field | Bytes | Notes |
| --- | --- | --- |
| nVersion | 4 | |
| hashPrevBlock | 32 | |
| hashMerkleRoot | 32 | |
| nTime | 4 | |
| nBits | 4 | compact target |
| vMergeBranch[0..2] | 3 × 32 | merge tree sibling hashes, leaf level first |
| nNonce64 | 8 | little-endian |

- Total 180 bytes. The first 76 bytes are the **body**. Block hash (identifier) = SHA256d of all 180 bytes.

## 4. Proof of work: RandomX with five-chain merged mining

1. Commitment `c = SHA256d("coin-series/commit" || body)`.
2. Merge tree with 8 leaves. Leaf s holds the commitment of the chain whose merge slot is s; unused leaves are 32 zero bytes. Inner node = `SHA256d(left || right)`.
3. A chain recomputes root `M` from its own commitment at its own slot and the three siblings in the header.
4. RandomX key `K = SHA256("coin-series/randomx" || LE64(floor(nTime / 1209600)))` — a new key every 2 weeks, derived from the header time only.
5. `pow = RandomX_v(K, M || LE64(nNonce64))`, v = RandomX version **1** (decided; version 2 is available on regtest only, via `-randomxversion=2`).
6. Valid if `target = Compact(nBits)` is positive, not overflowing, `≤ powLimit`, and `pow` (read as a little-endian 256-bit number) `≤ target`.
- The genesis block is fixed by hash and exempt from proof of work.
- A commitment placed in a different slot yields a different root; one solution can make at most one block per chain.
- One RandomX solution makes a block on every chain whose target it meets.

## 5. Difficulty

Parameters: spacing T = 600 s, half-life τ = 7,200 s, relief start R = 3,600 s, relief doubling D = 1,800 s, start bits 0x1e10c6f7 (1,000,000 hashes per block; measured 1,658 H/s on the launch desktop with all threads, RandomX version 1 fast mode, gives about 10-minute blocks), powLimit = start × 4,096 = 0x010c6f70… (about 244 hashes per block).

For a new block at height h with parent p (height h−1) and genesis g:

- h = 1: `nBits = startBits` (anchor; no relief).
- h ≥ 2:
  - anchor time `a = max(g.time, b1.time − T)`, where b1 is the block at height 1 (a late start after Bitcoin block H is not "behind schedule", so it releases no burst of easy blocks; back-dating height 1 can at most restore g.time)
  - `e_asert = floor(((p.time − a) − T × (h − 1)) × 65536 / τ)` (C++ integer division, truncating toward zero)
  - `gap = new.time − p.time`; `e_relief = floor((gap − R) × 65536 / D)` if gap > R, else 0
  - `e = e_asert + e_relief`
  - `target = start × 2^(e / 65536)` evaluated with the aserti3-2d integer method: `shifts = e >> 16` (arithmetic), `frac = e & 0xffff`, `factor = 65536 + ((195766423245049·frac + 971821376·frac² + 5127·frac³ + 2^47) >> 48)`; if start has more than 224 significant bits it is first shifted right by (bits − 224) and `shifts` increased by the same; `target = (start × factor) >> 16` shifted by `shifts`; 0 becomes 1; above powLimit (or overflow) becomes powLimit.
  - `nBits = Compact(target)`.
- The header's nBits must equal this value. Chain work is computed from nBits (so relieved blocks carry less work).
- Block time must be greater than the median of the previous 11 blocks and at most **10 minutes** ahead of the node's clock.

Simulation with the reference function (1,000× hash power for 48 h then leaving, 30 runs): first block after the exit median 4.5 h (90th percentile 5.6 h); back to ≤ 15-minute average median 21.5 h.

## 6. Replay protection

- Every signature hash (legacy, SegWit v0, Taproot) appends `LE32(chainSigId)` after the existing preimage (legacy/SegWit: after nHashType; Taproot: at the end of the tagged-hash preimage).
- `chainSigId = 0x43530000 | (mergeSlot << 8) | env` (env: main 0, test 1, regtest 2) — 15 distinct values.
- The legacy SIGHASH_SINGLE out-of-range case returns `SHA256d(uint256(1) || LE32(chainSigId))` instead of the constant 1.
- Exception: claim ownership proofs are verified with Bitcoin's original rules (no chain identifier).

## 7. Claim snapshot

- File: Bitcoin Core UTXO snapshot format version 2 (`dumptxoutset`): magic `utxo\xff`, version, network magic, base block hash, coin count, then per transaction id (in ascending byte order): txid, count, (vout, Coin)×count.
- Consensus value (main, test): serialized UTXO hash `a2a5521b1b5ab65f67818e5e8eccabb7171a517f9e2382208f77687310768f96` and base block `0000000000000000000320283a032748cef8227873ff4872689bf23f1cda83a5` (Bitcoin block 840,000), as published in Bitcoin Core (`m_assumeutxo_data`).
- Serialized hash: SHA256d over, for each output in file order (outputs of one txid in ascending vout): `outpoint || LE32(height × 2 + coinbase) || CTxOut`.
- A node on main or test does not start without a verified snapshot.

## 8. Claims

**Snapshot coins.** An unclaimed snapshot output `o` appears in the coin set as value `amount × m`, its original script, height `0x7FFFFFFE`. Once claimed, a marker coin at outpoint `(T, 0)` with `T` = BIP340-style tagged SHA256 (tag `coin-series/claimed`) of the serialized outpoint `o` (value 0, script `OP_FALSE`) exists, and `o` no longer appears. The marker is added when the claim is connected and removed when it is disconnected.

**Claim transaction** (version `0x434C4D31`, "CLM1"):
1. Every input is a snapshot coin; a non-claim transaction may not spend a snapshot coin.
2. At most 500 inputs; every input has sequence `0xFFFFFFFF`, empty scriptSig and exactly one witness item (the proof) of 1–10,000 bytes; lock time 0.
3. Outputs are ordinary; input total − output total = fee.
4. Signature-operation cost: 20 per input.

**Claim message** (UTF-8, `\n` line breaks, no trailing newline):

```
Coin Series claim v1
chain: <name>-<mainnet|testnet|regtest>
genesis: <genesis hash, hex>
snapshot: <snapshot serialized hash, hex>
transaction: <claim txid, hex>
```

The txid covers version, all inputs, all outputs and lock time; input amounts and scripts are fixed by the committed snapshot.

**Ownership proof** = format byte || payload, verified against the snapshot output script with Bitcoin's original signature rules:

| Format | Payload | Allowed for |
| --- | --- | --- |
| 0x01 legacy | 65-byte compact signature over the Bitcoin signed-message hash of the claim message | P2PKH |
| 0x02 simple | BIP-322 simple witness stack | native SegWit v0 and Taproot |
| 0x03 full | BIP-322 full `to_sign` transaction | any script |

- BIP-322 checks use the required and upgradeable rules together; anything not valid (including "inconclusive") is rejected.
- `to_sign` must have version 0, lock time 0, one input with sequence 0, and one zero-value `OP_RETURN` output (no time-locked proofs).
- Unprefixed (pre-final) BIP-322 signatures and proof-of-funds signatures are not accepted.

## 9. Coinbase

- The coinbase scriptSig must begin with the BIP34 height push followed by a push of the bytes `coin-series`. No coinbase on these chains can reproduce a Bitcoin transaction id, so snapshot outpoints stay unique.

## 10. Genesis (fair start)

- With the release, the Bitcoin height H is announced (release height + at least 432 blocks). The first 7-day testnet uses H = 973949 (already mined; the testnet carries no value).
- Each node is started with `-beaconheader=<80-byte header of Bitcoin block H>`; on main and test the header must carry real Bitcoin proof of work (target ≤ 2^200).
- Genesis per chain and environment: coinbase text `cs/<name>/<env>/<hash of block H, hex>` (short prefix: the coinbase script must stay within 100 bytes), output `OP_RETURN` with value 0, time = time of block H, bits = start bits, nonce 0. Genesis hash uses the 180-byte header.
- The genesis derived from the block H that remains in Bitcoin's final chain is canonical; blocks built on a replaced block H are invalid.
- Releases after mining starts hardcode the hash of block H.

## 11. Mining interface

- `getmergework <address> [time]` → commitment, slot, target, bits, time, height, RandomX version and key. Use one time for all five chains.
- `submitmergework <commitment> [3 sibling hashes] <nonce64>`.

## 12. Open items

- Bitcoin reference height H.
