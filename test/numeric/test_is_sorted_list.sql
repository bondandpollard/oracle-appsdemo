-- Test_is_sorted_list
SET SERVEROUTPUT ON
  ACCEPT p_list PROMPT "Enter a list of comma separated numbers"
  ACCEPT p_order PROMPT "Sort order A=Ascending, D=Descending?"
DECLARE
  v_is_sorted BOOLEAN;
BEGIN
  util_admin.log_message('Check if following list is sorted: ' || '&p_list');
  v_is_sorted := util_numeric.is_sorted_list('&p_list','&p_order');
  IF v_is_sorted THEN 
    util_admin.log_message('List is sorted!');
  ELSE
    util_admin.log_message('WARNING: List NOT sorted');
  END IF;
END;