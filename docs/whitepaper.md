# Bitcoin Coin Series — Whitepaper

October 7, 2026

Draft. Contents may change until design verification and the public testnet are complete. Items in 〔 〕 will be finalized before launch.

This project is an independent experiment with no official affiliation with Bitcoin (BTC), the Bitcoin Core developers, or any Bitcoin-related organization.

## 1. Summary

The Bitcoin Coin Series is a set of five independent blockchains that keep Bitcoin's transaction system while multiplying the supply by 2, 4, 10, 20 and 100, with a newly designed mining, difficulty and distribution scheme.

- Five coins: Bitcoin Half, Quarter, Dime, Nickel and Cent, named after the US half dollar, quarter, dime, nickel and cent (1/2, 1/4, 1/10, 1/20 and 1/100)
- Free distribution: anyone who held bitcoin at Bitcoin block 840,000 can prove ownership and receive each of the five coins in proportion to its multiplier. There is no deadline
- Simultaneous mining: a single computation produces blocks on all five chains and earns all five rewards together
- Ordinary-computer mining: mining uses general-purpose CPUs rather than specialized hardware
- Fair start: no premine and no developer allocation. No one, including the issuer, can start mining before the starting reference value is published
- No exchange listing is pursued, and no price or return is promised

## 2. Background

Bitcoin's supply is fixed at 21 million, so as its value rises, one unit drifts further from everyday amounts.

- Pricing a cup of coffee at 0.000034 BTC is not intuitive
- Handling many decimal places is error-prone for ordinary users

This can also be addressed within Bitcoin by using sub-unit notation. This project tests a different path: a long-term experiment observing how people receive and use five separate assets with different units, all started at the same moment under the same conditions.

Bitcoin forks with increased supply have existed before, and most have disappeared. This project differs in that:

- It launches five denominations at once rather than a single coin
- It does not depend on exchange listings
- One act of mining earns all five coins
- It does not aim to replace or compete with Bitcoin

The five coins are not sub-units of Bitcoin. Each is a separate asset with its own price. "Two Halves equal one bitcoin" is only the reference implied by the name; no one guarantees it.

## 3. The Five Coins

The five chains differ only in their supply multiplier; all other rules are identical.

| Coin | Ticker | Unit vs. Bitcoin | Multiplier | Block reward (at start) | Supply cap | Claim per 1 BTC held |
| --- | --- | --- | --- | --- | --- | --- |
| Bitcoin Half | BTCH | 1/2 | 2 | 6.25 | 42,000,000 | 2 |
| Bitcoin Quarter | BTCQ | 1/4 | 4 | 12.5 | 84,000,000 | 4 |
| Bitcoin Dime | BTCD | 1/10 | 10 | 31.25 | 210,000,000 | 10 |
| Bitcoin Nickel | BTCN | 1/20 | 20 | 62.5 | 420,000,000 | 20 |
| Bitcoin Cent | BTCC | 1/100 | 100 | 312.5 | 2,100,000,000 | 100 |

**Kept from Bitcoin**

- 10-minute block interval
- Halving every 210,000 blocks (about 4 years)
- Transaction and script system, including SegWit and Taproot
- The smallest unit: one coin divides into 100,000,000 base units

**Changed from Bitcoin**

- Supply and block rewards are multiplied
- Proof of work: RandomX (CPU-oriented) instead of SHA-256
- Difficulty adjustment every block instead of every two weeks
- Simultaneous mining of the five chains
- Each chain starts from a new genesis block. Bitcoin's transaction history is not carried over; only its ownership snapshot is referenced

**Reward schedule**

- The starting reward is Bitcoin's current block reward of 3.125 times the multiplier
- Each chain halves for the first time at its own block 210,000, and every 210,000 blocks after that
- The supply cap is a nominal ceiling combining the claimable amount and the amount yet to be mined. Because some coins will never be claimed, actual circulating supply will be lower
- Monthly issuance per chain is the equivalent of 13,500 BTC times the multiplier (about 27,000 Half, about 1,350,000 Cent)

## 4. Distribution: Snapshot and Claims

Anyone who held bitcoin at Bitcoin block 840,000 (the fourth halving block, April 2024) can claim the five coins free of charge.

**Principles**

- There is no deadline. Unclaimed amounts never expire and can be claimed at any time
- The claim amount is the holding at the snapshot times each coin's multiplier. Holding 1 BTC entitles you to 2 Half, 4 Quarter, 10 Dime, 20 Nickel and 100 Cent
- There is no registration or approval. A claim is an on-chain transaction, verified by every node under the same rules
- Even if you sold your bitcoin after the snapshot, you can claim as long as you hold the private key from the snapshot time

**How it works**

- Every node keeps the Bitcoin ownership state (the snapshot) at block 840,000
- The snapshot is verified against a value already recorded in the Bitcoin Core software. Because the issuer did not create that value, the snapshot's contents can be checked without trusting the issuer. The safety of the software itself is a separate matter, open to review through the published source
- A claimant proves ownership of the bitcoin by signing a message. Because a message, not a Bitcoin transaction, is signed, no bitcoin moves
- The signature commits to which bitcoin outputs are claimed, on which chain, and to which address. No one else can reuse the signature to change its contents or use it on another chain
- Each bitcoin output can be claimed only once per chain

**Please note**

- No claim will ever ask you to enter a private key or recovery phrase on a website. Any such site is an impersonation
- Claims are public. Anyone can see which bitcoin owner received coins at which new address
- Bitcoin held on an exchange cannot be claimed directly by the user, because the exchange holds the private keys
- Some special forms of bitcoin holdings may not be claimable at first. Even then, the record of what is claimable is preserved. Adding support later is a goal but cannot be guaranteed, since new rules apply only if node operators adopt them. Supported range: 〔to be finalized before launch〕
- For safety, consider moving the bitcoin in question to a new address before claiming

## 5. Mining

Mining is done on ordinary computers, and one computation produces blocks on all five chains.

**Proof of work**

- RandomX (version 1, in use since 2019) is used. It is designed for general-purpose CPUs, so specialized hardware gains little advantage
- Why not Bitcoin's SHA-256: if a few holders of specialized miners joined, ordinary participants' mining would become meaningless, and the chain could be attacked simply by renting hash power
- For the same reason, merged mining with Bitcoin, which would let Bitcoin miners mine these chains at no extra cost, is not used

**All five rewards at once**

- A miner combines block candidates for the five chains and performs a single computation
- If the solution meets a chain's difficulty target, a block is created on that chain. When all five chains share the same difficulty, five blocks are created together and all five rewards are earned together
- As long as miners mine all five together, hash power is not split and the five chains' security moves together. If only some chains are mined or attacked, security may differ between chains
- The five chains are independent. A problem on one chain does not affect the validity of another

**Difficulty**

- Difficulty is adjusted every block. On chains with few participants, hash power can change sharply, and adjusting only every two weeks could leave blocks stalled for a long time
- If no block appears for a long time, a rule makes the difficulty progressively easier as time passes. The goal is for the next block to appear within a few hours even after large hash power arrives and then leaves. Returning to the normal 10-minute interval may take longer
- Parameters: difficulty halves or doubles over a 2-hour half-life of schedule deviation; if no block appears for more than 1 hour, the target becomes twice as easy every further 30 minutes; block times may be at most 10 minutes ahead of the current time. In simulation, after 1,000-fold hash power arrived for 48 hours and left, the next block appeared after about 4.5 hours (median). The starting difficulty is 1,000,000 hashes per block, set from the launch desktop's measured hash rate (about 1,660 hashes per second, about 10-minute blocks). The schedule is counted from the first mined block, so a late start after the reference block does not release a burst of easy blocks

**Limitations**

- Chains with few participants are vulnerable to attacks using rented hash power. Changing the proof of work does not remove this risk, and there is no complete defense
- When receiving large amounts, wait until enough blocks have accumulated

## 6. Fair Start

The chains launch after verification on a public testnet, and the launch conditions, source code and mining method are published in advance. There is no premine or separate allocation for the issuer, and mining is open to everyone under identical conditions from the first block.

**No one can mine before the reference block appears**

- The first block (genesis) of each of the five chains is derived from a future Bitcoin block announced in advance
- No one in the world can know that Bitcoin block's contents until it is mined, so no one, including the issuer, can mine in advance
- Reference block height: 〔announced with the release; at least 432 blocks after the release height, about 72 hours on average〕
- The software is published beforehand. Once the reference block appears, participants can verify its value themselves and start immediately. Block propagation still introduces differences of seconds to tens of seconds. If the reference block is replaced by a Bitcoin reorganization, the replacing block becomes the reference, and blocks mined before that become invalid

**On the issuer's share of mining**

In the early period there may be few or no miners, so the issuer's share of mining may be overwhelmingly high. This is not a privilege granted by design but a consequence of the number of participants, and it will naturally decline as participation grows.

- The issuer starts mining at the same moment, with the same published software
- No rule favors the issuer. Starting difficulty, rewards and claim conditions are the same for everyone
- The issuer's mining reward addresses are published. Anyone can verify on-chain how much was mined to these addresses. This does not prove amounts the issuer received through claims or holds at other addresses

| Chain | Issuer's mining reward address |
| --- | --- |
| Half | 〔to be listed before launch〕 |
| Quarter | 〔to be listed before launch〕 |
| Dime | 〔to be listed before launch〕 |
| Nickel | 〔to be listed before launch〕 |
| Cent | 〔to be listed before launch〕 |

**Testnet and mainnet**

- Defect testing happens on a public testnet whose coins have no value, run for at least 7 days with the same start procedure as mainnet. The testnet may be restarted from scratch at any time
- The mainnet will not be restarted. Defects found on mainnet are fixed through rule improvements
- The issuer has no power to fix particular blocks or reverse transactions

## 7. Exchange and Value

This project does not guarantee the price of any of the five coins, and a price may never form.

**Reference ratio**

- The reference implied by the names: 2 Half, 4 Quarter, 10 Dime, 20 Nickel, 100 Cent = 1 bitcoin
- This ratio is only a reference. No one, including the issuer, guarantees exchange at this ratio
- Why it cannot be guaranteed: since every bitcoin holder can claim for free, exchanging at a fixed ratio for bitcoin would require reserves comparable to the entire bitcoin supply. Free distribution and a guaranteed fixed ratio cannot coexist
- The market sets prices. Most past forks traded far below the original and then disappeared

**How exchange works**

- No exchange listing is pursued
- Exchange is assumed to happen directly between individuals. Because the five chains use the same script system as Bitcoin, contracts can be built in which both transfers complete together or are cancelled together
- In this approach no third party holds anyone's coins. Losses can still occur in situations such as chain stalls, reorganizations, expired time limits or insufficient fees
- A tool that makes this easy and a space to post offers are post-launch tasks; whether and when they will be provided has not been decided

**The issuer's holdings**

- The issuer obtains coins only through mining and claims, the same ways as any other participant
- Early on, few people will claim, so most circulating coins will be mined coins, and the issuer may hold most of them. Coins mined to the addresses published in Section 6 can be verified

## 8. How to Participate

Anyone can run a node, mine and claim without permission.

**Distribution channels**

- Official repository: 〔to be listed before launch〕
- Torrent: 〔to be listed before launch〕
- Every release file comes with a hash and the issuer's signature. Issuer signing key: 〔to be listed before launch〕
- Releases from any other source are not from the issuer

**Running a node**

- Binaries are provided for Windows and Linux. You can also build from source
- A node must download the Bitcoin snapshot (about 10 GB) once. The five chains share one file
- The snapshot can also be extracted directly from a Bitcoin full node. However it is obtained, the node checks it against the verification value
- You may run all five chains or only some of them

**Mining**

- Use the mining program provided with the node
- Ordinary computers are sufficient; mining requires about 2 GB of memory or more
- Set one reward address per chain

**Claiming**

- Enter the bitcoin holdings you want to claim and your receiving addresses into the claim tool, and it will show a message to sign
- Sign that message with the Bitcoin wallet you normally use and paste the signature into the tool to create the claim transactions. Your private key never leaves your wallet
- For wallets that do not support message signing, the tool can also sign directly. In that case, use it on a computer disconnected from the internet, and move your bitcoin to a new address beforehand
- Fees can be paid out of the claimed amount, so you can claim even if you hold no coins yet

## 9. Risk Disclosure

The five coins may have no value, and any losses from participation are borne by the participant.

| Risk | Description |
| --- | --- |
| Value | A price may not form or may fall far below the reference ratio. Most past Bitcoin forks disappeared |
| Concentration | Early on, the issuer may hold most of the circulating coins |
| Mining attacks | While participation is low, a third party with rented hash power could reverse recent transactions |
| Stalls | Sudden changes in hash power may leave blocks absent for hours |
| Software defects | New software that changes several Bitcoin rules at once. It is tested and reviewed, but freedom from defects cannot be guaranteed |
| Single operator | Early on, one issuer handles development and node operation. If the issuer stops, development and security fixes may stop |
| Impersonation | Third parties may try to steal private keys with fake claim tools or sites. Check the official channels and signatures |
| Key management | If you lose your wallet's keys, the coins are gone forever. No one can recover them |
| Privacy | Claiming publicly links a bitcoin address to a new address |
| Regulation | Virtual asset regulations and taxes in each country may apply. Compliance is the participant's own responsibility |

## 10. Operating Principles and Disclaimer

The issuer commits to the following principles.

1. No premine and no allocation for the issuer
2. No sale of coins, no investment solicitation, and no promise of price or return
3. No pursuit of exchange listings
4. No custody of anyone else's coins or private keys
5. No request to submit private keys or recovery phrases to the issuer or any website. Entering them into the offline claim tool on your own computer is different, and those values are never transmitted
6. All source code is published, and the issuer's mining addresses are published
7. The mainnet will not be restarted, and there will be no power to fix particular blocks or reverse transactions
8. Consensus rule changes are announced in advance with an activation point. Each node operator decides whether to follow new rules

**Issuer**

- Pseudonym: Sento Daimon
- All announcements and release files are signed with a single signing key. Announcements without this signature are not from the issuer

**Disclaimer**

- This project has no official affiliation with Bitcoin (BTC), the Bitcoin Core developers, or any Bitcoin-related organization. "Bitcoin" in the names refers only to the source of the snapshot and the reference for the units
- This document is not an investment solicitation and is not legal, tax or investment advice
- The software is provided as is, and the issuer is not liable for losses arising from its use
- This project is based on the open source of Bitcoin Core (MIT License) and RandomX
