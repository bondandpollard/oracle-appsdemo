/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : test_data_holiday.sql
**
** DESCRIPTION
**   This script creates test data for the date functions
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 02/06/2022   Ian Bond      Created script
*/
SET SERVEROUTPUT ON
DECLARE
  v_year NUMBER(4);
BEGIN

  FOR v_year IN 1969 .. 2169 LOOP
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('01-JAN-'||to_char(v_year)));
      
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('03-JAN-'||to_char(v_year)));
  
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('15-APR-'||to_char(v_year)));
  
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('18-APR-'||to_char(v_year)));

    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('02-MAY-'||to_char(v_year)));
      
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('02-JUN-'||to_char(v_year)));
      
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('03-JUN-'||to_char(v_year)));
      
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('25-JUL-'||to_char(v_year)));
  
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('26-JUL-'||to_char(v_year)));
      
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('27-JUL-'||to_char(v_year)));
      
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('28-JUL-'||to_char(v_year)));

    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('29-JUL-'||to_char(v_year)));
      
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('29-AUG-'||to_char(v_year)));
 
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('25-DEC-'||to_char(v_year)));

    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('26-DEC-'||to_char(v_year)));
      
    INSERT INTO country_holiday (country_id, year_no, holiday_date)
      VALUES ('XX',v_year,to_date('27-DEC-'||to_char(v_year)));
  
  END LOOP;
  

END;
/