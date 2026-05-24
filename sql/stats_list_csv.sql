/*
** Copyright (c) 2026 Bond & Pollard Ltd. All rights reserved.  
** This software is free to use and modify at your own risk.
**
** NAME   : stats_list_csv.sql
**
** DESCRIPTION
**  Calculate statistics for a list of numbers, export result to CSV file.
**  The user is prompted for:
**    Name to include in CSV header as a title for the stats
**    List of numbers to calculate stats from
**    Percentile to calculate, a number between 0 and 1
**
**  A frequency table is generated from the data, the statistics are
**  displayed, and a CSV file is created. 
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 24/03/2026   Ian Bond      Created
** 14/05/2026   Ian Bond      Function export.stats renamed to export.stats_export to avoid conflict with stats package
**                            Statistic functions moved from util_numeric to stats package.
**                            Types moved to plsql_types.
** 24/05/2026   Ian Bond      Improve error handling.
*/
SET SERVEROUTPUT ON
ACCEPT p_name PROMPT "Enter a name for your statistics:"
ACCEPT p_list PROMPT "Enter a list of numbers separated by commas"
ACCEPT p_percentile NUMBER PROMPT "Percentile (number > 0 and < 1)?"

DECLARE
  v_stats_result plsql_types.t_stats_result;
  v_percentile_cont NUMBER;
  v_percentile_disc NUMBER;
  v_csv_fname plsql_constants.filenamelength_t;
  e_get_stats_error EXCEPTION;
  e_export_stats_error EXCEPTION;
BEGIN
  -- Display data entered by user
  util_admin.log_message('Name is: ' || '&p_name');
  util_admin.log_message('Input list is: ' || '&p_list');
  
  -- Calculate statistics for list of numbers entered
  v_stats_result := stats.get_stats_list('&p_list');
  IF v_stats_result.stats.sum_values IS NULL THEN
    RAISE e_get_stats_error;
  END IF;
  
  -- Display frequency table, and statistics
  stats.display_frequency_table(v_stats_result);
  stats.display_stats(v_stats_result,&p_percentile);
  
  -- Calculate and display percentiles
  util_admin.log_message('PERCENTILES');
  v_percentile_disc := stats.percentile_disc(v_stats_result.freq_tbl,&p_percentile);
  util_admin.log_message('PCT_DISC ('||to_char(&p_percentile,'0.99')||')='||trim(to_char(v_percentile_disc,'9,999,999,990.9999999999')));
  v_percentile_cont := stats.percentile_cont(v_stats_result.freq_tbl,&p_percentile);
  util_admin.log_message('PCT_CONT ('||to_char(&p_percentile,'0.99')||')='||trim(to_char(v_percentile_cont,'9,999,999,990.9999999999')));
  
  -- Write stats to CSV file
  v_csv_fname := export.stats_export(v_stats_result, '&p_name',&p_percentile);
  IF v_csv_fname IS NULL THEN 
    RAISE e_export_stats_error;
  END IF;
  
  util_admin.log_message('Statistics exported to CSV file: '||v_csv_fname); 
  
EXCEPTION
  WHEN e_get_stats_error THEN
    util_admin.log_message('No statistics results returned by function STATS.GET_STATS',SQLERRM,'STATS_LIST_CSV.SQL','B','E');
  WHEN e_export_stats_error THEN
    util_admin.log_message('Export failed (EXPORT.STATS_EXPORT)',SQLERRM,'STATS_LIST_CSV.SQL','B','E');
  WHEN OTHERS THEN
    util_admin.log_message('Unexpected error.',SQLERRM,'STATS_LIST_CSV.SQL','B','E');
END;