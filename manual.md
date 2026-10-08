# Bitcoin Coin Series — Implementation Manual

October 7, 2026

## 1. Purpose of This Document

This is an implementation guide containing the design and work procedure for building and running five independent chains based on Bitcoin Core.

- Intended reader: a developer or coding AI able to modify and build the Bitcoin Core source
- Project owner: a single non-developer. The owner does not type commands or edit files. The implementer presents options only at decision points and carries out everything else independently
- Level of this document: a design direction document. It is not a byte-level specification. A separate consensus specification must be written before coding (Section 10, Step 1)
- Labels
    - **Decided**: decided by the owner. Do not change it on your own; if a change is needed, ask first with reasons
    - **Proposed**: a design draft. You may change it if you find a better way, but report the change
    - **To verify**: figures or facts to be checked against primary sources during the work
- Code in this document is a draft showing direction; it has not been compiled or tested
- "Coin Series" is this document's collective name for the five coins
- Progress principle: design refinement, prototype development and the public testnet go ahead, but the mainnet launches only after every launch criterion in Section 11 is met

## 2. Project Overview

Five independent chains that keep Bitcoin's transaction system, multiply the supply by 2, 4, 10, 20 and 100, and change the mining, difficulty, signature, distribution and header format, all started at the same moment as a personal long-term experiment.

**What is being built**

- Bitcoin Half, Quarter, Dime, Nickel and Cent: five parallel assets modeled on US coin denominations (1/2, 1/4, 1/10, 1/20, 1/100)
- The five chains are independent and each starts from a new genesis block. Bitcoin's transaction history is not imported
- Holders at Bitcoin block 840,000 receive each of the five coins times its multiplier, free, by proving ownership. No deadline
- One mining computation produces blocks on all five chains and earns all five rewards together
- Mining runs on ordinary computers. The computation of existing SHA-256 specialized miners cannot be used (this does not prevent any person from participating)

**Principles (Decided)**

1. Issued and operated by one person: minimize third-party involvement such as cloud providers and exchanges
2. Accessibility: runs on one spare home laptop without dedicated servers or expensive hardware
3. Free distribution: holders prove ownership and claim themselves, with no deadline
4. No premine and no issuer allocation: mining is open to everyone under identical conditions from the first block
5. No exchange listing, no price pumping, no investment solicitation or promise of returns
6. Launch first; add-on services (explorer, exchange tool) later
7. A long-term project of 10 years or more. No assumption of short-term results
8. The mainnet is never restarted. Defect testing is done on a valueless public testnet; mainnet defects are fixed through rule improvements

**Design constraints (do not propose anything outside these)**

| Not done | Reason |
| --- | --- |
| A fork that shares Bitcoin's transaction history | Every node would have to store hundreds of GB of history; incompatible with laptop operation |
| SHA-256 mining | Specialized miners would make ordinary-computer mining meaningless; easy to attack with rented hash power |
| Merged mining with Bitcoin | Rewards would go to existing Bitcoin miners |
| Launching the five coins one at a time | Breaks the fairness of starting at the same moment under the same conditions |
| Different block intervals per chain | Complicates merged mining. Rewards apply the multiplier to the amount, not to frequency |
| An operator-run exchange at a fixed ratio to bitcoin | Incompatible with free distribution; would need reserves comparable to the entire bitcoin supply |
| Custody of others' coins or private keys | May require registration as a virtual asset service provider; conflicts with Principle 1 |
| A website that accepts private keys or recovery phrases | Indistinguishable from a phishing site |
| Cloud or dedicated servers | Principles 1 and 2 |
| Issuer power to fix particular blocks | Concentrates control in the issuer |

**Realities**

- Consensus that "each coin is worth bitcoin divided by its multiplier" cannot be enforced and is unlikely to form. A price may never form
- Early on there may be few or no miners, so the issuer's share of mining may be overwhelmingly high. This is not a design privilege but a result of participation; the whitepaper says so

## 3. Specifications of the Five Coins

The five chains differ only in multiplier and network identifiers; all other rules are identical.

**Issuance (Decided)**

| Coin | Ticker | Unit vs. Bitcoin | Multiplier | Block reward (at start) | Nominal supply cap | Claim per 1 BTC held |
| --- | --- | --- | --- | --- | --- | --- |
| Bitcoin Half | BTCH | 1/2 | 2 | 6.25 | 42,000,000 | 2 |
| Bitcoin Quarter | BTCQ | 1/4 | 4 | 12.5 | 84,000,000 | 4 |
| Bitcoin Dime | BTCD | 1/10 | 10 | 31.25 | 210,000,000 | 10 |
| Bitcoin Nickel | BTCN | 1/20 | 20 | 62.5 | 420,000,000 | 20 |
| Bitcoin Cent | BTCC | 1/100 | 100 | 312.5 | 2,100,000,000 | 100 |

- Block interval 10 minutes, halving every 210,000 blocks; common to all five chains
- Reward = Bitcoin's current block reward of 3.125 times the multiplier
- Monthly issuance: 4,320 blocks, equivalent to 13,500 BTC times the multiplier (27,000 Half, 1,350,000 Cent)
- Composition of the cap: claimable amount (nominal ceiling of 19,687,503.125 BTC equivalent times the multiplier) plus amount yet to be mined. The claimable amount is the 19,687,500 BTC issued through block 839,999 plus the 3.125 BTC reward of block 840,000 itself
- The actually claimable amount is slightly below the nominal ceiling (burned or unclaimed rewards). The exact value is fixed by the snapshot total
- Smallest unit: 1 coin = 100,000,000 base units, same as Bitcoin
- Because the names use "Bitcoin," the unofficial nature of the project is stated next to the names and in the whitepaper
- Check before launch whether the tickers collide with existing coins or companies (To verify). If they do, propose alternatives to the owner

**Network identifiers (Proposed)**

| Coin | Chain name | Merge slot | P2P port (main / test / regtest) | RPC port (main / test / regtest) | Address prefix (main / test / regtest) |
| --- | --- | --- | --- | --- | --- |
| Half | half | 0 | 38302 / 48302 / 58302 | 38202 / 48202 / 58202 | hf / thf / rhf |
| Quarter | quarter | 1 | 38304 / 48304 / 58304 | 38204 / 48204 / 58204 | qt / tqt / rqt |
| Dime | dime | 2 | 38310 / 48310 / 58310 | 38210 / 48210 / 58210 | dm / tdm / rdm |
| Nickel | nickel | 3 | 38320 / 48320 / 58320 | 38220 / 48220 / 58220 | nk / tnk / rnk |
| Cent | cent | 4 | 38400 / 48400 / 58400 | 38300 / 48300 / 58300 | ct / tct / rct |

- Network magic (4 bytes): the first 4 bytes of `SHA256("coin-series/<chain name>/<environment>")`, where environment is mainnet, testnet or regtest. Confirm no collision with Bitcoin or known forks
- Legacy address version bytes are also distinct per chain and environment
- Distinct prefixes per chain prevent sending to an address of the wrong chain
- RPC ports are never exposed externally

## 4. Source Structure, Chain Parameters and Reward Schedule

One source tree; a runtime option selects one of the five chains.

**Base source**

- Branch from the latest stable release tag of the official Bitcoin Core repository (`https://github.com/bitcoin/bitcoin`) at the time of work
- MIT License. Keep the original copyright notices
- Replace the "Bitcoin Core" name in program names, icons and UI text with the project's own name

**Chain selection (Proposed)**

- Extend Bitcoin Core's chain selection (`-chain=` option, `CChainParams`) to add `-chain=half | quarter | dime | nickel | cent`, each with its own testnet and regtest
- Separate data directory per chain. The snapshot directory is shared by all five
- Per-chain values: multiplier, network magic, ports, address prefixes, genesis block, merge slot number
- Common values: 600-second block interval, 210,000-block halving interval, snapshot verification value, proof of work, difficulty rules, launch reference block
- Bitcoin's existing rules such as SegWit and Taproot are active from the first block
- Remove Bitcoin mainnet checkpoints, minimum chain work, assumed-valid block, DNS seeds and fixed seeds. Initially, known node addresses are specified with `-addnode`

**Consensus parameters to add (draft)**

```cpp
// add to struct Params in src/consensus/params.h
int64_t nSupplyMultiplier;    // 2, 4, 10, 20, 100
int nSnapshotHeight;          // 840000
uint256 hashSnapshotBlock;    // hash of Bitcoin block 840,000
uint256 hashSnapshotUtxoSet;  // UTXO set verification value for height 840,000 embedded in Bitcoin Core (Section 5)
uint8_t nMergeSlot;           // merge mining slot 0..4 (Section 7)
int nBeaconHeight;            // Bitcoin block height used as the launch reference (Section 9)
uint32_t nChainSigId;         // chain identifier included in transaction signatures (Section 6)
```

**Reward schedule (draft implementation of the decided rule)**

- Height h on a new chain is treated as Bitcoin height 840,000 + h when computing the reward
- Heights 1 through 209,999 (209,999 blocks) form the first reward era; the first halving is at height 210,000, then every 210,000 blocks
- The genesis block (height 0) has a reward of 0
- Because the multiplier is applied before halving, late-era rewards differ slightly from "Bitcoin reward times multiplier." This is intended

```cpp
// src/validation.cpp
CAmount GetBlockSubsidy(int nHeight, const Consensus::Params& p)
{
    if (nHeight == 0) return 0;
    const int virtualHeight = p.nSnapshotHeight + nHeight;      // 840000 + h
    const int halvings = virtualHeight / p.nSubsidyHalvingInterval;
    if (halvings >= 64) return 0;
    CAmount subsidy = 50 * COIN * p.nSupplyMultiplier;          // multiply first, then halve
    subsidy >>= halvings;
    return subsidy;
}
// check: h=1 -> 840001/210000 = 4 halvings -> 3.125 x multiplier
//        h=210000 -> 1050000/210000 = 5 halvings -> 1.5625 x multiplier
```

**Total supply limit**

- Bitcoin Core's `MAX_MONEY` is a fixed constant. Since it must differ per chain, turn it into a function and update all callers
- Cent chain limit: 2.1 billion x 100,000,000 = 2.1 x 10^17, within the signed 64-bit range (about 9.2 x 10^18)
- Check for code that skips overflow checks when summing amounts within a transaction because it assumes the limit

```cpp
// src/consensus/amount.h : function instead of constant
inline CAmount MaxMoney(const Consensus::Params& p) { return 21000000 * COIN * p.nSupplyMultiplier; }
inline bool MoneyRange(const CAmount& v, const Consensus::Params& p) { return v >= 0 && v <= MaxMoney(p); }
```

## 5. Snapshot and Claims

Every node keeps the UTXO snapshot of Bitcoin block 840,000, and holders receive coins through claim transactions containing an ownership proof. There is no separate claim server or website.

**Snapshot (Decided: stored by every node)**

- Basis: the Bitcoin UTXO set as of block 840,000. File size about 10 GB (To verify)
- One file shared by all five chains. A node downloads it once
- Verification value: the UTXO set verification value for height 840,000 recorded in `m_assumeutxo_data` in the Bitcoin Core source is written directly into the consensus parameters. It was reviewed by Bitcoin Core developers, so the issuer need not be trusted
- The node computes the verification value from the snapshot contents itself and starts only if it matches
- Two values must be distinguished: the hash of the whole distribution file (checks that the downloaded file is identical) and the UTXO set verification value (checks that the contents are correct). Consensus uses the latter
- Acquisition A: extract from a synced Bitcoin full node with the rollback feature of `dumptxoutset`. Height 840,000 must be specified (otherwise the latest height supported by that version is chosen). Requires hundreds of GB of disk and days of syncing
- Acquisition B: download a publicly distributed height-840,000 snapshot and check the verification value
- Distribution: torrent and ordinary download. Node-to-node transfer is not an existing Bitcoin Core feature, so either do not use it or classify it as new development. Provide download, resume and verification steps before first start, consistent with the rule that a node will not start without the snapshot. Since claims have no deadline, provide replication and recovery procedures so the snapshot remains obtainable
- Lookup structure: a read-only index that finds amount and locking script from an output's txid and vout

**Claim transaction (Proposed)**

- A dedicated transaction version; in a transaction of this version, every input is a claim input
- An input references a Bitcoin output by txid and vout. The node looks up the amount and locking script in the snapshot
- Per-input attachment = ownership proof
- Input value = snapshot amount x chain multiplier
- Outputs are ordinary outputs. If the total output is less than the total input value, the difference is the fee. A claimant with no coins can pay the fee from the claim
- Outputs received through a claim become ordinary UTXOs, spendable immediately
- Claim status is recorded per chain as 1 bit per output (about 22.5 MB per chain for about 180 million outputs). It is stored atomically with block connection and disconnection and reverted on reorganization

**Validation order (every node)**

1. Confirm the referenced output exists in the snapshot and look up its amount and locking script
2. Confirm it has not yet been claimed on this chain. Duplicates within the same block or transaction are rejected
3. Confirm the ownership proof satisfies the locking script and the signed content matches this transaction
4. When included in a block, mark it claimed

**Ownership proof (Proposed: generic message signing)**

- Use the BIP-322 message signing format. Because a "message," not a Bitcoin transaction, is signed, the signature cannot be used as a transaction on Bitcoin mainnet
- The signed message commits to all of the following (Decided requirement)
    1. A fixed prefix and the rule version
    2. Chain name and environment (mainnet, testnet, regtest)
    3. The snapshot verification value
    4. All claim inputs: each input's txid, vout, amount and locking script
    5. All receiving outputs
    6. Transaction version, lock time and other mutable fields
- Why: if the signature covered only the receiving outputs, a third party could add another output at the same address as an input and divert the difference as fee. Without the chain name, a claim on one chain could be reused on another
- Separate verification paths: message signatures are verified under Bitcoin's original signing rules. Applying the chain identifier from Section 6 here would make signatures from existing wallets fail
- Whether Bitcoin Core contains verification code for this format and which wallets support it: To verify. If absent, implement it based on the proposal's reference implementation

**Claim support scope (to be fixed in the specification)**

| Item | To decide |
| --- | --- |
| Address types | Support method for legacy, SegWit, multisig, and Taproot key-path and script-path. Which of the simple and full message signing formats to accept |
| Time locks | Whether absolute and relative time locks are evaluated against the original Bitcoin state or the new chain state |
| Immature coinbase | Handling of Bitcoin mining rewards not yet mature at the snapshot |
| Special outputs | How to claim outputs not representable as addresses and unparseable scripts |
| Unsupported types | Preserving the claim right and adding support later. Since there is no deadline, the right never expires |
| Small outputs | How to aggregate small outputs that hit fee or dust policy into one transaction |
| Transaction format | Field layout, identifier hash computation, maximum size, how ownership proofs count toward block size and script operation limits |

**Additional items to fix in the specification for snapshot storage and proof verdicts**

- A fixed mapping between outputs and claim-status bit numbers: rebuilding the index must map the same output to the same bit
- Index verification and rebuilding: even with a correct original, a damaged index could return wrong amounts
- Access method, file locking and corruption handling when five nodes share one file and index
- Claim status is about 22.5 MB per chain, but the snapshot original, index, claim transactions and undo records require separate space
- Fix the version and accepted formats of the message signing proposal
- Message signature verification can return results other than valid or invalid, such as inconclusive or time-conditional. On chain these map only to accept or reject; inconclusive is rejected
- A rule by which every node rejects unsupported scripts identically
- Whether signatures from a previous testnet can be reused after a testnet restart. Proposal: include the genesis hash in the signed content to prevent reuse
- Scope of the promise for unsupported types: only that the claimable record is preserved. Later support requires node operators to adopt new consensus rules and cannot be guaranteed

**Safety requirements (mandatory)**

1. A signature used for a claim must never be reusable as a valid transaction on Bitcoin mainnet. The claimed output may still be unspent on Bitcoin; if this is broken, the claimant's real bitcoin leaks. The most important requirement
2. The signature must commit to all six items above. Adding or replacing inputs, changing the receiving address, or submitting to another chain or environment must always fail
3. Double claims of the same output must be impossible
4. Never build a website that accepts private keys or recovery phrases

**Claim tool (separate program)**

- Input: the Bitcoin outputs to claim (txid, vout, amount, address) and receiving addresses on the new chains. Claiming works without the snapshot file. For ordinary addresses, the locking script is derived from the address. Multisig and special outputs require the original locking script and extra signing data; guide users to obtain these from their own node's snapshot or a Bitcoin block explorer
- Path A: display the message to sign; the claimant signs it in an existing wallet and pastes the signature. The private key never leaves the wallet
- Path B: if no supporting wallet is available, the tool signs directly. It must work on a computer disconnected from the internet, with guidance to move the bitcoin to a new address before use
- Creates and broadcasts claim transactions for all five chains at once. Since the message differs per chain, a signature is needed per chain

**Properties to disclose**

- Claim records are public: anyone can see which bitcoin output's owner received coins at which new address
- Even if bitcoin was sold after the snapshot, whoever holds the snapshot-time private key holds the claim right
- Bitcoin held on exchanges cannot be claimed directly by users because the exchange holds the keys

## 6. Transaction Signing Rules

Ordinary transaction signatures include a per-chain identifier so that a signature on one chain cannot pass on Bitcoin or the other four chains.

- Applies to: all ordinary transactions except claim transactions
- Method: include the chain and environment identifier (network magic) in the signature hash computation. Same principle as the mechanism Bitcoin Cash introduced at its fork
- Scope of change: all three signature hash computations (legacy, SegWit, Taproot)
- Result: ordinary transactions on the new chains cannot be signed with existing Bitcoin wallets, only with this project's wallet
- Exception: claim ownership proofs are message signatures produced by existing wallets and are verified under Bitcoin's original rules (Section 5). Keep the two verification paths clearly separated in code
- Since the genesis differs, ordinary Bitcoin transactions cannot be replayed anyway because their inputs do not exist. This rule is an additional safeguard on top of that

## 7. Mining: RandomX and Five-Chain Merged Mining

One RandomX computation mines blocks on all five chains at once. Adoption is decided; the details are proposed.

**Proof of work: RandomX**

- The CPU-oriented proof of work used by Monero. Specialized hardware gains little advantage
- Reference implementation: `https://github.com/tevador/RandomX`
- BSD 3-Clause license, about 2,080 MiB shared memory in fast mode for mining, about 256 MiB in light mode for verification, Windows build support (all To verify against the original)
- The block identifier hash remains double SHA-256. RandomX is used only for the proof-of-work check

**RandomX key policy (Proposed)**

- RandomX requires a key. Official guidance is to change the key periodically without letting miners choose it. A permanently fixed key is not used
- Because the five chains share one hash, the key must be independent of chain height (heights can diverge across chains)
- Proposal: key = `SHA256("coin-series/randomx" || epoch)`, epoch = header timestamp divided by 2 weeks (1,209,600 seconds)
- Nodes compute the key from the timestamp in the header, not their own clock, so every node derives the same key
- To fix and test in the specification: key selection when timestamps straddle an epoch boundary, reorganizations, verification of old headers, attacks that force repeated key cache replacement to slow nodes, and how much a miner can choose the key by adjusting timestamps

**Merged mining (Proposed)**

- The miner builds a block candidate for each of the five chains, combines the five into one Merkle root, and performs proof of work on that root
- A symmetric structure with no parent chain. The five chains do not reference each other

| Header section | Contents | Size |
| --- | --- | --- |
| Body | version, previous block hash, transaction Merkle root, time, difficulty bits | 76 bytes |
| Proof of work | 3 sibling hashes of the merge tree, nonce | 96 + 8 bytes |

Validation rules:

1. Commitment c = `SHA256d("coin-series/commit" || 76-byte body)`
2. Merge tree: an 8-leaf Merkle tree. Slots 0..4 hold the commitments of Half, Quarter, Dime, Nickel and Cent; the rest are zero
3. A chain recomputes root M from its own slot number and the 3 sibling hashes
4. Valid if `RandomX(key, M || nonce)` is at or below that chain's target
5. Slot numbers are fixed per chain. A commitment in a different slot is invalid. This prevents one piece of work from producing two blocks on the same chain
6. Check that the header's difficulty bits match the value computed for that height (Section 8)

```cpp
// src/pow.cpp (draft)
bool CheckProofOfWork(const CBlockHeader& h, const Consensus::Params& p)
{
    const uint256 commit = CommitHash(h);                                   // tagged hash of the 76-byte body
    const uint256 root = MergeRoot(commit, p.nMergeSlot, h.vMergeBranch);   // recompute root from 3 siblings
    const uint256 key = RandomXKey(h.nTime / 1209600);                      // 2-week epoch key
    const uint256 pow = RandomXHash(key, root, h.nNonce64);
    arith_uint256 target; bool neg, over;
    target.SetCompact(h.nBits, &neg, &over);
    if (neg || over || target == 0 || target > UintToArith256(p.powLimit)) return false;
    return UintToArith256(pow) <= target;
}
```

- When the five chains share the same difficulty, one solution creates five blocks at once and earns all five rewards
- When difficulties differ, blocks are created only on chains whose target the solution meets. Mining only some chains is permitted by the rules
- The block identifier hash covers the body and the proof-of-work section
- To fix in the specification: nonce byte order, internal node hashing of the merge tree, fixed header length and serialization
- Since the header format differs from Bitcoin, review all code that assumes an 80-byte header (serialization, header relay, compact blocks, block index)

**Mining program (new)**

- Fetch block templates from the five nodes via `getblocktemplate`, build the merge tree, run RandomX on multiple threads, and `submitblock` to each chain whose target is met
- Use the same timestamp in all five headers
- Settings: five reward addresses, number of threads. A default thread limit that accounts for laptop heat
- Includes a benchmark function (used to calibrate the starting difficulty)
- Windows binary included

**Remaining limitation**

- An attacker renting large amounts of cloud CPU can overtake a chain run by a single laptop. A common limitation of small chains with no complete defense

## 8. Difficulty Adjustment and Stall Relief

Difficulty adjusts every block, with an added relief rule that makes it progressively easier when no block appears for a long time. Both rules are decided; the parameters are proposed.

**Base adjustment: per-block exponential adjustment**

- Bitcoin's 2,016-block adjustment is not used. On small chains it reacts far too slowly to sudden hash power changes
- Uses the algorithm Bitcoin Cash introduced in 2020 (aserti3-2d). Difficulty halves when the schedule falls behind the reference by one half-life and doubles when ahead. The half-life is shortened from the original 2 days to around 2 hours (see the simulation below; the value is fixed in the specification)

```latex
\text{target}_{h} = \text{target}_{\text{start}} \times 2^{\frac{(t_{h-1} - t_{0}) - 600\,(h-1)}{\tau}}
```

- Use the integer arithmetic of the published reference implementation as is (no floating point)
- Anchor definition: the reference specification uses the anchor block's parent time, but genesis has no parent. Proposal: the anchor block is height 1, and its parent time is the genesis time (t0 above). Then the target at height 1 is the starting target, and if blocks arrive exactly every 10 minutes the target stays at the starting target. Fix the expected values at heights 1 and 2 and at normal intervals as test vectors. τ is the half-life
- Starting target: calibrated to the owner's laptop's measured hash rate so that one block appears every 10 minutes. Example: at 2,000 hashes per second, the expected work per block is 1.2 million hashes
- The minimum difficulty limit is set well below the starting difficulty

**Why the base adjustment alone is insufficient**

- The next block's difficulty is computed from timestamps of blocks already produced. While no block is produced, difficulty does not fall no matter how much time passes
- If an outside miner raises hash power 1,000-fold and leaves, the remaining laptop needs about 7 days (10 minutes x 1,000) to find the next block

**Stall relief rule (Proposed)**

- If a new block's timestamp is more than 1 hour after the previous block, the target is relaxed according to the excess time (doubling per 30 minutes). Whether it is stepwise or continuous, and its integer arithmetic, are fixed in the specification. Not applied at height 1 (the genesis timestamp may differ from real time)

```latex
\text{target}_{h}^{\,\text{final}} = \min\left(\text{powLimit},\ \text{target}_{h} \times 2^{\frac{\max(0,\ t_{h} - t_{h-1} - 3600)}{1800}}\right)
```

- Target (Decided): even after a 1,000-fold hash power inflow and exit, one laptop produces the next block within about 6 hours. With these parameters, relief reaches about 1,000-fold after 6 hours
- From the relieved block onward, the base adjustment lowers difficulty according to the accumulated schedule delay
- Against timestamp manipulation: to curb attempts to gain relief by writing future timestamps, consider shortening the allowed future time limit from Bitcoin's 2 hours to 10 minutes. Nodes with badly wrong clocks would then reject or be rejected, so clock synchronization guidance is needed
- Parameters are fixed by simulation: 10x, 100x and 1,000x inflow then exit; long outage then restart; timestamp manipulation attempts. Measure time to first block and subsequent block intervals in each case
- This rule is newly designed, so it must go through cross-review at the specification stage

**Relief alone does not restore normal speed**

- Relief applies only to the stalled block. The next block starts again from the base difficulty. With a long half-life, blocks keep taking hours each for a long time
- Simple simulation results (1,000x laptop hash power for 48 hours then exit; median of 120 runs)

| Half-life | Relief rule | Time to first block after exit | Time to return to average interval of 15 minutes or less | Blocks produced during the 48-hour inflow (normal: 288) |
| --- | --- | --- | --- | --- |
| 2 days | Off | about 46 hours | about 17 days | 2,872 |
| 2 days | On | about 4 hours | about 18 days | 2,872 |
| 12 hours | On | about 4 hours | about 5 days | 999 |
| 4 hours | On | about 4.5 hours | about 45 hours | 527 |
| 2 hours | On | about 4.5 hours | about 24 hours | 408 |

- Shortening the half-life speeds recovery and reduces the number of blocks the inflowing party captures in a short time. This is the basis for proposing a half-life of around 2 hours
- Limitations of this simulation: constant hash power, block timestamps equal to real time, continuous relief, minimum difficulty never reached. Not included: integer rounding, network latency, timestamp manipulation, repeated inflow and exit, normal-time difficulty fluctuation. A shorter half-life increases normal-time fluctuation and the impact of timestamp manipulation, so these must be evaluated together

**Pass criteria and rules to define in the specification**

- Time to first block: mean, 95th and 99th percentile
- Time to return to an average 10-minute interval
- Whether blocks cluster or rewards concentrate during recovery
- Stability under repeated outside miner inflow and exit. Include inflow duration as well as size in test conditions
- Quantify the advantage of timestamp choice: in the relief zone, shifting the timestamp 10 minutes forward relaxes the target about 1.26-fold. Shortening the future limit only bounds this advantage; it does not eliminate it. Set an acceptable bound, and also test timestamps earlier than the previous block
- The difficulty bits recorded in the header are the final target including relief. Cumulative chain work is also computed from this final value, so a relaxed block is not credited with the original higher work
- Even if hash power rises 1,000-fold, difficulty does not immediately rise 1,000-fold. The size of the resulting stall depends on how long the inflow lasted

**Synchronization of the five chains**

- If the five chains use the same starting target and genesis time, and miners use the same timestamp in all five headers, difficulties move in step
- If some participants mine only some chains, difficulties may diverge per chain. Each chain must still operate correctly on its own

## 9. Fair Start

The genesis block is derived from the hash of a future Bitcoin block announced in advance, so no one, including the issuer, can start mining before the reference block appears (Decided). Propagation differences of seconds to tens of seconds remain, so "exactly the same moment" is not guaranteed.

**Why this is needed**

- If the genesis is known in advance, blocks with future timestamps can be computed beforehand and submitted all at once at launch
- Setting the genesis timestamp in the future or including a news headline does not prevent this. Those only prove "not created before then," not that no mining happened between publication and launch

**Method (Proposed)**

1. Announce the launch reference Bitcoin block height H together with the software release. H is the Bitcoin height at release plus at least 432 blocks; about 72 hours on average, and the actual time may be shorter or longer
2. H is recorded in the source as a consensus parameter. That block's hash cannot be known by anyone until the block is mined
3. The genesis block is derived by a fixed formula from that hash
    - Coinbase text = `"coin-series/<chain name>/" || reference block hash`
    - Time = the reference block's timestamp
    - Difficulty bits = starting target, reward 0, exempt from proof-of-work check
4. At startup a node takes the reference block hash as input and computes the genesis of all five chains itself. Participants verify the value on their own Bitcoin node or several block explorers
5. The issuer does not distribute the value later; that would give the issuer a head start
6. Releases after mining begins hardcode the reference hash and genesis hashes, removing the input step

**To fix in the specification**

- No waiting for confirmations: waiting would let anyone mine in advance during the wait, so the moment the reference block is published is the moment mining opens. In exchange, it must be fixed in advance which genesis is canonical if the reference block is replaced by a Bitcoin reorganization. Proposal: the genesis derived from block H remaining in Bitcoin's final chain is canonical, and blocks mined on a replaced hash are invalid. Announce in advance that roughly the first hour of mining may become invalid. This chooses prevention of precomputation over the safety of waiting for confirmations
- Bitcoin Core checks the genesis hash against a compiled constant, so the scope of changing this to runtime derivation
- A node given a wrong hash ends up with a different genesis and cannot join the network; provide an error message telling the user
- Start the testnet with the same procedure to verify the procedure itself

**What the issuer must do**

- Publish source, binaries, mining instructions and snapshot verification instructions together with the H announcement
- The issuer starts mining at the same moment with the same public program
- No rule favors the issuer. Starting difficulty, rewards and claim conditions are identical for all
- Publish the issuer's five mining reward addresses (Section 13)

## 10. Work Procedure

Steps 0 through 13. Each step proceeds to the next only after the pass criteria in Section 11 are confirmed by actual execution. Commands are drafts for Ubuntu-family Linux; exact dependencies follow `doc/build-unix.md` and `doc/build-windows.md` of the branched version.

**Step 0. Preliminary checks and early tests**

- Check the To-verify items in Section 16 against primary sources
- Build the original Bitcoin Core and confirm all tests pass
- Two early tests: whether a Windows cross-build including RandomX works, and whether message signature verification code, once added, verifies signatures per address type and rejects signatures with a different chain name
- If either fails, the design must change; report to the owner before the main work

```bash
sudo apt update
sudo apt install -y build-essential cmake pkgconf python3 git \
    libevent-dev libboost-dev libsqlite3-dev
git clone https://github.com/bitcoin/bitcoin.git coin-series
cd coin-series
git tag --sort=-v:refname | head        # find the latest stable tag
git checkout -b series <latest stable tag>
cmake -B build
cmake --build build -j"$(nproc)"
ctest --test-dir build -j"$(nproc)"     # unit tests
build/test/functional/test_runner.py    # functional tests
```

**Step 1. Write the consensus specification**

- A separate document fixing every Proposed item in this manual down to the byte level. Before code
- Include: claim transaction format and exact serialization of the signed message, claim support scope (Section 5 table), claim status storage rules, header and merge tree serialization, RandomX key rules, difficulty anchor and stall relief parameters, genesis derivation formula, full identifier table per chain
- Write every rule against the standard "do all nodes reach the same verdict on invalid input?"
- Build a simulation program alongside the difficulty rules to fix parameters
- Have the finished specification cross-reviewed by another developer or another AI, and report results to the owner

**Step 2. Renaming and five-chain parameters**

- Replace executable, config file and data directory names, and UI text
- Add the five chains and their testnets and regtests in `src/kernel/chainparams.cpp`, `src/chainparamsbase.cpp`, `src/util/chaintype.*` (file locations may vary by version)
- Keep Bitcoin mainnet and testnet definitions so existing tests keep working, but make them unselectable in release builds

**Step 3. Rewards and total supply**

- Apply `GetBlockSubsidy` and `MaxMoney` from Section 4
- Unit tests for rewards and cumulative totals at heights 1, 209,999, 210,000 and 420,000

**Step 4. Difficulty adjustment and stall relief**

- Replace `GetNextWorkRequired` in `src/pow.cpp`, applying stall relief and the future time limit
- Unit tests with the reference implementation's published test vectors and the Step 1 simulation results

**Step 5. RandomX and merged mining header**

- Include RandomX as a subdirectory and build it together
- Apply the header format and validation rules from Section 7
- The riskiest step. Search terms: `CBlockHeader`, `GetHash`, `CheckProofOfWork`, `headers` message handling, compact blocks, block index

**Step 6. Mining program**

- New program behaving as described in Section 7

**Step 7. Transaction signing rules**

- Apply the Section 6 chain identifier to all three signature hash computations. Update wallet signing code as well

**Step 8. Snapshot and claims**

- Snapshot loading and verification value check, lookup index
- Claim transaction validation, claim status storage and reversal
- Claim tool
- Relay policy: size limits and minimum fees for claim transactions
- During development, inject a mock snapshot of a few dozen outputs per address type into regtest

**Step 9. Fair start structure**

- Apply the Section 9 genesis derivation and reference block input

**Step 10. Integration tests**

- Add the Section 11 tests to Bitcoin Core's functional test framework (`test/functional/`) and pass them all on regtest

**Step 11. Real snapshot and Windows binaries**

- Obtain the snapshot by method A or B of Section 5, check the verification value, compute output count and amount total
- Measure the hash rate on the owner's laptop and calibrate the starting target

```bash
sudo apt install -y g++-mingw-w64-x86-64-posix nsis
make -C depends HOST=x86_64-w64-mingw32 -j"$(nproc)"
cmake -B build-win --toolchain depends/x86_64-w64-mingw32/toolchain.cmake
cmake --build build-win -j"$(nproc)"
```

- Deliverables: node, wallet GUI, command-line tools, mining program, claim tool, and a launcher that starts all five chains at once

**Step 12. Public testnet (Decided: 1 month)**

- Start with the same procedure as mainnet. State that the coins have no value; it may be restarted freely
- Because the period is short, deliberately trigger key epoch transitions, sudden difficulty changes, chain reorganizations and every claim type
- The end decision is based on the Section 11 mainnet launch criteria, not on elapsed time

**Step 13. Mainnet launch**

- After meeting the Section 11 launch criteria and the Section 15 legal review condition, start with the Section 9 procedure
- Install on the laptop per Section 12 and distribute per Section 13

## 11. Verification Criteria

Each item passes only when confirmed by actual execution. Estimates do not count, and failing tests are never deleted or skipped.

**Basic operation**

- [ ] All unit and functional tests of the original Bitcoin Core pass
- [ ] The five chains start simultaneously with separate ports and directories
- [ ] A node of one chain rejects connections from nodes of other chains and environments
- [ ] A wallet of one chain rejects addresses of other chains
- [ ] Height 1 rewards are 6.25, 12.5, 31.25, 62.5, 312.5, halving at height 210,000
- [ ] Claimed amount + mined amount ≤ 21 million x multiplier

**Mining and difficulty**

- [ ] One solution creates blocks on all five chains at once
- [ ] Blocks with the wrong slot number are rejected. One piece of work cannot create two blocks on one chain
- [ ] Blocks whose difficulty bits differ from the computed value are rejected
- [ ] With only some chains succeeding, stopping or reorganizing during merged mining, each chain still operates correctly on its own
- [ ] Block relay between nodes and initial sync of a new node work
- [ ] Correct behavior at RandomX key epoch boundaries. Windows and Linux produce identical results
- [ ] Difficulty reference test vectors match
- [ ] After 10x, 100x and 1,000x inflow then exit (inflow lasting 6 and 48 hours, including repeated inflow), time to first block and time to return to an average 10-minute interval are within the specification targets
- [ ] The advantage obtainable through timestamp choice is within the bound set in the specification (both future timestamps and timestamps earlier than the previous block). Cumulative work of relaxed blocks is computed from the final target
- [ ] One hour of continuous mining on regtest, with rewards credited to five wallets

**Claims**

- [ ] Normal claims per address type: balance = original amount x multiplier − fee
- [ ] Re-claiming the same output is rejected. Duplicates within a block and conflicts between unconfirmed transactions are handled
- [ ] Invalid signatures, outputs absent from the snapshot and tampered amounts are rejected
- [ ] Transactions that add or replace another output at the same address as an input are rejected
- [ ] Transactions with a substituted receiving address are rejected
- [ ] Claim transactions from another sister chain or from testnet are rejected
- [ ] A transaction built on Bitcoin regtest spending the same output with the claim signature is rejected
- [ ] Success and failure for time locks, multisig and Taproot match the specification's support scope
- [ ] After a block containing claims is reorganized away, re-claiming succeeds
- [ ] After a forced shutdown during claim processing, restart and reindex give identical results
- [ ] Coins received through claims can be sent in ordinary transactions
- [ ] Ordinary transaction signatures are rejected on other sister chains and on testnet

**Snapshot and launch**

- [ ] The verification value computed from the snapshot contents matches the value embedded in Bitcoin Core. A node will not start with a tampered snapshot
- [ ] Snapshot output count and amount total computed; total at most 19,687,503.125 BTC
- [ ] Nodes given the same reference block hash derive the same genesis. Nodes given a different hash do not connect

**Operation and recovery**

- [ ] Install on a clean Windows machine; start all five chains, mine, send
- [ ] With the laptop mining alone, average block interval is about 10 minutes
- [ ] Measured memory and storage while running mining, five nodes and snapshot lookup together
- [ ] Resource usage stays bounded when receiving large volumes of invalid headers and claim transactions
- [ ] Five wallets and chains restored on another computer from real backups

**Mainnet launch decision**

- All items above pass on regtest
- The public testnet is started with the same procedure as mainnet and runs for at least 1 month
- At the end of the testnet, remaining defects are graded and reported to the owner. If any defect affecting consensus rules or claimants' assets remains, the mainnet launch is postponed
- The claim signature safety requirements (Section 5) must pass regression tests, cross-review and the testnet
- The pre-mainnet legal review in Section 15 is complete
- The backup and secondary node procedures in Section 12 are documented and a recovery test is complete

**Reporting format to the owner**

- For each step, distinguish passed items, failed or skipped items, and design changes
- The owner is not a developer; explain at the level of the glossary in Section 17

## 12. Laptop Installation and Operation

One spare laptop of the owner runs the nodes and mining for all five chains. The operating system stays Windows.

**Recommended specs (fix by measurement)**

- Memory: 16 GB recommended. About 2 GB for mining plus five nodes and snapshot lookup. Whether 8 GB suffices must be measured
- Storage: start with at least 50 GB free. The snapshot original and lookup index take about 20–30 GB; chain data is small at first but grows with transactions and claims, so check periodically
- Wired internet recommended
- Pruning (prune) is prohibited: while this laptop is the only node, it must keep the full history so new participants can sync

**Installation**

- One launcher starts the five nodes and the mining program together
- Registered to start automatically with Windows
- Mining thread count: adjust for heat and noise. Running a laptop at full load for long periods shortens its life
- Enable automatic clock synchronization: block timestamp rules are strict, so a wrong clock causes rejection either way

**Windows settings**

- Disable sleep and hibernation; keep running with the lid closed
- Confirm automatic restart after Windows updates
- Battery charge limit (manufacturer tool): prevents battery swelling when always plugged in

**Wallet backup (most important)**

- Coin records live on the chain; the keys that can spend them live only in the wallet. Lose the keys and the coins can never be spent
- Document the backup format, backup commands and restore commands for the five wallets, and actually restore on another computer to confirm
- Keep at least two backup copies in a different place from the laptop. Encrypt the wallets
- Safer setup: set the mining reward addresses to a wallet on a separate device, not the laptop. Coins stay safe even if the laptop is hacked

**Chain data backup and secondary node (complete before mainnet)**

- While only one laptop exists, only one copy of the chain history exists
- Automate periodic backups of the chain data directory
- Run one more node on another computer. It need not mine, so an everyday computer is enough
- Keep a copy of the snapshot file on separate storage
- Document the procedure and test that recovery from backup actually works

**External access**

- While operating alone: no extra settings needed
- When others join: forward the five P2P ports (38302, 38304, 38310, 38320, 38400) on the router to the laptop
- Changing home IP address: new participants cannot find a first contact point. Decide the fix (dynamic DNS service, fixed IP from the ISP, adding participant nodes as seeds) at that stage
- Never expose RPC ports externally; doing so allows remote control of the wallet

**Routine checks**

- Are all five chain heights increasing, and similar to each other
- Are block intervals around 10 minutes
- Free disk space, laptop temperature and fan condition
- While the laptop is off, no blocks are produced but the chain is not damaged. After restart, the first block arrives under the stall relief rule and difficulty then adjusts

## 13. Distribution and Identity

Source and binaries are distributed through a public repository and torrent; the issuer operates under a fixed pseudonym and publishes the mining reward addresses (all Decided).

**Distribution**

- Public repository as the main channel, with the same files distributed via torrent, so distribution continues even if the repository account is suspended
- Distributed: source, Windows and Linux binaries, snapshot file and verification instructions, node, mining and claim guides, whitepaper
- Every release file carries a hash and the issuer's signature
- State the official distribution channels, with a notice that no site asks for private keys or recovery phrases

**Identity**

- Real name not disclosed. One pseudonym and one signing key are used consistently to sign every announcement and release file
- Pseudonym: Sento Daimon (Decided). GitHub account: sentodaimon
- Implementer checks: no real name, email or computer name left in commit author fields, build paths, document properties or repository accounts
- The repository account for distribution is a separate pseudonym-only account (created by the owner)

**Publishing the mining addresses**

- The issuer's five mining reward addresses are listed in the whitepaper and release documents
- So anyone can check the issuer's mining share on-chain
- The addresses are public but not linked to the real name. Moving those coins to a real-name account or exchanging them could create a link

**Long-term maintenance**

- Regularly merge Bitcoin Core security fixes and release new versions
- Consensus rule changes require all nodes to upgrade, so give sufficient advance notice and an activation height

## 14. Exchange (Post-Launch)

Exchange is done as direct peer-to-peer swaps where no operator holds others' coins, and the ratio is presented as a reference quote, not a guarantee (Decided).

**Principle**

- The five chains and Bitcoin share the same script system. A contract combining hash locks and time locks makes both transfers complete together or cancel together
- Under normal conditions neither side can lose by sending alone, and no third party holds coins
- Exceptions may occur: transactions not processed before the deadline due to chain stalls, reorganizations, expired refund deadlines, insufficient fees. On small chains, confirmation counts and deadlines must be generous
- The same method works between bitcoin and the series coins, and among the series coins (e.g. 10 Dime for 100 Cent)

**Components**

- Exchange tool: a program each party runs. Builds on an existing public implementation adapted to the five chains. Automates creation and verification of the lock contracts so that pasting the counterparty's terms (ratio, time lock deadline) creates the contract. Users never write scripts
- Offer board: a space to post "willing to swap at this rate." Holds no coins and does not settle trades
- Reference ratio display: Half 2, Quarter 4, Dime 10, Nickel 20, Cent 100 = 1 bitcoin

**Meaning of the reference ratio**

- Guaranteeing fixed-ratio exchange requires reserves, and since all holders can claim free, the reserves required would be enormous, comparable to the entire bitcoin supply. Therefore it is not guaranteed
- The issuer may post offers at the reference ratio within their own funds, but without a limit the funds would be exhausted
- The market sets prices; they are likely to fall far below the reference ratio

**Launch condition**

- Before opening the offer board or exchange tool, obtain legal review on whether it constitutes brokerage (Section 15)

## 15. Risks and Legal Considerations

The biggest risks are the safety of claim signatures, the attack vulnerability of a small chain, and Korean virtual asset regulation. Legal content here is not professional advice; check primary sources and consult a lawyer before acting.

**Technical risks**

| Risk | Description | Response |
| --- | --- | --- |
| Claim signature abuse | If a claim signature is reused on Bitcoin mainnet, the claimant's real bitcoin leaks | Section 5 safety requirements, Section 11 tests. No launch before passing |
| Claim interception | A narrow signature scope lets a third party add inputs or change the receiving address | Signature covers all inputs, outputs, chain and environment |
| Fake claim tools | Third parties distribute fake tools or sites to steal private keys | Official channels, file hashes and signatures, notices |
| Hash power attacks | Rented hash power used to reverse the chain and double-spend | Wait for enough confirmations when exchanging. No complete defense |
| Miner inflow and exit | Sudden difficulty changes stall blocks | Per-block adjustment and stall relief |
| Timestamp manipulation | Stall relief and key epochs depend on block timestamps | Shorter future limit, simulation and cross-review |
| Single node | Laptop failure loses chain history and wallet keys | Backups, secondary node, recovery tests |
| Large structural change | Header, proof of work, signatures and claims changed at once; high defect likelihood | Specification first, cross-review, step-by-step tests, public testnet |
| Post-launch rule changes | Consensus defects cannot be fixed without all nodes upgrading | Run the testnet to find them early while participants are few |
| Upstream security patches | Bitcoin Core security fixes must be merged continually | Regular merges; an ongoing cost of a long-term project |
| Snapshot availability | If the snapshot becomes unobtainable, new nodes cannot join | Torrent, ordinary download, kept copies, guide to direct extraction |

**Market risks**

- A price may not form or may fall far below the reference ratio
- That most early circulating coins are the issuer's mined coins may be read as a premine. Disclose it in advance in the whitepaper and publish the mining addresses

**Legal considerations (Korea; To verify)**

- Act on Reporting and Using Specified Financial Transaction Information: conducting the sale, purchase, exchange, transfer, custody or brokerage of virtual assets as a business requires registration as a virtual asset service provider, and unregistered business is subject to criminal penalties. Check the articles and penalties in the original text
- Activities that may fall under it: an exchange holding others' coins, continuous or repeated trading as a business, whether an offer board counts as brokerage
- Activities generally thought unlikely to fall under it: publishing source code, personal mining, free distribution. This cannot be asserted and must be checked
- Virtual Asset User Protection Act: prohibitions on unfair trading such as market manipulation may apply even to non-providers. Check whether posting reference offers while the issuer holds most coins could be a problem
- Financial Investment Services and Capital Markets Act: selling with promised investment returns may raise securities issues
- Taxes: whether and when gains from mining or exchange are taxed must be checked at the time of realization
- Trademarks: since the "Bitcoin" name is used, state that the project is unofficial; check for trademark issues

**Stage-by-stage legal review conditions (Decided)**

| Stage | What to check before starting |
| --- | --- |
| Public testnet | Nothing. State that the coins have no value |
| Mainnet launch | One lawyer consultation on issuance, mining, free distribution and use of the "Bitcoin" name. Record the outcome and date |
| Opening offer board or exchange tool | Whether it constitutes brokerage |
| Issuer disposing of coins or posting reference offers | Taxes and unfair trading rules |

- A stage is not started until its review is complete

**Operating principles**

- No investment solicitation, price forecasts or promises of returns
- No custody of others' coins or private keys

## 16. Items to Verify Before Work and Open Items

The owner's decisions are complete; the implementer verifies the rest against primary sources.

**Owner decisions**

- [x] Issuer pseudonym: Sento Daimon
- [ ] Launch reference Bitcoin block height: decided after release preparation is complete, separately for testnet and mainnet

**Implementer verification**

- [ ] Whether the Bitcoin Core source records the UTXO set verification value and block hash for height 840,000, and the value and computation method
- [ ] The rollback feature of `dumptxoutset`, how to specify the height, and required disk space
- [ ] Snapshot file size, output count and amount total
- [ ] Whether BIP-322 generic message signing is in Bitcoin Core, the support range of simple and full formats, and wallet support
- [ ] RandomX license, memory requirements, light-mode verification speed, official guidance on key changes, Windows cross-build
- [ ] Reference specification and published test vectors of the difficulty algorithm
- [ ] Whether the tickers BTCH, BTCQ, BTCD, BTCN, BTCC collide with existing coins or companies
- [ ] Whether the network magic and ports collide with other known chains
- [ ] Measured specs and hash rate of the owner's laptop

**Design items to fix in the specification (written as Proposed in the body)**

- [ ] Claim transaction format and serialization of the signed message (Section 5)
- [ ] The seven claim support scope items (Section 5 table)
- [ ] Header and merge tree serialization, RandomX key rules (Section 7)
- [ ] Difficulty anchor, half-life, stall relief parameters, future time limit (Section 8)
- [ ] Genesis derivation formula and handling of reference block reorganization (Section 9)
- [ ] Full identifier table for five chains x three environments (Section 3)

## 17. Glossary

Use explanations at this level when reporting to the owner.

| Term | Meaning |
| --- | --- |
| Hard fork | Creating a new chain whose rules are incompatible with an existing coin |
| Node | A program that stores the chain and verifies transactions and blocks, or the computer running it |
| Block | A unit of record bundling transactions over a period. About one every 10 minutes |
| Genesis block | The first block of a chain. Fixing it is the start of issuance |
| Mainnet | The official chain with real value |
| Testnet | A public test chain with the same rules but valueless coins |
| Regtest | A test chain that runs only on a developer's computer; blocks can be made instantly |
| Mining | Competing on computation to create new blocks and receive new coins as a reward |
| Proof of work | A value showing the computation was actually performed to create a block |
| Difficulty | The amount of computation needed to create one block. Adjusts automatically to participating hash power |
| Halving | The point at which the block reward is cut in half. Every 210,000 blocks (about 4 years) |
| SHA-256 | Bitcoin's mining computation. Specialized miners have an overwhelming advantage |
| RandomX | A mining computation designed for general-purpose CPUs |
| Merged mining | Producing blocks on several chains with one computation |
| 51% attack | An attack by whoever controls more than half the hash power to reverse the chain's history |
| Reorganization | A valid chain with greater cumulative work appears and replaces the most recent blocks |
| Snapshot | A record of all holdings at a specific point in time |
| Unspent output (UTXO) | A chunk of coins not yet spent. A Bitcoin balance is the sum of these chunks |
| txid, vout | The address of an output: which transaction, and which output within it |
| Locking script | The condition that determines who can spend an output |
| Claim | A snapshot-time holder proving ownership and receiving new coins |
| Private key | A secret value that allows spending coins. If leaked, the coins are lost |
| Message signing | A way to prove ownership of a key without revealing it |
| Replay attack | Rebroadcasting a transaction or signature from one chain on another to cause an unintended transfer |
| Consensus rules | Validity rules every node must follow identically. If nodes judge differently, the chain splits |
| Port | A numbered communication channel per program within one computer |
| Seed node | The node a new participant connects to first to obtain a list of other nodes |
| Peer-to-peer swap | Two people exchanging coins of different chains simultaneously, with no intermediary holding the coins |
