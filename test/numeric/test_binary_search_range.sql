-- Test_binary_search_range
-- Find count of values in range

SET SERVEROUTPUT ON
ACCEPT p_number_list PROMPT "Enter a list of numbers to search, separated by commas"
ACCEPT p_from NUMBER PROMPT "Enter start number of range"
ACCEPT p_to NUMBER PROMPT "Enter end number of range"


SELECT '&p_number_list' LIST, 
'&p_from' RANGEFROM,
'&p_to' RANGETO,
util_numeric.binary_search_range(&p_from, &p_to, '&p_number_list') RANGE
FROM dual;
