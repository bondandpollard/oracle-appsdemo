CREATE OR REPLACE PACKAGE BODY stats AS

  /*
  ** Private functions and procedures
  */
  
  FUNCTION median_array(
    p_array       IN plsql_types.t_number_array
  ) RETURN NUMBER
  IS
    v_median NUMBER;
    v_count NUMBER;
    v_debug_module applog.program_name%TYPE := 'STATS.MEDIAN_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    v_count := p_array.COUNT;
    -- IF odd number of elements in array, median is mid value
    IF util_numeric.is_odd(v_count) THEN 
      v_median := p_array(floor(v_count/2) +1);
    ELSE 
      v_median := (p_array(floor(v_count/2)) + p_array(floor(v_count/2) +1)) / 2;
    END IF;
    RETURN v_median;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END median_array;
  
  FUNCTION median(
    p_list       IN VARCHAR2
  ) RETURN NUMBER
  IS 
    v_debug_module applog.program_name%TYPE := 'STATS.MEDIAN';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    -- Convert list to array, sort ascending, and calculate median value.
    RETURN median_array(util_numeric.sort_array(util_numeric.list_to_array(p_list)));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END median;

  FUNCTION populate_frequency_table (
    p_array IN plsql_types.t_number_array
  ) RETURN plsql_types.t_frequency_table
  IS 
    v_frequency_table plsql_types.t_frequency_table := plsql_types.t_frequency_table();
    v_sorted_array plsql_types.t_number_array;
    v_array_size PLS_INTEGER;
    v_index PLS_INTEGER;
    v_current_key NUMBER;
    v_current_count PLS_INTEGER;
    v_error_value VARCHAR2(20);
    v_debug_module applog.program_name%TYPE := 'STATS.POPULATE_FREQUENCY_TABLE';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_array EXCEPTION;
    e_null_value EXCEPTION;
    e_non_integer EXCEPTION;
  BEGIN 
    IF p_array IS NULL THEN 
      RAISE e_null_array;
    END IF;
    
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    -- Sort array into ascending sequence
    -- This is required for sequential count of each key to work
    v_sorted_array := util_numeric.sort_array(p_array,'A');
    v_array_size := v_sorted_array.COUNT;
    
    v_index := 1;
    WHILE v_index <= v_array_size LOOP 
    
      -- Strict integer check 
      --IF v_sorted_array(v_index) != TRUNC(v_sorted_array(v_index)) THEN 
      --  v_error_value := TO_CHAR(v_sorted_array(v_index));
      --  RAISE e_non_integer;
      --END IF;
      
      v_current_key := v_sorted_array(v_index);
      v_current_count := 1;
      
      -- Count array values matching current value
      WHILE (v_index + v_current_count) <= v_array_size LOOP 
        EXIT WHEN v_sorted_array(v_index + v_current_count) != v_current_key;
        v_current_count := v_current_count +1;
      END LOOP;
      
      -- Add key (current value) and frequency (count of array items matching current value) to frequency table
      v_frequency_table.EXTEND;
      v_frequency_table(v_frequency_table.COUNT).key := v_current_key;
      v_frequency_table(v_frequency_table.COUNT).frequency := v_current_count;
      
      -- Move index to the next position that contains value that does not match current value
      v_index := v_index + v_current_count;
      
    END LOOP;
    
    RETURN v_frequency_table;
  EXCEPTION
    WHEN e_null_array THEN 
      util_admin.log_message('Array must not be null.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;    
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN e_non_integer THEN 
      util_admin.log_message('The array must contain integers only. Value '||v_error_value||' not allowed.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END populate_frequency_table;
  
  FUNCTION frequency_table_sum (
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS 
    v_sum NUMBER :=0;
    v_debug_module applog.program_name%TYPE := 'STATS.FREQUENCY_TABLE_SUM';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_table EXCEPTION;
  BEGIN 
    IF p_frequency_table IS NULL THEN 
      RAISE e_null_table;
    END IF;
    FOR i IN 1 .. p_frequency_table.COUNT LOOP 
      v_sum := v_sum + (p_frequency_table(i).key * p_frequency_table(i).frequency);
    END LOOP;
    RETURN v_sum;
  EXCEPTION
    WHEN e_null_table THEN
      util_admin.log_message('Frequency Table is null.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END frequency_table_sum;

  FUNCTION frequency_table_count (
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN PLS_INTEGER
  IS 
    v_count PLS_INTEGER :=0;
    v_debug_module applog.program_name%TYPE := 'STATS.FREQUENCY_TABLE_COUNT';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_table EXCEPTION;
  BEGIN 
    IF p_frequency_table IS NULL THEN 
      RAISE e_null_table;
    END IF;
    FOR i IN 1 .. p_frequency_table.COUNT LOOP 
      v_count := v_count + p_frequency_table(i).frequency;
    END LOOP;
    RETURN v_count;
  EXCEPTION
    WHEN e_null_table THEN
      util_admin.log_message('Frequency Table is null.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END frequency_table_count;
  
  FUNCTION frequency_table_mean (
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS 
    v_mean NUMBER :=0;
    v_debug_module applog.program_name%TYPE := 'STATS.FREQUENCY_TABLE_MEAN';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_table EXCEPTION;
  BEGIN 
    IF p_frequency_table IS NULL THEN 
      RAISE e_null_table;
    END IF;
    v_mean := frequency_table_sum(p_frequency_table) / frequency_table_count(p_frequency_table);
    RETURN v_mean;
  EXCEPTION
    WHEN e_null_table THEN
      util_admin.log_message('Frequency Table is null.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END frequency_table_mean;

  FUNCTION value_at_rank(
    p_frequency_table IN plsql_types.t_frequency_table,
    p_rank IN PLS_INTEGER
  ) RETURN NUMBER
  IS
    v_cum PLS_INTEGER := 0;
    i PLS_INTEGER;
    v_debug_module applog.program_name%TYPE := 'STATS.VALUE_AT_RANK';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
   BEGIN 
    IF p_frequency_table IS NULL OR p_frequency_table.COUNT = 0 OR p_rank < 1 THEN 
      RETURN NULL;
    END IF;
    
    FOR i IN 1 .. p_frequency_table.COUNT LOOP 
      v_cum := v_cum + p_frequency_table(i).frequency;
      IF v_cum >= p_rank THEN 
        RETURN p_frequency_table(i).key;
      END IF;
    END LOOP;
    RETURN p_frequency_table(p_frequency_table.COUNT).key; -- safe fallback
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END value_at_rank; 
  
  FUNCTION frequency_table_median (
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS 
    v_n PLS_INTEGER;
    v_r1 PLS_INTEGER;
    v_r2 PLS_INTEGER;
    v_x1 NUMBER;
    v_x2 NUMBER;
    v_debug_module applog.program_name%TYPE := 'STATS.FREQUENCY_TABLE_MEDIAN';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
   BEGIN 
    IF p_frequency_table IS NULL or p_frequency_table.COUNT = 0 THEN 
      RETURN NULL;
    END IF;
    
    v_n := frequency_table_count(p_frequency_table);
    IF v_n = 0 THEN 
      RETURN NULL;
    END IF;
    
    IF util_numeric.is_odd(v_n) THEN 
      -- For odd number of values in population return mid value
      v_r1 := (v_n + 1) / 2;
      RETURN value_at_rank(p_frequency_table, v_r1);
    ELSE 
      -- For even number return average of 2 mid values
      v_r1 := v_n / 2;
      v_r2 := v_r1 + 1;
      v_x1 := value_at_rank(p_frequency_table, v_r1);
      v_x2 := value_at_rank(p_frequency_table, v_r2);
      RETURN (v_x1 + v_x2) / 2;
    END IF;
  
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END frequency_table_median;
  
  FUNCTION frequency_table_mode (
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN plsql_types.t_num_table
  IS 
    tb_modes plsql_types.t_num_table := plsql_types.t_num_table();
    v_max_frequency PLS_INTEGER :=0;
    v_index PLS_INTEGER;
    v_debug_module applog.program_name%TYPE := 'STATS.FREQUENCY_TABLE_MODE';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_table EXCEPTION;
  BEGIN 
    IF p_frequency_table IS NULL OR p_frequency_table.COUNT = 0 THEN 
      RETURN tb_modes;
    END IF;
    
    -- Find maximum frequency (several key values may have same highest frequency)
    FOR v_index IN 1 .. p_frequency_table.COUNT LOOP 
      IF p_frequency_table(v_index).frequency > v_max_frequency THEN 
        v_max_frequency := p_frequency_table(v_index).frequency;
      END IF;
    END LOOP;
    
    -- Second pass, collect all key values with max frequency
    FOR v_index IN 1 .. p_frequency_table.COUNT LOOP 
      IF p_frequency_table(v_index).frequency = v_max_frequency THEN 
        tb_modes.EXTEND;
        tb_modes(tb_modes.COUNT) := p_frequency_table(v_index).key;
      END IF;
    END LOOP;
    RETURN tb_modes;
  EXCEPTION
    WHEN e_null_table THEN
      util_admin.log_message('Frequency Table is null.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END frequency_table_mode;
  
  FUNCTION frequency_table_highest (
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS 
    v_highest NUMBER :=0;
    v_debug_module applog.program_name%TYPE := 'STATS.FREQUENCY_TABLE_HIGHEST';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_table EXCEPTION;
  BEGIN 
    IF p_frequency_table IS NULL THEN 
      RAISE e_null_table;
    END IF;
    v_highest := p_frequency_table(p_frequency_table.COUNT).key;
    RETURN v_highest;
  EXCEPTION
    WHEN e_null_table THEN
      util_admin.log_message('Frequency Table is null.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END frequency_table_highest;

  FUNCTION frequency_table_lowest (
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS 
    v_lowest NUMBER :=0;
    v_debug_module applog.program_name%TYPE := 'STATS.FREQUENCY_TABLE_LOWEST';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'S';
    e_null_table EXCEPTION;
  BEGIN 
    IF p_frequency_table IS NULL THEN 
      RAISE e_null_table;
    END IF;
    v_lowest := p_frequency_table(1).key;
    RETURN v_lowest;
  EXCEPTION
    WHEN e_null_table THEN
      util_admin.log_message('Frequency Table is null.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END frequency_table_lowest;
  
  FUNCTION frequency_table_range (
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS 
    v_range NUMBER :=0;
    v_debug_module applog.program_name%TYPE := 'STATS.FREQUENCY_TABLE_RANGE';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_table EXCEPTION;
  BEGIN 
    IF p_frequency_table IS NULL THEN 
      RAISE e_null_table;
    END IF;
    v_range := frequency_table_highest(p_frequency_table) - frequency_table_lowest(p_frequency_table);
    RETURN v_range;
  EXCEPTION
    WHEN e_null_table THEN
      util_admin.log_message('Frequency Table is null.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END frequency_table_range;

  FUNCTION variance_pop(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS 
    v_freq_count PLS_INTEGER :=0;
    v_mean NUMBER;
    v_ss NUMBER :=0; -- Sum of squares about the Mean
    v_index PLS_INTEGER;
    v_diff NUMBER;
    v_debug_module applog.program_name%TYPE := 'STATS.VARIANCE_POP';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN 
    IF p_frequency_table IS NULL OR p_frequency_table.COUNT = 0 THEN 
      RETURN NULL;
    END IF;
    
    -- Total observations
    v_freq_count := frequency_table_count(p_frequency_table);
    IF v_freq_count = 0 THEN 
      RETURN NULL;
    END IF;
    
    v_mean := frequency_table_mean(p_frequency_table);
    
    -- Sum freq * (X - mean)^2 over distinct values
    FOR v_index IN 1 .. p_frequency_table.COUNT LOOP 
      v_diff := p_frequency_table(v_index).key - v_mean;
      v_ss := v_ss + (p_frequency_table(v_index).frequency * v_diff * v_diff);
    END LOOP;
    
    RETURN v_ss / v_freq_count;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END variance_pop;

  FUNCTION stddev_pop(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS
    v_var NUMBER;
    v_debug_module applog.program_name%TYPE := 'STATS.STDDEV_POP';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN 
    v_var := variance_pop(p_frequency_table);
    IF v_var IS NULL THEN 
      RETURN NULL;
    END IF;
    
    -- Variance should never be negative, but guard against tiny -ve
    -- due to floating error.
    IF v_var < 0 THEN 
      IF v_var >= -1e-12 THEN 
        v_var := 0;
      ELSE 
        RETURN NULL;
      END IF;
    END IF;
    
    RETURN SQRT(v_var);
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END stddev_pop;

  FUNCTION variance_samp(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS
    v_freq_count PLS_INTEGER :=0;
    v_mean NUMBER;
    v_ss  NUMBER :=0; -- Sum of squares about the Mean
    v_index PLS_INTEGER;
    v_diff NUMBER;
    v_debug_module applog.program_name%TYPE := 'STATS.VARIANCE_SAMP';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN 
    IF p_frequency_table IS NULL or p_frequency_table.COUNT = 0 THEN 
      RETURN NULL;
    END IF;
    
    v_freq_count := frequency_table_count(p_frequency_table); -- Sum of frequency
    
    -- Sample variance undefined for N < 2
    IF v_freq_count < 2 THEN 
      RETURN NULL;
    END IF;
    
    v_mean := frequency_table_mean(p_frequency_table);
    
    FOR v_index IN 1 .. p_frequency_table.COUNT LOOP 
      v_diff := p_frequency_table(v_index).key - v_mean;
      v_ss := v_ss + (p_frequency_table(v_index).frequency * v_diff * v_diff);
    END LOOP;
    
    RETURN v_ss / (v_freq_count - 1);
      
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END variance_samp;

  FUNCTION stddev_samp(
    p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS
    v_var NUMBER;
    v_debug_module applog.program_name%TYPE := 'STATS.STDDEV_SAMP';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN 
    v_var := variance_samp(p_frequency_table);
    IF v_var IS NULL THEN 
      RETURN NULL;
    END IF;
    
    -- Variance should never be negative, but guard against tiny -ve
    -- due to floating error.
    IF v_var < 0 THEN 
      IF v_var >= -1e-12 THEN 
        v_var := 0;
      ELSE 
        RETURN NULL;
      END IF;
    END IF;
    
    RETURN SQRT(v_var);
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END stddev_samp;

  FUNCTION percentile_disc(
    p_frequency_table IN plsql_types.t_frequency_table,
    p_pct             IN NUMBER 
  ) RETURN NUMBER
  IS 
    v_freq_count PLS_INTEGER;
    v_rank PLS_INTEGER;
    v_cum PLS_INTEGER := 0;
    i PLS_INTEGER;
    v_debug_module applog.program_name%TYPE := 'STATS.PERCENTILE_DISC';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN 
    IF p_frequency_table IS NULL OR p_frequency_table.COUNT = 0 THEN 
      RETURN NULL;
    END IF;
    
    IF p_pct IS NULL OR p_pct < 0 OR p_pct > 1 THEN 
      RETURN NULL;
    END IF;
    
    -- Total frequency = sum of frequencies in frequency table, Total
    -- number of data points.
    v_freq_count := frequency_table_count(p_frequency_table);
    IF v_freq_count = 0 THEN 
      RETURN NULL;
    END IF;
    
    -- Rank in [1..N]
    v_rank := CEIL(p_pct * v_freq_count);
    IF v_rank < 1 THEN 
      v_rank := 1;
    END IF;
    
    -- Walk cumulative frequency for all rows in frequency table
    FOR i IN 1 .. p_frequency_table.COUNT LOOP
      v_cum := v_cum + p_frequency_table(i).frequency;
      IF v_cum >= v_rank THEN 
        RETURN p_frequency_table(i).key;
      END IF;
    END LOOP;
    
    -- If p_pct = 1, rank=N, loop should return but have safe fallback return.
    RETURN p_frequency_table(p_frequency_table.COUNT).key;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END percentile_disc;
  
  FUNCTION percentile_cont(
    p_frequency_table IN plsql_types.t_frequency_table,
    p_pct             IN NUMBER 
  ) RETURN NUMBER
  IS 
    v_freq_count PLS_INTEGER;
    v_pos NUMBER;
    v_lower_rank PLS_INTEGER;
    v_upper_rank PLS_INTEGER;
    v_cum PLS_INTEGER := 0;
    i PLS_INTEGER;
    v_lower_val NUMBER := NULL;
    v_upper_val NUMBER := NULL;
    v_debug_module applog.program_name%TYPE := 'STATS.PERCENTILE_CONT';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN 
    IF p_frequency_table IS NULL OR p_frequency_table.COUNT = 0 THEN 
      RETURN NULL;
    END IF;
    
    IF p_pct IS NULL OR p_pct < 0 OR p_pct > 1 THEN 
      RETURN NULL;
    END IF;
    
    -- Total frequency = sum of frequencies in frequency table, Total
    -- number of data points.
    v_freq_count := frequency_table_count(p_frequency_table);
    IF v_freq_count = 0 THEN 
      RETURN NULL;
    END IF;
    
    -- Special case: single value
    IF v_freq_count = 1 THEN 
      RETURN p_frequency_table(1).key;
    END IF;
        
    -- Oracle definition
    v_pos := 1 + (v_freq_count -1) * p_pct;
    
    v_lower_rank := FLOOR(v_pos);
    v_upper_rank := CEIL(v_pos);
    
    -- Walk cumulative frequency to find values at the lower and 
    -- upper ranks.
    FOR i in 1 .. p_frequency_table.COUNT LOOP 
      v_cum := v_cum + p_frequency_table(i).frequency;
      
      IF v_lower_val IS NULL AND v_cum >= v_lower_rank THEN 
        v_lower_val := p_frequency_table(i).key;
      END IF;
      
      IF v_cum >= v_upper_rank THEN 
        v_upper_val := p_frequency_table(i).key;
        EXIT;
      END IF;
    END LOOP;
    
    -- If position is integer no interpolation needed 
    IF v_lower_rank = v_upper_rank THEN 
      RETURN v_lower_val;
    END IF;
    
    -- Linear interpolation
    RETURN  v_lower_val + (v_pos - v_lower_rank) 
            * (v_upper_val - v_lower_val);
    
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END percentile_cont;
  
  FUNCTION iqr(
     p_frequency_table IN plsql_types.t_frequency_table
  ) RETURN NUMBER
  IS 
    v_debug_module applog.program_name%TYPE := 'STATS.IQR';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN 
    RETURN  percentile_cont(p_frequency_table, 0.75) - 
            percentile_cont(p_frequency_table, 0.25);
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END iqr;
  
  FUNCTION get_stats(
    p_array IN plsql_types.t_number_array
  ) RETURN plsql_types.t_stats_result
  IS 
    tb_frequency_table plsql_types.t_frequency_table;
    rec_stats plsql_types.t_stats_summary;
    rec_stats_result plsql_types.t_stats_result;
    v_debug_module applog.program_name%TYPE := 'STATS.GET_STATS';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_array EXCEPTION;
    e_null_values EXCEPTION;
  BEGIN 
    IF p_array IS NULL OR p_array.COUNT = 0 THEN 
      RAISE e_null_array;
    END IF;
    
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_values;
    END IF;
    
    -- Populate Frequency Table with values from passed array of numbers
    tb_frequency_table := populate_frequency_table(p_array);
    -- Calculate statistics and store results
    rec_stats.sum_values      := frequency_table_sum(tb_frequency_table);
    rec_stats.n_total         := frequency_table_count(tb_frequency_table);
    rec_stats.distinct_n      := tb_frequency_table.COUNT;
    rec_stats.mean            := frequency_table_mean(tb_frequency_table);
    rec_stats.median          := frequency_table_median(tb_frequency_table);
    rec_stats.mode_values     := frequency_table_mode(tb_frequency_table); -- table of NUMBER
    rec_stats.lowest          := frequency_table_lowest(tb_frequency_table);
    rec_stats.highest         := frequency_table_highest(tb_frequency_table);
    rec_stats.range           := frequency_table_range(tb_frequency_table);
    rec_stats.variance_pop    := variance_pop(tb_frequency_table);
    rec_stats.variance_samp   := variance_samp(tb_frequency_table);
    rec_stats.stddev_pop      := stddev_pop(tb_frequency_table);
    rec_stats.stddev_samp     := stddev_samp(tb_frequency_table);
    rec_stats.iqr             := iqr(tb_frequency_table);
    
    -- Store stats and frequency table in rec_stats_result composite record
    -- and return it.
    rec_stats_result.stats := rec_stats;
    rec_stats_result.freq_tbl := tb_frequency_table;
    RETURN rec_stats_result;
  EXCEPTION
    WHEN e_null_array THEN 
      util_admin.log_message('Array must not be null (empty).', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN e_null_values THEN 
      util_admin.log_message('Null values not allowed in array.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END get_stats;
   
  FUNCTION get_stats_array(
    p_array IN plsql_types.t_number_array
  ) RETURN plsql_types.t_stats_result
  IS 
    v_debug_module applog.program_name%TYPE := 'STATS.GET_STATS_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_array EXCEPTION;
  BEGIN
    IF p_array IS NULL THEN 
      RAISE e_null_array;
    END IF;
    RETURN get_stats(p_array); 
  EXCEPTION
    WHEN e_null_array THEN 
      util_admin.log_message('Array must not be null, or contain null values.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END get_stats_array;
  
  FUNCTION get_stats_list(
    p_list IN VARCHAR2
  ) RETURN plsql_types.t_stats_result
  IS 
    v_debug_module applog.program_name%TYPE := 'STATS.GET_STATS_LIST';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_list EXCEPTION;
  BEGIN
    IF p_list IS NULL THEN 
      RAISE e_null_list;
    END IF;
    RETURN get_stats_array(util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN e_null_list THEN 
      util_admin.log_message('List must not be null, or contain null values.', sqlerrm, v_debug_module, 'S', gc_error);
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END get_stats_list;
  
  FUNCTION get_stats_project(
    p_project_id IN stats_project.stats_project_id%TYPE
  ) RETURN plsql_types.t_stats_result
  IS 
    TYPE t_stats_rec IS RECORD (
      data_id       stats_data.stats_data_id%TYPE, 
      data_value    stats_data.stats_value%TYPE
      );
    TYPE t_stats_value_table IS TABLE OF t_stats_rec;
    tb_stats_value t_stats_value_table;
    
    CURSOR stats_project_cur(cp_project_id stats_project.stats_project_id%TYPE) IS 
      SELECT p.stats_project_id
      FROM stats_project p
      WHERE p.stats_project_id = cp_project_id;
    
    v_null_data_id stats_data.stats_data_id%TYPE;
    v_array plsql_types.t_number_array := plsql_types.t_number_array();
    v_check_project stats_project.stats_project_id%TYPE;
    v_debug_module applog.program_name%TYPE := 'STATS.GET_STATS_PROJECT';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_project_null EXCEPTION;
    e_project_not_found EXCEPTION;
    e_no_data_found EXCEPTION;
    e_array_empty EXCEPTION;
    e_null_value EXCEPTION;
  BEGIN
    -- Check project_id is valid
    IF p_project_id IS NULL THEN 
      RAISE e_project_null;
    END IF;
    
    OPEN stats_project_cur(p_project_id);
    FETCH stats_project_cur INTO v_check_project;
    IF stats_project_cur%NOTFOUND THEN 
      CLOSE stats_project_cur;
      RAISE e_project_not_found;
    END IF;
    
    -- Load data from stats_data for specified project into array
    -- First bulk collect values into table tb_stats_value
    SELECT stats_data_id, stats_value
      BULK COLLECT INTO tb_stats_value
      FROM stats_data
      WHERE stats_project_id = p_project_id;
     
    -- If no data loaded raise error
    IF tb_stats_value.COUNT = 0 THEN 
      RAISE e_no_data_found;
    END IF;
    
    -- Load data from table into array
    FOR i IN tb_stats_value.FIRST .. tb_stats_value.LAST LOOP 
      IF tb_stats_value(i).data_value IS NULL THEN
        -- Check for null values
        v_null_data_id := tb_stats_value(i).data_id;
        RAISE e_null_value;
      END IF;
      v_array.EXTEND;
      v_array(v_array.LAST) := tb_stats_value(i).data_value;
    END LOOP;
    
    IF v_array IS NULL OR v_array.COUNT = 0 THEN 
      RAISE e_array_empty;
    END IF;
    
    IF stats_project_cur%ISOPEN THEN 
      CLOSE stats_project_cur;
    END IF;
    
    RETURN get_stats_array(v_array); 
    
  EXCEPTION
    WHEN e_project_null THEN 
      util_admin.log_message('Parameter p_project_id must not be null.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN e_project_not_found THEN 
      util_admin.log_message('Project not found for p_project_id '||to_char(p_project_id), sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN e_no_data_found THEN 
      util_admin.log_message('No data found in STATS_DATA for p_project_id '||to_char(p_project_id), sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN e_array_empty THEN 
      util_admin.log_message('Failed to populate v_array. Found '||to_char(tb_stats_value.COUNT)||' values in stats_data for Project ID '||
                              to_char(p_project_id), sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN e_null_value THEN 
      util_admin.log_message('Null values not allowed in stats_data. Null found for stats_data.stats_data_id '||to_char(v_null_data_id)||' in project_id '||to_char(p_project_id), sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END get_stats_project;  
  
  PROCEDURE display_frequency_table(
    p_stats_result IN plsql_types.t_stats_result
  )
  IS 
    c_format CONSTANT VARCHAR2(30) := '999,999,999,999,990.9999999999';
  BEGIN 
    util_admin.log_message('----------------------------------------------------------');
    util_admin.log_message('FREQUENCY TABLE');
    util_admin.log_message('----------------------------------------------------------');
    FOR i IN 1 .. p_stats_result.freq_tbl.COUNT LOOP 
      util_admin.log_message( 'KEY='||trim(to_char(p_stats_result.freq_tbl(i).KEY,c_format))||
                              ' Frequency='||to_char(p_stats_result.freq_tbl(i).frequency));
    END LOOP;
    util_admin.log_message('----------------------------------------------------------');
  END display_frequency_table;
  
  PROCEDURE display_stats(
    p_stats_result IN plsql_types.t_stats_result,
    p_pct IN NUMBER DEFAULT 0.5
  )
  IS
    c_format CONSTANT VARCHAR2(30) := '999,999,999,999,990.9999999999';
  BEGIN
    util_admin.log_message('STATISTICS');
    util_admin.log_message('Sum='||trim(to_char(p_stats_result.stats.sum_values,c_format)));
    util_admin.log_message('N Total='||to_char(p_stats_result.stats.n_total));
    util_admin.log_message('Distinct N='||to_char(p_stats_result.stats.distinct_n));
    util_admin.log_message('Mean='||trim(to_char(p_stats_result.stats.mean,c_format)));
    util_admin.log_message('Median='||trim(to_char(p_stats_result.stats.median,c_format)));
    FOR i IN 1 .. p_stats_result.stats.mode_values.COUNT LOOP 
      util_admin.log_message('Mode '||to_char(i)||' = '||trim(to_char(p_stats_result.stats.mode_values(i),c_format)));
    END LOOP;
    util_admin.log_message('Lowest='||trim(to_char(p_stats_result.stats.lowest,c_format)));
    util_admin.log_message('Highest='||trim(to_char(p_stats_result.stats.highest,c_format)));
    util_admin.log_message('Range='||trim(to_char(p_stats_result.stats.range,c_format)));
    util_admin.log_message('Variance Population='||trim(to_char(p_stats_result.stats.variance_pop,c_format)));
    util_admin.log_message('Variance Sample='||trim(to_char(p_stats_result.stats.variance_samp,c_format)));
    util_admin.log_message('Standard Deviation Population='||trim(to_char(p_stats_result.stats.stddev_pop,c_format)));
    util_admin.log_message('Standard Deviation Sample='||trim(to_char(p_stats_result.stats.stddev_samp,c_format)));
    util_admin.log_message('Interquartile Range='||trim(to_char(p_stats_result.stats.iqr,c_format)));
    
    -- Percentiles
    util_admin.log_message('Percentile Discrete ('||to_char(p_pct,'0.99')||')='||trim(to_char(percentile_disc(p_stats_result.freq_tbl, p_pct),c_format)));
    util_admin.log_message('Percentile Continuous ('||to_char(p_pct,'0.99')||')='||trim(to_char(percentile_cont(p_stats_result.freq_tbl, p_pct),c_format)));   
  END display_stats;
  
END stats;
/