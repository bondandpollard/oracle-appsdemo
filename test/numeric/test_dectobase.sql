SET SERVEROUTPUT ON
ACCEPT p_decimal PROMPT "Enter a decimal integer"
ACCEPT p_base PROMPT "Enter the number base to use. Binary is 2 etc."
SELECT util_numeric.dectobase(&p_decimal,&p_base) "base value"
FROM dual;

