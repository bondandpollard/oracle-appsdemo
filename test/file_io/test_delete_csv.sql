SET SERVEROUTPUT ON
DECLARE 
  v_file_id NUMBER :=0;
  v_rows_deleted NUMBER :=0;
BEGIN
  v_file_id := &p_file_id;
  v_rows_deleted := util_file.delete_csv(v_file_id);
  IF v_rows_deleted > 0 THEN
    dbms_output.put_line('Import CSV data deleted '||to_char(v_rows_deleted)||' rows from File ID: '|| to_char(v_file_id));
  ELSE
    dbms_output.put_line('Import CSV delete failed for File ID: '|| to_char(v_file_id));
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Error: '||to_char(SQLCODE)||' message: '||SQLERRM);
END;