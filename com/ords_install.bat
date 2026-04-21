set ORDS_HOME=c:\app\ords
set ORDS_CONFIG=%ORDS_HOME%\config
set ORDS_LOGS=%ORDS_HOME%\logs
set DB_HOSTNAME=localhost
set DB_PORT=1521
set DB_SERVICE=FREEPDB1
set SYSDBA_USER=SYS

%ORDS_HOME%\bin\ords.exe ^
  --config %ORDS_CONFIG% install ^
  --log-folder %ORDS_LOGS% ^
  --admin-user %SYSDBA_USER% ^
  --db-hostname %DB_HOSTNAME% ^
  --db-port %DB_PORT% ^
  --db-servicename %DB_SERVICE% ^
  --feature-db-api true ^
  --feature-rest-enabled-sql true ^
  --feature-sdw true ^
  --gateway-mode proxied ^
  --gateway-user APEX_PUBLIC_USER ^
  --proxy-user