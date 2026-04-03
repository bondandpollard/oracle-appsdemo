-- Test binary_search_predecessor
-- Find position of next lower value in array
-- E.g.
-- Array=1,1,3,4,5,5,5,6,7,7,7,7,7
-- Target=6
-- Result=7
SET SERVEROUTPUT ON
ACCEPT p_number_list PROMPT "Enter a list of numbers to search, separated by commas"
ACCEPT p_target NUMBER PROMPT "Enter a number to find predecessor of"
SELECT '&p_number_list' LIST, 
'&p_target' KEY
, util_numeric.binary_search_predecessor(&p_target, '&p_number_list') RESULT
FROM dual;