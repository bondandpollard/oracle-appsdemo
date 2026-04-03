-- test_statistics_prompt
-- Populate a frequency table with values from a list of numbers, and use
-- the table to calculate statistics: sum, count, mean, 
-- mode (>1 value may be returned), highest, lowest, range of values.
-- Also calculates variance, standard deviation.
--
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
  v_stats_result util_numeric.t_stats_result;
  v_percentile_cont NUMBER;
  v_percentile_disc NUMBER;
BEGIN
  util_admin.log_message('Input list is ' || '&p_list');

  v_stats_result := util_numeric.get_stats_list('&p_list');
  util_numeric.display_frequency_table(v_stats_result);
  util_numeric.display_stats(v_stats_result,&p_percentile);

EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('See error messages above.');
END;
