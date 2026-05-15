CREATE OR REPLACE PACKAGE stats AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : stats
  ** Description   : Statistics Package
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                Description
  **------------------------------------------------------------------------
  ** 14/05/2026       Ian Bond            Move stats functions from util_numeric package, reference types in plsql_types.pks.
  */
 
  
  /*  
  ** Global constants
  */
  gc_error            CONSTANT plsql_constants.severity_error%TYPE := plsql_constants.severity_error;
  gc_info             CONSTANT plsql_constants.severity_info%TYPE  := plsql_constants.severity_info;
  gc_warn             CONSTANT plsql_constants.severity_warn%TYPE  := plsql_constants.severity_warn;
  gc_max_array_size   CONSTANT plsql_constants.max_arraysize%TYPE  := plsql_constants.max_arraysize;


  /*
  ** Global variables
  */

  
  /*
  ** Global exceptionst
  */
  
  e_invalid_data EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_invalid_data,-20001);
  
  e_invalid_base EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_invalid_base,-20002);
  
  e_invalid_alpha_range EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_invalid_alpha_range,-20003);

  
  
  /*
  ** Public functions and procedures
  */
  
    
  /*
  ** median_array - Calculate median value for an array
  **
  ** Calculate the median for an array of numbers that have been sorted
  ** into ascending sequence.
  ** e.g.
  ** Where the number of elements in the array is odd, the median is the 
  ** middle value.
  ** 1,2,3,4,5,6,7
  ** Median value is 4
  **
  ** For an even number of elements take the average of the middle two
  ** values.
  ** 1,2,3,4,5,6
  ** Median value is (3+4)/2 = 3.5
  **
  ** IN
  **   p_array                - Array of pre-sorted numbers
  **
  ** RETURN
  **   NUMBER                 - Median value of array
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION median_array(
    p_array       IN plsql_types.t_number_array
  ) RETURN NUMBER;
  
  /*
  ** median - Calculate median value for a list of numbers
  **
  ** Calculate the median for a list of numbers that have been sorted
  ** into ascending sequence.
  ** e.g.
  ** Where the number of elements in the array is odd, the median is the 
  ** middle value.
  ** '1,2,3,4,5,6,7'
  ** Median value is 4
  **
  ** For an even number of elements take the average of the middle two
  ** values.
  ** '1,2,3,4,5,6'
  ** Median value is (3+4)/2 = 3.5
  **
  ** IN
  **   p_list                 - String containing list of numbers separated by commas, pre-sorted
  **
  ** RETURN
  **   NUMBER                 - Median value of array
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION median(
    p_list       IN VARCHAR2
  ) RETURN NUMBER;
 
  
  /*
  ** populate_frequency_table
  **
  ** Populate a frequency table structure with data from an array of numbers.
  ** The frequency table will store a record for each distinct number in the array.
  ** Each record contains:
  **    key                   - Unique occurrence of number in array
  **    frequency             - Count of occurrences of key in array.
  **
  ** The function will return the populated frequency table.
  ** The frequency table will be used by other functions to calculate: Sum, Count,
  ** Mean, Mode (1 or more values), highest, lowest, range.
  **
  ** See function get_stats.
  **
  ** IN
  **   p_array                - Array of numbers, must not be null.
  **
  ** RETURN
  **   t_frequency_table      - Table of t_frequency_row
  **                            t_frequency_row is record (key, frequency)
  **
  ** EXCEPTIONS
  **   e_null_array           - p_array must not be null.
  **   e_null_value           - p_array must not contain null values.
  **   e_non_integer          - Only integers allowed in p_array.
  */
  FUNCTION populate_frequency_table(
    p_array IN plsql_types.t_number_array
  ) RETURN plsql_types.t_frequency_table;

  /*
  ** frequency_table_sum
  **
  ** Calculate the sum of values in the frequency table.
  ** Sum of (key * frequency)
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Sum of values in p_frequency_table
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */
  FUNCTION frequency_table_sum(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;

  /*
  ** frequency_table_count
  **
  ** Calculate the count of all values in the frequency table.
  ** Sum of frequency
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   PLS_INTEGER            - count of values in p_frequency_table
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */
  FUNCTION frequency_table_count(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN PLS_INTEGER;
  
  /*
  ** frequency_table_mean
  **
  ** Calculate the mean of values in the frequency table.
  ** Mean = Sum / Count
  ** SQL equivalent AVG(n)
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Mean of values in p_frequency_table
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */
  FUNCTION frequency_table_mean(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;
  
  /*
  ** value_at_rank
  **
  ** Helper function for frequency_table_median
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **   p_rank                 - Integer
  **
  ** RETURN
  **   NUMBER                 - Key value at rank position
  **
  ** EXCEPTIONS
  */ 
  FUNCTION value_at_rank(
    p_frequency_table IN plsql_types.t_frequency_table,
    p_rank IN PLS_INTEGER
  ) RETURN NUMBER;
  
  /*
  ** frequency_table_median
  **
  ** Calculate the median value of the frequency table.
  ** Median is the mid point value of array if number of elements is odd.
  ** If number of elements is even, median is average of two mid values.
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Median value of p_frequency_table
  **
  ** EXCEPTIONS
  */
  FUNCTION frequency_table_median(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;
  

  /*
  ** frequency_table_mode
  **
  ** Calculate the mode values of the frequency table.
  ** These are the values with the highest frequency (count).
  ** There may be 1 or more values returned.
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   t_num_table            - Table of modes
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */
  FUNCTION frequency_table_mode(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN plsql_types.t_num_table;
  
  /*
  ** frequency_table_highest
  **
  ** Calculate the highest value in the frequency table.
  ** The table is sorted ascending so highest is the last value.
  ** SQL equivalent MAX(n)
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Highest value in p_frequency_table
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */  
  FUNCTION frequency_table_highest(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;
  
  /*
  ** frequency_table_lowest
  **
  ** Calculate the lowest value in the frequency table.
  ** The table is sorted ascending to lowest is the first value.
  ** SQL equivalent MIN(n)
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Lowest value in p_frequency_table
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */ 
  FUNCTION frequency_table_lowest(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;
  
  /*
  ** frequency_table_range
  **
  ** Calculate the range of values in the frequency table.
  ** Range = difference between highest and lowest value.
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Range of values in p_frequency_table
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */
  FUNCTION frequency_table_range(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;

  /*
  ** variance_pop
  **
  ** Calculate the population variance for a frequency table.
  ** Equivalent to SQL aggregate function VAR_POP(n)
  **
  ** VAR_POP = sum((x_i - m)^2) / N
  **
  ** VAR_POP = Population variance
  ** sum = Summation function
  ** x_i = Each individual data point in the population
  ** m = Mean of the population
  ** N = Total number of data points in the population
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Population Variance for Range of values in p_frequency_table
  **
  ** EXCEPTIONS
  */
  FUNCTION variance_pop(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;
  
  /*
  ** stddev_pop
  **
  ** Calculate the population standard deviation for a frequency table.
  ** Equivalent to SQL aggregate function STDDEV_POP(n)
  **
  ** d = sqrt(sum((x_i - m)^2) / N)
  **
  ** d = Population standard deviation
  ** sqrt = Square root function
  ** sum = Summation function
  ** x_i = Each individual data point in the population
  ** m = Mean of the population
  ** N = Total number of data points in the population
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Population Standard Deviation for Range of values in p_frequency_table
  **
  ** EXCEPTIONS
  */
  FUNCTION stddev_pop(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;
  
  /*
  ** variance_samp
  **
  ** Calculate the sample variance for a frequency table.
  ** Equivalent to SQL aggregate function VAR_SAMP(n)
  **
  ** VAR_SAMP = sum((x_i - x_bar)^2) / (n - 1)
  **
  ** VAR_SAMP = Sample variance
  ** sum = Summation function
  ** x_i = Each individual data point in the sample
  ** x_bar = Sample mean
  ** n = Total number of data points in the sample
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Sample Variance for Range of values in p_frequency_table
  **
  ** EXCEPTIONS
  */
  FUNCTION variance_samp(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;
  
  /*
  ** stddev_samp
  **
  ** Calculate the sample standard deviation for a frequency table.
  ** Equivalent to SQL aggregate function STDDEV_SAMP(n)
  **
  ** s = sqrt(sum((x_i - x_bar)^2) / (n - 1))
  **
  ** s = Sample standard deviation
  ** sqrt = Square root function
  ** sum = Summation function
  ** x_i = Each individual data point in the sample
  ** x_bar = Sample mean
  ** n = Total number of data points in the sample
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Standard Deviation Variance for Range of values in p_frequency_table
  **
  ** EXCEPTIONS
  */
  FUNCTION stddev_samp(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;

  /*
  ** percentile_disc
  **
  ** Calculate discrete (actually observed value) percentile for a frequency table.
  ** SQL equivalent PERCENTILE_DISC(n) WITHIN GROUP (ORDER BY m)
  **
  ** Usage:
  **
  ** First create a frequency table from a comma separated list of numbers or array,
  ** If you have a csv list call get_stats_list.
  ** If you have a populated array, call get_stats_array.
  ** Get_stats_* returns t_stats_result which contains a frequency table (freq_tbl).
  **
  ** Example to calculate 75th percentile for a csv list of numbers.
  **  
  **  SET SERVEROUTPUT ON
  **  DECLARE
  **    v_stats_result plsql_types.t_stats_result;
  **    v_pct_disc NUMBER;
  **  BEGIN
  **    v_stats_result := stats.get_stats_list('1,2,3,10,20,999');
  **    v_pct_disc := stats.percentile_disc(v_stats_result.freq_tbl,0.75);
  **    dbms_output.put_line('PCT_DISC='||to_char(v_pct_disc));
  **  END;
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **   p_pct                  - Percentile a number > 0 and < 1
  **
  **
  ** RETURN
  **   NUMBER                 - Key (observed value) in frequency table at the percentile p_pct
  **
  ** EXCEPTIONS
  */
  FUNCTION percentile_disc(
    p_frequency_table IN plsql_types.t_frequency_table,
    p_pct             IN NUMBER 
  ) RETURN NUMBER;

  /*
  ** percentile_cont
  **
  ** Calculate continuous interpolated percentile for a frequency table.
  ** SQL equivalent PERCENTILE_CONT
  **
  ** pos = 1 + (N - 1) x p
  ** 
  ** N = total observations
  ** p = percentile a number >0 and <=1
  ** pos may be fractional
  **
  ** X = X_lower + (pos - lower) x (x_upper - x_lower)
  **
  ** This may return a fractional result even if inputs are integer.
  **
  ** Usage:
  **
  ** First create a frequency table from a comma separated list of numbers or array,
  ** If you have a csv list call get_stats_list.
  ** If you have a populated array, call get_stats_array.
  ** Get_stats_* returns t_stats_result which contains a frequency table (freq_tbl).
  **
  ** Example to calculate 75th percentile for a csv list of numbers.
  **  
  **  SET SERVEROUTPUT ON
  **  DECLARE
  **    v_stats_result plsql_types.t_stats_result;
  **    v_pct_cont NUMBER;
  **  BEGIN
  **    v_stats_result := stats.get_stats_list('1,2,3,10,20,999');
  **    v_pct_cont := stats.percentile_cont(v_stats_result.freq_tbl,0.75);
  **    dbms_output.put_line('PCT_CONT='||to_char(v_pct_cont));
  **  END;
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **   p_pct                  - Percentile a number > 0 and < 1
  **
  **
  ** RETURN
  **   NUMBER                 - Interpolated value derived from frequency table, percentile p_pct
  **
  ** EXCEPTIONS
  */
  FUNCTION percentile_cont(
    p_frequency_table IN plsql_types.t_frequency_table,
    p_pct             IN NUMBER 
  ) RETURN NUMBER;

  /*
  ** iqr - Interquartile range
  **
  ** Calculate interquartile range (midspread, middle 50%, H-spread) as the difference between the
  ** 75th and 25th percentiles of the data.
  **
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   NUMBER                 - Interquartile range of the frequency table
  **
  ** EXCEPTIONS
  */
  FUNCTION iqr(
     p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER;
  
  
  /*
  ** get_stats
  **
  ** Statistics core function.
  ** Receives an array of numbers.
  ** Calls populate_frequency_table to create a frequency table.
  ** Calculates statistics for the frequency table.
  ** Returns results in a composite record, t_stats_result:
  **    stats       t_stats_summary     Record containing statistics: sum_vales (SUM), n_total (COUNT(*)), 
  **                                    distinct_n (COUNT(KEY)), mean (AVG), median, mode_values(N),lowest (MIN), 
  **                                    highest (MAX), range, variance_pop (VAR_POP), variance_samp (VAR_SAMP), 
  **                                    stddev_pop (STDDEV_POP), stddev_samp (STDDEV_SAMP), IQR
  **    freq_tabl   t_frequency_table   Table of t_frequency_row: key, frequency
  **
  ** NB: mode_values is a table of integer t_num_table as >1 mode may be returned
  **
  **
  ** IN
  **   p_array                - Array of numbers
  **
  ** RETURN
  **   t_stats_result         - Record containing stats and frequency table
  **
  ** EXCEPTIONS
  **   e_null_array           - Array must not be null
  **   e_null_values          - Null values not allowed in array
  */
  FUNCTION get_stats(
    p_array IN plsql_types.t_number_array
  ) RETURN plsql_types.t_stats_result;
  
  /*
  ** get_stats_array
  **
  ** Calls get_stats passing array of numbers. Array must not be null,
  ** or contain null values.
  ** Returns composite record t_stats_result containing statistics and 
  ** frequency table from which they were generated.
  ** 
  **
  ** IN
  **   p_array                - Array of numbers
  **
  ** RETURN
  **   t_stats_result         - Record containing stats and frequency table
  **
  ** EXCEPTIONS
  **   e_null_array           - Array must not be null.
  */
  FUNCTION get_stats_array(
    p_array IN plsql_types.t_number_array
  ) RETURN plsql_types.t_stats_result;
  
  /*
  ** get_stats_list
  **
  ** Receives a string of comma separated numbers (list).
  ** The list must not be null or contain null values.
  ** Converts list to an array.
  ** Calls get_stats_array passing array.
  ** Returns composite record t_stats_result containing statistics and 
  ** frequency table from which they were generated.  
  **
  ** IN
  **   p_list                 - String of comma separated numbers
  **
  ** RETURN
  **   t_stats_result         - Record containing stats and frequency table
  **
  ** EXCEPTIONS
  **   e_null_list            - List must not be null.
  */
  FUNCTION get_stats_list(
    p_list IN VARCHAR2
  ) RETURN plsql_types.t_stats_result;
  
  /*
  ** get_stats_project
  **
  ** Retrieve stat_data for specified stats_project_id,
  ** populate array with data, and call get_stats_array passing array which
  ** returns composite record t_stats_result containing statistics and 
  ** frequency table generated from stats data.
  **
  ** IN
  **   p_project_id           - Identifies project for which to retrieve stats_data
  **
  ** RETURN
  **   t_stats_result         - Record containing stats and frequency table
  **
  ** EXCEPTIONS
  **   e_project_null         - Project ID must not be null, returns null
  **   e_project_not_found    - Project_id not found on stats_project, returns null
  **   e_no_data_found        - No data found in stats_data, returns null
  **   e_array_empty          - Failed to populate array from stats_data, returns null
  **   e_null_value           - Null value not allowed in stats_data, returns null
  */
  FUNCTION get_stats_project(
    p_project_id IN stats_project.stats_project_id%TYPE
  ) RETURN plsql_types.t_stats_result;
  
  /*
  ** display_frequency_table
  **
  ** Display contents of frequency table.
  **
  ** IN
  **   p_stats_result          - Record containing stats and frequency table
  **
  */
  PROCEDURE display_frequency_table(
    p_stats_result IN plsql_types.t_stats_result
  );

  /*
  ** display_stats
  **
  ** Display statistics derived from a frequency table passed in p_stats_result.
  ** Percentiles will be calculated by this function, and so
  ** are not stored in p_stats_result.
  ** Calling display_stats to calculate percentiles means you don't need
  ** to re-create the Frequency Table each time you want to calculate a different percentile.
  ** If you do not specify a percentile to be calculated, a default value of 0.5 is used.
  **
  ** IN
  **   p_stats_result           - Record containing stats and frequency table
  **   p_pct                    - Optional percentile to calculate, number between 0 and 1, default 0.5
  **
  */
  PROCEDURE display_stats(
    p_stats_result IN plsql_types.t_stats_result,
    p_pct IN NUMBER DEFAULT 0.5
  );
   
END stats;
/