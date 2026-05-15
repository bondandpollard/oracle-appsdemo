CREATE OR REPLACE PACKAGE search AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : search
  ** Description   : Search functions
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                Description
  **------------------------------------------------------------------------
  ** 13/05/2026       Ian Bond            Created - move search functions from util_numeric, and reference common types in plsql_types.pks.
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
    p_array    IN plsql_types.t_number_array
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
    p_array    IN plsql_types.t_number_array
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
    p_array         IN plsql_types.t_number_array,
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
    p_array    IN plsql_types.t_number_array,
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
    p_array    IN plsql_types.t_number_array
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
    p_array    IN plsql_types.t_number_array
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
    p_array        IN plsql_types.t_number_array
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
    p_array        IN plsql_types.t_number_array
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
    p_array        IN plsql_types.t_number_array
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

END search;
/