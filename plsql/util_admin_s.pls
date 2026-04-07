CREATE OR REPLACE PACKAGE util_admin AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : util_admin
  ** Description   : Database admin utilities -
  **                 Auditing, error handling
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                  Description
  **------------------------------------------------------------------------
  ** 08/07/2022       Ian Bond              Program created
  ** 10/02/2026       Ian Bond              Add Log Mode 'X' Display Nothing for debugging.
  **                                        You can then include calls to log_message in your
  **                                        programs for debugging using Mode S (screen). 
  **                                        When you want to switch all those debug messages off,
  **                                        set Mode to X.
  ** 13/02/2026       Ian Bond              Amend log_message to provide verbose/brief message mode for screen output.
  ** 25/03/2026       Ian Bond              Amend format of log_message screen display text, move mode.
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
  ** Public functions
  */
  
  /*
  ** log_message - Record messages in the application log
  **
  ** Use this procedure to record messages in the application log,
  ** display on screen, or both.
  **
  ** Screen message format:
  ** {Severity} from program {program name} at DD-MON-YYYY HH:MM:SS.FF SQLERRM is {SQLERRM} Message: {message text} {Log mode is [mode]}
  **
  ** Parameters:
  **  All NULL                  : Blank line displayed on screen
  **  Mode = 'X'                : Nothing displayed  
  **  All except p_message NULL : message text only displayed on screen (verbose FALSE)
  **  Mode = 'F'                : message inserted into applog nothing displayed on screen
  **  ELSE                      : message plus all other info displayed on screen (verbose TRUE) 
  **
  ** Examples:
  **  util_admin.log_message('Hello World');                          -- Hello World
  **  util_admin.log_message();                                       -- Display blank line
  **  util_admin.log_message('NOTHING DISPLAYED',NULL,NULL,'X',NULL); -- Mode X nothing is displayed, no blank line or message
  **  util_admin.log_message('NOTHING DISPLAYED',NULL,NULL,'F',NULL); -- Mode F message inserted into APPLOG, nothing displayed
  **  util_admin.log_message('Hello World',NULL,NULL,NULL,'W');       -- Verbose warning message displayed
  **  
  ** APPLOG data logged in table if p_mode is B or F:
  **  message         : Text passed in p_message
  **  logged_at       : Date and time
  **  user_name       : Current user
  **  applog_sqlerrm  : SQLERRM or text passed in p_sqlerrm
  **  program_name    : Text passed in p_program_name
  **  severity        : I (info), W (warning), E (error)
  **
  ** IN
  **   p_message         - Message to display or write to the log 
  **   p_sqlerrm         - SQL Error Message
  **   p_program_name    - Name of the program creating the log
  **   p_log_mode        - One of:
  **                         F    = write message to log table
  **                         S    = display message on screen (default if mode NULL)
  **                         B    = both display message on screen and write to log table
  **                         X    = Do nothing (turn message OFF e.g. when it is just for debugging and not currently needed)
  **   p_severity        - Indicates the severity of the message, validated on table appseverity:
  **                         I    = Information (default if severity NULL)
  **                         W    = Warning
  **                         E    = Error
  ** OUT
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  PROCEDURE log_message (
      p_message         IN VARCHAR2 DEFAULT NULL,
      p_sqlerrm         IN VARCHAR2 DEFAULT NULL,
      p_program_name    IN VARCHAR2 DEFAULT NULL,
      p_log_mode        IN VARCHAR2 DEFAULT NULL,
      p_severity        IN VARCHAR2 DEFAULT NULL
    ); 
    
  /*
  ** severity_desc - Returns the description of application log severity level
  **
  **
  ** IN
  **   p_severity        - Severity code, e.g. I (info), W (warning), E (error)
  ** RETURN
  **   VARCHAR2  Description of the severity level
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION severity_desc (
     p_severity         IN VARCHAR2
    ) 
    RETURN VARCHAR2;
    
  /*
  ** get_user - Returns the name of the current database user
  **
  **
  ** IN
  ** RETURN
  **   VARCHAR2  Database user name
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */ 
  FUNCTION get_user RETURN VARCHAR2;
  PRAGMA RESTRICT_REFERENCES (get_user, WNDS, WNPS);


END util_admin;
/