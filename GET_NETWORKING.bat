@echo off
setlocal enableDelayedExpansion
REM REM Normalize ENV
cd /d %~dp0

echo  - GET_NETWORKING -

REM TODO make sure only ONE of me is running...

set STATE=unknown
for /f "tokens=2 delims= " %%F IN ('vagrant status ^| find /I "default"') DO (SET "STATE=%%F")
echo Vagrant status is: !STATE!
if "!STATE!" == "running" (
	ping -n 1 127.0.0.1 > NUL
	
	vagrant provision --provision-with get_networking
	
	
	if errorlevel 1 (
		echo FAILURE! Vagrant VM unresponsive...
		goto forceEnd
	)
	echo .
	echo .
	pause
	
	goto softEnd
) else (
	echo Vagrant is %STATE% start it first...
	goto forceEnd
)





:forceEnd
echo ERROR: ForceEnding...
pause
goto softEnd

:slowEnd
timeout /t 5
goto softEnd

:softEnd
