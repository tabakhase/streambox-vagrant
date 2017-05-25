@echo off
setlocal enableDelayedExpansion
REM REM Normalize ENV
cd /d %~dp0

echo  - RECONFIGURE_STREAMS -

REM TODO make sure only ONE of me is running...

set STATE=unknown
for /f "tokens=2 delims= " %%F IN ('vagrant status ^| find /I "default"') DO (SET "STATE=%%F")
echo Vagrant status is: !STATE!
if "!STATE!" == "running" (
	ping -n 1 127.0.0.1 > NUL
	
	vagrant provision --provision-with nginx_config_main
	if errorlevel 1 (
		echo FAILURE!...
		goto forceEnd
	)
	
	vagrant provision --provision-with nginx_config_apply
	if errorlevel 1 (
		echo FAILURE!...
		goto forceEnd
	)
	
	goto slowEnd
) else (
	echo Vagrant is %STATE% - start it first...
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
