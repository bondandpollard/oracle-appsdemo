CREATE OR REPLACE PACKAGE util_date AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : util_date
  ** Description   : Date manipulation functions
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                Description
  **------------------------------------------------------------------------
  ** 16/06/2022       Ian Bond            Program created
  ** 21/08/2023       Ian Bond            Use to_number function when assigning 
  **                                      char values to numeric variables. 
  ** 24/09/2025       Ian Bond            Add exceptions to handle incorrect input
  **                                      values such as years containing letters or
  **                                      decimals.
  ** 27/09/2025       Ian Bond            Improve exception handling.
  ** 31/03/2026       Ian Bond            Change function names:
  **                                        first_day_month --> month_first_day
  **                                        last_day_month  --> month_day_last
  */


  /*
  ** Global constants
  */
  gc_monday    CONSTANT INTEGER   :=1;
  gc_tuesday   CONSTANT INTEGER   :=2;
  gc_wednesday CONSTANT INTEGER   :=3;
  gc_thursday  CONSTANT INTEGER   :=4;
  gc_friday    CONSTANT INTEGER   :=5;
  gc_saturday  CONSTANT INTEGER   :=6;
  gc_sunday    CONSTANT INTEGER   :=7;
  gc_error     CONSTANT plsql_constants.severity_error%TYPE := plsql_constants.severity_error;
  gc_info      CONSTANT plsql_constants.severity_info%TYPE  := plsql_constants.severity_info;
  gc_warn      CONSTANT plsql_constants.severity_warn%TYPE  := plsql_constants.severity_warn;

  /*
  ** Global exceptions
  */

  e_invalid_data EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_invalid_data,-20001);

  /*
  ** Public functions and procedures
  */


  /*
  ** dayname - Returns name of day
  **
  ** Returns name of day for a given date
  **
  ** IN
  **   p_date         - A valid date
  ** RETURN
  **   VARCHAR2  String containing name of day
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION dayname(
    p_date IN DATE
    ) RETURN VARCHAR2;

  /*
  ** count_day_of_week - Count occurrences of day between dates
  **
  ** Count occurrence of specified day of week between two dates
  **
  ** IN
  **   p_date_start         - Beginning date in range
  **   p_date_end           - End date in range 
  **   p_dayno              - Number indicating the day
  **                            1 = Monday
  **                            2 = Tuesday etc
  ** RETURN
  **   NUMBER  Count of occurrences of given day in range
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION count_day_of_week(
    p_date_start IN DATE,
    p_date_end   IN DATE,
    p_dayno      IN NUMBER
    ) RETURN NUMBER;

  /*
  ** is_a_weekend - Returns TRUE if date falls on weekend
  **
  ** Returns value True if the specified date falls on a weekend (Saturday or Sunday), 
  ** and the day is not designated as a working day
  **
  ** IN
  **   p_date               - Date to be tested
  **   p_saturday_workday   - TRUE if Saturdays are working days
  **   p_sunday_workday     - TRUE if Sundays are working days
  ** RETURN
  **   BOOLEAN  TRUE if the date is a non-working Saturday or Sunday
  **            FALSE in all other cases
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION is_a_weekend(
    p_date             IN DATE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
    ) RETURN BOOLEAN;

  /*
  ** is_a_holiday - Returns TRUE if specified date is a holiday
  **
  ** Returns value TRUE if the specified date is a holiday in 
  ** the specified country.
  **
  ** IN
  **   p_date         - Date to be tested
  **   p_country_id   - Check holiday dates for this country 
  **                    as defined in table COUNTRY_HOLIDAY
  ** RETURN
  **   BOOLEAN   TRUE if the date is a holiday, otherwise FALSE
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION is_a_holiday(
    p_date       IN DATE, 
    p_country_id IN country_holiday.country_id%TYPE
    ) RETURN BOOLEAN;

  /*
  ** is_a_working_day - Returns TRUE if date is a working day
  **
  ** Returns value TRUE if the specified date is a working day 
  ** (not a holiday or non-working weekend day), 
  ** FALSE if the date is a holiday or weekend.
  ** 
  **
  ** The holiday dates for each country are defined in the table
  ** COUNTRY_HOLIDAY.
  **
  ** IN
  **   p_date              - Date to be tested
  **   p_country_id        - Check holiday dates for this country
  **   p_saturday_workday  - TRUE if Saturdays are working days
  **   p_sunday_workday    - TRUE if Sundays are working days

  ** RETURN
  **   BOOLEAN   TRUE if the date is a working day 
  **             FALSE in all other cases
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION is_a_working_day(
    p_date             IN DATE, 
    p_country_id       IN country_holiday.country_id%TYPE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
    ) RETURN BOOLEAN;

  /*
  ** first_day - Date of first day of specified month
  **
  ** Returns the date of the first day of a month containing the 
  ** specified date.
  **
  ** IN
  **   p_date         - A valid date 
  ** RETURN
  **   DATE  is the date of the first day of the month
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION first_day(
    p_date IN DATE
    ) RETURN DATE;

  /*
  ** month_day_first - First date in month for specified day
  **
  ** Return the date of the first occurrence of the specified day of the week in the month.
  **
  ** For example, to find the first Tuesday (day 2) in August 2022:
  **   l_first_date := util_date.month_day_first(to_date('01-AUG-22','DD-MON-RR'),2);
  **
  ** This will give the date 2-AUG-22 which is the first Tuesday in August.
  **
  ** IN
  **   p_date         - Any valid date in the target month 
  **   p_day_no       - Number indicating the day 
  **                      1 = Monday
  **                      2 = Tuesday
  **                      3 = Wednesday
  **                      4 = Thursday
  **                      5 = Friday
  **                      6 = Saturday
  **                      7 = Sunday
  ** RETURN
  **   DATE  the date on which the specified day first occurs in month
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION month_day_first(
    p_date   IN DATE, 
    p_day_no IN NUMBER
    ) RETURN DATE;

  /*
  ** month_day_last - Last day in month that a given day occurs
  **
  ** Return the date of the last occurrence of the specified day of the week in the month.
  **
  ** For example, to find the last Tuesday (day 2) in August 2022:
  **   l_last_date := util_date.month_day_last(to_date('01-AUG-22','DD-MON-RR'),2);
  **
  ** This will give the date 30-AUG-22 which is the last Tuesday in August.
  **
  ** IN
  **   p_date         - Any valid date in the target month 
  **   p_day_no       - Number indicating the day 
  **                      1 = Monday
  **                      2 = Tuesday
  **                      3 = Wednesday
  **                      4 = Thursday
  **                      5 = Friday
  **                      6 = Saturday
  **                      7 = Sunday
  ** RETURN
  **   DATE  the date on which the specified day last occurs in month
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION month_day_last(
    p_date   IN DATE, 
    p_day_no IN NUMBER
    ) RETURN DATE;

  /*
  ** first_workday_month - First working day of specified month
  **
  ** Return first working day of month containing the specified date. 
  ** Holidays for the specified country are excluded.
  ** Saturdays and Sundays can be treated as either non-working
  ** weekend days, or working days.
  **
  ** IN
  **   p_date              - A date in the target month
  **   p_country_id        - Check holiday dates for this country.
  **                         See table COUNTRY_HOLIDAY.
  **   p_saturday_workday  - TRUE if Saturdays are working days
  **                         FALSE if they are weekend non-work days.
  **   p_sunday_workday    - TRUE if Sundays are working days
  **                         FALSE if they are weekend non-work days.
  ** RETURN
  **   DATE   Is the date of the first working day in the month
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION first_workday_month(
    p_date             IN DATE, 
    p_country_id       IN country_holiday.country_id%TYPE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
    ) RETURN DATE;

  /*
  ** last_workday_month - last working day of specified month
  **
  ** Return date of last working day of month containing the specified date. 
  ** Holidays for the specified country are excluded.
  ** Saturdays and Sundays can be treated as either non-working
  ** weekend days, or working days.
  **
  ** IN
  **   p_date              - A date in the target month
  **   p_country_id        - Check holiday dates for this country.
  **                         See table COUNTRY_HOLIDAY.
  **   p_saturday_workday  - TRUE if Saturdays are working days
  **                         FALSE if they are weekend non-work days.
  **   p_sunday_workday    - TRUE if Sundays are working days
  **                         FALSE if they are weekend non-work days.
  ** RETURN
  **   DATE   Is the date of the last working day in the month
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION last_workday_month(
    p_date             IN DATE, 
    p_country_id       IN country_holiday.country_id%TYPE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
    ) RETURN DATE;

  /*
  ** working_days_between - Number of working days between two dates
  **                        INEFFICIENT METHOD
  **
  ** Note that this function is included as an example of inefficient code
  ** using a loop to solve a problem. You should use the efficient algorthmic
  ** function WORKING_DAYS instead.
  **
  ** Returns the number of working days between two dates. 
  ** Holidays for the specified country are excluded. 
  ** Weekends are excluded depending on the value given for 
  ** p_saturday_workday and p_sunday_workday. 
  ** If p_saturday_workday is FALSE, then Saturdays are not counted as working days. 
  ** If p_sunday_workday is TRUE, then Sundays are counted as working days.
  **
  ** Example: 
  **   To get the number of working days remaining in the current month, for country UK 
  **   where Saturday and Sunday are not working days:
  ** 
  **   n := util_date.working_days_between(SYSDATE, last_day(SYSDATE), 'UK', FALSE, FALSE);
  **
  ** IN
  **   p_date_start        - First date in range 
  **   p_date_end          - Last date in range
  **   p_country_id        - Check holiday dates for this country.
  **                         See table COUNTRY_HOLIDAY.
  **   p_saturday_workday  - TRUE if Saturdays are working days
  **                         FALSE if they are weekend non-work days.
  **   p_sunday_workday    - TRUE if Sundays are working days
  **                         FALSE if they are weekend non-work days
  ** RETURN
  **   NUMBER  Is the count of working days within the specified date range
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION working_days_between(
    p_date_start       IN DATE, 
    p_date_end         IN DATE, 
    p_country_id       IN country_holiday.country_id%TYPE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
    ) RETURN NUMBER;

  /*
  ** working_days - Number of working days between two dates
  **                EFFICIENT METHOD
  **
  ** Returns the number of working days between two dates efficiently using an algorithm instead of a loop. 
  ** The table containing the holidays is read once only. 
  ** This method is many orders of magnitude quicker than the loop method in function working_days_between, 
  ** depending on the range of dates supplied.
  **
  ** Returns the number of working days between two dates. 
  ** Holidays for the specified country are excluded. 
  ** Weekends are excluded depending on the value given for 
  ** p_saturday_workday and p_sunday_workday. 
  ** If p_saturday_workday is FALSE, then Saturdays are not counted as working days. 
  ** If p_sunday_workday is TRUE, then Sundays are counted as working days.
  **
  ** Example: 
  **   To get the number of working days remaining in the current month, for country UK 
  **   where Saturday and Sunday are not working days:
  ** 
  **   n := util_date.working_days(SYSDATE, last_day(SYSDATE), 'UK', FALSE, FALSE);
  **
  ** IN
  **   p_date_start        - First date in range 
  **   p_date_end          - Last date in range
  **   p_country_id        - Check holiday dates for this country.
  **                         See table COUNTRY_HOLIDAY.
  **   p_saturday_workday  - TRUE if Saturdays are working days
  **                         FALSE if they are weekend non-work days.
  **   p_sunday_workday    - TRUE if Sundays are working days
  **                         FALSE if they are weekend non-work days
  ** RETURN
  **   NUMBER  Is the count of working days within the specified date range
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION working_days(
    p_date_start       IN DATE, 
    p_date_end         IN DATE, 
    p_country_id       IN country_holiday.country_id%TYPE, 
    p_saturday_workday IN BOOLEAN DEFAULT FALSE, 
    p_sunday_workday   IN BOOLEAN DEFAULT FALSE
    ) RETURN NUMBER; 

  /*
  ** easter_sunday - Date of Easter Sunday
  **
  ** Returns the date of Easter Sunday for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Easter Sunday falls for the specified year
  ** EXCEPTIONS
  **   e_invalid_data      - Reports error if p_year is not a valid integer between 1 and 3000.
  */
  FUNCTION easter_sunday(
    p_year IN  NUMBER
    ) RETURN DATE;

  /*
  ** easter_friday - Date of Easter Friday
  **
  ** Returns the date of Easter Friday for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Easter Friday falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION easter_friday(
    p_year IN NUMBER
    ) RETURN DATE;

  /*
  ** easter_saturday - Date of Easter Saturday
  **
  ** Returns the date of Easter Saturday for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Easter Saturday falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION easter_saturday(
    p_year IN NUMBER
    ) RETURN DATE;

  /*
  ** easter_monday - Date of Easter Monday
  **
  ** Returns the date of Easter Monday for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Easter Monday falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION easter_monday(
    p_year IN NUMBER
    ) RETURN DATE;

  /*
  ** shrove_tuesday - Date of Shrove Tuesday
  **
  ** Returns the date of Shrove Tuesday for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Shrove Tuesday falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION shrove_tuesday(
    p_year IN NUMBER
    ) RETURN DATE;

  /*
  ** ash_wednesday - Date of Ash Wednesday
  **
  ** Returns the date of Ash Wednesday for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Ash Wednesday falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION ash_wednesday(
    p_year IN NUMBER
    ) RETURN DATE;

  /*
  ** palm_sunday - Date of Palm Sunday
  **
  ** Returns the date of Palm Sunday for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Palm Sunday falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION palm_sunday(
    p_year IN NUMBER
    ) RETURN DATE;

  /*
  ** whitsunday - Date of Whitsunday
  **
  ** Returns the date of Whitsunday for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Whitsunday falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION whitsunday(
    p_year IN NUMBER
    ) RETURN DATE;

  /*
  ** whit_monday - Date of Whit Monday
  **
  ** Returns the date of Whit Monday for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Whit Monday falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */ 
  FUNCTION whit_monday(
    p_year IN NUMBER
    ) RETURN DATE;

  /*
  ** ascension_day - Date of Ascension
  **
  ** Returns the date of Ascension for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Ascension falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION ascension_day(
    p_year IN NUMBER
    ) RETURN DATE;

  /*
  ** corpus_christi - Date of Corpus Christi
  **
  ** Returns the date of Corpus Christi for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Corpus Christi falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  -- Returns the date of Corpus Christi for the given year
  FUNCTION corpus_christi(
    p_year IN NUMBER
    ) RETURN DATE;

  /*
  ** mardi_gras - Date of Mardi Gras
  **
  ** Returns the date of Mardi Gras for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Mardi Gras falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION mardi_gras(
    p_year IN NUMBER
    ) RETURN DATE;

 /*
  ** carnival_monday - Date of Carnival Monday
  **
  ** Returns the date of Carnival Monday for a specified year.
  **
  ** IN
  **   p_year         - A 4-digit year number
  ** RETURN
  **   DATE  is the date on which Carnival Monday falls for the specified year
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION carnival_monday(
    p_year IN NUMBER
    ) RETURN DATE;

END util_date;
/

CREATE OR REPLACE PACKAGE BODY util_date AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : util_date
  ** Description   : Date manipulation functions
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                Description
  **------------------------------------------------------------------------
  ** 16/06/2022       Ian Bond            Program created
  ** 21/08/2023       Ian Bond            Use to_number function when assigning 
  **                                      char values to numeric variables. 
  ** 24/09/2025       Ian Bond            Add exceptions to handle incorrect input
  **                                      values such as years containing letters or
  **                                      decimals.
  ** 27/09/2025       Ian Bond            Improve exception handling.
  ** 31/03/2026       Ian Bond            Change function names:
  **                                        first_day_month --> month_first_day
  **                                        last_day_month  --> month_day_last
  */



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

  FUNCTION easter_friday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) -2;
  END easter_friday;

  FUNCTION easter_saturday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) -1;
  END easter_saturday;

  FUNCTION easter_monday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) +1;
  END easter_monday;

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

  FUNCTION whitsunday(
    p_year IN NUMBER
  ) 
  RETURN DATE 
  IS
  BEGIN
    RETURN easter_sunday(p_year) +49;
  END whitsunday;

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