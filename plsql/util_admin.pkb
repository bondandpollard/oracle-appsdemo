CREATE OR REPLACE PACKAGE BODY util_admin AS
 
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
            ' at '                    || TO_CHAR(LOCALTIMESTAMP,'DD-MON-YYYY HH24:MI:SS.FF')  ||
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
           ' at ' || TO_CHAR(LOCALTIMESTAMP,'DD-MON-RR HH24:MI:SS.FF') ||
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
