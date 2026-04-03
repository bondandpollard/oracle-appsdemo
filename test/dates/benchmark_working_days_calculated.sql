-- Benchmark
-- Test speed function to calculate working days between 2 dates
-- This is a more efficient method than checking each date in the period in a loop
SET SERVEROUTPUT ON
DECLARE
  v_date DATE;
  v_date_from DATE;
  v_date_to DATE;
  v_saturday_workday BOOLEAN := FALSE;
  v_sunday_workday BOOLEAN := FALSE;
  v_working_days NUMBER;
  v_start_time1 TIMESTAMP;
  v_end_time1 TIMESTAMP;
  v_start_time2 TIMESTAMP;
  v_end_time2 TIMESTAMP;
BEGIN

  v_date_from := TO_DATE('01-JAN-1969');
  v_date_to := TO_DATE('31-JAN-4545');
  
  dbms_output.put_line('Calculated (efficient)');
  v_start_time1 := current_timestamp;
  v_working_days := util_date.working_days(v_date_from,v_date_to,'XX',v_saturday_workday,v_sunday_workday);
  v_end_time1 := current_timestamp;
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from,'DD/MON/YYYY') || ' and ' || to_char(v_date_to,'DD/MON/YYYY'));
  dbms_output.put_line('Execution time=' || to_char(v_end_time1 - v_start_time1,'HH:MM:SS:TH'));
  
  dbms_output.put_line('Loop method (inefficient)');
  v_start_time2 := current_timestamp;
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,'XX',v_saturday_workday,v_sunday_workday);
  v_end_time2 := current_timestamp;
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from,'DD/MON/YYYY') || ' and ' || to_char(v_date_to,'DD/MON/YYYY'));
  dbms_output.put_line('Execution time=' || to_char(v_end_time2 - v_start_time2,'HH:MM:SS:TH'));
  
END;
/



