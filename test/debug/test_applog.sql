-- Test creating messaged on the APPLOG
--
SET SERVEROUTPUT ON
ACCEPT v_message  PROMPT "Enter a message to be placed on the log"
ACCEPT v_severity PROMPT "Severity? (I)nfo, (W)arning, (E)rror"
ACCEPT v_mode     PROMPT "Mode (S)creen, (F)ile or (B)oth"
ACCEPT v_sqlerrm  PROMPT "SQLERRM"
ACCEPT v_prog     PROMPT "Program Name"
BEGIN
  util_admin.log_message('FIRST LINE');
  util_admin.log_message('Hello World - next line blank');        -- Hello World
  util_admin.log_message();                                       -- Display blank line
  util_admin.log_message('NOTHING DISPLAYED',NULL,NULL,'X',NULL); -- Mode X nothing is displayed, no blank line or message
  util_admin.log_message('Insert message into APPLOG nothing displayed',NULL,NULL,'F',NULL); -- Mode F message inserted into APPLOG, nothing displayed
  util_admin.log_message('Verbose Warning',NULL,NULL,NULL,'W');   -- Verbose warning message displayed
  util_admin.log_message('Display SQLERRM verbose',SQLERRM,NULL ,NULL ,NULL);
  util_admin.log_message('Display prog verbose',NULL ,'myprog.exe' ,NULL ,NULL);
  util_admin.log_message('Display and log to table verbose',NULL ,NULL ,'B' ,NULL);
  util_admin.log_message('&v_message','&v_sqlerrm','&v_prog','&v_mode','&v_severity');
  util_admin.log_message('LAST LINE');
END;