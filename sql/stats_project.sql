/*
** Copyright (c) 2026 Bond & Pollard Ltd. All rights reserved.  
** This software is free to use and modify at your own risk.
**
** NAME   : stats_project.sql
**
** DESCRIPTION
**  Calculate statistics for a project.
**  The data is stored in table STATS_DATA.
**  The user is prompted for the project id and percentile to calculate.
**  A frequency table is generated from the data, and the statistics are
**  displayed. 
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 17/03/2026   Ian Bond      Created
** 14/05/2026   Ian Bond      Function export.stats renamed to export.stats_export to avoid conflict with stats package
**                            Statistic functions moved from util_numeric to stats package.
**                            Types moved to plsql_types.
*/
SET SERVEROUTPUT ON
ACCEPT p_project_id NUMBER PROMPT "Enter Project ID to generate statistics for:"
ACCEPT p_percentile NUMBER PROMPT "Percentile (number > 0 and < 1)?"
DECLARE 
  v_stats_result plsql_types.t_stats_result :=plsql_types.t_stats_result();
  v_percentile_disc NUMBER;
  v_percentile_cont NUMBER;
  e_invalid_data EXCEPTION;
BEGIN
  v_stats_result := stats.get_stats_project(&p_project_id);
  IF v_stats_result.freq_tbl IS NULL THEN 
    RAISE e_invalid_data;
  END IF;
  
  stats.display_frequency_table(v_stats_result);
  stats.display_stats(v_stats_result,&p_percentile);
  
  -- Calculate percentiles using frequency table
  util_admin.log_message('PERCENTILES');
  v_percentile_disc := stats.percentile_disc(v_stats_result.freq_tbl,&p_percentile);
  util_admin.log_message('PCT_DISC ('||to_char(&p_percentile,'0.99')||')='||trim(to_char(v_percentile_disc,'9,999,999,990.9999999999')));
  v_percentile_cont := stats.percentile_cont(v_stats_result.freq_tbl,&p_percentile);
  util_admin.log_message('PCT_CONT ('||to_char(&p_percentile,'0.99')||')='||trim(to_char(v_percentile_cont,'9,999,999,990.9999999999')));

EXCEPTION
  WHEN e_invalid_data THEN
    util_admin.log_message('Invalid data in STATS_DATA for Project_ID ' || to_char(&p_project_id), SQLERRM,'STATS_PROJECT.SQL','B','E');
  WHEN OTHERS THEN
    util_admin.log_message('Unexpected error.', SQLERRM,'STATS_PROJECT.SQL','B','E');
END;
