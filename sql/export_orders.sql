/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
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
*/

SET SERVEROUTPUT ON
DECLARE 
  v_result BOOLEAN;
BEGIN
  v_result := export.orders;
  IF v_result THEN
    util_admin.log_message('Success!');
  ELSE
    raise_application_error (-20099,'Order export failed.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('Error exporting data',SQLERRM,'EXPORT_ORDERS.SQL','B','E');
END;
/
EXIT