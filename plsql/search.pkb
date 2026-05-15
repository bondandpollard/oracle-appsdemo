CREATE OR REPLACE PACKAGE BODY search AS

  /*
  ** Private functions and procedures
  */
  
  
  
  /* 
  ** Public functions and procedures
  */
  
    
  FUNCTION binary_chop_search(
    p_key   IN NUMBER,
    p_list  IN VARCHAR2
  ) RETURN NUMBER
  IS
    v_list_array plsql_types.t_number_array;
    v_lower_bound INTEGER;
    v_upper_bound INTEGER;
    v_interval INTEGER;
    v_half INTEGER;
    v_position INTEGER :=1;
    found BOOLEAN := FALSE;
    v_insert_position INTEGER :=1;
    v_debug_msg applog.message%TYPE;
    v_debug_module applog.program_name%TYPE := 'SEARCH.BINARY_CHOP_SEARCH';
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_list EXCEPTION;
    e_null_value EXCEPTION;
  BEGIN
   
    IF p_list IS NULL THEN
      RAISE e_null_list;
    END IF;
    
    v_debug_msg := 'Key to find is ' || to_char(p_key);
    util_admin.log_message(v_debug_msg, sqlerrm, v_debug_module, v_debug_mode, gc_info);
      
    -- Populate array with fields passed in p_list, a comma separated list of values
    v_list_array := util_numeric.list_to_array(p_list);
    
    -- Check there are no null values
    IF util_numeric.array_contains_null(v_list_array) THEN 
      RAISE e_null_value;
    END IF;
    
    -- Sort the array ascending, as binary chop only works with sorted array.
    v_list_array := util_numeric.sort_array(v_list_array);
    
    v_lower_bound := 1;
    
    -- Set upper bound to search to last non null number is list
    v_upper_bound := v_list_array.LAST;
  
    IF v_debug_mode <> 'X' THEN 
      -- Display contents of sorted list
      FOR m IN 1 .. v_upper_bound LOOP
        util_admin.log_message('Array item ' || to_char(m) || '=' || to_char(v_list_array(m)), sqlerrm, v_debug_module, v_debug_mode, gc_info);
      END LOOP;
    END IF;
  
    -- Search list for position of key value
    WHILE v_lower_bound <= v_upper_bound
    LOOP
      -- Determine position of value at halfway point in list
      v_interval := v_upper_bound - v_lower_bound +1;
      v_half := floor(v_interval / 2);
      v_position := v_lower_bound + v_half;
      v_debug_msg := 'v_lower_bound='   || to_char(v_lower_bound) || 
                     ' v_upper_bound='  || to_char(v_upper_bound) || 
                     ' v_interval='     || to_char(v_interval)    ||
                     ' v_half='         || to_char(v_half)        || 
                     ' v_list_array('   || to_char(v_position)    || ') = ' || 
                                           to_char(v_list_array(v_position));
      util_admin.log_message(v_debug_msg, sqlerrm, v_debug_module, v_debug_mode, gc_info);
      IF p_key = v_list_array(v_position) THEN
        -- Search value found
        found := TRUE;
        EXIT;
      ELSIF p_key > v_list_array(v_position) THEN
        -- The value sought must be greater than the found value in the list so search the half of the list above
        v_lower_bound := v_position +1;
      ELSE
        -- The value sought is less than the found value in the list so search the half of the list below
        v_upper_bound := v_position -1;
      END IF;
    END LOOP;
    
    IF NOT found THEN
      -- Key not found in list. Final upper bound position is the insertion point if you wanted to add the value to the list. All items at and
      -- above insertion point must first be moved 1 position forward.

      v_debug_msg :=  'New value to insert='              || to_char(p_key)         || 
                      ' Upper Bound Position of Search='  || to_char(v_upper_bound);
      util_admin.log_message(v_debug_msg, sqlerrm, v_debug_module, v_debug_mode, gc_info);
      v_insert_position := v_upper_bound +1;
      v_debug_msg := 'Key value ' || to_char(p_key) || ' not found in list. Insert new value at position ' || to_char(v_insert_position);
      util_admin.log_message(v_debug_msg, sqlerrm, v_debug_module, 'S', gc_info);
      v_position :=0;
    END IF;
    RETURN v_position;
    
  EXCEPTION
    WHEN e_null_list THEN 
      util_admin.log_message('Invalid data, input string must not be null.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN e_null_value THEN 
      util_admin.log_message('Invalid data, null values not allowed.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END binary_chop_search;
  
  
 FUNCTION binary_search_array(
    p_target   IN NUMBER,
    p_array    IN plsql_types.t_number_array
  ) RETURN NUMBER
  IS 
    l PLS_INTEGER; -- Left bound of array to search
    r PLS_INTEGER; -- Right bound of array to search
    n PLS_INTEGER; -- For VARRAY count = last element of array
    t NUMBER;      -- Search target value
    m PLS_INTEGER; -- Mid position of range [l,r]
    p PLS_INTEGER; -- Position of target
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
  
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    IF NOT util_numeric.is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    
    t := p_target;
    n := p_array.LAST;
    l := 1;
    r := n;
    p := 0;

    -- Find position of target t in array
    WHILE l <= r LOOP
      m := l + floor((r -l) / 2);
      IF p_array(m) < t THEN 
        l := m+1;
      ELSIF p_array(m) > t THEN 
        r := m-1;
      ELSE
        p := m;
        EXIT;
      END IF;
    END LOOP;
    RETURN p;
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'SEARCH.BINARY_SEARCH_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, 'SEARCH.BINARY_SEARCH_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'SEARCH.BINARY_SEARCH_ARRAY', 'S', gc_error);
      RETURN NULL;
  END binary_search_array;
  
  
  FUNCTION binary_search(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2
  ) RETURN NUMBER
  IS
  BEGIN
    RETURN binary_search_array(p_target,util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'SEARCH.BINARY_SEARCH', 'S', gc_error);
      RETURN NULL;
  END binary_search;
 
  FUNCTION binary_rank_array(
    p_target   IN NUMBER,
    p_array    IN plsql_types.t_number_array
  ) RETURN NUMBER
  IS 
    p NUMBER :=0;
    r NUMBER :=0;
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    IF NOT util_numeric.is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    
    -- Position of target value in array (not exact match, so if value not found gives position it should be in list
    p := search.binary_search_leftmost_array(p_target, p_array, FALSE);
    -- Rank is number of elements in array less than target value.
    IF p > 0 THEN
      r := p-1; --Rank is target found in array (otherwise it is 0)
    END IF;
    RETURN r;  
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'SEARCH.BINARY_RANK_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, 'SEARCH.BINARY_RANK_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'SEARCH.BINARY_RANK_ARRAY', 'S', gc_error);
      RETURN NULL;
  END binary_rank_array;
  
  FUNCTION binary_rank(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2
  ) RETURN NUMBER
  IS
    p NUMBER :=0;
    r NUMBER :=0;
  BEGIN
    -- Position of target value in array (not exact match, so if value not found gives position it should be in list
    RETURN search.binary_rank_array(p_target, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'SEARCH.BINARY_RANK', 'S', gc_error);
      RETURN NULL;
  END binary_rank;
  
  FUNCTION binary_search_leftmost_array(
    p_target        IN NUMBER,
    p_array         IN plsql_types.t_number_array,
    p_exact_match   IN BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER
  IS 
    l PLS_INTEGER; -- Left bound of array to search
    r PLS_INTEGER; -- Right bound of array to search
    n PLS_INTEGER; -- For VARRAY count = last element of array
    t NUMBER;      -- Search target value
    m PLS_INTEGER; -- Mid position of range [l,r]
    p PLS_INTEGER; -- Position of target
    v_debug_msg applog.message%TYPE;
    v_debug_module applog.program_name%TYPE := 'SEARCH.BINARY_SEARCH_LEFTMOST_ARRAY';
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    IF NOT util_numeric.is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    
    t := p_target;
    n := p_array.LAST;
    l := 1;
    r := n;
    p := 0;

    -- Find position of target t in array
    WHILE l < r LOOP
      m := l + floor((r -l) / 2);
      IF p_array(m) < t THEN 
        l := m+1;
      ELSE
        r := m;
      END IF;
    END LOOP;
    
    v_debug_msg :=  't=' || to_char(t) ||
                   ' n=' || to_char(n) ||
                   ' l=' || to_char(l) ||
                   ' r=' || to_char(r) ||    
                   ' m=' || to_char(m);   
    util_admin.log_message(v_debug_msg, sqlerrm, v_debug_module, v_debug_mode, gc_info);

    IF p_array(l) = t THEN
      -- Target found at last left boundary searched, so return value will be its position
      p := l;
    ELSIF NOT p_exact_match THEN
      -- Target not found, exact match not required, determine position to insert missing value
      IF t < p_array(r) THEN
        -- Target value smaller than last right value searched so it belongs at that position
        p := r;
      ELSE 
        -- Target value greater than highest value at right bound, so belongs after it
        p := n+1;
      END IF;
    ELSE 
      -- Target not found and exact match required so return 0 (not found)
      p := 0;
    END IF;
    RETURN p;
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END binary_search_leftmost_array;
  
  FUNCTION binary_search_leftmost(
    p_target        IN NUMBER,
    p_list          IN VARCHAR2,
    p_exact_match   IN BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER
  IS
    v_debug_msg applog.message%TYPE;
    v_debug_module applog.program_name%TYPE := 'SEARCH.BINARY_SEARCH_LEFTMOST';
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    RETURN search.binary_search_leftmost_array(p_target, util_numeric.list_to_array(p_list), p_exact_match);
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END binary_search_leftmost;
  
  FUNCTION binary_search_rightmost_array(
    p_target      IN NUMBER,
    p_array       IN plsql_types.t_number_array,
    p_exact_match IN BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER
  IS 
    l PLS_INTEGER; -- Left bound of array to search
    r PLS_INTEGER; -- Right bound of array to search
    n PLS_INTEGER; -- For VARRAY count = last element of array
    t NUMBER;      -- Search target value
    m PLS_INTEGER; -- Mid position of range [l,r]
    p PLS_INTEGER; -- Position of target
    v_debug_module applog.program_name%TYPE := 'SEARCH.BINARY_SEARCH_RIGHTMOST_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    IF NOT util_numeric.is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    
    t := p_target;
    n := p_array.LAST;
    l := 1;
    r := n;
    p := 0;
                            
    -- Find position of target t in array
    WHILE l < r LOOP
      m := l + floor((r -l) / 2);
      v_debug_msg := 'In WHILE loop. m=' || to_char(m) || ' l=' || to_char(l) || ' r=' || to_char(r);
      util_admin.log_message(v_debug_msg, sqlerrm, v_debug_module, v_debug_mode, gc_info);
      IF p_array(m) > t THEN 
        util_admin.log_message('p_array(m) > t THEN r:=m; m=' || to_char(m), sqlerrm, v_debug_module, v_debug_mode, gc_info);
        r := m;
      ELSE
        util_admin.log_message('ELSE l := m+1 =' || to_char(m+1), sqlerrm, v_debug_module, v_debug_mode, gc_info);
        l := m+1;
      END IF;
    END LOOP;

    v_debug_msg := ' EXIT LOOP '        || 
                   ' t=' || to_char(t)  ||
                   ' n=' || to_char(n)  ||
                   ' l=' || to_char(l)  ||
                   ' r=' || to_char(r)  ||    
                   ' m=' || to_char(m);    
    util_admin.log_message(v_debug_msg, sqlerrm, v_debug_module, v_debug_mode, gc_info);
    
    IF n > 0 AND p_array(n) = p_target THEN 
      p := n; -- target found at last position of array
    ELSIF l > 1 AND p_array(l-1) = p_target THEN 
      p := l - 1; --target found at 1 position before last left bound searched is the rightmost target
    ELSE 
      IF p_exact_match THEN 
        p := 0; -- target not found, exact match required
      ELSE 
        p := l; -- insertion point for missing value is at last leftmost bound searched
      END IF;
    END IF;
    RETURN p;
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END binary_search_rightmost_array;
  
  FUNCTION binary_search_rightmost(
    p_target      IN NUMBER,
    p_list        IN VARCHAR2,
    p_exact_match IN BOOLEAN DEFAULT TRUE  
  ) RETURN NUMBER
  IS
    v_debug_module applog.program_name%TYPE := 'SEARCH.BINARY_SEARCH_RIGHTMOST';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    RETURN search.binary_search_rightmost_array(p_target, util_numeric.list_to_array(p_list), p_exact_match);
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END binary_search_rightmost;
 
  FUNCTION binary_search_predecessor_array(
    p_target   IN NUMBER,
    p_array    IN plsql_types.t_number_array
  ) RETURN NUMBER
  IS
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    IF NOT util_numeric.is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    
    RETURN search.binary_rank_array(p_target, p_array);
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'SEARCH.BINARY_SEARCH_PREDECESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, 'SEARCH.BINARY_SEARCH_PREDECESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'SEARCH.BINARY_SEARCH_PREDECESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
  END binary_search_predecessor_array;
  
  FUNCTION binary_search_predecessor(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2
  ) RETURN NUMBER
  IS
  BEGIN
    RETURN search.binary_search_predecessor_array(p_target, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'SEARCH.BINARY_SEARCH_PREDECESSOR', 'S', gc_error);
      RETURN NULL;
  END binary_search_predecessor;

  FUNCTION binary_search_successor_array(
    p_target   IN NUMBER,
    p_array    IN plsql_types.t_number_array
  ) RETURN NUMBER
  IS
    v_position NUMBER;
    v_result NUMBER;
    v_found BOOLEAN := FALSE;
    v_count NUMBER;
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    IF NOT util_numeric.is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    v_count := p_array.COUNT;
    -- Determine if target exists in p_list
    v_position := search.binary_search_rightmost_array(p_target, p_array, TRUE);
    IF v_position > 0 THEN
      v_found := TRUE;
    END IF;
    v_result := search.binary_search_rightmost_array(p_target, p_array, FALSE);
    IF v_result >= 1 AND v_found AND v_result < v_count THEN 
      -- Target found in list, not last value, so successer is next position
      v_result := v_result +1;
    ELSIF (v_result >= v_count AND v_found) THEN 
      -- Target found and is highest value in list so no successor
      v_result := 0;
    ELSIF (NOT v_found AND v_result > v_count) THEN 
      -- Target not found and higher than end value
      v_result := 0;
    END IF;
    RETURN v_result;
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'SEARCH.BINARY_SEARCH_SUCCESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, 'SEARCH.BINARY_SEARCH_SUCCESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'SEARCH.BINARY_SEARCH_SUCCESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
  END binary_search_successor_array;
  
  FUNCTION binary_search_successor(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2
  ) RETURN NUMBER
  IS 
  BEGIN
    RETURN search.binary_search_successor_array(p_target, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'SEARCH.BINARY_SEARCH_SUCCESSOR', 'S', gc_error);
      RETURN NULL;
  END binary_search_successor;
 
  FUNCTION binary_search_nearest_array(
    p_target       IN NUMBER,
    p_array        IN plsql_types.t_number_array
  ) RETURN NUMBER
  IS
    v_predecessor_pos NUMBER;
    v_predecessor_value NUMBER;
    v_predecessor_diff NUMBER;
    v_successor_pos NUMBER;
    v_successor_value NUMBER;
    v_successor_diff NUMBER;
    v_target_pos NUMBER;
    v_count NUMBER;
    v_result NUMBER;
    v_debug_module applog.program_name%TYPE := 'SEARCH.BINARY_SEARCH_NEAREST_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    IF NOT util_numeric.is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    v_count := p_array.COUNT;
    v_target_pos := search.binary_search_rightmost_array(p_target, p_array, TRUE);
    v_predecessor_pos := search.binary_search_predecessor_array(p_target, p_array);
    IF v_predecessor_pos > 0 THEN 
      v_predecessor_value := p_array(v_predecessor_pos);
      v_predecessor_diff := p_target - v_predecessor_value;
    END IF;
    v_successor_pos := search.binary_search_successor_array(p_target, p_array);
    IF v_successor_pos > 0 THEN 
      v_successor_value := p_array(v_successor_pos);
      v_successor_diff := v_successor_value - p_target;
    END IF;
    IF (v_predecessor_pos > 0 AND v_predecessor_diff < v_successor_diff) OR v_target_pos >= v_count THEN 
      v_result := v_predecessor_pos;
    ELSIF v_predecessor_pos < v_count THEN
      v_result := v_successor_pos;
    ELSE 
      v_result := v_predecessor_pos;
    END IF;
    v_debug_msg :='pre pos='    || to_char(v_predecessor_pos)   || 
                  ' pre val='   || to_char(v_predecessor_value) || 
                  ' pre diff='  || to_char(v_predecessor_diff)  ||
                  ' suc pos='   || to_char(v_successor_pos)     || 
                  ' suc val='   || to_char(v_successor_value)   ||
                  ' suc diff='  || to_char(v_successor_diff);
    util_admin.log_message(v_debug_msg, sqlerrm, v_debug_module, v_debug_mode, gc_info);
    RETURN v_result;
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END binary_search_nearest_array;

  FUNCTION binary_search_nearest(
    p_target       IN NUMBER,
    p_list         IN VARCHAR2
  ) RETURN NUMBER
  IS
    v_debug_module applog.program_name%TYPE := 'SEARCH.BINARY_SEARCH_NEAREST';
    v_debug_msg applog.message%type;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    RETURN search.binary_search_nearest_array(p_target, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END binary_search_nearest;

  FUNCTION binary_search_range_array(
    p_range_from   IN NUMBER,
    p_range_to     IN NUMBER,
    p_array        IN plsql_types.t_number_array
  ) RETURN NUMBER
  IS
    v_low_rank NUMBER;
    v_hi_rank NUMBER;
    v_result NUMBER;
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    IF NOT util_numeric.is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    v_low_rank := search.binary_rank_array(p_range_from, p_array);
    v_hi_rank := search.binary_rank_array(p_range_to, p_array);
    v_result := (v_hi_rank - v_low_rank) +1;
    RETURN v_result;
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'SEARCH.BINARY_SEARCH_RANGE_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, 'SEARCH.BINARY_SEARCH_RANGE_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'SEARCH.BINARY_SEARCH_RANGE_ARRAY', 'S', gc_error);
      RETURN NULL;
  END binary_search_range_array;
  
  FUNCTION binary_search_range(
    p_range_from   IN NUMBER,
    p_range_to     IN NUMBER,
    p_list         IN VARCHAR2
  ) RETURN NUMBER
  IS
  BEGIN
    RETURN search.binary_search_range_array(p_range_from, p_range_to, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'SEARCH.BINARY_SEARCH_RANGE', 'S', gc_error);
      RETURN NULL;
  END binary_search_range;

  FUNCTION search_unsorted_array(
    p_target       IN NUMBER,
    p_array        IN plsql_types.t_number_array
  ) RETURN NUMBER
  IS
    v_index INTEGER;
    v_position INTEGER;
    v_searching BOOLEAN;
    v_found BOOLEAN;
    v_debug_module applog.program_name%TYPE := 'SEARCH.SEARCH_UNSORTED_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    v_searching := TRUE;
    v_found := FALSE;
    v_index := 1;
    WHILE v_searching LOOP 
      --util_admin.log_message('v_position='||to_char(v_index), sqlerrm, v_debug_module, v_debug_mode, gc_info);
      IF p_target = p_array(v_index) THEN 
        v_searching := FALSE;
        v_found := TRUE;
      ELSIF v_index = p_array.LAST THEN 
        v_searching := FALSE;
        v_found := FALSE;  
      ELSE
        v_index := v_index +1;
      END IF;
    END LOOP;
    IF v_found THEN 
      v_position := v_index;
    ELSE 
      v_position := 0;
    END IF;
    RETURN v_position;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END search_unsorted_array;
  
  FUNCTION search_unsorted(
    p_target       IN NUMBER,
    p_list         IN VARCHAR2
  ) RETURN NUMBER
  IS
    v_debug_module applog.program_name%TYPE := 'SEARCH.SEARCH_UNSORTED';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    RETURN search_unsorted_array(p_target, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END search_unsorted;
  
END search;
/