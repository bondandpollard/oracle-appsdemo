/*
** Copyright (c) 2026 Bond & Pollard Ltd. All rights reserved.  
** This software is free to use and modify at your own risk.
**
** NAME   : test_export_demo_csv.sql
**
** DESCRIPTION
**   TEST: Call a PL/SQL package function to export demo data to a CSV file.
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 20/05/2026   Ian Bond      Created
*/

SET SERVEROUTPUT ON
DECLARE 
  v_result plsql_constants.filenamelength_t;
BEGIN
  v_result := export.demo;
  IF NOT v_result IS NULL THEN
    util_admin.log_message('Success! File created: '||v_result);
  ELSE
    raise_application_error (-20099,'Export failed.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('Error exporting data',SQLERRM,'TEST_EXPORT_DEMO.SQL','B','E');
END;
/
EXIT