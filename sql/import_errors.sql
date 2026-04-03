/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : import_errors.sql
**
** DESCRIPTION
**   Report data import errors
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 21/07/2022   Ian Bond      Created
*/

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN recid            HEADING 'Rec ID'     FORMAT A6
COLUMN filename         HEADING 'Filename'   FORMAT A20
COLUMN key_value        HEADING 'Key Value'  FORMAT A15
COLUMN error_data       HEADING 'Data'       FORMAT A20
COLUMN error_message    HEADING 'Message'    FORMAT A30
COLUMN import_sqlerrm   HEADING 'SQLERRM'    FORMAT A30
COLUMN date_time        HEADING 'Date'       FORMAT A20
COLUMN user_name        HEADING 'User'       FORMAT A15

BREAK ON filename SKIP 2 ON REPORT

SET PAGESIZE 66
SET NEWPAGE 0
SET LINESIZE 200

TTITLE CENTER 'Bond and Pollard Limited' SKIP 1 -
  CENTER ======================== SKIP 1-
  LEFT 'Data Import Error Report'  -
  RIGHT 'Page:' SQL.PNO SKIP 2


SELECT E.recid,
       E.filename,
       E.key_value,
       E.error_data,
       E.error_message, 
       E.import_sqlerrm,
       to_char(E.error_time,'DD-MON-RR HH24:MM:SS.FF') date_time,
       E.user_name
FROM importerror E
--WHERE trunc(E.error_date) >= trunc(SYSDATE)
ORDER BY E.recid ASC ; 