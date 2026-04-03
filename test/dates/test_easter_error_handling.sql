-- Test easter_sunday
SET SERVEROUTPUT ON SIZE 1000000
ACCEPT p_year PROMPT "Please enter a year:"

DECLARE 
  v_string_result VARCHAR2(4000);
BEGIN 
  v_string_result := util_date.easter_sunday(&p_year);
  dbms_output.put_line('Result  : ' ||v_string_result);
END;