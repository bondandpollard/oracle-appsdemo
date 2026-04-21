-- Test function to return last working day of the month
SET SERVEROUTPUT ON
ACCEPT p_date DATE FORMAT 'DD-MON-YYYY' PROMPT "Enter a date in the format DD-MON-YYYY" 
ACCEPT p_country PROMPT "Enter Country Code (UK, XX)"
DECLARE
  v_date DATE;
  v_country country.country_id%TYPE;
  v_first_working_day DATE;
  v_last_working_day DATE;
  v_first_day_of_month DATE;
BEGIN
  v_date := NVL(TO_DATE('&p_date'),SYSDATE);
  v_country := NVL(UPPER('&p_country'),'UK');
  
  dbms_output.put_line('Date is ' || to_char(v_date) || ' Country is ' || v_country);
  
  v_first_day_of_month := util_date.first_day(v_date);
  dbms_output.put_line('First day of ' || TRIM(to_char(v_date,'Month')) || ' is ' || to_char(v_first_day_of_month));
  
  v_first_working_day := util_date.first_workday_month(v_date,v_country);
  dbms_output.put_line('First working day of ' || TRIM(to_char(v_date,'Month')) || 
    ' is ' || to_char(v_first_working_day) || 
    ' which is a ' || to_char(v_first_working_day,'DAY') || 
    ' Sat/Sun not work days. Country is ' || v_country);
 
  v_last_working_day := util_date.last_workday_month(v_date,v_country);
  dbms_output.put_line('Last working day of ' || TRIM(to_char(v_date,'Month')) || 
    ' is ' || to_char(v_last_working_day) || 
    ' which is a ' || to_char(v_last_working_day,'DAY')|| 
    ' Sat/Sun not work days. Country is ' || v_country);

  v_last_working_day := util_date.last_workday_month(v_date,v_country,FALSE,TRUE);
  dbms_output.put_line('Last working day of ' || TRIM(to_char(v_date,'Month')) || 
    ' is ' || to_char(v_last_working_day) || 
    ' which is a ' || to_char(v_last_working_day,'DAY')|| 
    ' Sat not work / Sun work. Country is ' || v_country);
  
   v_last_working_day := util_date.last_workday_month(v_date,v_country,TRUE,FALSE);
  dbms_output.put_line('Last working day of ' || TRIM(to_char(v_date,'Month')) || 
    ' is ' || to_char(v_last_working_day) || 
    ' which is a ' || to_char(v_last_working_day,'DAY')|| 
    ' Sat work / Sun not work. Country is ' || v_country);
  
   v_last_working_day := util_date.last_workday_month(v_date,v_country,TRUE,TRUE);
  dbms_output.put_line('Last working day of ' || TRIM(to_char(v_date,'Month')) || 
    ' is ' || to_char(v_last_working_day) || 
    ' which is a ' || to_char(v_last_working_day,'DAY')|| 
    ' Sat and Sun work. Country is ' || v_country);
 

END;
/



