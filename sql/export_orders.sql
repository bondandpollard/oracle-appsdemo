/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** This software is free to use and modify at your own risk.
**
** NAME   : export_orders.sql
**
** DESCRIPTION
**   Call a PL/SQL package function to export orders to a CSV file.

** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 23/07/2022   Ian Bond      Created
** 20/05/2026   Ian Bond      export.orders amended to return CSV filename
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
    util_admin.log_message('Error exporting data',SQLERRM,'EXPORT_ORDERS.SQL','B','E');
END;
/
EXIT