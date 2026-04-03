-- Test BASETODEC
SET SERVEROUTPUT ON
ACCEPT p_base_value PROMPT "Enter a number as a base value, e.g. 10 for 2 in base 2 binary:"
ACCEPT p_base PROMPT "Enter the number base to use. Binary is 2 etc."
SELECT util_numeric.basetodec('&p_base_value',&p_base) "decimal value"
FROM dual;