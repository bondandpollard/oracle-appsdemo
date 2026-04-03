-- Test import of order data from a CSV file
-- Directory DATA_IN gives the operating system file location where the CSV files must be
--
SET SERVEROUTPUT ON
ACCEPT v_filename prompt "Enter the filename: ";
DECLARE 
  v_result BOOLEAN;
BEGIN
  
  util_admin.log_message('TEST Order Data Import from file: '||'&v_filename');
  v_result := import.ord_imp('&v_filename');
  IF v_result THEN
    util_admin.log_message('Success!');
  ELSE
    raise_application_error (-20099,'Order import failed. View errors in IMPORTERROR for file '||'&v_filename');
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('Unexpected error importing file ' || '&v_filename',SQLERRM,'TEST_IMPORT_ORDER.SQL','B','E');
END;