@echo off
cd /d "%~dp0"
echo ==== Coin Series MAINNET start ====
echo This window waits for Bitcoin block H, then starts the five mainnet nodes and mining by itself.
echo Keep this PC on and awake. Do not click inside black windows.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0m1-start-mainnet.ps1"
pause
