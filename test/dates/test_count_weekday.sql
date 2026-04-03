-- Test count_day_of_week
SET SERVEROUTPUT ON
DECLARE
  v_date_from DATE;
  v_date_to DATE;
  v_count_days NUMBER;
  v_total_days NUMBER;
BEGIN
  dbms_output.put_line('Count days within specified range of dates');
  
  v_date_from := TO_DATE('04-APR-2022');
  v_date_to := TO_DATE('25-MAY-2022');

  v_total_days := 0;
  
  v_count_days := util_date.count_day_of_week(v_date_from,v_date_to,1);
  v_total_days := v_total_days + v_count_days;
  dbms_output.put_line('There are ' || to_char(v_count_days) || ' Mondays between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));

  v_count_days := util_date.count_day_of_week(v_date_from,v_date_to,2);
  v_total_days := v_total_days + v_count_days;
  dbms_output.put_line('There are ' || to_char(v_count_days) || ' Tuesdays between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));

  v_count_days := util_date.count_day_of_week(v_date_from,v_date_to,3);
  v_total_days := v_total_days + v_count_days;
  dbms_output.put_line('There are ' || to_char(v_count_days) || ' Wednesdays between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));

  v_count_days := util_date.count_day_of_week(v_date_from,v_date_to,4);
  v_total_days := v_total_days + v_count_days;
  dbms_output.put_line('There are ' || to_char(v_count_days) || ' Thursdays between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));

  v_count_days := util_date.count_day_of_week(v_date_from,v_date_to,5);
  v_total_days := v_total_days + v_count_days;
  dbms_output.put_line('There are ' || to_char(v_count_days) || ' Fridays between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));

  v_count_days := util_date.count_day_of_week(v_date_from,v_date_to,6);
  v_total_days := v_total_days + v_count_days;
  dbms_output.put_line('There are ' || to_char(v_count_days) || ' Saturdays between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));

  v_count_days := util_date.count_day_of_week(v_date_from,v_date_to,7);
  v_total_days := v_total_days + v_count_days;
  dbms_output.put_line('There are ' || to_char(v_count_days) || ' Sundays between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
  dbms_output.put_line('There are a total of ' || to_char(v_total_days) || ' days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));
  
    
  dbms_output.put_line('Check total days ' || to_char(v_date_to - v_date_from +1) || ' days between ' || to_char(v_date_from) || ' and ' || to_char(v_date_to));



END;
/



