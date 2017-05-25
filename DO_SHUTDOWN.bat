@echo off
setlocal enableDelayedExpansion
REM REM Normalize ENV
cd /d %~dp0

echo  - DO_SHUTDOWN -

REM TODO make sure only ONE of me is running...

set STATE=unknown
for /f "tokens=2 delims= " %%F IN ('vagrant status ^| find /I "default"') DO (SET "STATE=%%F")
echo Vagrant status is: !STATE!
if "!STATE!" == "running" (
	ping -n 1 127.0.0.1 > NUL
	
	vagrant halt

	if errorlevel 1 (
		echo FAILURE! Vagrant VM unresponsive...
		goto forceEnd
	)
	goto slowEnd
) else (
	echo ERROR: System is not running!
	goto slowEnd
)





:forceEnd
echo ERROR: ForceEnding...
pause
goto softEnd

:slowEnd
timeout /t 5
goto softEnd

:softEnd
