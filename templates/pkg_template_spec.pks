CREATE OR REPLACE PACKAGE <package name> AS
  /*
  ** (c) Bond & Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   :
  ** Description   :
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date            Name                 Description
  **------------------------------------------------------------------------
  ** DD/MM/YYYY      <your name>          Program created
  **   
  */

  /*  
  ** Global constants
  */
  gc_<name> CONSTANT <TYPE> := <value>;
  
  /*
  ** Global variables
  */
  g_<name> <TYPE> := <value>;
  
  /*
  ** Global exceptions
  */
  e_<name> EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_<name>,-20000);


  /*
  ** Public functions and procedures
  */
  
  /*
  ** <func name> - <brief description>
  **
  ** <detailed description>
  **
  ** IN
  **   <p1>         - <describe use of p1>
  ** RETURN
  **   <return datatype> <brief description>
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION <func name> ( 
    <p1 name> <IN/OUT> <TYPE>
  ) RETURN <TYPE>;
  PRAGMA RESTRICT_REFERENCES (<FUNC NAME>, WNDS, WNPS);

  /*
  ** <proc name> - <brief description>
  **
  ** <detailed description>
  **
  ** IN
  **   <p1>         - <describe use of p1>
  ** OUT
  **   <p2>         - <describe use of p2>
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  PROCEDURE <procedure name> ( 
    <p1 name> <IN/OUT> <TYPE>
  );
  
END <package name>;
/
