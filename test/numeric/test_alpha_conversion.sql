-- Test alphabetic string to decimal integer conversion functions
SET SERVEROUTPUT ON SIZE 1000000
ACCEPT p_alpha_str PROMPT "Enter an alphabetic string of characters to be converted to a decimal number, A to Z only:"
ACCEPT p_range NUMBER PROMPT "Enter the number of alphabetic character in the range e.g. 5 for A to E:"
ACCEPT p_number NUMBER PROMPT "Enter a number to be converted to an alpha string with letter A to Z:"
DECLARE
  v_alpha_str VARCHAR2(100);
  v_chk_alpha VARCHAR2(100);
  v_chk2_alpha VARCHAR2(100);
  v_range INTEGER;
  v_decimal INTEGER;
  v_number INTEGER;
  v_result INTEGER;
BEGIN 
  dbms_output.put_line('Test alphabetic code / numbers with a specified range of letters in code.');
  v_alpha_str := '&p_alpha_str';
  v_range := &p_range;
  v_number := &p_number;
  
  v_decimal := util_numeric.alphatodec(v_alpha_str, v_range);
  v_chk_alpha := util_numeric.dectoalpha(v_decimal, v_range);
  dbms_output.put_line('Alpha string ' || v_alpha_str || ' is decimal number: ' || to_char(v_decimal));
  dbms_output.put_line('Check conversion of number to alpha: ' || v_chk_alpha);
  IF v_chk_alpha = v_alpha_str THEN
    dbms_output.put_line('SUCCESS! The alpha codes matched.');
  ELSE
    dbms_output.put_line('ERROR: The alpha codes do not match.');
  END IF;
  
  dbms_output.put_line('Test alphabetic code (no range specified)');

  v_chk2_alpha := util_numeric.num_to_alphanumeric(v_number);
  dbms_output.put_line('Convert number ' || to_char(v_number) || ' to alpha (num_to_alphanumeric) ' || v_chk2_alpha);
  v_result := util_numeric.alphatodec(v_chk2_alpha,26);
  dbms_output.put_line('Check conversion of alpha code back to number, result = ' || to_char(v_result));
  IF v_result = v_number THEN
      dbms_output.put_line('SUCCESS! The numeric codes matched.');
  ELSE
    dbms_output.put_line('ERROR: The numbers do not match.');
  END IF;
  
END;