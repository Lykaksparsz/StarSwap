:: STARSWAP - Swap between your Vanilla/Modded saves easily. made by wistlyr.
:: You can read about STARSWAP over at https://github.com/wistlyr/StarSwap/

:: Begin Initialization

@echo off
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo ~[!]~ StarSwap requires administrator priviledges to make changes to Starbound's storage.
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

echo ~[=]~ Initializing...
set vanillasave=%APPDATA%\StarSwap\vanillasave
set modsave=%APPDATA%\StarSwap\modsave
set backup=%APPDATA%\StarSwap\backups
set ssdata=%APPDATA%\StarSwap
set ver=1.0.0
IF EXIST "%ProgramFiles(x86)%" goto:64bit
IF NOT EXIST "%ProgramFiles(x86)%" goto:32bit

:64bit
set steamdir=%ProgramFiles(x86)%\Steam
set sysarch=64x
title StarSwap - Version %ver%
goto:checkSetup

:32bit
set steamdir=%ProgramFiles%\Steam
set sysarch=32x
title StarSwap - Version %ver%
goto:checkSetup

:checkSetup
call:getOSVersion
IF "%VERSION%"=="5.2" goto:errorOSXP
IF "%VERSION%"=="5.1" goto:errorOSXP
IF NOT EXIST "%APPDATA%\StarSwap\" goto:asksetup
IF NOT EXIST "%APPDATA%\StarSwap\state.txt" goto:setupinitstate
IF NOT EXIST "%APPDATA%\StarSwap\wsModMonitor.bat" goto:setupwsModMonitor
IF EXIST "%APPDATA%\StarSwap\" goto:premain
goto:errorPlaceholder

:: End Initialization

:: Begin Setup Sequence

:asksetup
cls
echo ~[!]~ StarSwap is not currently set up.
echo ~[?]~ Is it okay to install to your APPDATA folder?
echo [1] Yes
echo [2] No
set /p initsetup=Selected option:
if "%initsetup%"=="1" goto:setupDir
if "%initsetup%"=="2" goto:errorSetup

:setupDir
cls
color 0E
echo ~[=]~ Setting up...
  IF NOT EXIST "%APPDATA%\StarSwap\" mkdir "%APPDATA%\StarSwap\"
  IF NOT EXIST "%APPDATA%\StarSwap\backups" mkdir "%APPDATA%\StarSwap\backups"
  IF NOT EXIST "%APPDATA%\StarSwap\modsave" mkdir "%APPDATA%\StarSwap\modsave"
  IF NOT EXIST "%APPDATA%\StarSwap\modsave\mods" mkdir "%APPDATA%\StarSwap\modsave\mods"
  IF NOT EXIST "%APPDATA%\StarSwap\modsave\save" mkdir "%APPDATA%\StarSwap\modsave\save"
  IF NOT EXIST "%APPDATA%\StarSwap\vanillasave\save" mkdir "%APPDATA%\StarSwap\vanillasave\save"
color 07
  IF NOT EXIST "%APPDATA%\StarSwap\wsModMonitor.bat" goto:setupwsModMonitor
  IF NOT EXIST "%APPDATA%\StarSwap\state.txt" goto:setupinitstate
goto:setupFIN

:setupwsModMonitor
IF NOT EXIST "%~dp0wsModMonitor.bat" goto:errormissingDependency
IF EXIST "%~dp0wsModMonitor.bat" move /Y "%~dp0wsModMonitor.bat" "%APPDATA%\StarSwap\"
IF NOT EXIST "%APPDATA%\StarSwap\state.txt" goto:setupinitstate
goto:premain

:setupinitstate
cls
echo ~[!]~ Current state unknown.
echo ~[?]~ What is the current state of your Starbound installation?
echo [1] Modded
echo [2] Vanilla
set /p initopt=Selected option:
if %initopt%==1 goto:initstateModded
if %initopt%==2 goto:initstateVanilla
goto:errorInvalidC

:initstateModded
cls
echo modded>"%APPDATA%\StarSwap\state.txt"
echo ~[!]~ Please note that StarSwap is intended to work with Steam Workshop mods!
echo ~[!]~ Mods downloaded directly from the forums will not play nicely with StarSwap! (Yet!)
pause
IF EXIST "%APPDATA%\StarSwap\vanillasave\save\starbound.config" goto:setupFIN
cls
echo ~[?]~ Would you like to import a previous Vanilla save?
echo [1] Yes
echo [2] No
set /p vanSetupSave=Selected option:
if "%vanSetupSave%"=="1" goto:setupMvanBKUPImport
if "%vanSetupSave%"=="2" goto:setupFIN
if "%vanSetupSave%"=="" goto:initstateModded
goto:initstateModded

:initstateVanilla
cls
echo ~[!]~ Please note that StarSwap is intended to work with Steam Workshop mods!
echo ~[!]~ Mods downloaded directly from the forums will not play nicely with StarSwap! (Yet!)
pause
cls
color 0C
echo ~[!]~ Please mod your Starbound first before using this tool. Workshop mods only!
echo ~[!]~ Make a backup of your "storage" directory, and run this tool again once you do.
pause
goto:cleanExit

:: BEGIN UNUSED CODE

IF EXIST "%APPDATA%\StarSwap\modsave\save\starbound.config" goto:setupFIN
cls
echo ~[?]~ Would you like to import a previous Modded save?
echo [1] Yes
echo [2] No
set /p modSetupSave=Selected option:
if "%modSetupSave%"=="1" goto:setupVmodBKUPImport
if "%modSetupSave%"=="2" goto:errorVanillaState
goto:errorPlaceholder

:: END UNUSED CODE

:: Begin Setup Vanilla import Subsequence

:setupMvanBKUPImport
cls
echo ~[?]~ Where is your current Vanilla save?
echo   Example:
echo       C:\Users\username\Documents\StarboundBackup
echo   Contents of folder should look like this!
echo   + StarboundBackup
echo     + \player\
echo     + \universe\
echo     ~ starbound.config
echo     ~ starbound.log
echo   Make sure folder has NO other data!
set /p vansaveloc=Location of directory:
cls
echo ~[?]~ Is this location correct?
echo %vansaveloc%
echo [1] Yes
echo [2] No
set /p confirm=Selected option:
if "%confirm%"=="1" goto:setupMvanBKUPChk
if "%confirm%"=="2" goto:setupMvanBKUPImport
if "%confirm%"=="" goto:setupMvanBKUPImport
goto:errorInvalidC

:setupMvanBKUPChk
cls
color 0E
if exist "%vansaveloc%\starbound.config" goto:setupMvanBKUPFix
if exist "%vansaveloc%starbound.config" goto:setupMBKUPImport
goto:errorSetupVanillaNF

:setupMvanBKUPFix
set vansaveloc=%vansaveloc%\
goto:setupMBKUPImport

:setupMBKUPImport
echo ~[=]~ StarSwap will now import your Vanilla save from backup...
TIMEOUT /T 3 /NOBREAK
color 0E
robocopy "%vansaveloc%\" "%vanillasave%\save" /E /NJH /NJS
IF NOT EXIST "%vansaveloc%" mkdir "%vansaveloc%"
color 07
goto:setupMBKUPPostImport

:setupMBKUPPostImport
cls
echo ~[!]~ Finished importing your Vanilla save.
pause
goto:setupFIN

:: End Setup Vanilla import Subsequence

:: BEGIN UNUSED CODE "Setup Modded import Subsequence"

:setupVmodBKUPImport
cls
echo ~[?]~ Where is your current Modded save?
echo   Example:
echo       C:\Users\username\Documents\StarboundModdedBackup
echo   Contents of folder should look like this!
echo   + StarboundModdedBackup
echo     + \player\
echo     + \universe\
echo     ~ starbound.config
echo     ~ starbound.log
echo   Make sure folder has NO other data!
set /p modsaveloc=Location of directory:
cls
echo ~[?]~ Is this location correct?
echo %modsaveloc%
echo [1] Yes
echo [2] No
set /p confirm=Selected option:
if "%confirm%"=="1" goto:setupVModBKUPChk
if "%confirm%"=="2" goto:setupVModBKUPImport
if "%confirm%"=="" goto:setupVModBKUPImport
goto:errorInvalidC

:setupVModBKUPChk
cls
color 0E
if exist "%modsaveloc%\starbound.config" goto:setupVModBKUPFix
if exist "%modsaveloc%starbound.config" goto:setupVBKUPImport
goto:errorSetupModdedNF

:setupVModBKUPFix
set modsaveloc=%modsaveloc%\
goto:setupVBKUPImport

:setupVBKUPImport
echo ~[=]~ StarSwap will now import your Modded save from backup...
TIMEOUT /T 3 /NOBREAK
color 0E
robocopy "%modsaveloc%\" "%modsave%\save" /E /NJH /NJS
IF NOT EXIST "%modsaveloc%" mkdir "%modsaveloc%"
color 07
goto:setupVBKUPPostImport

:setupVBKUPPostImport
cls
echo ~[!]~ Finished importing your Modded save.
pause
goto:setupFIN

:: END UNUSED CODE "Setup Modded import Subsequence"	

:setupFIN
cls
echo ~[!]~ StarSwap has been set up.
pause
goto:premain

:: End Setup Sequence

:premain
set /p state=<"%APPDATA%\StarSwap\state.txt"
set "mainPick=="
if "%state%"=="modded" set notstate=vanilla
if "%state%"=="vanilla" set notstate=modded
if "%state%"=="notset" goto:errorStateNotSet
goto:main

:: Begin Menus

:main
cls
color 07
echo STARSWAP - Swap between your Vanilla/Modded saves easily.
echo Version %ver% - Current state is %state%. System architecture is %sysarch%.
echo [1] Run StarSwap to %notstate%.
echo [2] Backup loaded/unloaded saves, or mods.
echo [3] Settings.
echo [4] About StarSwap.
echo [5] Exit.
set /p mainPick=Selected option:
if "%mainPick%"=="1" goto:ssInit
if "%mainPick%"=="2" goto:BKUPstatecheck
if "%mainPick%"=="3" goto:settings
if "%mainPick%"=="4" goto:aboutSS
if "%mainPick%"=="5" goto:cleanExit
if "%mainPick%"=="" goto:main
goto:main

:settings
set "settingsPick=="
cls
echo STARSWAP Settings - Version %ver% - Current state is %state%.
echo [1] Open StarSwap data folder.
echo [2] Launch/Kill wsModMonitor.
echo [3] Return to Menu.
set /p settingsPick=Selected option:
if "%settingsPick%"=="1" goto:openDataFolder
if "%settingsPick%"=="2" goto:utilwsModMonitor
if "%settingsPick%"=="3" goto:premain
if "%settingsPick%"=="4" goto:debugMenu
if "%settingsPick%"=="" goto:settings
goto:settings

:debugMenu
set "debugPick=="
cls
echo STARSWAP Debug Menu - Version %ver% - Current state is %state%.
echo [1] Manually switch states.
echo [2] Manually enter a command.
echo [3] Return to Settings.
set /p debugPick=Selected option:
if "%debugPick%"=="1" goto:manualSwapPre
if "%debugPick%"=="2" goto:debugCMD
if "%debugPick%"=="3" goto:settings
if "%debugPick%"=="" goto:debugMenu
goto:debugMenu

:BKUPstatecheck
if %state%==modded goto:BKUPmoddedmenu
if %state%==vanilla goto:BKUPvanillamenu
goto:errorStateNotSet

:BKUPmoddedmenu
set "savemod=="
cls
echo STARSWAP Backup - Starbound is currently modded.
echo [1] Backup loaded modded save.
echo [2] Backup loaded mods.
echo [3] Backup unloaded vanilla save.
echo [4] Return to menu.
set /p savemod=Selected option:
if "%savemod%"=="1" goto:BKUPloadModSaveCheck
if "%savemod%"=="2" goto:BKUPloadModsChk
if "%savemod%"=="3" goto:BKUPunloadVanSaveCheck
if "%savemod%"=="4" goto:premain
if "%savemod%"=="" goto:BKUPmoddedmenu
goto:BKUPmoddedmenu

:BKUPvanillamenu
set "savemod=="
cls
echo STARSWAP Backup - Starbound is currently vanilla.
echo [1] Backup loaded vanilla save.
echo [2] Backup unloaded modded save.
echo [3] Backup unloaded mods.
echo [4] Return to menu.
set /p savemod=Selected option:
if "%savemod%"=="1" goto:BKUPloadVanSaveCheck
if "%savemod%"=="2" goto:BKUPunloadModSaveCheck
if "%savemod%"=="3" goto:BKUPunloadModsChk
if "%savemod%"=="4" goto:premain
if "%savemod%"=="" goto:BKUPvanillamenu
goto:BKUPvanillamenu

:: End Menus

:: Begin Menu Functions

:openDataFolder
call:openData
goto:settings

:manualSwapPre
cls
echo ~[!]~ Are you sure you want to manually switch states from "%state%" to "%notstate%"?
echo [1] Yes
echo [2] No
set /p swapConfirm=Selected option:
if "%swapConfirm%"=="1" goto:manualSwap
if "%swapConfirm%"=="2" goto:settings

:manualSwap
echo %notstate%>"%APPDATA%\StarSwap\state.txt"
set /p state=<"%APPDATA%\StarSwap\state.txt"
cls
echo ~[!]~ State has been set to %state%.
pause
goto:premain

:debugCMD
cls
echo ~[?]~ Enter a debug command here. If you don't know what this is, just press Enter.
set /p debugCMD=
%debugCMD%
pause
set "debugCMD="
goto:debugMenu

:utilwsModMonitor
if %state%==modded goto:errorwsModded
tasklist /FI "WINDOWTITLE eq Administrator:  StarSwap wsModMonitor" 2>NUL | find /I /N "cmd.exe">NUL
if "%ERRORLEVEL%"=="0" goto:utilwsModMonitorKill
goto:utilwsModMonitorLaunch


:utilwsModMonitorLaunch
START "wsModMonitor" "%APPDATA%\StarSwap\wsModMonitor.bat"
goto:settings

:utilwsModMonitorKill
TASKKILL /FI "WINDOWTITLE eq Administrator:  StarSwap wsModMonitor"
goto:settings

:: End Menu Functions

:: Begin main StarSwap program

:ssInit
cls
echo ~[=]~ Checking for running Starbound process...
color 0E
TASKLIST /FI "IMAGENAME eq starbound.exe" /FO CSV | FIND /I /N "starbound.exe"
echo %errorlevel%
if "%errorlevel%"=="0" goto:ssRunning
if "%errorlevel%"=="1" goto:ssNoRun

:: Begin Starbound taskkill

:ssRunning
set "errorlevel="
cls
color 07
echo ~[?]~ Starbound is currently running. Is it okay to close?
echo ~[!]~ (Make sure you're not currently in game!!)
echo [1] Yes
echo [2] No
set /p yesno=Selected option:
if "%yesno%"=="1" goto:ssClose
if "%yesno%"=="2" goto:errorSBrun
goto:ssRunning

:ssClose
cls
color 0E
echo ~[=]~ Closing Starbound...
TASKKILL /IM starbound.exe
echo ~[=]~ Waiting for Steam...
TIMEOUT /T 7 /NOBREAK
cls
color 07
echo ~[!]~ Starbound has been closed.
pause
goto:ssMS

:ssNoRun
color 07
set "errorlevel="
goto:ssMS

:: End Starbound taskkill

:: Begin main sequence

:ssMS
cls
color 0E
echo ~[=]~ Reading state.txt. . .
call:readState
color 07
if %state%==notset goto:errorStateNotSet
if %state%==modded goto:ssModdedSeq
if %state%==vanilla goto:ssVanillaSeq
goto:errorStateNotSet

:: Begin StarSwap Modded Sequence

:ssModdedSeq
cls
echo ~[!]~ StarSwap will now get ready to swap from %state% to %notstate%...
pause
goto:ssMconfCheck

:ssMconfCheck
cls
IF EXIST "%steamdir%\steamapps\common\Starbound\storage\starbound.config" goto:ssMBKUPsaveCheck
goto:errorssNoSave

:: Begin StarSwap auto modded save backup.

:ssMBKUPsaveCheck
call:getTime
IF EXIST "%backup%\%curmonth%-%curday%-%curyear%\moddedsave\starbound.config" goto:ssMsaveImport
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\moddedsave\starbound.config" goto:ssMBKUPsaveask

:ssMBKUPsaveask
cls
echo ~[?]~ Would you like to backup your current Modded save?
echo [1] Yes
echo [2] No
set /p askbackup=Selected option:
if %askbackup%==1 goto:ssMBKUPsave
if %askbackup%==2 goto:ssMsaveImport

:ssMBKUPsave
call:fBKUPloadModSave
cls
echo ~[!]~ StarSwap backed up your Modded save successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:ssMsaveImport

:: End StarSwap auto modded save backup.

:ssMsaveImport
cls
echo ~[=]~ StarSwap will now unload your Modded save...
TIMEOUT /T 3 /NOBREAK
color 0E
robocopy "%steamdir%\steamapps\common\Starbound\storage" "%modsave%\save" /MOVE /E /NJH /NJS
IF NOT EXIST "%steamdir%\steamapps\common\Starbound\storage" mkdir "%steamdir%\steamapps\common\Starbound\storage"	
color 07
goto:ssMsavePostImport

:ssMsavePostImport
cls
echo ~[!]~ StarSwap unloaded your Modded save successfully.
pause
goto:ssMBKUPmodsCheck

:: Begin StarSwap auto mod backup.

:ssMBKUPmodsCheck
call:getTime
dir /b /ad "%backup%\%curmonth%-%curday%-%curyear%\wsmods\*" | >nul findstr "^" && (set modws=nonempty) || (set modws=empty)
if %modws%==nonempty goto:ssMmodImport
if %modws%==empty goto:ssMBKUPmodsAsk
goto:errorPlaceholder

:ssMBKUPmodsask
cls
echo ~[?]~ Would you like to backup your current mods?
echo [1] Yes
echo [2] No
set /p askbackup=Selected option:
if %askbackup%==1 goto:ssMBKUPmods
if %askbackup%==2 goto:ssMmodImport

:ssMBKUPmods
call:fBKUPloadMods
cls
color 07
echo ~[!]~ StarSwap backed up your mods successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:ssMmodImport

:: End StarSwap auto mod backup.

:ssMmodImport
cls
echo ~[=]~ StarSwap will now unload your Starbound mods...
TIMEOUT /T 3 /NOBREAK
color 0E
robocopy "%steamdir%\steamapps\workshop\content\211820" "%modsave%\mods" /MOVE /E /NJH /NJS /XO
START "wsModMonitor" "%APPDATA%\StarSwap\wsModMonitor.bat"
color 07
goto:ssMmodPostImport

:ssMmodPostImport
attrib +R "%steamdir%\steamapps\workshop\content\211820" /S /D
attrib +R "%steamdir%\steamapps\workshop\appworkshop_211820.acf" /S
IF NOT EXIST "%steamdir%\steamapps\workshop\content\211820" mkdir "%steamdir%\steamapps\workshop\content\211820"
cls
echo ~[!]~ StarSwap unloaded your Starbound mods successfully. wsModMonitor has been launched.
pause	
goto:ssMvanSaveCheck

:ssMvanSaveCheck
IF EXIST "%vanillasave%\save\starbound.config" goto:ssMBKUPunlsaveCheck
IF NOT EXIST "%vanillasave%\save\starbound.config" goto:ssMnoSave

:ssMnoSave
cls
echo ~[!]~ StarSwap cannot find an unloaded Vanilla save.
echo ~[?]~ Would you like to have a new save, or import a previous save?
echo [1] New save
echo [2] Import save
set /p newimp=Selected option:
if "%newimp%"=="1" goto:ssMnewSave
if "%newimp%"=="2" goto:ssMyesBKUPExport

:ssMnewSave
echo ~[!]~ Chosen not to import a save.
goto:ssModdedComplete

:: Begin Vanilla backup save loading

:ssMyesBKUPExport
cls
echo ~[?]~ Where is your current Vanilla save?
echo   Example:
echo       C:\Users\username\Documents\StarboundBackup
echo   Contents of folder should look like this!
echo   + StarboundBackup
echo     + \player\
echo     + \universe\
echo     ~ starbound.config
echo     ~ starbound.log
echo   Make sure folder has NO other data!
set /p vansaveloc=Location of directory:
cls
echo ~[?]~ Is this location correct?
echo %vansaveloc%
echo [1] Yes
echo [2] No
set /p confirm=Selected option:
if %confirm%==1 goto:ssMvanBKUPSaveCheck
if %confirm%==2 goto:ssMyesBKUPExport
goto:ssMyesBKUPExport

:ssMvanBKUPSaveCheck
if exist "%vansaveloc%\starbound.config" goto:ssMvanBKUPSaveFix
if exist "%vansaveloc%starbound.config" goto:ssMvanBKUPExport
goto:errorBKUPExportVNF

:ssMvanBKUPSaveFix
set vansaveloc=%vansaveloc%\
goto:ssMvanBKUPExport

:ssMvanBKUPExport
cls
echo ~[=]~ StarSwap will now load your Vanilla save from backup...
TIMEOUT /T 3 /NOBREAK
color 0E
robocopy "%vansaveloc%\" "%steamdir%\steamapps\common\Starbound\storage" /E /NJH /NJS
IF NOT EXIST "%vansaveloc%" mkdir %vansaveloc%"
color 07
goto:ssMvanBKUPPostExport

:ssMvanBKUPPostExport
cls
echo ~[!]~ StarSwap loaded your Starbound backup successfully.
pause
goto:ssModdedComplete

:: End Vanilla backup save loading.

:: Begin StarSwap auto Vanilla backup.

:ssMBKUPunlsaveCheck
call:getTime
IF EXIST "%backup%\%curmonth%-%curday%-%curyear%\vanillasave\starbound.config" goto:ssMsaveExport
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\vanillasave\starbound.config" goto:ssMBKUPunlsaveask

:ssMBKUPunlsaveask
cls
echo ~[?]~ Would you like to backup your current Vanilla save?
echo [1] Yes
echo [2] No
set /p askbackup=Selected option:
if %askbackup%==1 goto:ssMBKUPunlsave
if %askbackup%==2 goto:ssMsaveExport

:ssMBKUPunlsave
call:fBKUPunloadVanSave
cls
echo ~[!]~ StarSwap backed up your Vanilla save successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:ssMsaveExport

:: End StarSwap auto Vanilla backup.

:: Begin Vanilla save loading.

:ssMsaveExport
cls
echo ~[=]~ StarSwap will now load your Vanilla save...
TIMEOUT /T 3 /NOBREAK	
color 0E
robocopy "%vanillasave%\save" "%steamdir%\steamapps\common\Starbound\storage" /MOVE /E /NJH /NJS
IF NOT EXIST "%vanillasave%\save" mkdir "%vanillasave%\save"
color 07
goto:ssMsavePostExport

:ssMsavePostExport
cls
echo ~[!]~ StarSwap loaded your Vanilla save successfully.
pause
goto:ssModdedComplete

:: End Vanilla save loading.

:ssModdedComplete
cls
echo vanilla>"%APPDATA%\StarSwap\state.txt"
echo ~[!]~ Successfully swapped between your two configurations!
pause
goto:premain

:: End StarSwap Modded Sequence

:: Begin StarSwap Vanilla Sequence

:ssVanillaSeq
cls
echo ~[!]~ StarSwap will now get ready to swap from %state% to %notstate%...
pause
goto:ssVconfCheck

:ssVconfCheck
cls
IF EXIST "%steamdir%\steamapps\common\Starbound\storage\starbound.config" goto:ssVBKUPsaveCheck
IF NOT EXIST "%steamdir%\steamapps\common\Starbound\storage\starbound.config" goto:ssVnoSaveFound

:ssVnoSaveFound
cls
echo ~[!]~ StarSwap did not detect an unloaded Starbound save. Assuming new, blank save...
pause
goto:ssVBKUPmodsask

:: Begin StarSwap auto vanilla save backup.

:ssVBKUPsaveCheck
call:getTime
IF EXIST "%backup%\%curmonth%-%curday%-%curyear%\vanillasave\starbound.config" goto:ssVsaveImport
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\vanillasave\starbound.config" goto:ssVBKUPsaveask

:ssVBKUPsaveask
cls
echo ~[?]~ Would you like to backup your current Vanilla save?
echo [1] Yes
echo [2] No
set /p askbackup=Selected option:
if %askbackup%==1 goto:ssVBKUPsave
if %askbackup%==2 goto:ssVsaveImport

:ssVBKUPsave
call:fBKUPloadVansave
cls
echo ~[!]~ StarSwap backed up your Vanilla save successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:ssVsaveImport

:: End StarSwap auto vanilla save backup.

:ssVsaveImport
cls
echo ~[=]~ StarSwap will now unload your Vanilla save...
TIMEOUT /T 3 /NOBREAK
color 0E
robocopy "%steamdir%\steamapps\common\Starbound\storage" "%vanillasave%\save" /MOVE /E /NJH /NJS
IF NOT EXIST "%steamdir%\steamapps\common\Starbound\storage" mkdir "%steamdir%\steamapps\common\Starbound\storage"	
color 07
goto:ssVsavePostImport

:ssVsavePostImport
cls
echo ~[!]~ StarSwap unloaded your Vanilla save successfully.
pause
goto:ssVBKUPmodsCheck

:: Begin StarSwap auto mod backup.

:ssVBKUPmodsCheck
call:getTime
dir /b /ad "%backup%\%curmonth%-%curday%-%curyear%\wsmods\*" | >nul findstr "^" && (set modws=nonempty) || (set modws=empty)
if %modws%==nonempty goto:ssVmodExport
if %modws%==empty goto:ssVBKUPmodsAsk
goto:errorPlaceholder

:ssVBKUPmodsask
cls
echo ~[?]~ Would you like to backup your current mods?
echo [1] Yes
echo [2] No
set /p askbackup=Selected option:
if %askbackup%==1 goto:ssVBKUPmods
if %askbackup%==2 goto:ssVmodExport

:ssVBKUPmods
call:fBKUPunloadMods
cls
color 07
echo ~[!]~ StarSwap backed up your mods successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:ssVmodExport

:: End StarSwap auto mod backup.

:ssVmodExport
cls
echo ~[=]~ StarSwap will now kill wsModMonitor and load your Starbound mods...
TIMEOUT /T 3 /NOBREAK
color 0E
TASKKILL /FI "WINDOWTITLE eq Administrator:  StarSwap wsModMonitor"
robocopy "%modsave%\mods" "%steamdir%\steamapps\workshop\content\211820" /MOVE /E /NJH /NJS /XO
IF NOT EXIST "%modsave%\mods" mkdir "%modsave%\mods"
color 07
goto:ssVmodPostExport

:ssVmodPostExport
attrib -R "%steamdir%\steamapps\workshop\content\211820" /S /D
attrib -R "%steamdir%\steamapps\workshop\appworkshop_211820.acf" /S
cls
echo ~[!]~ StarSwap loaded your Starbound mods successfully.
pause
goto:ssVmodSaveCheck

:ssVmodSaveCheck
IF EXIST "%modsave%\save\starbound.config" goto:ssVBKUPunlsaveCheck
IF NOT EXIST "%modsave%\save\starbound.config" goto:ssVnoSave

:ssVnoSave
cls
echo ~[!]~ StarSwap cannot find an unloaded modded save.
echo ~[?]~ Would you like to have a new save, or import a previous save?
echo [1] New save
echo [2] Import save
set /p newimp=Selected option:
if "%newimp%"=="1" goto:ssVnewSave
if "%newimp%"=="2" goto:ssVyesBKUPExport

:ssVnewSave
echo ~[!]~ Chosen not to import a save.
goto:ssVanillaComplete

:: Begin Modded backup save loading

:ssVyesBKUPExport
cls
echo ~[?]~ Where is your current Modded save?
echo   Example:
echo       C:\Users\username\Documents\StarboundModdedBackup
echo   Contents of folder should look like this!
echo   + StarboundModdedBackup
echo     + \player\
echo     + \universe\
echo     ~ starbound.config
echo     ~ starbound.log
echo   Make sure folder has NO other data!
set /p modsaveloc=Location of directory:
cls
echo ~[?]~ Is this location correct?
echo [1] Yes
echo [2] No
echo %modsaveloc%
set /p confirm=Selected option:
if %confirm%==1 goto:ssVmodBKUPSaveCheck
if %confirm%==2 goto:ssVyesBKUPExport
goto:ssVyesBKUPExport

:ssVmodBKUPSaveCheck
if exist "%modsaveloc%\starbound.config" goto:ssVmodBKUPSaveFix
if exist "%modsaveloc%starbound.config" goto:ssVmodBKUPExport
goto:errorBKUPExportMNF

:ssVmodBKUPSaveFix
set modsaveloc=%modsaveloc%\
goto:ssVmodBKUPExport

:ssVmodBKUPExport
cls
echo ~[=]~ StarSwap will now load your Modded save from backup...
TIMEOUT /T 3 /NOBREAK
color 0E
robocopy "%modsaveloc%\" "%steamdir%\steamapps\common\Starbound\storage" /E /NJH /NJS
IF NOT EXIST "%modsaveloc%" mkdir "%modsaveloc%"
color 07
goto:ssVmodBKUPPostExport

:ssVmodBKUPPostExport
cls
echo ~[!]~ StarSwap loaded your Starbound backup successfully.
pause
goto:ssVanillaComplete

:: End Modded backup save loading

:: Begin StarSwap auto Modded backup.

:ssVBKUPunlsaveCheck
call:getTime
IF EXIST "%backup%\%curmonth%-%curday%-%curyear%\moddedsave\starbound.config" goto:ssVsaveExport
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\moddedsave\starbound.config" goto:ssVBKUPunlsaveask

:ssVBKUPunlsaveask
cls
echo ~[?]~ Would you like to backup your current Modded save?
echo [1] Yes
echo [2] No
set /p askbackup=Selected option:
if %askbackup%==1 goto:ssVBKUPunlsave
if %askbackup%==2 goto:ssVsaveExport

:ssVBKUPunlsave
call:fBKUPunloadModSave
cls
echo ~[!]~ StarSwap backed up your Modded save successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:ssVsaveExport

:: End StarSwap audo Modded backup.

:: Begin Modded save loading.

:ssVsaveExport
cls
echo ~[=]~ StarSwap will now load your Modded save...
TIMEOUT /T 3 /NOBREAK	
color 0E
robocopy "%modsave%\save" "%steamdir%\steamapps\common\Starbound\storage" /MOVE /E /NJH /NJS
IF NOT EXIST "%modsave%\save" mkdir "%modsave%\save"
color 07
goto:ssVsavePostExport

:ssVsavePostExport
cls
echo ~[!]~ StarSwap loaded your Modded save successfully.
pause
goto:ssVanillaComplete

:: End Modded save loading.

:ssVanillaComplete
cls
echo modded>"%APPDATA%\StarSwap\state.txt"
echo ~[!]~ Successfully swapped between your two configurations!
pause
goto:premain

:: End Starswap Vanilla Sequence

:: End main StarSwap Sequence

:: End main StarSwap program

:: Begin backup script.

:: Begin loaded modded save Backup subscript.

:BKUPloadModSaveCheck
call:getTime
IF EXIST "%backup%\%curmonth%-%curday%-%curyear%\moddedsave\starbound.config" goto:BKUPloadModSaveWarn
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\moddedsave\starbound.config" goto:BKUPloadModSave

:BKUPloadModSaveWarn
cls
echo ~[?]~ A backup already exists in the destination directory. Is it okay to overwrite this backup?
echo %backup%\%curmonth%-%curday%-%curyear%\moddedsave\
echo [1] Yes
echo [2] No
set /p confirm=Selected option:
if %confirm%==1 goto:BKUPloadModSavePurge
if %confirm%==2 goto:BKUPmoddedmenu
goto:BKUPloadModSaveWarn

:BKUPloadModSavePurge
cls
echo ~[=]~ Removing old backup...
color 0E
rmdir /s /q "%backup%\%curmonth%-%curday%-%curyear%\moddedsave\"
color 07
goto:BKUPloadModSave

:BKUPloadModSave
call:fBKUPloadModSave
cls
echo ~[!]~ StarSwap backed up your Modded save successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:BKUPmoddedmenu

:: End loaded modded save Backup subscript.

:: Begin loaded vanilla save Backup subscript.

:BKUPloadVanSaveCheck
call:getTime
IF EXIST "%backup%\%curmonth%-%curday%-%curyear%\vanillasave\starbound.config" goto:BKUPloadVanSaveWarn
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\vanillasave\starbound.config" goto:BKUPloadVanSave

:BKUPloadVanSaveWarn
cls
echo ~[?]~ A backup already exists in the destination directory. Is it okay to overwrite this backup?
echo %backup%\%curmonth%-%curday%-%curyear%\vanillasave\
echo [1] Yes
echo [2] No
set /p confirm=Selected option:
if %confirm%==1 goto:BKUPloadVansavePurge
if %confirm%==2 goto:BKUPvanillamenu
goto:BKUPloadVanSaveWarn

:BKUPloadVanSavePurge
cls
echo ~[=]~ Removing old backup...
color 0E
rmdir /s /q "%backup%\%curmonth%-%curday%-%curyear%\vanillasave\"
color 07
goto:BKUPloadVanSave

:BKUPloadVanSave
call:fBKUPloadVanSave
cls
echo ~[!]~ StarSwap backed up your Vanilla save successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:BKUPvanillamenu

:: End loaded vanilla save Backup subscript.

:: Begin unloaded mod save Backup subscript.

:BKUPunloadModSaveCheck
call:getTime
IF NOT EXIST "%modsave%\save\starbound.config" goto:errorBKUPunloadModSNF
IF EXIST "%backup%\%curmonth%-%curday%-%curyear%\moddedsave\starbound.config" goto:BKUPunloadModSaveWarn
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\moddedsave\starbound.config" goto:BKUPunloadModSave

:BKUPunloadModSaveWarn
cls
echo ~[?]~ A backup already exists in the destination directory. Is it okay to overwrite this backup?
echo %backup%\%curmonth%-%curday%-%curyear%\moddedsave\
echo [1] Yes
echo [2] No
set /p confirm=Selected option:
if %confirm%==1 goto:BKUPunloadModSavePurge
if %confirm%==2 goto:BKUPmoddedmenu
goto:BKUPunloadModSaveWarn

:BKUPunloadModSavePurge
cls
echo ~[=]~ Removing old backup...
color 0E
rmdir /s /q "%backup%\%curmonth%-%curday%-%curyear%\moddedsave\"
color 07
goto:BKUPunloadModSave

:BKUPunloadModSave
call:fBKUPunloadModSave
cls
echo ~[!]~ StarSwap backed up your Modded save successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:BKUPvanillamenu

:: End unloaded mod save Backup subscript.

:: Begin unloaded vanilla save Backup subscript.

:BKUPunloadVanSaveCheck
call:getTime
IF NOT EXIST "%vanillasave%\save\starbound.config" goto:errorBKUPunloadVanSNF
IF EXIST "%backup%\%curmonth%-%curday%-%curyear%\vanillasave\starbound.config" goto:BKUPunloadVanSaveWarn
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\vanillasave\starbound.config" goto:BKUPunloadVanSave

:BKUPunloadVanSaveWarn
cls
echo ~[?]~ A backup already exists in the destination directory. Is it okay to overwrite this backup?
echo %backup%\%curmonth%-%curday%-%curyear%\vanillasave\
echo [1] Yes
echo [2] No
set /p confirm=Selected option:
if %confirm%==1 goto:BKUPunloadVanSavePurge
if %confirm%==2 goto:BKUPvanillamenu
goto:BKUPunloadVanSaveWarn

:BKUPunloadVanSavePurge
cls
echo ~[=]~ Removing old backup...
color 0E
rmdir /s /q "%backup%\%curmonth%-%curday%-%curyear%\vanillasave\"
color 07
goto:BKUPunloadVanSave

:BKUPunloadVanSave
call:fBKUPunloadVanSave
cls
echo ~[!]~ StarSwap backed up your Vanilla save successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:BKUPmoddedmenu

:: End unloaded vanilla save Backup subscript.

:: Begin loaded mods Backup subscript.

:BKUPloadModsChk
call:getTime
dir /b /ad "%backup%\%curmonth%-%curday%-%curyear%\wsmods\*" | >nul findstr "^" && (set modws=nonempty) || (set modws=empty)
if %modws%==nonempty goto:BKUPloadModsWarn
if %modws%==empty goto:BKUPloadModsMain
goto:errorPlaceholder

:BKUPloadModsWarn
cls
echo ~[?]~ A backup already exists in the destination directory. Is it okay to overwrite this backup?
echo %backup%\%curmonth%-%curday%-%curyear%\wsmods
echo [1] Yes
echo [2] No
set /p confirm=Selected option:
if %confirm%==1 goto:BKUPloadModsPurge
if %confirm%==2 goto:BKUPmoddedmenu
goto:BKUPloadModsWarn

:BKUPloadModsPurge
cls
echo ~[=]~ Removing old backup...
color 0E
rmdir /s /q "%backup%\%curmonth%-%curday%-%curyear%\wsmods"
color 07
goto:BKUPloadModsMain

:BKUPloadModsMain
call:fBKUPloadMods
cls
color 07
echo ~[!]~ StarSwap backed up your mods successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:BKUPmoddedmenu

:: End loaded mods Backup subscript.

:: Begin unloaded mods Backup subscript.

:BKUPunloadModsChk
call:getTime
dir /b /ad "%backup%\%curmonth%-%curday%-%curyear%\wsmods\*" | >nul findstr "^" && (set modws=nonempty) || (set modws=empty)
if %modws%==nonempty goto:BKUPunloadModsWarn
if %modws%==empty goto:BKUPunloadModsMain
goto:errorPlaceholder

:BKUPunloadModsWarn
cls
echo ~[?]~ A backup already exists in the destination directory. Is it okay to overwrite this backup?
echo %backup%\%curmonth%-%curday%-%curyear%\wsmods
echo [1] Yes
echo [2] No
set /p confirm=Selected option:
if %confirm%==1 goto:BKUPunloadModsPurge
if %confirm%==2 goto:BKUPvanillamenu
goto:BKUPunloadModsWarn

:BKUPunloadModsPurge
cls
echo ~[=]~ Removing old backup...
color 0E
rmdir /s /q "%backup%\%curmonth%-%curday%-%curyear%\wsmods\"
color 07
goto:BKUPunloadModsMain

:BKUPunloadModsMain
call:fBKUPunloadMods
cls
color 07
echo ~[!]~ StarSwap backed up your mods successfully.
echo ~[!]~ You can find your backups in StarSwap's data files, in Settings.
pause
goto:BKUPvanillamenu

:: End unloaded mods Backup subscript.

:: End backup script.

:: Begin miscellaneous 

:aboutSS
cls
echo ~[?]~ StarSwap - Version %ver% - by wistlyr
echo A batch script to swap, backup, and restore Vanilla/Modded Starbound saves.
echo Created for the nutshacks over at Dispenz0r's Fun Server.
echo Check me out on Github! https://github.com/wistlyr/
pause
goto:premain

:: End miscellaneous

:: Begin error returns

:errorPlaceholder
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: Generic error. A command likely failed to execute.
echo ~[?]~ If you see this error, please report it on GitHub. https://github.com/wistlyr/StarSwap
pause
goto:cleanExit

:errorSetup
cls
color 0C
echo ~[!]~ StarSwap setup has been cancelled.
pause
goto:cleanExit

:errorSetupVanillaNF
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap was unable to find Starbound files in this directory.
pause
color 07
goto:setupMvanBKUPImport

:errorSetupModdedNF
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap was unable to find Starbound files in this directory.
pause
color 07
goto:setupVmodBKUPImport

:errorBKUPExportVNF
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap was unable to find Starbound files in this directory.
pause
color 07
goto:ssMyesBKUPExport

:errorBKUPExportMNF
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap was unable to find Starbound files in this directory.
pause
color 07
goto:ssVyesBKUPExport

:errorBKUPunloadVanSNF
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap was unable to find Starbound files in this directory.
pause
color 07
goto:BKUPmoddedmenu

:errorBKUPunloadModSNF
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap was unable to find Starbound files in this directory.
pause
color 07
goto:BKUPvanillamenu

:errorssNoSave
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap was unable to find starbound.config. Please launch Starbound and try again.
pause
goto:cleanExit

:errorSBrun
cls
color 0C
echo ~[!]~ Please close Starbound and try again.
pause
goto:cleanExit

:errorStateNotSet
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: State not set. Please restart StarSwap.
pause
goto:cleanExit

:errorInvalidC
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: Invalid choice.

:errorOSXP
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap does not support Windows XP.
pause
exit

:errormissingDependency
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap cannot find wsModMonitor. Did you move it?
echo ~[?]~ Please return it to %~dp0, and press any key to try again.
pause
goto:setupwsModMonitor

:errorwsModded
cls
color 0C
echo ~[!]~ An error has occured.
echo ~[!]~ Error: StarSwap cannot launch wsModMonitor if the current state is Modded.
echo ~[?]~ Please swap to Vanilla before launching wsModMonitor.
pause
color 07
goto:settings

:: End error returns

:: Begin BKUP Function group

:fBKUPloadModSave
cls
echo ~[=]~ StarSwap will now backup your loaded Modded save...
TIMEOUT /T 3 /NOBREAK
color 0E
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%" mkdir "%backup%\%curmonth%-%curday%-%curyear%"
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\moddedsave" mkdir "%backup%\%curmonth%-%curday%-%curyear%\moddedsave"
robocopy "%steamdir%\steamapps\common\Starbound\storage" "%backup%\%curmonth%-%curday%-%curyear%\moddedsave" /E /NJH /NJS
IF NOT EXIST "%steamdir%\steamapps\common\Starbound\storage" mkdir "%steamdir%\steamapps\common\Starbound\storage"
color 07
goto:eof

:fBKUPloadVanSave
cls
echo ~[=]~ StarSwap will now backup your loaded Vanilla save...
TIMEOUT /T 3 /NOBREAK
color 0E
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%" mkdir "%backup%\%curmonth%-%curday%-%curyear%"
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\vanillasave" mkdir "%backup%\%curmonth%-%curday%-%curyear%\vanillasave"
robocopy "%steamdir%\steamapps\common\Starbound\storage" "%backup%\%curmonth%-%curday%-%curyear%\vanillasave" /E /NJH /NJS
IF NOT EXIST "%steamdir%\steamapps\common\Starbound\storage" mkdir "%steamdir%\steamapps\common\Starbound\storage"
color 07
goto:eof

:fBKUPunloadModSave
cls
echo ~[=]~ StarSwap will now backup your unloaded Modded save...
TIMEOUT /T 3 /NOBREAK
color 0E
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%" mkdir "%backup%\%curmonth%-%curday%-%curyear%"
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\moddedsave" mkdir "%backup%\%curmonth%-%curday%-%curyear%\moddedsave"
robocopy "%modsave%\save" "%backup%\%curmonth%-%curday%-%curyear%\moddedsave" /E /NJH /NJS
IF NOT EXIST "%modsave%\save" mkdir "%modsave%\save"
color 07
goto:eof

:fBKUPunloadVanSave
cls
echo ~[=]~ StarSwap will now backup your unloaded Vanilla save...
TIMEOUT /T 3 /NOBREAK
color 0E
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%" mkdir "%backup%\%curmonth%-%curday%-%curyear%"
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\vanillasave" mkdir "%backup%\%curmonth%-%curday%-%curyear%\moddedsave"
robocopy "%vanillasave%\save" "%backup%\%curmonth%-%curday%-%curyear%\vanillasave" /E /NJH /NJS
IF NOT EXIST "%vanillasave%\save" mkdir "%vanillasave%"
color 07
goto:eof

:fBKUPloadMods
cls
echo ~[=]~ StarSwap will now backup your loaded mods...
TIMEOUT /T 3 /NOBREAK
color 0E
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%" mkdir "%backup%\%curmonth%-%curday%-%curyear%"
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\wsmods" mkdir "%backup%\%curmonth%-%curday%-%curyear%\wsmods"
robocopy "%steamdir%\steamapps\workshop\content\211820" "%backup%\%curmonth%-%curday%-%curyear%\wsmods" /E /NJH /NJS
IF NOT EXIST "%steamdir%\steamapps\workshop\content\211820" mkdir "%steamdir%\steamapps\workshop\content\211820"
goto:eof

:fBKUPunloadMods
cls
echo ~[=]~ StarSwap will now backup your unloaded mods...
TIMEOUT /T 3 /NOBREAK
color 0E
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%" mkdir "%backup%\%curmonth%-%curday%-%curyear%"
IF NOT EXIST "%backup%\%curmonth%-%curday%-%curyear%\wsmods" mkdir "%backup%\%curmonth%-%curday%-%curyear%\wsmods"
robocopy "%modsave%\mods" "%backup%\%curmonth%-%curday%-%curyear%\wsmods" /E /NJH /NJS
IF NOT EXIST "%modsave%\mods" mkdir "%modsave%\mods"
goto:eof

:: End BKUP Function group

:: Begin Function group

:readState
set /p state=<"%APPDATA%\StarSwap\state.txt"
goto:eof

:openData
%SystemRoot%\explorer.exe "%appdata%\StarSwap\"
goto:eof

:getTime
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /format:list') do set datetime=%%I
set curmonth=%datetime:~4,2%
set curday=%datetime:~6,2%
set curyear=%datetime:~0,4%
goto:eof

:getOSVersion
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
goto:eof

:: End Function group

:cleanExit
color 07
cls
set "errorlevel="
exit /b 0

:eof
EXIT /b 0
