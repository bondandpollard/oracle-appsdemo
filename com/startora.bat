ECHO OFF
REM NAME: startora.bat
REM
REM DESCRIPTION
REM   Oracle application startup script.
REM     Configures the Oracle environment.
REM     Starts the database.
REM
REM INSTRUCTIONS
REM   Copy this batch file to your user login directory.
REM   Run this script from the Command Prompt.
REM
REM ---------------------------------------------------------------------------------------
REM MODIFICATION HISTORY
REM
REM Date         Name          Description
REM ---------------------------------------------------------------------------------------
REM 22/07/2022   Ian Bond      Created script
REM 20/04/2023   Ian Bond      Amend call to set_env.bat so that it does not prompt for the
REM                            connect_user password.

REM Setting evironment variables
CALL ..\config\SET_ENV.BAT STARTORA

ECHO Starting Oracle environment for database service %DBSERVICE% application %app_owner%

CD %app_home%
REM Set the command prompt to the application evironment name
PROMPT=%DBSERVICE%\%APP_OWNER%$G

REM Start the database
SQLPLUS / AS SYSDBA @%APP_HOME%\ADMIN\STARTUP.SQL %DBSERVICE% %APP_OWNER%

REM Do not close the Command Prompt window
CMD /K
