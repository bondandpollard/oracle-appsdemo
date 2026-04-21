-- Test functions to convert string of numbers to array,
-- and convert array of number to string of comma separated values.
-- ,,,4,,6,,8,
SET SERVEROUTPUT ON SIZE 1000000
ACCEPT plist PROMPT "Enter a list of numbers separated by commas"
DECLARE 
  l_list VARCHAR2(32767);
  l_list_out VARCHAR2(32767);
  v_array util_numeric.t_number_array := util_numeric.t_number_array();
  e_null_list EXCEPTION;
BEGIN 
  NULL;
  l_list := '&plist';
  dbms_output.put_line('List is ' || l_list);

  v_array := util_numeric.list_to_array(l_list);
  
  IF v_array IS NULL THEN
    RAISE e_null_list;
  END IF;
  
  dbms_output.put_line('List converted to ARRAY.');
  FOR m IN 1 .. v_array.LAST LOOP
    dbms_output.put_line('Array item ' || to_char(m) || '=' || to_char(v_array(m)));
  END LOOP;  
  
  dbms_output.put_line('Converting array back to list...');
  l_list_out := util_numeric.array_to_list(v_array);
  dbms_output.put_line('Array -> List =' || l_list_out);
EXCEPTION
  WHEN e_null_list THEN
    NULL;
  WHEN OTHERS THEN
    util_admin.log_message('Unexpected error.');
END;