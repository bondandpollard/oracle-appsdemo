CREATE OR REPLACE PACKAGE util_numeric AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : util_numeric
  ** Description   : Number handling utilities
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                Description
  **------------------------------------------------------------------------
  ** 16/06/2022       Ian Bond            Program created
  ** 12/02/2024       Ian Bond            Add AI generated function num_to_alphanumeric
  **                                      to convert integer to alphanumeric code.
  ** 16/03/2024       Ian Bond            Add function to calculate pi   
  ** 25/09/2025       Ian Bond            Ensure hex numbers are uppercase.
  **                                      Validate input to alphatodec, input string must
  **                                      only contain characters A to Z.
  **                                      Amend base conversion to handle -ve numbers.
  ** 27/09/2025       Ian Bond            Improve exception handling WHEN OTHERS.  
  **                                      Fix handling of NULL and 0 in base/hex conversion.
  ** 05/02/2026       Ian Bond            Add function binary_chop_search.
  ** 07/02/2026       Ian Bond            Add functions:
  **                                      list_to_array
  **                                      array_to_list
  **                                      binary_search
  **                                      binary_rank
  **                                      binary_search_leftmost
  **                                      binary_search_rightmost
  **                                      binary_search_predecessor
  **                                      binary_search_successor
  **                                      binary_search_nearest
  **                                      binary_search_range
  ** 12/02/2026       Ian Bond            search_unsorted
  ** 18/02/2026       Ian Bond            Modify binary searches to allow either comma separated list
  **                                      or array to be searched. Wrapper functions accept list as input, 
  **                                      convert the list to an array, then call binary search passing array.
  **                                      This modular approach gives flexibility.
  ** 19/02/2026       Ian Bond            Add statistical function to calculate median.
  ** 20/02/2026       Ian Bond            Add remove_duplicates_array to remove duplicate values from an array,
  **                                      remove_duplicates_no_sort array to remove duplicates without sorting.
  ** 21/02/2026       Ian Bond            Disallow NULL values in array for binary searches. Add function array_contains_null.
  ** 22/02/2026       Ian Bond            Add function is_sorted_array. Amend binary search functions to check array sorted.
  ** 23/02/2026       Ian Bond            Add functions to populate frequency table and calculate: sum, count, mean (AVG), mode,
  **                                      highest (MAX), lowest (MIN), range.
  ** 24/02/2026       Ian Bond            Add variance and standard deviation functions (Oracle SQL equivalents in right column):
  **                                      variance_pop          VAR_POP
  **                                      stddev_pop            STDDEV_POP
  **                                      variance_samp         VAR_SAMP
  **                                      stddev_samp           STDDEV_SAMP
  **                                      percentile_disc       PERCENTILE_DISC
  **                                      percentile_cont       PERCENTILE_CONT
  **                                      iqr (interquartile range)
  **
  ** 25/02/2026       Ian Bond            Refactor stats functions into clean, 'build-once-use-everywhere' library.
  **                                      Create wrapper functions to generate statistics:-
  **
  **                                      get_stats_list          : Receives a string of comma separated numbers, calls list_to_array to
  **                                                                convert to array, then calls get_stats_array passing array.
  **                                                                RETURN t_stats_result (record containing stats and frequency table)
  **
  **                                      get_stats_array         : Receives array. Calls get_stats passing array.
  **                                                                RETURN t_stats_result (record containing stats and frequency table)
  **
  **                                      get_stats               : Core stats function. Receives array. Calls populate_frequency_table
  **                                                                passing array, which returns frequency table.
  **                                                                calculates the statistics for frequency table (sum, mean, median, mode, lowest,  
  **                                                                highest, range, variance, standard deviation)
  **                                                                RETURN composite record containing frequency table plus stats 't_stats_result'. 
  **
  **                                      populate_frequency_table: Receives array of numbers and generates a frequency table.
  **                                                                RETURN frequency table
  **
  **                                      display_frequency_table : Procedure. Receives t_stats_result and displays frequency table.
  **                                      display_stats           : Procedure. Receives t_stats_result and displays all statistics.
  **                                      percentile_cont         : Receives frequency table and percentile (>0 <=1) and returns number.
  **                                      percentile_disc         : Receives frequency table and percentile (>0 <=1) and returns number.
  **
  ** 04/03/2026       Ian Bond            Add get_stats_project to call get_stats with data from table stats_data.
  ** 22/03/2026       Ian Bond            Add functions to write frequency table and stats to CSV file.
  ** 24/03/2026       Ian Bond            Add function to export project stats to CSV file.
  ** 12/02/2026       Ian Bond            Allow decimal places in statistics data.
  ** 13/05/2026       Ian Bond            Add function reverse_array, reverse_list - reverse the order of an array of numbers. NB: Does not sort array.
  ** 14/05/2026       Ian Bond            Move search and stats functions to separate packagees, and reference common types in plsql_types.pks.
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
  ** Global exceptions
  */
  
  e_invalid_data EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_invalid_data,-20001);
  
  e_invalid_base EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_invalid_base,-20002);
  
  e_invalid_alpha_range EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_invalid_alpha_range,-20003);

  /*
  ** TYPES
  */
  
  /*
  ** Public functions and procedures
  */
  
  /*
  ** list_to_array
  **
  ** Convert a comma separated list of numbers to an array.
  **
  ** IN
  **   p_list               - String containing list of numbers separated by commas. String must not be null.
  **
  ** RETURN
  **   t_number_array       - Array of numbers
  ** EXCEPTIONS
  **   e_list_size          - List entries exceed array capacity
  **   e_null_list          - List empty
  */
  FUNCTION list_to_array (
    p_list IN VARCHAR2
  ) RETURN plsql_types.t_number_array;

  /*
  ** array_to_list
  **
  ** Convert an array of numbers to a string containing numbers separated by commas.
  ** NULL values are excluded from the result.
  **
  ** IN
  **   p_array              - Array of numbers. Must not be null.
  **
  ** RETURN
  **   VARCHAR2             - String containing numbers separated by commas
  ** EXCEPTIONS
  **   e_array_null         - Array is empty
  */
  FUNCTION array_to_list (
    p_array IN plsql_types.t_number_array
  ) RETURN VARCHAR2;
  
  /*
  ** dectobase - Convert a decimal integer to the specified base value
  **
  ** IN
  **   p_number             - Decimal integer to be converted
  **   p_base               - Integer representing number base, e.g. 2 is Binary, 8 is octal, 
  **                          16 is hexadecimal
  ** RETURN
  **   VARCHAR2             - A string representing the base value of the decimal
  ** EXCEPTIONS
  **   e_null_value         - p_number is NULL, return NULL
  **   e_zero_value         - Return 0
  **   e_invalid_data       - p_base < 2 or > 16 not allowed
  */
  FUNCTION dectobase (
    p_number IN INTEGER, 
    p_base   IN INTEGER
  ) RETURN VARCHAR2;

  /*
  ** basetodec - Convert a number of the specified base to a decimal value
  **
  ** IN
  **   p_number             - A string containing the base value to be converted to decimal.
  **                          e.g. '10' is the binary string representing 2 in base 10.
  **   p_base               - Integer representing number base, e.g. 2 is Binary, 8 is octal, 
  **                          16 is hexadecimal
  ** RETURN
  **   NUMBER               - Is the decimal value of the specified base number
  ** EXCEPTIONS
  **   e_null_value         - p_number is NULL not allowed
  **   e_invalid_data       - Log error if number passed contains characters other than 0 - 9, A - Z.
  **   e_invalid_base       - Log error if number base passed not in range 1 to 16.
  */
  FUNCTION basetodec (
    p_number IN VARCHAR2, 
    p_base   IN INTEGER
  ) RETURN NUMBER;

  /*
  ** dectohex - Convert a decimal integer to a hexadecimal string value
  **
  ** IN
  **   p_number              - A decimal integer value to be converted to Hexadecimal
  ** RETURN
  **   VARCHAR2              - A string containing the Hexadecimal value of the decimal integer
  ** EXCEPTIONS
  **   e_null_value          - p_number is NULL not allowed
  */
  FUNCTION dectohex (
    p_number IN INTEGER
  ) RETURN VARCHAR2;

  /*
  ** hextodec - Convert a hexadecimal string value to a decimal integer
  **
  ** IN
  **   p_number              - Hexadecimal string to be converted to decimal
  ** RETURN
  **   NUMBER                - The decimal value of the Hexadecimal number
  ** EXCEPTIONS
  **   e_null_value          - p_number is NULL not allowed
  **   e_invalid_data        - Log error if number passed contains characters other than 0 - 9, A - Z.
  */
  FUNCTION hextodec (
    p_number IN VARCHAR2
  ) RETURN NUMBER;

  /*
  ** factorial - Calculate the factorial for a positive integer
  **
  ** IN
  **   p_number              - Positive integer
  ** RETURN
  **   NUMBER                - Factorial of p_number
  ** EXCEPTIONS
  **   <exception_name1>     - <brief description>
  */
  FUNCTION factorial(
    p_number IN INTEGER
  ) RETURN NUMBER;

  /*
  ** factorialr - Calculate the factorial for a positive integer
  **
  ** Calculate the factorial using a recursive function.
  ** IN
  **   p_number              - Positive integer
  ** RETURN
  **   NUMBER                - Factorial of p_number
  ** EXCEPTIONS
  **   <exception_name1>     - <brief description>
  */
  FUNCTION factorialr (
    p_number IN INTEGER
  ) RETURN NUMBER;
  
  /*
  ** sort_array - Sort array of numbers
  **
  ** 
  ** IN
  **   p_array               - Array of numbers to sort
  **   p_order               - Sort sequence 'A' for Ascending (Default), all other values Descending
  ** RETURN
  **   t_number_array        - Array containing the sorted numbers
  ** EXCEPTIONS
  **   <exception_name1>     - <brief description>
  */
  FUNCTION sort_array (
    p_array  IN plsql_types.t_number_array,
    p_order  IN VARCHAR2 DEFAULT 'A'
  ) RETURN plsql_types.t_number_array;

  /*
  ** sort_numbers - Sort a list of numbers
  **
  ** 
  ** IN
  **   p_list                - String of numbers to sort, separated by commas
  **   p_order               - Sort sequence 'A' for Ascending (Default), all other values Descending
  ** RETURN
  **   VARCHAR2              - String containing the sorted list of numbers
  ** EXCEPTIONS
  **   e_list_null           - p_list must not be null
  */
  FUNCTION sort_numbers (
    p_list   IN VARCHAR2, 
    p_order  IN VARCHAR2 DEFAULT 'A'
  ) RETURN VARCHAR2;
  
  /*
  ** num_to_alphanumeric - Convert integer to alphanumeric code
  **
  ** A copilot AI generated pl/sql function to convert numbers to an alphanumeric code where:
  ** 1=A, 2=B, 26=Z, 27=AA, 28=AB, 52=AZ, 53=BA etc.
  **
  ** Here is how the function works:
  ** We start with the input number.
  ** In each iteration, we calculate the remainder after dividing by 26 (the number of letters in the alphabet).
  ** We convert the remainder to the corresponding letter (‘A’ for 1, ‘B’ for 2, and so on).
  ** We prepend the letter to the result string.
  ** We update the input number by subtracting the remainder and dividing by 26.
  ** Repeat until the input number becomes zero.
  ** Now you can use this function to convert numbers to the desired alphanumeric code. For example:
  **
  ** NUM_TO_ALPHANUMERIC(1) returns 'A'.
  ** NUM_TO_ALPHANUMERIC(27) returns 'AA'.
  ** NUM_TO_ALPHANUMERIC(52) returns 'AZ'.
  ** NUM_TO_ALPHANUMERIC(53) returns 'BA'.
  ** 
  ** IN
  **   p_number              - Positive integer to convert
  ** RETURN
  **   VARCHAR2              - String containing the alphanumeric code
  ** EXCEPTIONS
  **   e_invalid_data        - p_number must be an integer > 0
  */
  FUNCTION num_to_alphanumeric (
    p_number IN NUMBER
  ) RETURN VARCHAR2;

  /*
  ** dectoalpha - Convert a decimal value to an alphabetic code
  **
  ** Convert a positive integer into an alphabetic code, using the specified range of letters. 
  ** Use an efficient calculation instead of a simple but highly inefficient loop. 
  ** 
  ** e.g.
  **
  ** 1=A
  ** 2=B
  ** 3=C
  ** 26=Z
  ** 27=AA
  ** 28=AB 
  ** 52=AZ
  ** 53=BA
  ** 700=ZX
  ** 702=ZZ
  ** 703=AAA
  ** 704=AAB
  ** 18278=ZZZ
  ** 18279=AAAA
  ** 72385=DCBA
  ** 475254=ZZZZ
  ** 1143606698788=ELIZABETH
  ** 
  ** IN
  **   p_number              - Positive decimal integer to be converted
  **   p_range               - Number between 1 and 26, representing range of alphabetic characters to use in code.
  **                           e.g. 5 would use letters A to E.
  ** RETURN
  **   VARCHAR2              - String containing the alphabetic code
  ** EXCEPTIONS
  **   e_invalid_data        - Log error if number passed < 1
  */
  FUNCTION dectoalpha (
    p_number IN INTEGER, 
    p_range  IN INTEGER
  ) RETURN VARCHAR2;

  /*
  ** alphatodec - Convert an alphabetic code to a decimal integer
  **
  ** Decode an alphabetic code, with the specified range of characters, converting it back to an integer. 
  **
  ** Example alphacodes using all 26 letters of the alphabet:
  ** A=1
  ** B=2
  ** Z=26
  ** AA=27
  ** ZZ=702
  ** AAA=703
  ** 
  ** IN
  **   p_code               - String containing the alphabetic code
  **   p_range              - Number between 1 and 26, representing range of alphabetic characters to use in code.
  **                          e.g. 5 would use letters A to E.
  ** RETURN
  **   NUMBER               - Decimal integer value of the alphabetic code
  ** EXCEPTIONS
  **   e_invalid_data       - Log error if alphabetic code passed contains letters outside range, e.g. if range is 5, only A-E allowed.
  */
  FUNCTION alphatodec(
    p_code  IN VARCHAR2, 
    p_range IN INTEGER
  ) RETURN NUMBER;

  /*
  ** pi - Calculate pi to a reasonable accuracy
  **
  ** RETURN
  **   NUMBER  Value of pi
  **
  */
  FUNCTION pi
    RETURN NUMBER;

  /*
  ** is_odd - Returns TRUE if odd number
  **
  **
  ** IN
  **   p_number               - Number to test
  **
  ** RETURN
  **   BOOLEAN                - TRUE if number odd else FALSE
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION is_odd(
    p_number       IN NUMBER
  ) RETURN BOOLEAN;
  
  /*
  ** is_even - Returns TRUE if even number
  **
  **
  ** IN
  **   p_number               - Number to test
  **
  ** RETURN
  **   BOOLEAN                - TRUE if number even else FALSE
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION is_even(
    p_number       IN NUMBER
  ) RETURN BOOLEAN;
    

  /*
  ** remove_duplicates_nosort_array 
  **
  ** Remove duplicate values from an array without sorting it.
  **
  ** IN
  **   p_array                - Array of numbers
  **
  ** RETURN
  **   t_number_array         - Array without duplicate values
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION remove_duplicates_nosort_array(
    p_array       IN plsql_types.t_number_array
  ) RETURN plsql_types.t_number_array;
 
  /*
  ** remove_duplicates_nosort_list 
  **
  ** Remove duplicate values from an unsorted list of numbers separated by commas.
  **
  ** IN
  **   p_list                 - String containing list of comma separated numbers.
  **
  ** RETURN
  **   VARCHAR2               - List of numbers without duplicate values
  **
  ** EXCEPTIONS
  **   e_null_list            - p_list must not be null
  */
  FUNCTION remove_duplicates_nosort_list(
    p_list       IN VARCHAR2
  ) RETURN VARCHAR2;
  
  /*
  ** remove_duplicates_array 
  **
  ** Remove duplicate values from an array.
  ** Array is sorted into ascending sequence.
  **
  ** IN
  **   p_array                - Array of numbers
  **
  ** RETURN
  **   t_number_array         - Array without duplicate values
  **
  ** EXCEPTIONS
  **   e_null_array           - p_array must not be null
  */
  FUNCTION remove_duplicates_array(
    p_array       IN plsql_types.t_number_array
  ) RETURN plsql_types.t_number_array;
  
  /*
  ** remove_duplicates_list 
  **
  ** Remove duplicate values from a list of numbers separated by commas.
  ** The list is sorted into ascending sequence.
  **
  ** IN
  **   p_list                 - String containing list of comma separated numbers.
  **
  ** RETURN
  **   VARCHAR2               - List of numbers without duplicate values, sorted ascending.
  **
  ** EXCEPTIONS
  **   e_null_list            - p_list must not be a null string
  */
  FUNCTION remove_duplicates_list(
    p_list       IN VARCHAR2
  ) RETURN VARCHAR2;
  

  /*
  ** reverse_array 
  **
  ** Reverse order of numbers in an array.
  ** Array is NOT sorted sequentially.
  **
  ** IN
  **   p_array                - Array of numbers
  **
  ** RETURN
  **   t_number_array         - Array in reverse order
  **
  ** EXCEPTIONS
  **   e_null_array           - p_array must not be null
  */
  FUNCTION reverse_array(
    p_array       IN plsql_types.t_number_array
  ) RETURN plsql_types.t_number_array;
  
  /*
  ** reverse_list 
  **
  ** Reverse order of list of numbers separated by commas.
  ** The list is NOT sorted sequentially!
  **
  ** IN
  **   p_list                 - String containing list of comma separated numbers.
  **
  ** RETURN
  **   VARCHAR2               - List of numbers in reverse order.
  **
  ** EXCEPTIONS
  **   e_null_list            - p_list must not be a null string
  */
  FUNCTION reverse_list(
    p_list       IN VARCHAR2
  ) RETURN VARCHAR2;
  
  /*
  ** array_contains_null      - Check if array contains null values
  **
  ** IN
  **   p_array                - Array of numbers to be checked.
  ** RETURN
  **   BOOLEAN                - TRUE if NULL values found cotherwise FALSE.
  ** EXCEPTIONS
  **   e_null_array           - Array must not be null.
  */
  FUNCTION array_contains_null(
    p_array IN plsql_types.t_number_array
  ) RETURN BOOLEAN;
  
  /*
  ** is_sorted_array
  **
  ** Check if an array is sorted into either ascending or descending order.
  ** The array must not be null, and must not contain null values.
  **
  ** IN
  **   p_array                - Array of numbers to be checked
  **   p_order                - Sort sequence: 'A' Ascending (default), 'D' Descending
  **
  ** RETURN
  **   BOOLEAN                - TRUE if array is sorted, otherwise FALSE.
  **
  ** EXCEPTIONS
  **   e_null_values          - p_array must not contain null values.
  */
  FUNCTION is_sorted_array(
    p_array       IN plsql_types.t_number_array,
    p_order       IN VARCHAR2 DEFAULT 'A'
  ) RETURN BOOLEAN;

  /*
  ** is_sorted_list
  **
  ** Check if a list of comma sepatated numbers is sorted into either ascending or descending order.
  ** The list must not be null, and must not contain null values.
  **
  ** IN
  **   p_list                 - String of numbers separated by commas
  **   p_order                - Sort sequence: 'A' Ascending (default), 'D' Descending
  **
  ** RETURN
  **   BOOLEAN                - TRUE if list is sorted, otherwise FALSE.
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION is_sorted_list(
    p_list  IN VARCHAR2,
    p_order IN VARCHAR2
  ) RETURN BOOLEAN;
   
END util_numeric;
/