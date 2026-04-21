-- Test functions to convert comma separated list of strings to array,
-- and convert back to list.
SET SERVEROUTPUT ON SIZE 1000000
ACCEPT plist PROMPT "Enter a list of strings separated by commas"
DECLARE 
  l_list VARCHAR2(32767);
  l_list_out VARCHAR2(32767);
  v_array util_string.t_string_array;
BEGIN 
  l_list := '&plist';
  dbms_output.put_line('List is ' || l_list);

  v_array := util_string.list_to_array_str(l_list);
  
  dbms_output.put_line('List converted to ARRAY.');
  FOR m IN 1 .. v_array.LAST LOOP
    dbms_output.put_line('Array item ' || to_char(m) || '=' || to_char(v_array(m)));
  END LOOP;  
  
  dbms_output.put_line('Converting array back to list...');
  l_list_out := util_string.array_to_list_str(v_array);
  dbms_output.put_line('Array -> List =' || l_list_out);
  
END;