-- test_reverse_array
-- Reverse the sequence of a list of integers in an array.
-- Does not sort the integers!
SET SERVEROUTPUT ON
ACCEPT p_list PROMPT "Enter a list of numbers separated by commas"
DECLARE
  v_reverse_list VARCHAR2(32767);
BEGIN
  v_reverse_list := util_numeric.reverse_list('&p_list');
  util_admin.log_message('List reversed is: '||v_reverse_list);
END;