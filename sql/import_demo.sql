/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : import_demo.sql
**
** DESCRIPTION
**   Call a PL/SQL package function to:
**     Load CSV data into the staging table IMPORTCSV
**     Validate the data, recording all errors in table IMPORTERROR
**     If no errors
**       Load the imported data into the demo table
**       Move the CSV file to the processed directory
**     Else if errors found
**       Move the CSV file to the error directory
**       Exit with an error status
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
  v_filename VARCHAR2(100) := '&1';
  v_result BOOLEAN;
BEGIN
  util_admin.log_message('Data Import from file: '||v_filename);
  v_result := import.demo_imp(v_filename);
  IF v_result THEN
    util_admin.log_message('Success!');
  ELSE
    raise_application_error (-20099,'Import failed. View errors in IMPORTERROR for file '||v_filename);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('Error importing file '||v_filename,SQLERRM,'IMPORT_DEMO.SQL','B','E');
END;
/
EXIT