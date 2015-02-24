@ECHO OFF

:: Name:
::      Reboot-TerminalServer.cmd
::
:: Synopsis:
::      Reboots the terminal server after sending a warning
::
:: Author:
::      Frank Peter Schultze

SET WARNING_DELAY_SECONDS=600
SET REBOOT_DELAY_SECONDS=30

:: Get no. of sessions
CALL :CheckSessions

:: If there are sessions send warnings, wait, and force logoff afterwards
IF ERRORLEVEL 1 (
	CALL :SendWarning
	CALL :Sleep %WARNING_DELAY_SECONDS%
	CALL :ForceLogoff
)

:: Reboot
CALL :Reboot

:: Don't return to caller
CALL :Loop

EXIT /B

:CheckSessions
SETLOCAL
	FOR /F %%i IN ('quser ^| find ">%USERNAME% " /V ^| find "" /V /C') DO SET _=%%i
	SET /A _ -= 1
ENDLOCAL & EXIT /B %_%

:SendWarning
SETLOCAL
	SET /A _ = WARNING_DELAY_SECONDS - 30
	msg * /TIME:%_% /V Save your work and log off! The server will enter maintenance in less than %WARNING_DELAY_SECONDS% seconds.
ENDLOCAL & EXIT /B

:Sleep
	IF NOT "%1"=="" ping.exe -n %1 localhost >NUL
EXIT /B

:ForceLogoff
SETLOCAL ENABLEDELAYEDEXPANSION
	SET _=
	FOR /F "TOKENS=2,3" %%i IN ('quser ^| find /v ">%USERNAME% "') DO (
		ECHO %%j | findstr /R "[0-9]" >NUL
		IF ERRORLEVEL 1 (SET _=!_! %%i) ELSE (SET _=!_! %%j)
	)
	FOR %%i IN (%_%) DO logoff %%i /V
ENDLOCAL & EXIT /B

:Reboot
	shutdown /r /f /t %REBOOT_DELAY_SECONDS% /d p:4:1 /c "The server will reboot in less than %REBOOT_DELAY_SECONDS% seconds."
EXIT /B

:Loop
	PAUSE>NUL
GOTO :Loop
