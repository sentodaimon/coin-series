# Wallet guide

There is no graphical wallet yet. Each coin has its own wallet named `w`, used through `bitcoin-cli`.

Windows: open a Command Prompt in the kit's `windows` folder (where `bitcoin-cli.exe` is). The examples use Half and the default data folder `C:\CoinSeries\mainnet`; for other coins change `-coin=half` to `quarter`, `dime`, `nickel` or `cent`. If you changed `DATA` in `m0-settings.bat`, use that folder. On Linux use `-datadir=~/coinseries` (see `docs/build-linux.md`).

## 1. Protect and back up first

Run `m2-protect-wallets.bat`. It sets one password on all five wallets and saves a copy of each wallet to `C:\CoinSeries\mainnet-backup` (`half-wallet.dat`, `quarter-wallet.dat`, …). Write the password on paper and copy that folder to a USB stick. Without the password the coins cannot be spent, and nobody can recover it.

## 2. Balance

```
bitcoin-cli -datadir=C:\CoinSeries\mainnet -chain=main -coin=half -rpcwallet=w getbalances
```

Mining rewards show as `immature` first and become spendable after 100 blocks (about 17 hours). `m3-status.bat` shows all five coins.

## 3. Receive

```
bitcoin-cli -datadir=C:\CoinSeries\mainnet -chain=main -coin=half -rpcwallet=w getnewaddress
```

## 4. Send

Unlock for 60 seconds (only needed after step 1), then send:

```
bitcoin-cli -datadir=C:\CoinSeries\mainnet -chain=main -coin=half -rpcwallet=w walletpassphrase "your password" 60
bitcoin-cli -datadir=C:\CoinSeries\mainnet -chain=main -coin=half -rpcwallet=w sendtoaddress hf1q... 1.5
```

Each coin only accepts its own addresses (`hf1` Half, `qt1` Quarter, `dm1` Dime, `nk1` Nickel, `ct1` Cent), so coins cannot be sent to the wrong chain by mistake.

## 5. Restore

On any PC with the node running (same coin), restore a backup file under a new wallet name:

```
bitcoin-cli -datadir=C:\CoinSeries\mainnet -chain=main -coin=half restorewallet w2 "D:\backup\half-wallet.dat"
```

Then use `-rpcwallet=w2` in the commands above, with the same password. Repeat for each coin with its own backup file. Restored balances appear after the node has rescanned the chain.

Keep backup files private: anyone with a backup and its password can spend the coins.
