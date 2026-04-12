CREATE OR REPLACE PACKAGE BODY util_date AS

  /*
  ** Private functions and procedures
  */


  /*
  ** Public functions and procedures
  */

  FUNCTION dayname(
    p_date IN DATE
  ) 
  RETURN VARCHAR2 
  IS
  BEGIN
    RETURN to_char(p_date,'DAY');
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Date invalid: ' || to_char(p_date),sqlerrm, 'UTIL_DATE.DAYNAME', 'S', gc_error);
      RETURN NULL;
  END dayname;

  FUNCTION is_a_weekend(
    p_date             IN DATE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
  ) 
  RETURN BOOLEAN 
  IS
    v_weekend BOOLEAN := FALSE;
    v_day_no INTEGER := 0;
  BEGIN
    v_day_no := to_number(to_char(p_date,'D'));
    CASE
      WHEN (NOT p_saturday_workday AND v_day_no = gc_saturday) 
      OR (NOT p_sunday_workday AND v_day_no = gc_sunday) THEN
        v_weekend := TRUE;
      ELSE
        v_weekend := FALSE;
    END CASE;
    RETURN v_weekend;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.IS_A_WEEKEND', 'S', gc_error);
      RETURN NULL;
  END is_a_weekend;

  FUNCTION is_a_holiday(
    p_date       IN DATE, 
    p_country_id IN country_holiday.country_id%TYPE
  ) 
  RETURN BOOLEAN 
  IS
    CURSOR holiday_cur(p_country_id country_holiday.country_id%TYPE, p_date DATE) IS
      SELECT H.holiday_date
      FROM country_holiday H
      WHERE H.country_id = p_country_id
      AND H.year_no = extract(YEAR FROM p_date)
      AND H.holiday_date = p_date;
    r_holiday holiday_cur%ROWTYPE;
    v_holiday BOOLEAN := FALSE;
  BEGIN
      -- Is this date a holiday for the specified country?
      OPEN holiday_cur(p_country_id, p_date);
      FETCH holiday_cur INTO r_holiday;
      IF holiday_cur%FOUND THEN
        v_holiday := TRUE;
      END IF;
      CLOSE holiday_cur;
      RETURN v_holiday;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.IS_A_HOLIDAY', 'S', gc_error);
      RETURN NULL;
  END is_a_holiday;

  FUNCTION is_a_working_day(
    p_date             IN DATE, 
    p_country_id       IN country_holiday.country_id%TYPE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
  ) 
  RETURN BOOLEAN 
  IS
    v_holiday BOOLEAN := FALSE;
    v_weekend BOOLEAN := FALSE;
    v_working_day BOOLEAN := TRUE;
  BEGIN
    -- Is today a non-working weekend day?
    v_weekend := is_a_weekend(p_date, p_saturday_workday, p_sunday_workday);
    IF NOT v_weekend THEN
      -- Is today a holiday?
      v_holiday := is_a_holiday(p_date, p_country_id);
    END IF;
    CASE
      WHEN v_weekend OR v_holiday THEN 
        v_working_day := FALSE;
      ELSE
        v_working_day := TRUE;
    END CASE;
    RETURN v_working_day;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.IS_A_WORKING_DAY', 'S', gc_error);
      RETURN NULL;
  END is_a_working_day;

  FUNCTION first_day(
    p_date IN DATE
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN last_day(add_months(p_date,-1))+1;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.FIRST_DAY', 'S', gc_error);
      RETURN NULL;
  END first_day;

  FUNCTION month_day_first(
    p_date   IN DATE, 
    p_day_no IN NUMBER
  ) 
  RETURN DATE 
  IS
    out_of_range EXCEPTION;
    v_result_date DATE;
    v_start_dayno NUMBER;
    v_offset NUMBER;
  BEGIN
    IF p_day_no < 1 OR p_day_no > 7 THEN
      RAISE out_of_range;
    END IF;
    v_start_dayno := to_number(to_char(first_day(p_date),'D'));
    v_offset := (p_day_no - v_start_dayno);
    IF v_offset > 7 THEN
      v_offset := v_offset - 7;
    ELSIF v_offset < 0 THEN
      v_offset := v_offset + 7;
    END IF;
    v_result_date := to_date(first_day(p_date) + v_offset);
    RETURN v_result_date;
  EXCEPTION
    WHEN out_of_range THEN
      util_admin.log_message('Day number ' || to_char(p_day_no) || ' not in range 1 to 7.' ,sqlerrm, 'UTIL_DATE.MONTH_DAY_FIRST', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.MONTH_DAY_FIRST', 'S', gc_error);
      RETURN NULL;
  END month_day_first;

  FUNCTION month_day_last(
    p_date   IN DATE, 
    p_day_no IN NUMBER
  ) 
  RETURN DATE 
  IS
    out_of_range EXCEPTION;
    v_result_date DATE;
    v_start_dayno NUMBER;
    v_offset NUMBER;
  BEGIN
    IF p_day_no < 1 OR p_day_no > 7 THEN
      RAISE out_of_range;
    END IF;
    v_start_dayno := to_number(to_char(last_day(p_date),'D'));
    v_offset := (v_start_dayno - p_day_no);
    IF v_offset > 7 THEN
      v_offset := v_offset - 7;
    ELSIF v_offset < 0 THEN
      v_offset := v_offset + 7;
    END IF;
    v_result_date := to_date(last_day(p_date) - v_offset);
    RETURN v_result_date;
  EXCEPTION
    WHEN out_of_range THEN
      util_admin.log_message('Day number ' || to_char(p_day_no) || ' not in range 1 to 7.' ,sqlerrm, 'UTIL_DATE.MONTH_DAY_LAST', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.MONTH_DAY_LAST', 'S', gc_error);
      RETURN NULL;
  END month_day_last;

  FUNCTION first_workday_month(
    p_date             IN DATE, 
    p_country_id       IN country_holiday.country_id%TYPE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
  ) 
  RETURN DATE 
  IS
    v_current_date DATE;
    v_working_day BOOLEAN;
    v_last_day_of_month DATE;
  BEGIN
    v_current_date := first_day(p_date); -- Start at the first day of the month for the specified date
    v_working_day := FALSE;
    v_last_day_of_month := last_day(p_date);
    WHILE NOT v_working_day AND v_current_date <= v_last_day_of_month LOOP
      IF is_a_working_day(v_current_date, p_country_id, p_saturday_workday, p_sunday_workday) THEN
        EXIT;
      END IF;
      v_current_date := v_current_date +1;
    END LOOP;
    RETURN v_current_date;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.FIRST_WORKDAY_MONTH', 'S', gc_error);
      RETURN NULL;
  END first_workday_month;

  FUNCTION last_workday_month(
    p_date             IN DATE, 
    p_country_id       IN country_holiday.country_id%TYPE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
  ) 
  RETURN DATE 
  IS
    v_current_date DATE;
    v_working_day BOOLEAN;
    v_first_day_of_month DATE;
  BEGIN
    v_current_date := last_day(p_date); -- Start at the last day of the month for the specified date
    v_working_day := FALSE;
    v_first_day_of_month := last_day(add_months(p_date,-1))+1;
    WHILE NOT v_working_day AND v_current_date >= v_first_day_of_month LOOP
      IF is_a_working_day(v_current_date, p_country_id, p_saturday_workday, p_sunday_workday) THEN
        EXIT;
      END IF;
      v_current_date := v_current_date -1;
    END LOOP;
    RETURN v_current_date;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.LAST_WORKDAY_MONTH', 'S', gc_error);
      RETURN NULL;
  END last_workday_month;

  FUNCTION working_days_between(
    p_date_start       IN DATE, 
    p_date_end         IN DATE, 
    p_country_id       IN country_holiday.country_id%TYPE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
  ) 
  RETURN NUMBER 
  IS
    v_current_date DATE;
    v_working_day_count NUMBER;
  BEGIN
    IF p_date_end < p_date_start THEN
      RETURN 0;
    END IF;
    v_current_date := p_date_start;
    v_working_day_count :=0;
    WHILE v_current_date <= p_date_end LOOP
      IF is_a_working_day(v_current_date, p_country_id, p_saturday_workday, p_sunday_workday) THEN
        v_working_day_count := v_working_day_count +1;
      END IF;
      v_current_date := v_current_date +1;
    END LOOP;
    RETURN v_working_day_count;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.WORKING_DAYS_BETWEEN', 'S', gc_error);
      RETURN NULL;
  END working_days_between;

  FUNCTION count_day_of_week(
    p_date_start IN DATE, 
    p_date_end   IN DATE, 
    p_dayno      IN NUMBER
  ) 
  RETURN NUMBER 
  IS
    c_days_in_week CONSTANT INTEGER := 7;
    v_total_days NUMBER;
    v_start_dayno NUMBER;
    v_end_dayno NUMBER;
    v_start_offset NUMBER;
    v_end_offset NUMBER;
    v_count_days NUMBER;
  BEGIN
    IF p_date_start > p_date_end THEN
      RETURN 0;
    END IF;
    v_total_days := (p_date_end - p_date_start) +1;
    v_start_dayno := to_number(to_char(p_date_start,'D'));
    v_start_offset := c_days_in_week - (v_start_dayno+(c_days_in_week-p_dayno));
    IF v_start_offset < 0 THEN
      v_start_offset := v_start_offset+c_days_in_week;
    END IF;
    v_end_dayno := to_number(to_char(p_date_end,'D')); 
    v_end_offset := v_end_dayno+(c_days_in_week-p_dayno);
    IF v_end_offset >= c_days_in_week THEN
      v_end_offset := v_end_offset-c_days_in_week;
    END IF;
    v_count_days := floor((v_total_days - (v_start_offset + v_end_offset)) / c_days_in_week) +1;
    RETURN v_count_days;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.COUNT_DAY_OF_WEEK', 'S', gc_error);
      RETURN NULL;
  END count_day_of_week;

  FUNCTION working_days(
    p_date_start       IN DATE, 
    p_date_end         IN DATE, 
    p_country_id       IN country_holiday.country_id%TYPE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
  ) 
  RETURN NUMBER 
  IS
   CURSOR holiday_cur(p_country_id country_holiday.country_id%TYPE, p_date_start DATE, p_date_end DATE) IS
      SELECT H.holiday_date
      FROM country_holiday H
      WHERE H.country_id = p_country_id
      AND   H.holiday_date >= p_date_start
      AND   H.holiday_date <= p_date_end;
    v_total_days NUMBER := 0;
    v_dayno NUMBER;
    v_total_saturdays NUMBER := 0; -- Total non working Saturdays in period
    v_total_sundays NUMBER := 0; -- Total non working Sundays in period
    v_total_holidays NUMBER := 0;
    v_total_working_days NUMBER := 0;
  BEGIN
    IF p_date_end < p_date_start THEN
      RETURN 0;
    END IF;

    v_total_days := (p_date_end - p_date_start) +1;

    -- Calculate number of non working Satudays in period
    IF NOT p_saturday_workday THEN
      v_total_saturdays := count_day_of_week(p_date_start, p_date_end, gc_saturday);
    ELSE
      v_total_saturdays :=0;
    END IF;

    -- Calculate number of non working Sundays in period
    IF NOT p_sunday_workday THEN
      v_total_sundays := count_day_of_week(p_date_start, p_date_end, gc_sunday);
    ELSE
      v_total_sundays :=0;
    END IF;

    -- Count the holidays within the period
    FOR r_holiday IN holiday_cur(p_country_id, p_date_start, p_date_end) LOOP
      v_dayno := to_number(to_char(r_holiday.holiday_date,'D'));
      IF v_dayno < gc_saturday OR (p_saturday_workday AND v_dayno = gc_saturday) OR (p_sunday_workday AND v_dayno = gc_sunday) THEN
        -- Only count weekends as holidays if they are usually working days, otherwise you may count a weekend twice as a non working day
        v_total_holidays := v_total_holidays+1;
      END IF;
    END LOOP;

    v_total_working_days := v_total_days - v_total_saturdays - v_total_sundays - v_total_holidays;
    RETURN v_total_working_days;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_DATE.WORKING_DAYS', 'S', gc_error);
      RETURN NULL;
  END working_days;

  FUNCTION easter_sunday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
    v_current_year INTEGER;
    a INTEGER;
    b INTEGER;
    c INTEGER;
    d INTEGER;
    e INTEGER;
    f INTEGER;
    g INTEGER;
    h INTEGER;
    i INTEGER;
    k INTEGER;
    l INTEGER;
    m INTEGER;
    n INTEGER;
    p INTEGER;
    c1 CONSTANT INTEGER :=19;
    c2 CONSTANT INTEGER :=100;
    c3 CONSTANT INTEGER :=4;
    c4 CONSTANT INTEGER :=8;
    c5 CONSTANT INTEGER :=25;
    c6 CONSTANT INTEGER :=3;
    c7 CONSTANT INTEGER :=30;
    c8 CONSTANT INTEGER :=4;
    c9 CONSTANT INTEGER :=7;
    c10 CONSTANT INTEGER :=451;
    c11 CONSTANT INTEGER :=31;
    c12 CONSTANT INTEGER :=1;
    c13 CONSTANT INTEGER :=15;
    c14 CONSTANT INTEGER :=32;
    c15 CONSTANT INTEGER :=2;
    c16 CONSTANT INTEGER :=11;
    c17 CONSTANT INTEGER :=22;
    c18 CONSTANT INTEGER :=114;
  BEGIN
  
   IF p_year < 1 OR p_year > 3000 THEN
    RAISE e_invalid_data;
   END IF;
   
   
   v_current_year := floor(p_year);
   a := mod(v_current_year,c1);
   b := floor(v_current_year / c2);
   c := mod(v_current_year,c2);
   d := floor(b / c3);
   e := mod(b,c3);
   f := floor(( b + c4 ) / c5);
   g := floor(( b - f + c12 ) / c6);
   h := mod(( ( c1 * a ) + b - d - g + c13 ),c7);
   i := floor(c / c8);
   k := mod(c,c8);
   l := mod(( c14 + ( c15 * e ) + ( c15 * i ) - h - k ),c9);
   m := floor(( a + ( c16 * h ) + ( c17 * l ) ) / c10);
   n := floor(( h + l - ( c9 * m ) + c18 ) / c11);
   p := mod(( h + l - ( c9 * m ) + c18 ),c11); 
   RETURN(to_date(to_char(v_current_year)||'/'||to_char(n)||'/'||to_char(p+1),'YYYY/MM/DD'));
   
  EXCEPTION
  
    WHEN e_invalid_data THEN
      util_admin.log_message('Invalid year ' || to_char(p_year) || ' must be a whole number between 1 and 3000.', sqlerrm, 'UTIL_DATE.EASTER_SUNDAY', 'S', gc_error);
      RETURN NULL;
      
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error. ', sqlerrm, 'UTIL_DATE.EASTER_SUNDAY', 'S', gc_error);
      RETURN NULL;
      
  END easter_sunday;
  
  FUNCTION easter_monday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) +1;
  END easter_monday;

  FUNCTION good_friday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) -2;
  END good_friday;
  
  FUNCTION easter_friday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) +5;
  END easter_friday;

  FUNCTION easter_saturday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) +6;
  END easter_saturday;

  FUNCTION shrove_tuesday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) -47;
  END shrove_tuesday;

  FUNCTION ash_wednesday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) -46;
  END ash_wednesday;

  FUNCTION palm_sunday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) -7;
  END palm_sunday;

  FUNCTION whitsun(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) +49;
  END whitsun;

  FUNCTION whit_monday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) +50;
  END whit_monday;

  FUNCTION ascension_day(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) +39;
  END ascension_day;

  FUNCTION corpus_christi(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) +60;
  END corpus_christi;

  FUNCTION mardi_gras(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) -47;
  END mardi_gras;

  FUNCTION carnival_monday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
    BEGIN
    RETURN easter_sunday(p_year) -48;
  END carnival_monday;

END util_date;
/