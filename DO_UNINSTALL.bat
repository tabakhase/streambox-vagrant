@echo off
setlocal enableDelayedExpansion
REM REM Normalize ENV
cd /d %~dp0

echo  - DO_UNINSTALL -

REM TODO make sure only ONE of me is running...

vagrant destroy

if errorlevel 1 (
	echo FAILURE! Vagrant destroy failed...
	goto forceEnd
)
echo VM deleted, you can now delete this folder by hand.
goto slowEnd





:forceEnd
echo ERROR: ForceEnding...
pause
goto softEnd

:slowEnd
timeout /t 5
goto softEnd

:softEnd
