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
** 20/05/2026   Ian Bond      export.demo amended to return CSV filename
*/

SET SERVEROUTPUT ON
DECLARE 
  v_result plsql_constants.filenamelength_t;
BEGIN
  v_result := export.demo;
  IF NOT v_result IS NULL THEN
    util_admin.log_message('Success! CSV File created: ' || v_result);
  ELSE
    raise_application_error (-20099,'Export failed.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('Error exporting data',SQLERRM,'EXPORT_DEMO.SQL','B','E');
END;
/
EXIT