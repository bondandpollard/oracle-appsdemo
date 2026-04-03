-- Test search_unsorted
-- Find position of target value in unsorted array
SET SERVEROUTPUT ON
ACCEPT p_number_list PROMPT "Enter a list of unsorted numbers to search, separated by commas"
ACCEPT p_target NUMBER PROMPT "Enter a number to search for"
SELECT '&p_number_list' LIST, 
'&p_target' TARGET
, util_numeric.search_unsorted(&p_target, '&p_number_list') RESULT
FROM dual;