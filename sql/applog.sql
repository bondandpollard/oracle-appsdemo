/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : applog.sql
**
** DESCRIPTION
**   Application Log report
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 03/08/2022   Ian Bond      Created
*/

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN message          HEADING 'Message'    FORMAT A30
COLUMN date_time        HEADING 'Logged At'  FORMAT A20
COLUMN user_name        HEADING 'Username'   FORMAT A12
COLUMN applog_sqlerrm   HEADING 'SQLERRM'    FORMAT A30
COLUMN program_name     HEADING 'Program'    FORMAT A12
COLUMN severity_desc    HEADING 'Severity'   FORMAT A12
COLUMN recid            HEADING 'RECID'      FORMAT A8

SET PAGESIZE 66
SET NEWPAGE 0
SET LINESIZE 132

TTITLE CENTER 'Bond and Pollard Limited' SKIP 1 -
  CENTER ======================== SKIP 1-
  LEFT 'Application Log'  -
  RIGHT 'Page:' SQL.PNO SKIP 2
SELECT L.message,
  to_char(L.logged_at,'DD/MM/RR HH24:MM:SS.FF') date_time,
  L.user_name,
  L.applog_sqlerrm,
  L.program_name,
  S.severity_desc,
  L.recid
FROM applog L,
     appseverity S
WHERE S.severity (+) = L.severity
ORDER BY L.logged_at;
