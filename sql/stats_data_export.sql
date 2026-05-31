/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.
** This software is free to use and modify at your own risk.
**
** NAME   : stats_data_export.sql
**
** DESCRIPTION
**   Call a PL/SQL package function to export statistics data to a CSV file.

** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 20/05/2026   Ian Bond      Created
*/

SET SERVEROUTPUT ON
ACCEPT p_project_id NUMBER PROMPT "Enter Project ID to export statistics data from:"
DECLARE 
  v_result plsql_constants.filenamelength_t;
BEGIN
  v_result := export.project_stats_data(&p_project_id);
  IF NOT v_result IS NULL THEN
    util_admin.log_message('Success! CSV file created: ' || v_result);
  ELSE
    raise_application_error (-20099,'Statistics data export failed.');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('Error exporting data',SQLERRM,'STATS_DATA_EXPORT.SQL','B','E');
END;
/
EXIT