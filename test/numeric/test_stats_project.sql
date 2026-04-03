-- test_stats_project
-- Test the frequency table statistical functions with data loaded into array
-- from stats_data
--
SET SERVEROUTPUT ON
ACCEPT p_project_id NUMBER PROMPT "Enter Project ID to generate statistics for:"
ACCEPT p_percentile NUMBER PROMPT "Percentile (number > 0 and < 1)?"
DECLARE 
  v_stats_result util_numeric.t_stats_result :=util_numeric.t_stats_result();
  v_percentile_disc NUMBER;
  v_percentile_cont NUMBER;
  e_invalid_data EXCEPTION;
BEGIN
  v_stats_result := util_numeric.get_stats_project(&p_project_id);
  IF v_stats_result.freq_tbl IS NULL THEN 
    RAISE e_invalid_data;
  END IF;
  
  util_numeric.display_frequency_table(v_stats_result);
  util_numeric.display_stats(v_stats_result,&p_percentile);
EXCEPTION
  WHEN e_invalid_data THEN
    util_admin.log_message('Invalid data!');
END;
