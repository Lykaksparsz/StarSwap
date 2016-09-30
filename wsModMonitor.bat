:: STARSWAP wsModMonitor - Monitors Workshop mod downloads.
:: This is a dependency for StarSwap, as Steam will download mods automatically.
:: This dependency will keep the most up to date version of your mods.
:: PLEASE LEAVE THIS IN YOUR STARSWAP DATA FOLDER.
:: If you're looking at this first before installing StarSwap,
:: leave this file in the same directory as StarSwap so it can install it during Setup.

:: Designed for use with StarSwap Versions later than Version 1.0.0.
:: Last updated during Version 1.1.0.

@echo off
IF NOT EXIST "%APPDATA%\StarSwap\state.txt" goto:errorNoState
set /p state=<"%APPDATA%\StarSwap\state.txt"
if %state%==modded goto:errorwsModded
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
echo ~[!]~ StarSwap wsModMonitor requires administrator priviledges to make changes to Starbound's storage.
goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

"%temp%\getadmin.vbs"
exit /B

:gotAdmin
if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
pushd "%CD%"
CD /D "%~dp0"

IF EXIST "%ProgramFiles(x86)%" goto:64bit
IF NOT EXIST "%ProgramFiles(x86)%" goto:32bit

:64bit
set steamdir=%ProgramFiles(x86)%\Steam
set modsave=%APPDATA%\StarSwap\modsave
goto:mainScript

:32bit
set steamdir=%ProgramFiles%\Steam
set modsave=%APPDATA%\StarSwap\modsave
goto:mainScript

:mainScript
cls
title StarSwap wsModMonitor
echo ~[=]~ StarSwap wsModMonitor will now monitor your workshop storage for updated mods...
echo ~[!]~ Please leave this open. StarSwap will close it when your mods are reloaded.
TIMEOUT /T 10 /NOBREAK
color 0E
robocopy "%steamdir%\steamapps\workshop\content\211820" "%modsave%\mods" /MOVE /E /NJH /NJS /XO /MON:1

:errorwsModded
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: wsModMonitor cannot run if the current state is Modded.
echo ~[?]~ Please swap to Vanilla before launching wsModMonitor.
pause
color 07
goto:settings

:errorNoState
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: wsModMonitor cannot read StarSwap's current state.
echo ~[?]~ Please run StarSwap before launching wsModMonitor.