-- Test binary_chop_search
-- E.g.
-- Array=1,1,3,4,5,5,5,6
-- Find Key 1 returns position 1
-- Find Key 4 returns position 4
-- Find Key 5 returns position 5
-- Find Key 6 returns position 8
-- Find Key 0 returns 0 (not found)
-- Find Key 2 returns 0
-- Find Key 7 returns 0
SET SERVEROUTPUT ON
ACCEPT p_number_list PROMPT "Enter a list of numbers to search, separated by commas"
ACCEPT p_key NUMBER PROMPT "Enter a number to search for"
SELECT '&p_number_list' LIST, 
'&p_key' KEY
, util_numeric.binary_chop_search(&p_key, '&p_number_list') RESULT
FROM dual;