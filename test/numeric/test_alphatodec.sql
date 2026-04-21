-- Test alphatodec function to convert an alphabetic string to a numeric value
SET SERVEROUTPUT ON SIZE 1000000
ACCEPT p_in_string PROMPT "Please enter a string of alpha characters"
ACCEPT p_range PROMPT "Enter the range of alpha characters to use e.g. 26 is A-Z, 5 is A-E:"

DECLARE 
  v_num_result NUMBER;
  v_string_result VARCHAR2(4000);
BEGIN 
  v_num_result := util_numeric.alphatodec('&p_in_string',&p_range);
  v_string_result := util_numeric.dectoalpha(v_num_result,&p_range);
  dbms_output.put_line('Numeric valus is   : ' ||to_char(v_num_result));
  dbms_output.put_line('String valus is    : ' ||v_string_result);
  dbms_output.put_line('Original message is: ' ||'&p_in_string');
END;