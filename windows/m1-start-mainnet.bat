@echo off
cd /d "%~dp0"
echo ==== Coin Series MAINNET start ====
echo This window checks the start reference (Bitcoin block 974800), starts the five nodes,
echo waits until they have synced with the network, then starts mining.
echo Keep this PC on and awake. Do not click inside black windows (press Esc if one pauses).
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0m1-start-mainnet.ps1"
pause
