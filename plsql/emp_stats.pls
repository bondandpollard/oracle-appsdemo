CREATE OR REPLACE PROCEDURE emp_stats (
  p_pct IN NUMBER
)
AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : emp_stats
  ** Description   : Calculate statistics for EMP table
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                Description
  **------------------------------------------------------------------------ 
  ** 25/02/2026       Ian Bond            Created.
  */
  
  /*
  ** emp_stats
  **
  ** Calculate statistics for salaries in EMP table.
  ** Display statistics.
  **
  ** IN
  **   p_pct          - Number >0 and <=1 is percentile to calculate
  **                    e.g. 0.33 is 33rd Percentile.      
  **
  */
  
  CURSOR c_emp IS
    SELECT e.sal
    FROM emp e;
  v_array util_numeric.t_number_array :=util_numeric.t_number_array();
  v_stats_result util_numeric.t_stats_result;
  percentile_valid BOOLEAN := TRUE;
  v_pct_disc NUMBER;
  v_pct_cont NUMBER;
  e_null_array EXCEPTION;
BEGIN

  IF p_pct IS NOT NULL AND p_pct > 0 AND p_pct <= 1 THEN 
    percentile_valid := TRUE;
  ELSE
    percentile_valid := FALSE;
  END IF;
  -- Load salary data into v_array
  
  FOR emp_rec IN c_emp LOOP
    v_array.EXTEND;
    v_array(v_array.COUNT) := emp_rec.sal;
    util_admin.log_message('Salary='||to_char(v_array(v_array.COUNT)));
  END LOOP;
  
  IF v_array IS NULL OR v_array.COUNT = 0 THEN 
    RAISE e_null_array;
  END IF;
  
  
  -- Pass array to get_stats_array which will call functions
  -- to populate frequency table, get statistics and return 
  -- results in record contains frequency tables and all stats
  v_stats_result := util_numeric.get_stats_array(v_array);
  
  -- Display frequency table and statistics
  util_numeric.display_frequency_table(v_stats_result);
  util_numeric.display_stats(v_stats_result);
  
  -- Calculate percentiles if valid 
  IF percentile_valid THEN 
    v_pct_disc := util_numeric.percentile_disc(v_stats_result.freq_tbl,p_pct);
    util_admin.log_message('Discrete Percentile (actually observered data point) PCT_DISC ('||trim(to_char(p_pct,'0.99'))||') ='||trim(to_char(v_pct_disc,'9999999990.9999')));
    v_pct_cont := util_numeric.percentile_cont(v_stats_result.freq_tbl,p_pct);
    util_admin.log_message('Continuous Percentile (Interpolated value) PCT_CONT ('||trim(to_char(p_pct,'0.99'))||') ='||trim(to_char(v_pct_cont,'9999999990.9999')));
  END IF;

EXCEPTION
  WHEN e_null_array THEN
    util_admin.log_message('Array must not be null (empty).');  
  WHEN OTHERS THEN
    util_admin.log_message('Unexpected error. Please see previous error messages.');
END;
/