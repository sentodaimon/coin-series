@echo off
cd /d "%~dp0"
call m0-settings.bat
echo Sets ONE password on all five mainnet wallets and saves backups to %DATA%-backup
echo Write the password on paper. Without it the coins cannot be spent. Claude never needs it.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0m2-protect-wallets.ps1"
pause
