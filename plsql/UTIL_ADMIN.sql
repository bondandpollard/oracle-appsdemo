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


CREATE OR REPLACE PACKAGE BODY util_admin AS
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
  ** Private functions and procedures
  */

  /*
  ** severity_validate - Validate the severity code
  **
  **
  ** IN
  **   p_severity      - Severity code e.g. I (info), E (error), W (warning)
  ** RETURN
  **   BOOLEAN  TRUE if the severity code is valid, otherwise FALSE
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */ 
  FUNCTION severity_validate (
      p_severity        IN VARCHAR2
    )
    RETURN BOOLEAN
  IS
    l_severity applog.severity%TYPE;
    l_valid BOOLEAN := FALSE;
  BEGIN
    SELECT S.severity INTO l_severity 
      FROM appseverity S
      WHERE S.severity = p_severity;
    IF SQL%FOUND THEN
      l_valid := TRUE;
    END IF;
    RETURN l_valid;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      dbms_output.put_line('UTIL_ADMIN.SEVERITY_VALIDATE Invalid Severity ' || p_severity);
      RETURN FALSE;
    WHEN OTHERS THEN
      dbms_output.put_line('UTIL_ADMIN.SEVERITY_VALIDATE Unexpected error for Severity ' || p_severity);
      RETURN FALSE;
  END severity_validate;
  
  /*
  ** Public functions and procedures
  */


  FUNCTION severity_desc (
     p_severity         IN VARCHAR2
    ) 
    RETURN VARCHAR2
  IS
    l_severity applog.severity%TYPE;
    l_severity_desc appseverity.severity_desc%TYPE;
  BEGIN
    SELECT S.severity_desc INTO l_severity_desc
      FROM appseverity S
      WHERE S.severity = p_severity;
    IF SQL%NOTFOUND THEN
      l_severity_desc := 'No description found';
    END IF;
    RETURN l_severity_desc;
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('No description found on APPSEVERITY for ' || p_severity);
      RETURN 'NOT FOUND';
  END severity_desc;
  
  PROCEDURE log_message (
      p_message         IN VARCHAR2 DEFAULT NULL,
      p_sqlerrm         IN VARCHAR2 DEFAULT NULL,
      p_program_name    IN VARCHAR2 DEFAULT NULL,
      p_log_mode        IN VARCHAR2 DEFAULT NULL,
      p_severity        IN VARCHAR2 DEFAULT NULL
    ) 
  IS
    l_severity applog.severity%TYPE;
    l_mode VARCHAR2(1);
    verbose BOOLEAN := TRUE; -- Default verbose messages
    l_program_msg VARCHAR2(120);
    l_sqlerrm_msg VARCHAR2(300);
  BEGIN
    -- Verbose or brief message? If all parameters except message NULL then verbose is FALSE
    IF p_sqlerrm IS NULL AND p_program_name IS NULL AND p_severity IS NULL AND p_log_mode IS NULL THEN 
      verbose := FALSE;
    END IF;
    
    -- Validate mode
    l_mode := NVL(UPPER(SUBSTR(p_log_mode,1,1)),'S');
    IF NOT l_mode IN ('B','F','S','X') THEN
      dbms_output.put_line('UTIL_ADMIN.LOG_MESSAGE Invalid Log Mode (' || l_mode || ') must be one of B (both), F (file), S (screen - DEFAULT), X (cancel - do nothing). Defaulted to S - Screen');
      l_mode := 'S'; --Default to display message on screen
    END IF;
    
    -- Validate Severity
    l_severity := NVL(SUBSTR(p_severity,1,1),'I');
    IF NOT severity_validate(l_severity) THEN
      dbms_output.put_line('UTIL_ADMIN.LOG_MESSAGE Invalid Severity (' || l_severity || ') defaulted to I - Information');
      l_severity := 'I'; -- Default value for invalid severity
    END IF;
    
    IF l_mode <> 'X' THEN 
      -- NOT mode X (debug/message OFF) so display or write message to log
      
      IF l_mode IN ('F','B') THEN
        -- Write message to applog table (mode is File or Both)
        
        INSERT INTO applog (
            message,
            logged_at,
            user_name,
            applog_sqlerrm,
            program_name,
            severity
          )
          VALUES (
            p_message,
            LOCALTIMESTAMP,
            get_user,
            NVL(p_sqlerrm,'No SQLERRM'),
            NVL(p_program_name,'Not Named'),
            l_severity
          );
      END IF;
      IF l_mode IN ('S','B') THEN
        -- Display log message on screen (node is Screen or Both)
       
        -- Short or verbose message?
        IF verbose THEN
          -- Verbose message
          dbms_output.put_line(
            NVL(severity_desc(l_severity),'Message')                                          ||
            ' from program '          || NVL(p_program_name,'[not named]')                    || 
            ' at '                    || TO_CHAR(LOCALTIMESTAMP,'DD-MON-YYYY HH24:MM:SS.FF')  ||
            ' [Log mode is '          || l_mode ||  ']'                                       ||
            ' SQLERRM is '            || NVL(p_sqlerrm,'[not passed]')                        ||
            ' Message: '              || p_message

            );
        ELSE 
          -- Brief message
          dbms_output.put_line(p_message);
        END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
       dbms_output.put_line('UTIL_ADMIN.LOG_MESSAGE Unexpected error. Program ' || NVL(p_program_name,'[NOT SPECIFIED]') || 
           ' at ' || TO_CHAR(LOCALTIMESTAMP,'DD-MON-RR HH24:MM:SS.FF') ||
           ' could not log message: ' || p_message || 
           ' SQLERRM is ' || SQLERRM ||
           ' (Log mode is ' || l_mode || ')' 
         );
  END log_message;
  
  FUNCTION get_user RETURN VARCHAR2 IS
   -- local variables
   l_username VARCHAR2(128);
  BEGIN
    SELECT sys_context('USERENV', 'CURRENT_USER')
      INTO l_username 
      FROM dual;
    RETURN l_username;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_user;

END util_admin;
/
