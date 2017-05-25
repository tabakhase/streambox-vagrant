@echo off
setlocal enableDelayedExpansion
REM REM Normalize ENV
cd /d %~dp0

echo  - DO_POWERON -

REM TODO make sure only ONE of me is running...

set STATE=unknown
for /f "tokens=2 delims= " %%F IN ('vagrant status ^| find /I "default"') DO (SET "STATE=%%F")
echo Vagrant status is: !STATE!
if "!STATE!" == "running" (
	echo System already !STATE!
	REM TODO check if watchdog running, start if not
	goto slowEnd

) else (

	ping -n 3 127.0.0.1 > NUL
	for /f "tokens=2 delims= " %%F IN ('vagrant status ^| find /I "default"') DO (SET "STATE=%%F")
	if "!STATE!" NEQ "saved" (
		echo Starting Vagrant VM from powered down state...
		vagrant up
	) else (
		echo Resuming Vagrant VM from saved state...
		vagrant resume
	)
	
	if errorlevel 1 (
		echo FAILURE! Vagrant VM unresponsive...
		goto forceEnd
	)
	
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
