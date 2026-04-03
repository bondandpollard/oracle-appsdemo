-- Test binary_search_nearest
-- Find position of nearest value in array

SET SERVEROUTPUT ON
ACCEPT p_number_list PROMPT "Enter a list of numbers to search, separated by commas"
ACCEPT p_target NUMBER PROMPT "Enter a number to find position of nearest value for"
SELECT '&p_number_list' LIST, 
'&p_target' KEY
, util_numeric.binary_search_nearest(&p_target, '&p_number_list') RESULT
FROM dual;