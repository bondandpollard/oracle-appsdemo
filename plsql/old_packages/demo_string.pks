CREATE OR REPLACE PACKAGE demo_string AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : demo_string
  ** Description   : Demonstrate String Functions
  ** Notes         : Use this package for demonstrating string functions
  **                 and training.
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date            Name                 Description
  **------------------------------------------------------------------------
  ** 09/07/2022      Ian Bond          Program created
  **   
  */

  /*  
  ** Global constants
  */

  
  /*
  ** Global variables
  */

  
  /*
  ** Global exceptions
  */



  /*
  ** Public functions and procedures
  */
  
  /*
  ** ALPHACODE functions convert a positive integer into an alphabetic string.
  ** e.g.
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
  */

  /*
  ** alphacode - Convert a positive integer into an alphabetic code
  **
  ** Inefficient loop method.
  **
  ** With 3 registers used for the code, the maximum value this works for is 18278.
  ** This code is inefficient as it uses a loop, only works for codes up to ZZZ, and repeats code.
  ** Create an improved version using an array, removing the repeated code.
  ** Use an algorithm to calculate the code, instead of looping through every number from 1 to n.
  **
  ** IN
  **   p_number     - a positive integer
  ** RETURN
  **   VARCHAR2     - alphabetic string representing the integer value passed in
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION alphacode (
    p_number IN INTEGER
    ) RETURN VARCHAR2;

  /*
  ** alphacode_array - Convert a positive integer into an alphabetic code.
  **
  ** Convert a positive integer into an alphabetic code. Uses an array to eliminate duplicate code.
  ** This code is stll inefficient as it loops through every number from 1 to N.
  ** With a code length of 5 characters, this works for a maximum value of 12356630 which is ZZZZZ.
  **
  ** IN
  **   p_number     - a positive integer
  ** RETURN
  **   VARCHAR2     - alphabetic string representing the integer value passed in
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION alphacode_array (
    p_number IN INTEGER
    ) RETURN VARCHAR2;


  /*
  ** alphacode_calc - Convert a positive integer into an alphabetic code using an efficient calculation.
  **
  ** Convert a positive integer into an alphabetic code. Uses an efficient calculation instead of a simple
  ** but highly inefficient loop. This is an efficient algorithmic solution.
  ** Maximum value of integer this works for is: 
  **
  ** IN
  **   p_number     - a positive integer
  ** RETURN
  **   VARCHAR2     - alphabetic string representing the integer value passed in
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION alphacode_calc (
    p_number IN INTEGER
    ) RETURN VARCHAR2;

  /*
  ** alphacode_calc_na - Convert a positive integer into an alphabetic code using an efficient calculation.
  **                     No arrary required.
  **
  ** Convert a positive isnteger into an alphabetic code. Uses an efficient calculation instead of a simple
  ** but highly inefficient loop. This is an efficient algorithmic solution.
  ** This version has been simplified and does not need and array for the result.
  ** Maximum value of integer this works for is: 
  **
  ** IN
  **   p_number     - a positive integer
  ** RETURN
  **   VARCHAR2     - alphabetic string representing the integer value passed in
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION alphacode_calc_na (
    p_number IN INTEGER
    ) RETURN VARCHAR2;

  /*
  ** alphacode_range - Convert a positive integer into an alphabetic code, using the specified range of letters.
  **
  ** Uses an efficient calculation instead of a simple but highly inefficient loop. 
  **
  ** IN
  **   p_number     - Positive integer to be converted to an alpha code
  **   p_range      - Number between 1 and 26 giving the number of letter to use in the code
  ** RETURN
  **   VARCHAR2     - alphabetic string representing the integer value passed in
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION alphacode_range (
    p_number IN INTEGER, 
    p_range  IN INTEGER
    ) RETURN VARCHAR2;

  /*
  ** alphacode_atg - Convert a positive integer into an alphabetic code
  **
  ** ATG Coding test
  **
  ** This is the corrected version, which works but only for numbers up to
  ** 18278, as we only code 3 characters. The source code is poorly written with repeated lines of code.
  ** For the correct way to program the solution, see alphacode_calc.
  **
  ** IN
  **   p_number     - Positive integer to be converted to an alpha code
  ** RETURN
  **   VARCHAR2     - alphabetic string representing the integer value passed in
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION alphacode_atg (
    p_number IN INTEGER
    ) RETURN VARCHAR2;

  /*
  ** alphacode_atg_wrong - Convert a positive integer into an alphabetic code
  **
  ** ATG Coding test: WRONG code values returned
  **
  ** The code I submitted to ATG was incorrect:
  ** 1. Should have started at rightmost column and calculated units first
  ** 2. First column should have been calculated using MOD, then DIV for others.
  ** 3. Needed a boundary check for values < 1 or > 26
  **
  ** IN
  **   p_number     - Positive integer to be converted to an alpha code
  ** RETURN
  **   VARCHAR2     - alphabetic string representing the integer value passed in
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION alphacode_atg_wrong (
    p_number IN INTEGER
    ) RETURN VARCHAR2;

  /*
  ** alphadecode - Convert an alphabetic code to an integer
  **
  ** Decode an alphabetic code, converting it back to an integer.
  ** Where:
  ** A=1
  ** B=2
  ** Z=26
  ** AA=27
  ** ZZ=702
  ** AAA=703
  **
  ** IN
  **   p_code       - Alphabetic code string
  ** RETURN
  **   NUMBER       - Positive integer value of alphabetic code
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION alphadecode(
    p_code IN VARCHAR2
  ) RETURN NUMBER;

 /*
  ** alphadecode_range - Convert an alphabetic code with a specified range of characters to an integer
  **
  ** Decode an alphabetic code, converting it back to an integer.
  **
  ** IN
  **   p_code       - Alphabetic code string
  **   p_range      - Number between 1 and 26 specifying the range of alphabetic characters in the code
  **                  e.g. 4 uses leters A to D.
  ** RETURN
  **   NUMBER       - Positive integer value of alphabetic code
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION alphadecode_range(
    p_code  IN VARCHAR2, 
    p_range IN INTEGER
  ) RETURN NUMBER;

END demo_string;
/