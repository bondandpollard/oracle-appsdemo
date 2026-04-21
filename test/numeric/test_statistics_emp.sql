-- test_statistics_emp
-- Test the frequency table statistical functions with salary data loaded into array
-- from emp.
-- Cross reference using test_statistics_emp_SQL.sql
--
SET SERVEROUTPUT ON
ACCEPT p_percentile NUMBER PROMPT "Percentile (number > 0 and < 1)?"
DECLARE
  CURSOR c_emp IS
    SELECT e.sal
    FROM emp e;
  v_array util_numeric.t_number_array :=util_numeric.t_number_array();
  v_stats_result util_numeric.t_stats_result;
  v_percentile_disc NUMBER;
  v_percentile_cont NUMBER;
  e_invalid_data EXCEPTION;
BEGIN
  -- Load salary data into v_array
  
  FOR emp_rec IN c_emp LOOP
    v_array.EXTEND;
    v_array(v_array.COUNT) := emp_rec.sal;
    util_admin.log_message('Salary='||to_char(v_array(v_array.COUNT)));
  END LOOP;
  
  IF v_array IS NULL THEN 
    util_admin.log_message('Array must not be null.');
    RAISE e_invalid_data;
  END IF;

  v_stats_result := util_numeric.get_stats_array(v_array);
  
  util_numeric.display_frequency_table(v_stats_result);
  util_numeric.display_stats(v_stats_result,&p_percentile);
  
  -- Calculate percentiles using frequency table
  v_percentile_disc := util_numeric.percentile_disc(v_stats_result.freq_tbl,&p_percentile);
  util_admin.log_message('PCT_DISC ('||to_char(&p_percentile,'0.99')||')='||trim(to_char(v_percentile_disc,'9,999,999,990.9999999999')));
  v_percentile_cont := util_numeric.percentile_cont(v_stats_result.freq_tbl,&p_percentile);
  util_admin.log_message('PCT_CONT ('||to_char(&p_percentile,'0.99')||')='||trim(to_char(v_percentile_cont,'9,999,999,990.9999999999')));
  

EXCEPTION
  WHEN e_invalid_data THEN
    util_admin.log_message('Invalid data!');
  WHEN OTHERS THEN
    util_admin.log_message('Unexpected error, SQLERRM: ' || SQLERRM);
END;
