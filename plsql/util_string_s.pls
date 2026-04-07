CREATE OR REPLACE PACKAGE util_string AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : util_string
  ** Description   : String handling utilities
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                Description
  **------------------------------------------------------------------------
  ** 16/06/2022       Ian Bond            Program created
  ** 29/02/2024       Ian Bond            Add custom initcap function to handle
  **                                      names like Mc and Mac using regexp.
  ** 27/09/2025       Ian Bond            Improve exception handling.
  ** 13/02/2026       Ian Bond            Get_field, delimiter_position, count_fields 
  **                                      fix to handle delimiter at first char in string
  **                                      meaning field 1 is NULL.
  ** 17/02/2026       Ian Bond            Add functions list_to_array_str to convert a delimited string 
  **                                      to an array of string, and array_to_list_str to convert an 
  **                                      array of string into a comma separated list.
  */
  

  /*
  ** Global constants
  */
  gc_newline                CONSTANT  plsql_constants.newline%TYPE                := plsql_constants.newline;
  gc_newline_str            CONSTANT  plsql_constants.newline_string%TYPE         := plsql_constants.newline_string;
  gc_carriage_return        CONSTANT  plsql_constants.carriage_return%TYPE        := plsql_constants.carriage_return;
  gc_carriage_return_str    CONSTANT  plsql_constants.carriage_return_string%TYPE := plsql_constants.carriage_return_string;
  gc_tab                    CONSTANT  plsql_constants.tab%TYPE                    := plsql_constants.tab;
  gc_tab_str                CONSTANT  plsql_constants.tab_string%TYPE             := plsql_constants.tab_string;
  gc_error                  CONSTANT  plsql_constants.severity_error%TYPE         := plsql_constants.severity_error;
  gc_info                   CONSTANT  plsql_constants.severity_info%TYPE          := plsql_constants.severity_info;
  gc_warn                   CONSTANT  plsql_constants.severity_warn%TYPE          := plsql_constants.severity_warn;
  gc_debug_mode             CONSTANT  VARCHAR2(1)                                 := 'X'; -- X turns off debug messages, S display on screen
  gc_max_array_size         CONSTANT  NUMBER := 999;
  gc_array_string_size      CONSTANT  NUMBER := 200;

  
  /*
  ** Global variables
  */


  /*
  ** Global exceptions
  */
  
  /*
  ** TYPES
  */
  TYPE t_string_array IS VARRAY(gc_max_array_size) OF VARCHAR2(gc_array_string_size);

  /*
  ** Public functions and procedures
  */
  
  /*
  ** array_to_list_str
  **
  ** Convert an array of strings to a list of comma separated strings.
  ** NULL values are excluded from the result.
  **
  ** IN
  **   p_string_array        - Array of strings
  **
  ** RETURN
  **   VARCHAR2     String containing list of comma separated strings
  ** EXCEPTIONS
  **   
  */
  FUNCTION array_to_list_str (
    p_array_str    IN t_string_array
  ) RETURN VARCHAR2;
 
  /*
  ** list_to_array_str
  **
  ** Convert a comma separated list of strings to an array strings.
  ** NULL values are excluded from the result.
  **
  ** IN
  **   p_list_str         - String containing comma separated list of strngs
  **
  ** RETURN
  **   t_string_array VARRAY of VARCHAR2    Array of strings
  ** EXCEPTIONS
  **   
  */
  FUNCTION list_to_array_str (
    p_list_str    IN VARCHAR2
  ) RETURN t_string_array;

  /*
  ** delimiter_position - Return position of Nth delimiter in string
  **
  ** Return the position within a string of the Nth delimiter from the start position.
  ** Ignore delimiters between a pair of double quotes.
  ** Fields that are delimited by quotes can contain quotes.
  ** Ignore spaces between fields and delimiters.
  **
  ** IN
  **   p_string           - Delimited string such as a CSV record "ABC",124,"Some text"
  **   p_start_position   - Start searching string at this position
  **   p_delim_position   - Indicate which delimiter to return e.g. Nth in string 
  **   p_delimiter        - Delimiter character to search for
  ** RETURN
  **   NUMBER  Position of the delimiter in string, 0 if not found, -1 if error
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION delimiter_position (
    p_string         IN VARCHAR2, 
    p_start_position IN NUMBER, 
    p_delim_position IN NUMBER, 
    p_delimiter      IN VARCHAR2 DEFAULT ','
  ) RETURN NUMBER;


 
  /*
  ** get_field - Return the Nth field within a string, where the fields are separated by a specified delimiter 
  **
  ** Return the Nth field within a string, where the fields are separated by a specified delimiter 
  ** e.g. semicolon, comma or tab character.
  ** Ignore the delimiters within pairs of double quotes. 
  ** Strip double quotes from the start and end of the string.
  ** Example:
  **   select get_field('field1;"field;;;2";"field"""3";field4',3,';') from dual;
  ** Result:
  **   field3"""3
  **
  ** IN
  **   p_string        - String containing delimiter separated values 
  **   p_position      - Indicates which field to return, Nth in string
  **   p_delimiter     - Delimiter character used to separate fields
  ** RETURN
  **   VARCHAR2  Nth field of the string
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION get_field(
    p_string    IN VARCHAR2, 
    p_position  IN NUMBER, 
    p_delimiter IN VARCHAR2 DEFAULT ','
  ) RETURN VARCHAR2;
  
  

  /*
  ** delimiter_position_nospace - Return the position within a string of the Nth delimiter
  **
  ** Return the position within a string of the Nth delimiter.
  ** Ignore delimiters if they are within a pair of double quotes.
  ** NB: There must be no spaces between the delimiters and the previous and next fields
  **
  ** IN
  **   p_string         - String containing delimiter separated values 
  **   p_delim_position - Which delimiter to find, Nth in string
  **   p_delimiter      - Delimiter character used to separate fields
  ** RETURN
  **   NUMBER  Position of the Nth delimiter in the string. 0 if not found, -1 if error.
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION delimiter_position_nospace (
    p_string         IN VARCHAR2, 
    p_delim_position IN NUMBER, 
    p_delimiter      IN VARCHAR2 DEFAULT ','
  ) RETURN NUMBER;
  
  
  /*
  ** get_field_nospace - Return the Nth field within a string, where the fields are separated by a specified delimiter 
  **
  ** Note: This only works if there are no spaces between the fields and delimiters.
  **       Use the get_field function instead, as it handles spaces correctly.
  **
  ** Return the Nth field within a string, where the fields are separated by a specified delimiter 
  ** e.g. semicolon, comma or tab character.
  ** Ignore the delimiters within pairs of double quotes. 
  ** Strip double quotes from the start and end of the string.
  ** Example:
  **   select get_field('field1;"field;;;2";"field"""3";field4',3,';') from dual;
  ** Result:
  **   field3"""3
  **
  ** IN
  **   p_string        - String containing delimiter separated values 
  **   p_position      - Indicates which field to return, Nth in string
  **   p_delimiter     - Delimiter character used to separate fields
  ** RETURN
  **   VARCHAR2  Nth field of the string
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION get_field_nospace(
    p_string    IN VARCHAR2, 
    p_position  IN NUMBER, 
    p_delimiter IN VARCHAR2 DEFAULT ','
  ) RETURN VARCHAR2;


  /*
  ** get_delimiter - Return the field delimiter character used in a string
  **
  ** Return best match for the delimiter used in string, as most frequently occuring
  ** of comma, semicolon or tab characters.
  ** Tab is the default.
  **
  ** IN
  **   p_string        - String containing fields separated by a delimiter
  ** RETURN
  **   VARCHAR2  The delimiter character found
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION get_delimiter(
    p_string IN VARCHAR2
  ) RETURN VARCHAR2;


  /*
  ** count_fields - Count number of fields in a delimited string
  **
  ** Return the number of fields found in a delimited string
  ** Count number of fields in a delimited string
  **
  ** IN
  **   p_string        - String containing fields separated by a delimiter
  ** RETURN
  **   NUMBER  Count of fields found separated by the delimiter
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION count_fields(
    p_string    IN VARCHAR2, 
    p_delimiter IN VARCHAR2 DEFAULT ','
  ) RETURN NUMBER;

  
  /*
  ** replace - Replace all occurrences of one string within another
  **
  ** Replace all occurrences of substring within string.
  ** This replicates the Oracle REPLACE function.
  **
  ** Note that this function must handle the new substring containing some or all of the 
  ** characters in the old substring. For example, if you replace "a" with "an" the function must not
  ** repeatedly replace the "a" in "an" with another "an".
  **
  ** IN
  **   p_instring        - Input string 
  **   p_replacewhat     - The substring you want to replace 
  **   p_replacewith     - Insert this value in place of p_replacewhat
  ** RETURN
  **   VARCHAR2  Output string with all replacements made
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION replace(
    p_instring    IN VARCHAR2, 
    p_replacewhat IN VARCHAR2, 
    p_replacewith IN VARCHAR2
  ) RETURN VARCHAR2;


  /*
  ** textconvert - Replace escaped formatting characters with ASCII equivalent
  **
  ** Replace backslash n with ASCII char 10 (new line)
  ** Replace backslash t with ASCII char  9 (tab)
  ** Replace backslash r with ASCII char 13 (Carriage Return)
  ** Replace backslash t with tab, backslash n with new line, and backslash r with carriage return
  **
  ** If you place the output string in a text document, it will be formatted
  ** using the above characters. New lines will cause a line break etc.
  **
  ** IN
  **   p_instring        - Original string containing escaped characters
  ** RETURN
  **   VARCHAR2  Converted string containing ASCII formatting characters
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION textconvert(
    p_instring IN VARCHAR2
  ) RETURN VARCHAR2;

  

  /*
  ** sort_string - Sort the contents of a string into ascending or descending order.
  **
  ** Sort the characters within a string into ascending or descending sequence
  **
  ** IN
  **   p_string        - String containing unsorted characters
  **   p_order         - A for Ascending sort, any other value is a Descending sort
  ** RETURN
  **   VARCHAR2  is the sorted string
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION sort_string (
    p_string IN VARCHAR2, 
    p_order  IN VARCHAR2 DEFAULT 'A'
  ) RETURN VARCHAR2;

  /*
  ** sort_list - Sort a list of comma separated values into ascending or descending order
  **
  **  Sort values in a comma separated list into either ascending or descending order of value.
  **  This is a simple bubble sort.
  **
  ** IN
  **   p_string        - String containing a list of values separated by commas
  **   p_order         - A for Ascending sort, any other value for Descending sort
  ** RETURN
  **   VARCHAR2  is a string containg the sorted list
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION sort_list (
    p_string IN VARCHAR2, 
    p_order  IN VARCHAR2 DEFAULT 'A'
  ) RETURN VARCHAR2;
  
  /*
  ** name_initcap - Capitalise the first letter of each word in a string (name), taking into
  **                account names with a Mc, or Mac prefix.
  **
  **
  ** IN
  **   p_string        - String to be converted to initial capitals
  ** RETURN
  **   VARCHAR2  is a string with capitalised first letters of each word.  
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION name_initcap (
    p_string IN VARCHAR2
  ) RETURN VARCHAR2;


END util_string;
/