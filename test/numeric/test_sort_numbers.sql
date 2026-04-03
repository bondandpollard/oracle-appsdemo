--Test sort_numbers
SET SERVEROUTPUT ON
ACCEPT p_number_list PROMPT "Enter a list of numbers to sort, separated by commas"
ACCEPT p_order PROMPT "Sort sequence A=Ascending, D=Descending?"
DECLARE
  v_sorted_list VARCHAR2(32767);
BEGIN
  v_sorted_list := util_numeric.sort_numbers('&p_number_list', '&p_order');
  util_admin.log_message('Sorted list: '||v_sorted_list);
END;