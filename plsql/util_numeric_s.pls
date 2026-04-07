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
  */
 
  
  /*  
  ** Global constants
  */
  gc_error            CONSTANT plsql_constants.severity_error%TYPE := plsql_constants.severity_error;
  gc_info             CONSTANT plsql_constants.severity_info%TYPE  := plsql_constants.severity_info;
  gc_warn             CONSTANT plsql_constants.severity_warn%TYPE  := plsql_constants.severity_warn;
  gc_max_array_size   CONSTANT NUMBER := 32767; -- VARRAY used in preference to table for in-memory search and sort, to ensure density enforced, no gaps.


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
  TYPE t_number_array IS VARRAY(gc_max_array_size) OF NUMBER;
  
  TYPE t_frequency_row IS RECORD (
    key         PLS_INTEGER,
    frequency   PLS_INTEGER
  );
  
  TYPE t_frequency_table IS TABLE OF t_frequency_row;
  
  TYPE t_int_table IS TABLE OF PLS_INTEGER;
  
  -- Used by get_stats to return all statistics for frequency table 
  -- Note this is nested, supporting multiple mode values in t_int_table
  TYPE t_stats_summary IS RECORD (
    sum_values      PLS_INTEGER,
    n_total         PLS_INTEGER,
    distinct_n      PLS_INTEGER,
    mean            NUMBER,
    median          NUMBER,
    mode_values     t_int_table,
    lowest          NUMBER,
    highest         NUMBER,
    range           NUMBER,
    variance_pop    NUMBER,
    variance_samp   NUMBER,
    stddev_pop      NUMBER,
    stddev_samp     NUMBER,
    iqr             NUMBER 
  );
  
  -- Get_stats uses this composite record to store the calculated
  -- statistics and frequency table from which they were generated.
  TYPE t_stats_result IS RECORD (
    stats       t_stats_summary,
    freq_tbl    t_frequency_table
  );
  
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
  ) RETURN t_number_array;

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
    p_array IN t_number_array
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
    p_array  IN t_number_array,
    p_order  IN VARCHAR2 DEFAULT 'A'
  ) RETURN t_number_array;

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
  ** binary_chop_search - Binary Chop, or logarithmic search.
  **
  ** Find the position of a key value in a list and return its position if found,
  ** or 0 if not found.
  **
  ** (1)  Convert comma separated list into array of numbers.
  ** (2)  Sort array into ascending order.
  ** (3)  Set lower bound to first position of array, upper bound to last position of array.
  ** (4)  While the interval between the lower and upper bounds of the search >0
  ** (5)  Search sorted list for key value by looking at the 
  **      item in the middle of the lower and upper bounds to see if it matches.
  ** (6)  If the key value sought matches the value found then stop searching and return its position.
  ** (7)  If the key value sought is less than the value found then it must be in
  **      the lower half of the list; set the upper search bound to the position
  **      just checked -1, and search again at step 4.
  ** (8)  If the value sought is greater than the value found then it must be in
  **      the upper half of the list; set the lower search bound to the position 
  **      just checked +1, and search again at step 4.
  **
  ** NB: 
  **  The numbers in the list must be sorted into ascending order first.
  **  Separate function may be created to return the following:
  **    Position to insert missing value (move all items from this position onward 1 place forward before insertion).
  **    Next smallest value in list to key value, even if key value missing from list.
  **    Next largest value in list to key value, even if key value missing from list.
  **
  **
  ** Description of binary search
  **
  ** Perform a logarithmic search on a sorted numeric array to locate
  ** a target value.
  **
  ** The algorithm maintains a bounded search interval and repeatedly
  ** halves the interval by comparing the target with the midpoint
  ** element. On each iteration, one half of the remaining range is
  ** eliminated. The process continues until the interval collapses.
  **
  ** If the target exists, its position is returned. If not, the function returns 0. 
  **
  ** Time Complexity:
  **      O(log n) comparisons.
  **
  ** Preconditions:
  **      - Input array must be sorted in ascending order.
  **      - Array must not contain NULL values.
  **
  **
  ** IN
  **   p_key                - Number to search for in array.
  **   p_list               - String containing numbers to search, separated by commas.
  **                          e.g. '1,2,3'
  **
  ** RETURN
  **   NUMBER               - Position of number p_key in list. 
  **                          0 if not found.
  ** EXCEPTIONS
  **   e_null_list          - p_list must not be null
  **   e_null_value         - Array (list) must not contain null values
  */
  FUNCTION binary_chop_search(
    p_key   IN NUMBER,
    p_list  IN VARCHAR2
  ) RETURN NUMBER;
  
  /*
  ** binary_search_array
  **
  ** Perform a binary, or logarithmic search on a sorted numeric array to locate
  ** a target value.
  **
  ** The algorithm maintains a bounded search interval and repeatedly
  ** halves the interval by comparing the target with the midpoint
  ** element. On each iteration, one half of the remaining range is
  ** eliminated. The process continues until the interval collapses.
  **
  ** If the target exists, its position is returned. If not, the function returns 0.
  **
  ** Time Complexity:
  **      O(log n) comparisons.
  **
  ** Preconditions:
  **      - Input array must be sorted in ascending order.
  **      - Array must not contain NULL values.
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_array                - Array containing numbers to search, pre-sorted.
  **
  ** RETURN
  **   NUMBER                 - Position of number p_target in array. 
  **                            0 if not found.
  ** EXCEPTIONS
  **   e_null_value           - p_array must not contain null values
  **   e_unsorted_array       - p_array must be pre-sorted into ascending order
  */
  FUNCTION binary_search_array(
    p_target   IN NUMBER,
    p_array    IN t_number_array
  ) RETURN NUMBER;
  
  /*
  ** binary_search
  **
  ** Binary search a comma separated list of numbers for target value.
  **
  ** Converts comma separated list to array and passes array to binary_search_array.
  **
  ** Perform a logarithmic search on a sorted numeric array to locate
  ** a target value.
  **
  ** The algorithm maintains a bounded search interval and repeatedly
  ** halves the interval by comparing the target with the midpoint
  ** element. On each iteration, one half of the remaining range is
  ** eliminated. The process continues until the interval collapses.
  **
  ** If the target exists, its position is returned. If not, the function returns 0. 
  **
  ** Time Complexity:
  **      O(log n) comparisons.
  **
  ** Preconditions:
  **      - Input array must be sorted in ascending order.
  **      - Array must not contain NULL values.
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_list                 - String containing numbers to search, separated by commas, pre-sorted into ascending order.
  **                            e.g. '1,2,3'
  **
  ** RETURN
  **   NUMBER                 - Position of number p_target in list. 
  **                            0 if not found.
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION binary_search(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2
  ) RETURN NUMBER;
  
  /*
  ** binary_rank_array
  **
  ** Use a logarithmic search to rank a target number within in array of sorted numbers.
  ** The rank of the target value is number of elements prior to the position
  ** of the leftmost element matching the target value.
  ** E.g. Array=10,20,30,40,50
  ** Search for target 40 returns 3
  ** Search for target 45 returns 4
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_array                - Array containing numbers to search, pre-sorted into ascending order.
  **
  ** RETURN
  **   NUMBER                 - Rank of target value in list. 
  **            
  ** EXCEPTIONS
  **   e_null_value           - p_array must not contain null values
  **   e_unsorted_array       - p_array must be pre-sorted into ascending order
  */
  FUNCTION binary_rank_array(
    p_target   IN NUMBER,
    p_array    IN t_number_array
  ) RETURN NUMBER;
  
  /*
  ** binary_rank
  **
  ** Use a logarithmic search to rank a target number within in array of sorted numbers.
  ** The rank of the target value is number of elements prior to the position
  ** of the leftmost element matching the target value.
  ** E.g. Array=10,20,30,40,50
  ** Search for target 40 returns 3
  ** Search for target 45 returns 4
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_list                 - String containing numbers to search, separated by commas, pre-sorted into ascending order.
  **                            e.g. '1,2,3'
  **
  ** RETURN
  **   NUMBER                 - Rank of target value in list. 
  **            
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION binary_rank(
    p_target   IN NUMBER,
    p_list    IN VARCHAR2
  ) RETURN NUMBER;

  /*
  ** binary_search_leftmost_array
  **
  ** Use a logarithmic search to find the leftmost position of a target value in an array of sorted numbers that contains duplicate values.
  ** If exact match specified (default): If target found return its position, else 0.
  ** If not exact match: return position target should be inserted into array.
  ** 
  ** E.g. Exact Match TRUE
  ** Array=1,1,2,2,2,3,4,4,4,4,5,6,8
  ** Search for target 4 will return position 7
  ** Search for target 7 will return 0 (not found)
  **
  ** E.g. Exact Match FALSE
  ** Array=1,1,2,2,2,3,4,4,4,4,5,6,8
  ** Search for target 7 will return 13
  ** Search for target -1 will return 1
  ** Search for target 99 will return 14
  **
  **
  ** Perform a logarithmic search on a sorted numeric array to locate
  ** a target value or determine its relative position.
  **
  ** The algorithm maintains a bounded search interval and repeatedly
  ** halves the interval by comparing the target with the midpoint
  ** element. On each iteration, one half of the remaining range is
  ** eliminated. The process continues until the interval collapses.
  **
  ** If the target exists, its position (or derived position, depending
  ** on variant) is returned. If not, the function returns either 0 or
  ** an insertion index according to the specific search contract.
  **
  ** Time Complexity:
  **      O(log n) comparisons.
  **
  ** Preconditions:
  **      - Input array must be sorted in ascending order.
  **      - Array must not contain NULL values.
  ** IN
  **   p_target               - Number to search for in array.
  **   p_array                - Array containing numbers to search, pre-sorted into ascending order.
  **   p_exact_match          - Boolean if true (default) returns exact match, otherwise returns position value should be inserted.
  **
  ** RETURN
  **   NUMBER                 - Exact Match True: Position of leftmost value p_target in array, or 0 if not found.
  **                            Exact Match False: Position value should be inserted into list.
  **
  ** EXCEPTIONS
  **   e_null_value           - p_array must not contain null values
  **   e_unsorted_array       - p_array must be pre-sorted into ascending order
  */
  FUNCTION binary_search_leftmost_array(
    p_target        IN NUMBER,
    p_array         IN t_number_array,
    p_exact_match   IN BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER;

  /*
  ** binary_search_leftmost
  **
  ** Use a logarithmic search to find the leftmost position of a target value in an array of sorted numbers that contains duplicate values.
  ** If exact match specified (default): If target found return its position, else 0.
  ** If not exact match: return position target should be inserted into array.
  ** 
  ** E.g. Exact Match TRUE
  ** Array=1,1,2,2,2,3,4,4,4,4,5,6,8
  ** Search for target 4 will return position 7
  ** Search for target 7 will return 0 (not found)
  **
  ** E.g. Exact Match FALSE
  ** Array=1,1,2,2,2,3,4,4,4,4,5,6,8
  ** Search for target 7 will return 13
  ** Search for target -1 will return 1
  ** Search for target 99 will return 14
  **
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_list                 - String containing numbers to search, separated by commas, pre-sorted into ascending order.
  **                            e.g. '1,2,3'
  **   p_exact_match          - Boolean if true (default) returns exact match, otherwise returns position value should be inserted.
  **
  ** RETURN
  **   NUMBER                 - Exact Match True: Position of leftmost value p_target in list, or 0 if not found.
  **                            Exact Match False: Position value should be inserted into list.
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION binary_search_leftmost(
    p_target        IN NUMBER,
    p_list          IN VARCHAR2,
    p_exact_match   IN BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER;

  /*
  ** binary_search_rightmost_array
  **
  ** Use a logarithmic search to find the rightmost position of a target value in an array of sorted numbers that contains duplicate values.
  ** If exact match specified (default): If target found return its position, else 0.
  ** If not exact match: return position target should be inserted into array.
  ** 
  ** E.g. Exact Match TRUE
  ** Array=1,1,2,2,2,3,4,4,4,4,5,6,8
  ** Search for target 4 will return position 10
  ** Search for target 7 will return 0 (not found)
  **
  ** E.g. Exact Match FALSE
  ** Array=1,1,2,2,2,3,4,4,4,4,5,6,8
  ** Search for target 7 will return 13
  ** Search for target -1 will return 1
  ** Search for target 99 will return 14
  **
  ** Perform a logarithmic search on a sorted numeric array to locate
  ** a target value or determine its relative position.
  **
  ** The algorithm maintains a bounded search interval and repeatedly
  ** halves the interval by comparing the target with the midpoint
  ** element. On each iteration, one half of the remaining range is
  ** eliminated. The process continues until the interval collapses.
  **
  ** If the target exists, its position (or derived position, depending
  ** on variant) is returned. If not, the function returns either 0 or
  ** an insertion index according to the specific search contract.
  **
  ** Time Complexity:
  **      O(log n) comparisons.
  **
  ** Preconditions:
  **      - Input array must be sorted in ascending order.
  **      - Array must not contain NULL values.
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_array                - Array containing numbers to search, pre-sorted into ascending order.
  **   p_exact_match          - Boolean if true (default) returns exact match, otherwise returns position value should be inserted.
  **
  ** RETURN
  **   NUMBER                 - Exact Match True: Position of rightmost value p_target in list, or 0 if not found.
  **                            Exact Match False: Position value should be inserted into list.
  **
  ** EXCEPTIONS
  **   e_null_value           - p_array must not contain null values
  **   e_unsorted_array       - p_array must be pre-sorted into ascending order
  */
  FUNCTION binary_search_rightmost_array(
    p_target   IN NUMBER,
    p_array    IN t_number_array,
    p_exact_match   IN BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER;
  
  /*
  ** binary_search_rightmost
  **
  ** Use a logarithmic search to find the rightmost position of a target value in an array of sorted numbers that contains duplicate values.
  ** If exact match specified (default) return position of target if found, else 0.
  ** If not exact match then return position target should be inserted into array.
  ** 
  ** E.g. Exact Match TRUE
  ** Array=1,1,2,2,2,3,4,4,4,4,5,6,8
  ** Search for target 4 will return position 10
  ** Search for target 7 will return 0 (not found)
  **
  ** E.g. Exact Match FALSE
  ** Array=1,1,2,2,2,3,4,4,4,4,5,6,8
  ** Search for target 7 will return 13
  ** Search for target -1 will return 1
  ** Search for target 99 will return 14
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_list                 - String containing numbers to search, separated by commas, pre-sorted into ascending order.
  **                            e.g. '1,2,3'
  **   p_exact_match          - Boolean if true (default) returns exact match, otherwise returns position value should be inserted.
  **
  ** RETURN
  **   NUMBER                 - Exact Match True: Position of rightmost value p_target in list, or 0 if not found.
  **                            Exact Match False: Position value should be inserted into list.
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION binary_search_rightmost(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2,
    p_exact_match   IN BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER;

  /*
  ** binary_search_predecessor_array
  **
  ** Use a logarithmic search to return the position of the nearest smaller value to a target value in an array of sorted numbers.
  ** Return 0 if not found.
  ** E.g. Array=1,2,3,5,7
  ** Target=5, Return value=3
  ** Target=4, Return value=3
  ** Target=1, Return value=0
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_array                - Array containing numbers to search, pre-sorted into ascending order.
  **
  ** RETURN
  **   NUMBER                 - Position of predecessor to target value in list.
  **                            0 if not found.
  **
  ** EXCEPTIONS
  **   e_null_value           - p_array must not contain null values
  **   e_unsorted_array       - p_array must be pre-sorted into ascending order
  */
  FUNCTION binary_search_predecessor_array(
    p_target   IN NUMBER,
    p_array    IN t_number_array
  ) RETURN NUMBER;
  
  /*
  ** binary_search_predecessor
  **
  ** Use a logarithmic search to return the position of the nearest smaller value to a target value in an array of sorted numbers.
  ** Return 0 if not found.
  ** E.g. Array=1,2,3,5,7
  ** Target=5, Return value=3
  ** Target=4, Return value=3
  ** Target=1, Return value=0
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_list                 - String containing numbers to search, separated by commas, pre-sorted into ascending order.
  **                            e.g. '1,2,3'
  **
  ** RETURN
  **   NUMBER                 - Position of predecessor to target value in list.
  **                            0 if not found.
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION binary_search_predecessor(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2
  ) RETURN NUMBER;
  
 
  /*
  ** binary_search_successor_array
  **
  ** Use a logarithmic search to return the position of the nearest larger value to a target value in an array of sorted numbers.
  ** Return 0 if not found.
  ** E.g. Array=1,2,3,5,7
  ** Target=5, Return value=5
  ** Target=4, Return value=4
  ** Target=7, Return value=0
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_array                - Array containing numbers to search, pre-sorted into ascending order.
  **
  ** RETURN
  **   NUMBER                 - Position of successor to target value in list.
  **                            0 if not found.
  **
  ** EXCEPTIONS
  **   e_null_value           - p_array must not contain null values
  **   e_unsorted_array       - p_array must be pre-sorted into ascending order
  */
  FUNCTION binary_search_successor_array(
    p_target   IN NUMBER,
    p_array    IN t_number_array
  ) RETURN NUMBER;
  
  /*
  ** binary_search_successor
  **
  ** Use a logarithmic search to return the position of the nearest larger value to a target value in an array of sorted numbers.
  ** Return 0 if not found.
  ** E.g. Array=1,2,3,5,7
  ** Target=5, Return value=5
  ** Target=4, Return value=4
  ** Target=7, Return value=0
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_list                 - String containing numbers to search, separated by commas, pre-sorted into ascending order.
  **                            e.g. '1,2,3'
  **
  ** RETURN
  **   NUMBER                 - Position of successor to target value in list.
  **                            0 if not found.
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION binary_search_successor(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2
  ) RETURN NUMBER;

  /*
  ** binary_search_nearest_array
  **
  ** Use a logarithmic search to find the nearest neighbour of the target value, it's predecessor or 
  ** successor, whichever is closest, in an array of sorted numbers.
  ** E.g.
  ** Array=1,2,3,6,7,8,9,10,11,12
  ** Target=3
  ** Return value=2
  ** Target=5
  ** Return value=4
  **
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_array                - Array containing numbers to search, pre-sorted into ascending order.
  **
  ** RETURN
  **   NUMBER                 - Position of nearest value to target
  **                            0 if not found.
  **
  ** EXCEPTIONS
  **   e_null_value           - p_array must not contain null values
  **   e_unsorted_array       - p_array must be pre-sorted into ascending order
  */
  FUNCTION binary_search_nearest_array(
    p_target       IN NUMBER,
    p_array        IN t_number_array
  ) RETURN NUMBER;
  
  /*
  ** binary_search_nearest
  **
  ** Use a logarithmic search to find the nearest neighbour of the target value, it's predecessor or 
  ** successor, whichever is closest, in an array of sorted numbers.
  ** E.g.
  ** Array=1,2,3,6,7,8,9,10,11,12
  ** Target=3
  ** Return value=2
  ** Target=5
  ** Return value=4
  **
  **
  ** IN
  **   p_target               - Number to search for in array.
  **   p_list                 - String containing numbers to search, separated by commas, pre-sorted into ascending order.
  **                            e.g. '1,2,3'
  **
  ** RETURN
  **   NUMBER                 - Position of nearest value to target
  **                            0 if not found.
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION binary_search_nearest(
    p_target       IN NUMBER,
    p_list         IN VARCHAR2
  ) RETURN NUMBER;
  
  /*
  ** binary_search_range_array
  **
  ** Use a logarithmic search to find the range, or count of values between 2 intervals in an array of sorted numbers.
  ** E.g.
  ** Array=1,2,3,6,7,8,9,10,11,12
  ** Range From=2
  ** Range To=10
  ** Return value=7
  **
  ** Range From=4
  ** Range To=10
  ** Return value=5
  **
  ** IN
  **   p_range_from           - Lower value to search for in array
  **   p_range_to             - Upper value to search for in array
  **   p_array                - Array containing numbers to search, pre-sorted into ascending order.
  **
  ** RETURN
  **   NUMBER                 - Range (number of values between) 2 values in list.
  **                            0 if not found.
  **
  ** EXCEPTIONS
  **   e_null_value           - p_array must not contain null values
  **   e_unsorted_array       - p_array must be pre-sorted into ascending order
  */
  FUNCTION binary_search_range_array(
    p_range_from   IN NUMBER,
    p_range_to     IN NUMBER,
    p_array        IN t_number_array
  ) RETURN NUMBER;
  
  /*
  ** binary_search_range
  **
  ** Use a logarithmic search to find the range, or count of values between 2 intervals in an array of sorted numbers.
  ** E.g.
  ** Array=1,2,3,6,7,8,9,10,11,12
  ** Range From=2
  ** Range To=10
  ** Return value=7
  **
  ** Range From=4
  ** Range To=10
  ** Return value=5
  **
  ** IN
  **   p_range_from           - Lower value to search for in array
  **   p_range_to             - Upper value to search for in array
  **   p_list                 - String containing numbers to search, separated by commas, pre-sorted into ascending order.
  **                              e.g. '1,2,3'
  **
  ** RETURN
  **   NUMBER                 - Range (number of values between) 2 values in list.
  **                            0 if not found.
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION binary_search_range(
    p_range_from   IN NUMBER,
    p_range_to     IN NUMBER,
    p_list         IN VARCHAR2
  ) RETURN NUMBER;
  
  /*
  ** search_unsorted_array
  **
  ** Search an unsorted array for a target value.
  ** E.g.
  ** Array=-99,-1,99,0,5,1,-1000,400,6,9999,-6
  ** Target=400
  ** Return value=8
  **
  ** IN
  **   p_target               - Number to search for
  **   p_array                - Array containing numbers to search, NOT sorted.
  **
  ** RETURN
  **   NUMBER                 - Position of target in array
  **                            0 if not found.
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION search_unsorted_array(
    p_target       IN NUMBER,
    p_array        IN t_number_array
  ) RETURN NUMBER;
  
  /*
  ** search_unsorted
  **
  ** Search an unsorted array for a target value.
  ** E.g.
  ** Array=-99,-1,99,0,5,1,-1000,400,6,9999,-6
  ** Target=400
  ** Return value=8
  **
  ** IN
  **   p_target               - Number to search for
  **   p_list                 - String containing numbers to search, separated by commas, NOT sorted.
  **                            e.g. '3,1,2,99,-1'
  **
  ** RETURN
  **   NUMBER                 - Position of target in array
  **                            0 if not found.
  **
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION search_unsorted(
    p_target       IN NUMBER,
    p_list         IN VARCHAR2
  ) RETURN NUMBER;

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
    p_array       IN t_number_array
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
    p_array       IN t_number_array
  ) RETURN t_number_array;
 
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
    p_array       IN t_number_array
  ) RETURN t_number_array;
  
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
    p_array IN t_number_array
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
    p_array       IN t_number_array,
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
    p_array IN t_number_array
  ) RETURN t_frequency_table;

  /*
  ** frequency_table_sum
  **
  ** Calculate the sum of values in the frequency table.
  ** Sum of (key * frequency)
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **
  ** RETURN
  **   PLS_INTEGER            - Sum of values in p_frequency_table
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */
  FUNCTION frequency_table_sum(
    p_frequency_table IN t_frequency_table
  ) RETURN PLS_INTEGER;

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
    p_frequency_table IN t_frequency_table
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
    p_frequency_table IN t_frequency_table
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
    p_frequency_table IN t_frequency_table,
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
    p_frequency_table IN t_frequency_table
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
  **   t_int_table            - Table of modes
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */
  FUNCTION frequency_table_mode(
    p_frequency_table IN t_frequency_table
  ) RETURN t_int_table;
  
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
  **   PLS_INTEGER            - Highest value in p_frequency_table
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */  
  FUNCTION frequency_table_highest(
    p_frequency_table IN t_frequency_table
  ) RETURN PLS_INTEGER;
  
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
  **   PLS_INTEGER            - Lowest value in p_frequency_table
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */ 
  FUNCTION frequency_table_lowest(
    p_frequency_table IN t_frequency_table
  ) RETURN PLS_INTEGER;
  
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
  **   PLS_INTEGER            - Range of values in p_frequency_table
  **
  ** EXCEPTIONS
  **   e_null_table           - p_frequency_table must not be null.
  */
  FUNCTION frequency_table_range(
    p_frequency_table IN t_frequency_table
  ) RETURN PLS_INTEGER;

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
  ** RETURN
  **   NUMBER               - Population Variance for Range of values in p_frequency_table
  **
  ** EXCEPTIONS
  */
  FUNCTION variance_pop(
    p_frequency_table IN t_frequency_table
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
    p_frequency_table IN t_frequency_table
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
    p_frequency_table IN t_frequency_table
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
    p_frequency_table IN t_frequency_table
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
  **    v_stats_result util_numeric.t_stats_result;
  **    v_pct_disc NUMBER;
  **  BEGIN
  **    v_stats_result := util_numeric.get_stats_list('1,2,3,10,20,999');
  **    v_pct_disc := util_numeric.percentile_disc(v_stats_result.freq_tbl,0.75);
  **    dbms_output.put_line('PCT_DISC='||to_char(v_pct_disc));
  **  END;
  **
  ** IN
  **   p_frequency_table      - Table of t_frequency_row
  **   p_pct                  - Percentile a number > 0 and < 1
  **
  **
  ** RETURN
  **   PLS_INTEGER            - Key (observed value) in frequency table at the percentile p_pct
  **
  ** EXCEPTIONS
  */
  FUNCTION percentile_disc(
    p_frequency_table IN t_frequency_table,
    p_pct             IN NUMBER 
  ) RETURN PLS_INTEGER;

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
  **    v_stats_result util_numeric.t_stats_result;
  **    v_pct_cont NUMBER;
  **  BEGIN
  **    v_stats_result := util_numeric.get_stats_list('1,2,3,10,20,999');
  **    v_pct_cont := util_numeric.percentile_cont(v_stats_result.freq_tbl,0.75);
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
    p_frequency_table IN t_frequency_table,
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
     p_frequency_table IN t_frequency_table
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
  ** NB: mode_values is a table of integer t_int_table as >1 mode may be returned
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
    p_array IN t_number_array
  ) RETURN t_stats_result;
  
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
    p_array IN t_number_array
  ) RETURN t_stats_result;
  
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
  ) RETURN t_stats_result;
  
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
  ) RETURN t_stats_result;
  
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
    p_stats_result IN t_stats_result
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
    p_stats_result IN t_stats_result,
    p_pct IN NUMBER DEFAULT 0.5
  );
   
END util_numeric;
/