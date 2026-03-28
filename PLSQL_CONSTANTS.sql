CREATE OR REPLACE PACKAGE plsql_constants AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : plsql_constants
  ** Description   : Define your non table derived data types here
  **
  ** Notes         : 
  **
  **   The backslash character has been defined as a constant, with the character
  **   code ASCII value 92. Oracle SQL Developer is removing the backslash character
  **   wherever it is specified as a string literal, after a SET ESCAPE ON command is 
  **   issued, so this is a work-around.
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date            Name                 Description
  **------------------------------------------------------------------------
  ** 10/07/2022      Ian Bond             Program created
  **   
  */


  SUBTYPE maxvarchar2_t IS VARCHAR2(32767);
  SUBTYPE filenamelength_t IS VARCHAR2(255);
  SUBTYPE csvfieldlength_t IS VARCHAR2(255);
  SUBTYPE dirdelimlength_t IS VARCHAR2(1);
  SUBTYPE csvfielddelim_t IS VARCHAR2(1);

  max_linesize           CONSTANT INTEGER := 32767;
  severity_info          CONSTANT appseverity.severity%TYPE        := 'I'; -- Severity codes used in APPLOG and APPSEVERITY
  severity_error         CONSTANT appseverity.severity%TYPE        := 'E'; -- Severity codes used in APPLOG and APPSEVERITY
  severity_warn          CONSTANT appseverity.severity%TYPE        := 'W'; -- Severity codes used in APPLOG and APPSEVERITY
  import_directory       CONSTANT plsql_constants.filenamelength_t := 'DATA_IN';
  import_error_dir       CONSTANT plsql_constants.filenamelength_t := 'DATA_IN_ERROR';
  import_processed_dir   CONSTANT plsql_constants.filenamelength_t := 'DATA_IN_PROCESSED';
  export_directory       CONSTANT plsql_constants.filenamelength_t := 'DATA_OUT';
  backslash              CONSTANT VARCHAR2(1)                      := CHR(92);
  directory_delimiter    CONSTANT plsql_constants.dirdelimlength_t := backslash; -- Backslash (SQL Developer removes the literal character)
  csv_delimiter          CONSTANT plsql_constants.csvfielddelim_t  := ',';
  newline                CONSTANT VARCHAR2(1)                      := CHR(10);
  newline_string         CONSTANT VARCHAR2(2)                      := backslash||'n';
  carriage_return        CONSTANT VARCHAR2(1)                      := CHR(13);
  carriage_return_string CONSTANT VARCHAR2(2)                      := backslash||'r';
  tab                    CONSTANT VARCHAR2(1)                      := CHR(9);
  tab_string             CONSTANT VARCHAR2(2)                      := backslash||'t';


END plsql_constants;
/

