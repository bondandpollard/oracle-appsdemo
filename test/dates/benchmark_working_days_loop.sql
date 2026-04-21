-- Benchmark
-- Test speed function to calculate working days between 2 dates
-- This is an inefficient method as it checks every day in the period in a loop.
SET SERVEROUTPUT ON
DECLARE
  v_date DATE;
  v_date_from DATE;
  v_date_to DATE;
  v_saturday_workday BOOLEAN := FALSE;
  v_sunday_workday BOOLEAN := FALSE;
  v_working_days NUMBER;
  
BEGIN
  dbms_output.put_line('Loop Method (inefficient)');
  
  v_date_from := TO_DATE('01-JAN-1969');
  v_date_to := TO_DATE('31-JAN-4545');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,'XX');
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
    
  
END;
/



