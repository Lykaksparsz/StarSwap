:: STARSWAP wsModMonitor Update Tool - Update wsModMonitor from previous versions.
:: Please only run this tool if a new version of wsModMonitor exists. Do not use this to load previous versions.

:init
@echo off
title StarSwap wsModsMonitor Updater
echo ~[?]~ StarSwap wsModMonitor Updater - Update wsModMonitor from previous versions.
echo ~[?]~ Make sure an updated version of wsModMonitor is in the same directory as this tool:
echo %~dp0wsModMonitor.bat
pause
IF NOT EXIST "%APPDATA%\StarSwap\" goto:errorNoSetup
IF EXIST "%~dp0wsModMonitor.bat" goto:main
IF NOT EXIST "%~dp0wsModMonitor.bat" goto:errorNoUpdatedVer

:main
cls
echo ~[=]~ StarSwap wsModMonitor Updater will now update...
TIMEOUT /T 3 /NOBREAK
move /Y "%~dp0wsModMonitor.bat" "%APPDATA%\StarSwap\"
cls
echo ~[!]~ StarSwap wsModsMonitor Updater has updated wsModsMonitor successfully.
pause
exit

:errorNoSetup
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap is not currently installed on your system.
echo ~[?]~ Please install StarSwap before updating it, dummy.
pause
exit

:errorNoUpdatedVer
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap cannot find an updated version of wsModMonitor here:
echo %~dp0
echo ~[?]~ Please download an updated version of wsModMonitor from StarSwap's GitHub page before using this tool.
pause
exit