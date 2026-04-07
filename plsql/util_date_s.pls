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