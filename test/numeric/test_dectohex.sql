SET SERVEROUTPUT ON
ACCEPT p1 PROMPT "Enter a decimal integer to convert to hexadecimal"
SELECT util_numeric.dectohex(&p1) "hex"
FROM dual;

