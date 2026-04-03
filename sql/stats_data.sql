/*
** Copyright (c) 2026 Bond & Pollard Ltd. All rights reserved.  
** NAME   : stats_data.sql
**
** DESCRIPTION
**  Report statistics data in STATS_DATA.
**  You can generate statistic for this data by using function UTIL_NUMERIC.GET_STATS_PROJECT 
**  to generate a frequency table from data for a specified project.
**
**  See stats_project.sql
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 17/03/2026   Ian Bond      Created
*/
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN project_id         HEADING 'Project ID'          FORMAT 9999;
COLUMN project_desc       HEADING 'Description'         FORMAT A20;
COLUMN data_project_id    HEADING 'Data Project ID'     FORMAT 9999;
COLUMN stats_data_id      HEADING 'Data ID'             FORMAT 9999;
COLUMN data_desc          HEADING 'Data Description'    FORMAT A20; 
COLUMN stats_data_value   HEADING 'Value'               FORMAT A30;

BREAK ON project_id SKIP PAGE NODUP

SET PAGESIZE 66
SET NEWPAGE 0
SET LINESIZE 132

TTITLE CENTER 'Bond and Pollard Limited' SKIP 1 -
  CENTER ======================== SKIP 1-
  LEFT 'Project Statistics Data'  -
  RIGHT 'Page:' SQL.PNO SKIP 2
  
ACCEPT p_project_id NUMBER PROMPT "Project Id:"

SELECT P.stats_project_id   project_id
  ,P.DESCRIPTION            project_desc
  ,S.stats_data_id
  ,S.stats_project_id       data_project_id
  ,S.DESCRIPTION            data_desc
  ,NVL(TO_CHAR(S.stats_value),'*** ERROR NULL VALUE ***') stats_data_value
FROM stats_project P
FULL JOIN stats_data S ON S.stats_project_id = P.stats_project_id
WHERE P.stats_project_id = &p_project_id OR &p_project_id = 0
ORDER BY P.stats_project_id, S.stats_data_id;