-- Check database service status
--
  SELECT instance_name, status, database_status, host_name, startup_time
  FROM v$instance;

