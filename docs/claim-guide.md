# Claim guide

If you held bitcoin **in your own wallet** at Bitcoin block 840,000 (2024-04-20), you can claim the multiplied amount on each of the five chains (Half x2, Quarter x4, Dime x10, Nickel x20, Cent x100). There is no deadline. A claim **never moves your bitcoin** and your private key never leaves your wallet.

Not claimable directly: bitcoin held on an exchange at that block (the exchange holds the keys), and outputs whose keys are lost.

## What you need

- A running Coin Series node (Windows kit `m1-start-mainnet.bat`, see README). Claims are checked by the node against the block 840,000 snapshot.
- Your Bitcoin wallet, able to sign either
  - a **message** (legacy addresses starting with `1`), or
  - a **PSBT** (any address type: `1…`, `3…`, `bc1q…`, `bc1p…`). Bitcoin Core and most modern wallets can.
- For the PSBT route: Python 3.8+ and `tools/cs_claim_psbt.py` from this repository (single file, no network access, no dependencies).

## Steps (example: Half; repeat for each coin with `-coin=quarter`, `dime`, `nickel`, `cent`)

In the commands below, `cli` means
`bitcoin-cli -datadir=C:\CoinSeries\mainnet -chain=main -coin=half`.

**1. Find the outputs you owned at block 840,000.**
Each output is a transaction id and an output number (`txid`, `vout`) that paid one of your addresses before block 840,000 and was still unspent at that block (it may have been spent later). A block explorer's address page shows them. Check each one:

```
cli getclaimable <txid> <vout>
```

`found: true` and `claimed: false` means it can be claimed; `claim_amount` is what you receive.

**2. Create the claim.** Choose a receiving address on the Coin Series chain (`cli getnewaddress`) and leave about 0.001 for the fee:

```
cli createclaim "[{\"txid\":\"<txid>\",\"vout\":<vout>}]" "[{\"<your hf1… address>\":<claim_amount minus 0.001>}]"
```

It returns `hex` (the unsigned claim) and `message` (the text to sign). Save the message exactly, without extra spaces or lines, to `msg.txt`.

**3a. Legacy address (`1…`): sign the message** in your Bitcoin wallet (Bitcoin Core: `signmessage <address> "<message>"`) and copy the signature.

**3b. Any address type: sign a PSBT.**

```
python cs_claim_psbt.py psbt msg.txt <your bitcoin address>
```

Sign the printed PSBT in your Bitcoin wallet like an ordinary transaction (Bitcoin Core: `walletprocesspsbt "<psbt>"`) and finalize it. Then:

```
python cs_claim_psbt.py proof "<signed psbt>"
```

This prints the proof (starting with `ful`). The PSBT spends only a virtual zero-value output that exists inside the proof; broadcasting it on Bitcoin is impossible.

**4. Attach the proof and send.**

```
cli addclaimproof <hex from step 2> 0 "<signature or proof>"
cli sendrawtransaction <hex returned by addclaimproof>
```

After the next block the coins are spendable in your Coin Series wallet.

## Notes

- Each coin has its own claim message, so you sign five times (once per coin).
- Several outputs can be claimed in one transaction: list them in `createclaim` and attach one proof per input index (`0`, `1`, …).
- Multisig and other script outputs: the claim right is preserved, but this route is not tested yet. Ask in the forum thread before trying.
- Never type a private key or seed phrase into any website or tool, including anything claiming to be from this project. Only sign messages or PSBTs in your own wallet.
- Tested end to end on regtest with a Bitcoin Core wallet: P2PKH, P2SH-P2WPKH, P2WPKH and P2TR, all five coins (`tools/psbt_claim_test.sh`).
