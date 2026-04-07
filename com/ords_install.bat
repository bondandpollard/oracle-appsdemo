set ORDS_HOME=d:\ords-25.2.3.224.1517
set ORDS_CONFIG=\ords-25.2.3.224.1517\config
set ORDS_LOGS=%ORDS_CONFIG%\logs
set DB_HOSTNAME=localhost
set DB_PORT=1521
set DB_SERVICE=XEPDB1
set SYSDBA_USER=SYS

d:\ords-25.2.3.224.1517\bin\ords.exe ^
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