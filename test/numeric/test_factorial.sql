-- Test Factorial and recursive version of Factorial
ACCEPT p_number PROMPT "Enter an integer value to calculate its factorial"
SELECT util_numeric.factorial(&p_number) "factorial"
,util_numeric.factorialr(&p_number) "factorial recursive"
FROM dual;