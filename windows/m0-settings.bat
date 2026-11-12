@echo off
rem ===== Coin Series MAINNET settings =====
set DATA=C:\CoinSeries\mainnet
rem Bitcoin block H (fixed start reference of the mainnet). Do not change.
set HEIGHT=974800
rem Claim snapshot utxo-840000.dat (about 9.8 GB, see README "Windows quick start")
set SNAPSHOT=C:\CoinSeries\snapshot\utxo-840000.dat
rem Public node to connect to (each chain uses its own port)
set SEED=coinseries.duckdns.org
rem Mining threads (default: all CPU threads; lower it if the PC gets too hot or slow)
set THREADS=%NUMBER_OF_PROCESSORS%
