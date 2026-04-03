SET SERVEROUTPUT ON
ACCEPT p1 PROMPT "Enter a hexadecimal number to convert to decimal"
SELECT util_numeric.hextodec('&p1') "hexadecimal"
FROM dual;

