@echo off
cd /d "%~dp0"
call m0-settings.bat
set D=%DATA%
set OUT=%D%\status.txt
echo Coin Series mainnet status %DATE% %TIME% > "%OUT%"
for %%c in (half quarter dime nickel cent) do (
  echo ==== %%c >> "%OUT%"
  bitcoin-cli.exe -datadir=%D% -chain=main -coin=%%c getmininginfo >> "%OUT%" 2>&1
  bitcoin-cli.exe -datadir=%D% -chain=main -coin=%%c getconnectioncount >> "%OUT%" 2>&1
  bitcoin-cli.exe -datadir=%D% -chain=main -coin=%%c -rpcwallet=w getbalances >> "%OUT%" 2>&1
)
type "%OUT%"
pause
