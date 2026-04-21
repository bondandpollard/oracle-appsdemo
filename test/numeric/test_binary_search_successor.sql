-- Test binary_search_successor
-- Find position of next higher value in array
-- E.g.
-- Array=1,1,3,4,5,5,5,6,7,7,7,7,7
-- Target=6
-- Result=9
-- 
-- Target=1
-- Result=3
-- 
-- Target=2
-- Result=3
--
-- Array=1,3
-- Target=3
-- Result=0
-- Target=4
-- Result=0
-- Target=2
-- Result=2
SET SERVEROUTPUT ON
ACCEPT p_number_list PROMPT "Enter a list of numbers to search, separated by commas"
ACCEPT p_target NUMBER PROMPT "Enter a number to find successor of"
SELECT '&p_number_list' LIST, 
'&p_target' KEY
, util_numeric.binary_search_successor(&p_target, '&p_number_list') RESULT
FROM dual;