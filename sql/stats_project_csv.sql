/*
** Copyright (c) 2026 Bond & Pollard Ltd. All rights reserved.  
** NAME   : stats_project_csv.sql
**
** DESCRIPTION
**  Calculate statistics for a project, export result to CSV file.
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
** 22/03/2026   Ian Bond      Created
*/
SET SERVEROUTPUT ON
ACCEPT p_project_id NUMBER PROMPT "Enter Project ID to generate statistics for:"
ACCEPT p_percentile NUMBER PROMPT "Percentile (number > 0 and < 1)?"
DECLARE 
  v_stats_result util_numeric.t_stats_result :=util_numeric.t_stats_result();
  v_proj_desc stats_project.description%TYPE;
  v_csv_fname plsql_constants.filenamelength_t;
  v_percentile_disc NUMBER;
  v_percentile_cont NUMBER;
  e_invalid_data EXCEPTION;
BEGIN
  v_stats_result := util_numeric.get_stats_project(&p_project_id);
  IF v_stats_result.freq_tbl IS NULL THEN 
    RAISE e_invalid_data;
  END IF;
  
  SELECT description
  INTO v_proj_desc
  FROM stats_project
  WHERE stats_project_id = &p_project_id;
  
  util_admin.log_message('Project Desc: '||v_proj_desc);
  
  util_numeric.display_frequency_table(v_stats_result);
  util_numeric.display_stats(v_stats_result,&p_percentile);
  
  -- Calculate percentiles using frequency table
  util_admin.log_message('PERCENTILES');
  v_percentile_disc := util_numeric.percentile_disc(v_stats_result.freq_tbl,&p_percentile);
  util_admin.log_message('PCT_DISC ('||to_char(&p_percentile,'0.99')||')='||trim(to_char(v_percentile_disc,'9999999990.9999')));
  v_percentile_cont := util_numeric.percentile_cont(v_stats_result.freq_tbl,&p_percentile);
  util_admin.log_message('PCT_CONT ('||to_char(&p_percentile,'0.99')||')='||trim(to_char(v_percentile_cont,'9999999990.9999')));
  
  -- Export stats to CSV file
  v_csv_fname := export.project_stats(&p_project_id, v_stats_result, &p_percentile);
  
  util_admin.log_message('Statistics exported to CSV file: '||v_csv_fname); 
    

EXCEPTION
  WHEN e_invalid_data THEN
    util_admin.log_message('Invalid data in STATS_DATA for Project_ID ' || to_char(&p_project_id));
END;
