SET SERVEROUTPUT ON
BEGIN
  util_admin.log_message('Hello World - next line blank'); -- Hello World
  util_admin.log_message(); -- Display blank line
  util_admin.log_message('NOTHING DISPLAYED',NULL,NULL,'X',NULL); -- Mode X nothing is displayed, no blank line or message
  util_admin.log_message('Insert message into APPLOG nothing displayed',SQLERRM,'applog_demo.sql','F'); -- Mode F message inserted into APPLOG, nothing displayed
  util_admin.log_message('Verbose Warning',SQLERRM,'applog_demo.sql',NULL,'W'); -- Verbose warning message displayed
END;