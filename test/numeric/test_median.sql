-- test_median
SET SERVEROUTPUT ON
ACCEPT p_list PROMPT "Enter a list of numbers separated by commas"
DECLARE
  v_sorted_list VARCHAR2(32767);
  v_median NUMBER;
BEGIN
  v_sorted_list := util_numeric.sort_numbers('&p_list');
  util_admin.log_message('Sorted list is: '||v_sorted_list);
  v_median := util_numeric.median(v_sorted_list);
  util_admin.log_message('Median is '||to_char(v_median));
END;
