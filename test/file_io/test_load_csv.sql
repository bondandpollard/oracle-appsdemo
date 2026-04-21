SET SERVEROUTPUT ON
ACCEPT p_filename PROMPT "Enter the name of the CSV file to load"
DECLARE 
  v_filename VARCHAR2(100);
  v_file_id NUMBER :=0;
  v_error_message VARCHAR2(100);
  e_file_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_file_not_found,-20000);
BEGIN
  v_filename := rtrim('&p_filename',' ');
  util_admin.log_message('TEST CSV Data Import from file: '||v_filename);
  v_file_id := util_file.load_csv(v_filename);
  CASE v_file_id
  WHEN -1 THEN
    RAISE e_file_not_found;
  WHEN 0 THEN
    util_admin.log_message('Failed, FileID = '||to_char(v_file_id));
  ELSE
    util_admin.log_message('Success, FileID = '||to_char(v_file_id));
  END CASE;
EXCEPTION
  WHEN e_file_not_found THEN
    util_admin.log_message('Error, file '||v_filename|| ' not found.');
  WHEN OTHERS THEN
    util_admin.log_message('Error: '||to_char(SQLCODE)||' message: '||SQLERRM,SQLERRM,'TEST_LOAD_CSV.SQL','B','E');
END;