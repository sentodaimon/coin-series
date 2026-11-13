@echo off
cd /d "%~dp0"
call m0-settings.bat
taskkill /im cs-miner.exe /f >nul 2>&1
for %%c in (half quarter dime nickel cent) do bitcoin-cli.exe -datadir=%DATA% -chain=main -coin=%%c stop
echo Mainnet nodes stopping. Start again with m1-start-mainnet.bat (it skips waiting once block H is known).
pause
