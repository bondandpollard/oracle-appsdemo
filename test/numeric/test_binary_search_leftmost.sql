-- Test binary_search_LEFTMOST
-- Find first (leftmost) of duplicate target value in array
-- E.g.
-- Array=1,1,3,4,5,5,5,6
-- Find Target 1 returns position 1
-- Find Target 4 returns position 4
-- Find Target 5 returns position 5
-- Find Target 6 returns position 8
-- Find Target 0 returns 0 (not found)
-- Find Target 2 returns 0
-- Find Target 7 returns 0
SET SERVEROUTPUT ON
ACCEPT p_number_list PROMPT "Enter a list of numbers to search, separated by commas"
ACCEPT p_target NUMBER PROMPT "Enter a number to search for"
SELECT 'EXACT MATCH', '&p_number_list' LIST, 
'&p_target' TARGET
, util_numeric.binary_search_leftmost(&p_target, '&p_number_list') RESULT
FROM dual;

