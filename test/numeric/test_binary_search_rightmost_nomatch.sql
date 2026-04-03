-- Test binary_search_RIGHTMOST_NOMATCH
-- Find last (rightmost) of duplicate target value in array EXACT MATCH FALSE

SET SERVEROUTPUT ON
ACCEPT p_number_list PROMPT "Enter a list of numbers to search, separated by commas"
ACCEPT p_target NUMBER PROMPT "Enter a number to search for"
DECLARE
  v_result NUMBER;
BEGIN
  v_result := util_numeric.binary_search_rightmost(&p_target, '&p_number_list', FALSE);
  util_admin.log_message('EXACT MATCH FALSE: v_result=' || to_char(v_result));
  v_result := util_numeric.binary_search_rightmost(&p_target, '&p_number_list', TRUE);
  util_admin.log_message('EXACT MATCH TRUE: v_result=' || to_char(v_result));
END;