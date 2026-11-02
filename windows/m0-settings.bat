@echo off
rem ===== Coin Series MAINNET settings =====
set DATA=C:\CoinSeries\mainnet
rem Announced Bitcoin block H (height). The start script waits for it and reads its header itself.
set HEIGHT=974800
rem Verified claim snapshot (already checked on the testnet)
set SNAPSHOT=C:\CoinSeries\snapshot\utxo-840000.dat
rem Another mainnet node to connect to (empty = none)
set SEED=
rem Mining threads (default: all CPU threads)
set THREADS=%NUMBER_OF_PROCESSORS%
