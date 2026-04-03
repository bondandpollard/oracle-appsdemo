-- Test count_fields 
-- Count fields in a CSV format string
SET SERVEROUTPUT ON
ACCEPT p_rec PROMPT "Enter a CSV format string within single quotes: "
DECLARE
  l_rec VARCHAR2(1000);
  l_result NUMBER;
BEGIN
  l_rec := &p_rec;
  DBMS_OUTPUT.PUT_LINE('CSV format string entered is: ' || l_rec);
  SELECT util_string.count_fields(l_rec,',') INTO l_result FROM dual;
  DBMS_OUTPUT.PUT_LINE('Number of fields in CSV record is: ' || l_result);
END;