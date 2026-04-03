/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : export_demo.sql
**
** DESCRIPTION
**   Call a PL/SQL package function to export demo data to a CSV file.
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 24/07/2022   Ian Bond      Created
*/

SET SERVEROUTPUT ON
DECLARE 
  v_result BOOLEAN;
BEGIN
  v_result := export.demo;
  IF v_result THEN
    util_admin.log_message('Success!');
  ELSE
    raise_application_error (-20099,'Export failed.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('Error exporting data',SQLERRM,'EXPORT_DEMO.SQL','B','E');
END;
/
EXIT