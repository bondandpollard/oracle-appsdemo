-- Test function to count working days between 2 dates
SET SERVEROUTPUT ON
DECLARE
  v_date DATE;
  v_date_from DATE;
  v_date_to DATE;
  v_country_id country_holiday.country_id%TYPE := 'UK';
  v_saturday_workday BOOLEAN := FALSE;
  v_sunday_workday BOOLEAN := FALSE;
  v_weekend BOOLEAN;
  v_holiday BOOLEAN;
  v_working_day BOOLEAN;
  v_working_days NUMBER :=0;
BEGIN

  v_date_from := TO_DATE('01-JAN-22');
  v_date_to := TO_DATE('31-JAN-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-FEB-22');
  v_date_to := TO_DATE('28-FEB-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-MAR-22');
  v_date_to := TO_DATE('31-MAR-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-APR-22');
  v_date_to := TO_DATE('30-APR-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));

  v_date_from := TO_DATE('01-MAY-22');
  v_date_to := TO_DATE('31-MAY-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-JUN-22');
  v_date_to := TO_DATE('30-JUN-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-JUL-22');
  v_date_to := TO_DATE('31-JUL-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-AUG-22');
  v_date_to := TO_DATE('31-AUG-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-SEP-22');
  v_date_to := TO_DATE('30-SEP-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-OCT-22');
  v_date_to := TO_DATE('31-OCT-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-NOV-22');
  v_date_to := TO_DATE('30-NOV-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-DEC-22');
  v_date_to := TO_DATE('31-DEC-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  v_date_from := TO_DATE('01-JAN-22');
  v_date_to := TO_DATE('31-DEC-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));

  v_date_from := TO_DATE('04-APR-2021');
  v_date_to := TO_DATE('31-DEC-22');
  v_working_days := util_date.working_days_between(v_date_from,v_date_to,v_country_id,v_saturday_workday,v_sunday_workday);
  dbms_output.put_line('There are ' || to_char(v_working_days) || ' working days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
END;
/



