@echo off
cd /d "%~dp0"
echo Sets ONE password on all five mainnet wallets and saves backups to C:\CoinSeries\mainnet-backup
echo Write the password on paper. Without it the coins cannot be spent. Claude never needs it.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0m2-protect-wallets.ps1"
pause
