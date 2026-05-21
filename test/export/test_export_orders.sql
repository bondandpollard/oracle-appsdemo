/*
** Copyright (c) 2026 Bond & Pollard Ltd. All rights reserved.  
** This software is free to use and modify at your own risk.
**
** NAME   : test_export_orders.sql
**
** DESCRIPTION
**   TEST: Call a PL/SQL package function to export orders to a CSV file.

** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 23/07/2022   Ian Bond      Created
*/

SET SERVEROUTPUT ON
DECLARE 
  v_result plsql_constants.filenamelength_t;
BEGIN
  v_result := export.orders;
  IF NOT v_result IS NULL THEN
    util_admin.log_message('Success! CSV file created: ' || v_result);
  ELSE
    raise_application_error (-20099,'Order export failed.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('Error exporting data',SQLERRM,'TEST_EXPORT_ORDERS.SQL','B','E');
END;
/
EXIT