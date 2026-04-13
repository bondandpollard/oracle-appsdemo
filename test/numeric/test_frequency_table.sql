-- test_frequency_table
-- Populate a frequency table with values from a list of numbers, and use
-- the table to calculate statistics: sum, count, mean, 
-- mode (>1 value may be returned), highest, lowest, range of values.
-- Also calculates variance, standard deviation.
--
-- Function populate_frequency_table
-- A record is placed in frequency table for each unique number in the array.
-- Each record contains the number (the key) and the count of its occurrences in 
-- the array (frequency).
-- e.g.
-- Array=1,2,1,3,2,4,1
-- FREQUENCY TABLE
-- KEY      FREQUENCY
-----------------------
--  1       3
--  2       2
--  3       1
--  4       1
-----------------------
SET SERVEROUTPUT ON
ACCEPT p_list PROMPT "Enter a list of numbers separated by commas"
ACCEPT p_percentile NUMBER PROMPT "Percentile (number > 0 and < 1)?"

DECLARE
  v_array util_numeric.t_number_array;
  v_frequency_table util_numeric.t_frequency_table;
  v_sum NUMBER;
  v_count_distinct NUMBER;
  v_mean NUMBER;
  v_median NUMBER;
  v_median_array NUMBER; 
  v_modes util_numeric.t_num_table := util_numeric.t_num_table();
  v_highest NUMBER;
  v_lowest NUMBER;
  v_range NUMBER;
  v_var_pop NUMBER;
  v_stddev_pop NUMBER;
  v_var_samp NUMBER;
  v_stddev_samp NUMBER;
  v_percentile_disc NUMBER;
  v_percentile_cont NUMBER;
  v_iqr NUMBER;
  e_invalid_data EXCEPTION;
BEGIN
  util_admin.log_message('Input list is ' || '&p_list');
  -- Array must be sorted for median to be calculated correctly on array
  v_array := util_numeric.sort_array(util_numeric.list_to_array('&p_list'));
  IF v_array IS NULL THEN 
    util_admin.log_message('Array must not be null.');
    RAISE e_invalid_data;
  END IF;
  util_admin.log_message('SORTED ARRAY:');
  FOR m IN 1 .. v_array.LAST LOOP
    util_admin.log_message('v_array('||to_char(m)||') = '||to_char(v_array(m)));
  END LOOP;
  
  v_frequency_table := util_numeric.populate_frequency_table(v_array);
  IF v_frequency_table IS NULL THEN 
    util_admin.log_message('Array must not be null.');
    RAISE e_invalid_data;
  END IF; 
  util_admin.log_message('--------------------------------------------');
  util_admin.log_message('FREQUENCY TABLE');
  util_admin.log_message('--------------------------------------------');
  FOR M IN 1 .. v_frequency_table.COUNT LOOP
    util_admin.log_message('v_frequency_table KEY='||to_char(v_frequency_table(M).KEY)||' Frequency='||to_char(v_frequency_table(M).frequency));
  END LOOP;
  util_admin.log_message('---------------------------------------------');
  v_sum := util_numeric.frequency_table_sum(v_frequency_table);
  util_admin.log_message('Sum='||to_char(v_sum));
  util_admin.log_message('N Total='||to_char(v_array.COUNT));
  v_count_distinct := v_frequency_table.COUNT;
  util_admin.log_message('Distinct N='||to_char(v_count_distinct));
  v_mean := util_numeric.frequency_table_mean(v_frequency_table);
  util_admin.log_message('Mean (AVG)='||trim(to_char(v_mean,'9999990.9999')));
  v_median_array := util_numeric.median_array(v_array);
  util_admin.log_message('Median (ARRAY) ='||to_char(v_median_array)||' NB: This value is derived from array not frequency table and shows mid array value');
  v_median := util_numeric.frequency_table_median(v_frequency_table);
  util_admin.log_message('Median ='||to_char(v_median));
  v_modes := util_numeric.frequency_table_mode(v_frequency_table);
  FOR i IN 1 .. v_modes.COUNT LOOP 
    util_admin.log_message('Mode '||to_char(i)||' = '||to_char(v_modes(i)));
  END LOOP;
  v_lowest := util_numeric.frequency_table_lowest(v_frequency_table);
  util_admin.log_message('Lowest (MIN)='||to_char(v_lowest));
  v_highest := util_numeric.frequency_table_highest(v_frequency_table);
  util_admin.log_message('Highest (MAX)='||to_char(v_highest));
  v_range := util_numeric.frequency_table_range(v_frequency_table);
  util_admin.log_message('Range='||to_char(v_range));
  v_var_pop := util_numeric.variance_pop(v_frequency_table);
  util_admin.log_message('Variance Pop (VAR_POP)='||trim(to_char(v_var_pop,'999999999999990.9999')));
  v_var_samp := util_numeric.variance_samp(v_frequency_table);
  util_admin.log_message('Variance Sample (VAR_SAMP)='||trim(to_char(v_var_samp,'99999999999990.9999')));
  v_stddev_pop := util_numeric.stddev_pop(v_frequency_table);
  util_admin.log_message('Standard Deviation Pop (STDDEV_POP)='||trim(to_char(v_stddev_pop,'9999999990.9999')));
  v_stddev_samp := util_numeric.stddev_samp(v_frequency_table);
  util_admin.log_message('Standard Deviation Sample (STDDEV_SAMP)='||trim(to_char(v_stddev_samp,'9999999990.9999')));
  v_percentile_disc := util_numeric.percentile_disc(v_frequency_table,&p_percentile);
  v_iqr := util_numeric.iqr(v_frequency_table);
  util_admin.log_message('Interquartile Range='||trim(to_char(v_iqr,'9999999990.9999')));
  util_admin.log_message('Discrete Percentile (PERCENTILE_DISC) for ('||to_char(&p_percentile,'0.99')||') ='||trim(to_char(v_percentile_disc,'9999999999.9999')));
  v_percentile_cont := util_numeric.percentile_cont(v_frequency_table,&p_percentile);
  util_admin.log_message('Continuous Interpolated Percentile(PERCENTILE_CONT) for ('||to_char(&p_percentile,'0.99')||') ='||trim(to_char(v_percentile_cont,'9999999999.9999')));

  
EXCEPTION
  WHEN e_invalid_data THEN
    util_admin.log_message('Invalid data!');
END;
