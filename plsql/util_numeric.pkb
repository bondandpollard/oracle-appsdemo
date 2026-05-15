CREATE OR REPLACE PACKAGE BODY util_numeric AS

  /*
  ** Private functions and procedures
  */
  
  /*
  ** hex_valid - Check if a string contains a valid hexadecimal value.
  **
  ** IN
  **   p_hex                  - String containing hexadecimal value to be checked.
  ** RETURN
  **   BOOLEAN                - TRUE if valid HEX otherwise FALSE
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION hex_valid (
    p_hex    IN VARCHAR2
    ) RETURN BOOLEAN
  IS
    v_valid BOOLEAN := TRUE;
    v_length INTEGER := 0;
    i INTEGER := 0;
    c_valid_chars CONSTANT VARCHAR2(17) :='-0123456789ABCDEF';
  BEGIN
    v_length := length(p_hex);
    FOR i IN 1 .. v_length LOOP
      IF instr(c_valid_chars,substr(p_hex,i,1)) <= 0 THEN
        v_valid := FALSE;
        EXIT;
      END IF;
    END LOOP;
    RETURN v_valid;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.HEX_VALID', 'S', gc_error);
      RETURN FALSE;
  END hex_valid;
  
  /*
  ** base_string_valid - Check if a string contains a valid base value.
  **
  ** IN
  **   p_num_str              - String containing base value to be checked.
  ** RETURN
  **   BOOLEAN                - TRUE if base string valid otherwise FALSE
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION base_string_valid (
    p_num_str  IN VARCHAR2,
    p_base IN INTEGER
    ) RETURN BOOLEAN
  IS
    v_valid BOOLEAN := TRUE;
    v_match BOOLEAN := FALSE;
    c_valid_chars CONSTANT VARCHAR2(16) :='0123456789ABCDEF';
  BEGIN
    /*
      Parse each char in the input string (base number string) from left to right in turn.
      Check to see if each character is found within the list of valid characters for the 
      specified base range.
      If no match is found for any character in the input string, exit and return false.
    */
    FOR i IN 1 .. length(p_num_str) LOOP
      v_match := FALSE;
      FOR j IN 1 .. p_base LOOP
        IF substr(p_num_str,i,1) = substr(c_valid_chars,j,1) THEN   /* compare each char in base number with each valid char in base range */
          v_match := TRUE;
          EXIT;
        END IF;
      END LOOP;
      IF NOT v_match THEN
        v_valid := FALSE;
        EXIT;
      END IF;
    END LOOP;
    RETURN v_valid;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BASE_STRING_VALID', 'S', gc_error);
      RETURN FALSE;
  END base_string_valid;
  
  /*
  ** alpha_valid - Check if a string contains a valid alphabetic value.
  **
  ** IN
  **   p_hex                    - String containing value to be checked.
  ** RETURN
  **   BOOLEAN                  - TRUE if string contains only characters A to Z (or char at upper end of range) otherwise FALSE
  ** EXCEPTIONS
  **   e_invalid_alpha_range    - Log error if invalid range of alphabetic characters passed, must be 1 to 26.
  */
  FUNCTION alpha_valid (
    p_alpha_str   IN VARCHAR2,
    p_alpha_range  IN INTEGER
    ) RETURN BOOLEAN
  IS
    v_valid BOOLEAN := TRUE;
    v_testchar VARCHAR2(1);
    v_fromchar VARCHAR2(1);
    v_tochar VARCHAR2(1);
    i INTEGER := 0;
  BEGIN
    /* Check that the range of characters specified is between 1 and 26, per the alphabet */
    IF p_alpha_range < 0 OR p_alpha_range > 26 THEN
      RAISE e_invalid_alpha_range;
    END IF;
    
    /* Set the lower and upper characters for the range of letters used in the alphabetic code.
        e.g. where range is 5 only leters A through E may be used.
    */
    v_fromchar := chr(65); /* 'A' */
    v_tochar := chr(65 + p_alpha_range -1); /* e.g. 'E' if alpha contains a range of 5 characters A to E */
    
    FOR i IN 1 .. length(p_alpha_str) LOOP
      v_testchar := substr(p_alpha_str,i,1);
      IF v_testchar < v_fromchar OR v_testchar > v_tochar THEN
        v_valid := FALSE;
        EXIT;
      END IF;
    END LOOP;
    RETURN v_valid;
  EXCEPTION
    WHEN e_invalid_alpha_range THEN
      util_admin.log_message('Invalid range, must be a number between 1 and 26: ' || to_char(p_alpha_range), sqlerrm, 'UTIL_NUMERIC.ALPHA_VALID', 'S', gc_error);
      RETURN FALSE;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.ALPHA_VALID', 'S', gc_error);
      RETURN FALSE;
  END alpha_valid;
  
  
  
  /* 
  ** Public functions and procedures
  */
  
  
  FUNCTION array_contains_null(
    p_array IN plsql_types.t_number_array
  ) RETURN BOOLEAN 
  IS 
    v_result BOOLEAN :=FALSE;
    e_null_array EXCEPTION;
  BEGIN
    IF p_array IS NULL THEN 
      RAISE e_null_array;
    END IF;
    FOR m IN 1 .. p_array.LAST LOOP 
      IF p_array(m) IS NULL THEN 
        v_result := TRUE;
        EXIT;
      END IF;
    END LOOP;
    RETURN v_result;
  EXCEPTION 
    WHEN e_null_array THEN 
      util_admin.log_message('Array must not be null.', sqlerrm, 'UTIL_NUMERIC.ARRAY_CONTAINS_NULL', 'S', gc_error);
      RETURN TRUE;      
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.ARRAY_CONTAINS_NULL', 'S', gc_error);
      RETURN TRUE;
  END array_contains_null;

  FUNCTION is_sorted_array(
    p_array IN plsql_types.t_number_array,
    p_order IN VARCHAR2 DEFAULT 'A'
  ) RETURN BOOLEAN 
  IS 
    v_sorted BOOLEAN := TRUE;
    v_order VARCHAR2(1);
    v_previous_value NUMBER;
    e_null_values EXCEPTION;
  BEGIN
    v_order := NVL(upper(p_order),'A');
    IF util_numeric.array_contains_null(p_array) THEN 
      RAISE e_null_values;
    END IF;
    FOR i in 1 .. p_array.LAST LOOP 
      IF i > 1 THEN 
        IF (v_order = 'A' AND p_array(i) < v_previous_value) OR 
           (v_order <> 'A' AND p_array(i) > v_previous_value) THEN 
           v_sorted := FALSE;
           EXIT;
        END IF;
      END IF;
      v_previous_value := p_array(i);
    END LOOP;
    RETURN v_sorted;
  EXCEPTION  
    WHEN e_null_values THEN
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'UTIL_NUMERIC.IS_SORTED_ARRAY', 'S', gc_error);
      RETURN FALSE;  
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.IS_SORTED_ARRAY', 'S', gc_error);
      RETURN FALSE;
  END is_sorted_array;
  
  FUNCTION is_sorted_list (
    p_list  IN VARCHAR2,
    p_order IN VARCHAR2
  ) RETURN BOOLEAN
  IS 
  BEGIN
    RETURN util_numeric.is_sorted_array(util_numeric.list_to_array(p_list), p_order);
  END is_sorted_list;
  
  FUNCTION list_to_array (
    p_list IN VARCHAR2
  ) RETURN plsql_types.t_number_array
  IS 
    v_array plsql_types.t_number_array;
    v_field_count NUMBER :=0;
    e_null_list EXCEPTION;
    e_list_size EXCEPTION;
  BEGIN
    IF p_list IS NULL THEN 
      RAISE e_null_list;
    END IF;
    v_array := plsql_types.t_number_array();
    v_field_count := util_string.count_fields(p_list);
    IF v_field_count > gc_max_array_size then
      RAISE e_list_size;
    END IF;
    FOR m IN 1 .. v_field_count LOOP
      v_array.EXTEND;
      v_array(m) := to_number(util_string.get_field(p_list,m,','));
    END LOOP;
    RETURN v_array;
  EXCEPTION
    WHEN e_list_size THEN
      util_admin.log_message('Error: List size exceeds array capacity, maximum ' || to_char(gc_max_array_size) || ' entries.', sqlerrm, 'UTIL_NUMERIC.LIST_TO_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_null_list THEN
      util_admin.log_message('Error: List is NULL.', sqlerrm, 'UTIL_NUMERIC.LIST_TO_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.LIST_TO_ARRAY', 'S', gc_error);
      RETURN NULL;
  END list_to_array;
  
  FUNCTION array_to_list (
    p_array IN plsql_types.t_number_array
  ) RETURN VARCHAR2
  IS 
    v_result plsql_constants.maxvarchar2_t;
    v_debug_msg applog.message%TYPE;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.ARRAY_TO_LIST';
    v_debug_mode VARCHAR2(1) := 'S';
    e_array_null EXCEPTION;
  BEGIN
    IF p_array IS NULL OR p_array.COUNT = 0 THEN 
      RAISE e_array_null;
    END IF;
    FOR m IN 1 .. p_array.LAST LOOP
      IF m = 1 THEN
        v_result := to_char(p_array(m));
      ELSE
        v_result := v_result || ',' || to_char(p_array(m));
      END IF;
    END LOOP;
    RETURN v_result;
  EXCEPTION
    WHEN e_array_null THEN 
      util_admin.log_message('Array is null.', sqlerrm, 'UTIL_NUMERIC.ARRAY_TO_LIST', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.ARRAY_TO_LIST', 'S', gc_error);
      RETURN NULL;
  END array_to_list;
 
  FUNCTION dectobase(
    p_number IN INTEGER, 
    p_base   IN INTEGER
  ) 
  RETURN VARCHAR2
  IS
    v_result plsql_constants.maxvarchar2_t;
    v_quotient INTEGER;
    v_remainder INTEGER;
    c_digits CONSTANT VARCHAR2(16) :='0123456789ABCDEF';
    v_negative BOOLEAN := FALSE;
    v_sign NUMBER :=1;
    e_zero_value EXCEPTION;
    e_null_value EXCEPTION;
  BEGIN
  
    IF NVL(p_base,0) < 2 OR NVL(p_base,0) > 16 THEN
      RAISE e_invalid_data;
    END IF;
    
    IF p_number IS NULL THEN
      RAISE e_null_value;
    END IF;
    
    IF p_number = 0 THEN
      RAISE e_zero_value;
    END IF;
    
    /* Handle -ve numbers */
    IF nvl(p_number,0) < 0 THEN
      v_sign := -1;
      v_negative := true;
    END IF;
    
    v_quotient := p_number * v_sign; /* strip sign from -ve numbers */
   
    WHILE v_quotient > 0 LOOP
      v_remainder := mod(v_quotient,p_base);
      v_quotient := trunc(v_quotient / p_base);
      v_result := substr(c_digits, v_remainder +1, 1) || v_result;
    END LOOP;
    
    IF v_negative THEN
      v_result := concat('-',v_result); /* Reinstate sign to -ve numbers */
    END IF;
    
    RETURN nvl(v_result,'0');
  EXCEPTION
    WHEN e_null_value THEN
      RETURN NULL;
    WHEN e_zero_value THEN
      RETURN '0';
    WHEN e_invalid_data THEN
      util_admin.log_message('Invalid base number: ' || to_char(p_base) || '. Base must be between 2 and 16.', sqlerrm, 'UTIL_NUMERIC.DECTOBASE', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.DECTOBASE', 'S', gc_error);
      RETURN NULL;
  END dectobase;

  FUNCTION basetodec(
    p_number IN VARCHAR2, 
    p_base   IN INTEGER
  ) 
  RETURN NUMBER 
  IS
    c_digits CONSTANT VARCHAR2(16) := '0123456789ABCDEF';
    v_power INTEGER;
    v_result INTEGER :=0;
    v_decimal INTEGER;
    v_value_in plsql_constants.maxvarchar2_t;
    v_negative BOOLEAN := FALSE;
    e_null_value EXCEPTION;
  BEGIN
  
    IF p_number IS NULL THEN
      RAISE e_null_value;
    END IF;
    
    /* Handle negative numbers */
    IF substr(p_number,1,1) = '-' THEN
      v_negative := TRUE;
      v_value_in := upper(substr(p_number,2)); /* remove leading sign */
    ELSE
      v_value_in := upper(p_number);
    END IF;
    
    /* Check base specified is in correct range 1 to 16 */
    IF NVL(p_base,0) < 1 OR NVL(p_base,0) > 16 THEN
      RAISE e_invalid_base;
    END IF;
    
    /* Check input string contains a valid base number */
    IF NOT base_string_valid(v_value_in, p_base) THEN
      RAISE e_invalid_data;
    END IF;
    
    FOR i IN REVERSE 1 .. length(v_value_in) LOOP
      v_power := p_base**(length(v_value_in)-i);
      v_decimal := instr(c_digits,substr(v_value_in,i,1))-1;
      v_result := v_result + (v_decimal * v_power);
    END LOOP;
    IF v_negative THEN
      v_result := v_result * -1;  /* Add sign to negative numbers */
    END IF;
    RETURN v_result;
  EXCEPTION
    WHEN e_null_value THEN
      RETURN NULL;
    WHEN e_invalid_data THEN
      util_admin.log_message('Invalid number: ' || p_number || ' is not a base ' || to_char(p_base) || ' number.', sqlerrm, 'UTIL_NUMERIC.BASETODEC', 'S', gc_error);
      RETURN NULL;
    WHEN e_invalid_base THEN
      util_admin.log_message('Invalid base, must be a number between 1 and 16: ' || to_char(p_base), sqlerrm, 'UTIL_NUMERIC.BASETODEC', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error:', sqlerrm, 'UTIL_NUMERIC.BASETODEC', 'S', gc_error);
      RETURN NULL;
  END basetodec;

  FUNCTION dectohex(
    p_number IN INTEGER
  ) 
  RETURN VARCHAR2 
  IS
    v_result plsql_constants.maxvarchar2_t;
    v_quotient INTEGER;
    v_remainder INTEGER;
    c_base CONSTANT INTEGER :=16;
    c_digits CONSTANT VARCHAR2(c_base) :='0123456789ABCDEF';
    v_negative BOOLEAN := FALSE;
    v_sign NUMBER :=1;
    e_null_value EXCEPTION;
  BEGIN
    IF p_number IS NULL THEN
      RAISE e_null_value;
    END IF;
    
    IF p_number < 0 THEN
      v_negative := TRUE;
      v_sign := -1;
    END IF;
    v_quotient := p_number * v_sign; /* strip sign from -ve numbers */
    WHILE v_quotient > 0 LOOP
      v_remainder := mod(v_quotient,c_base);
      v_quotient := trunc(v_quotient / c_base);
      v_result := substr(c_digits, v_remainder +1, 1) || v_result;
    END LOOP;
    IF v_negative THEN
      v_result := concat('-',v_result); /* Reinstate sign to -ve numbers */
    END IF;
    RETURN nvl(v_result,'0');
  EXCEPTION
    WHEN e_null_value THEN
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error:', sqlerrm, 'UTIL_NUMERIC.DECTOHEX', 'S', gc_error);
      RETURN NULL;
  END dectohex;

  FUNCTION hextodec(
    p_number IN VARCHAR2
  ) 
  RETURN NUMBER 
  IS
    v_value_in plsql_constants.maxvarchar2_t;
    c_digits CONSTANT VARCHAR2(16) := '0123456789ABCDEF';
    c_base CONSTANT INTEGER := 16;
    v_power INTEGER;
    v_result INTEGER :=0;
    v_decimal INTEGER;
    v_negative BOOLEAN := FALSE;
    e_null_value EXCEPTION;
  BEGIN
    IF p_number IS NULL THEN
      RAISE e_null_value;
    END IF;
     /* Handle negative numbers */
    IF substr(p_number,1,1) = '-' THEN
      v_negative := TRUE;
      v_value_in := upper(substr(p_number,2)); /* remove leading sign */
    ELSE
      v_value_in := upper(p_number);
    END IF;
       
    IF NOT hex_valid(v_value_in) THEN
      RAISE e_invalid_data;
    END IF;
    
    FOR i IN REVERSE 1 .. length(v_value_in) LOOP
      v_power := c_base**(length(v_value_in)-i);
      v_decimal := instr(c_digits,substr(v_value_in,i,1))-1;
      v_result := v_result + (v_decimal * v_power);
    END LOOP;
    
    IF v_negative THEN
      v_result := v_result * -1;  /* Add sign to negative numbers */
    END IF;
    RETURN v_result;
    
  EXCEPTION
    WHEN e_null_value THEN
      RETURN NULL;
    WHEN e_invalid_data THEN
      util_admin.log_message('Invalid hexadecimal number: ' || p_number, sqlerrm, 'UTIL_NUMERIC.HEXTODEC', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.HEXTODEC', 'S', gc_error);
      RETURN NULL;
  END hextodec;

  FUNCTION factorial(
    p_number IN INTEGER
  ) 
  RETURN NUMBER 
  IS
    v_fact NUMBER := 1;
    i NUMBER;
  BEGIN
    i := p_number;
    WHILE i > 1 LOOP
      v_fact := v_fact * i;
      i := i-1;
    END LOOP;
    RETURN (v_fact);
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.FACTORIAL', 'S', gc_error);
      RETURN NULL; 
  END factorial;

  -- Factorial using recursion
  FUNCTION factorialr(
    p_number IN INTEGER
  ) 
  RETURN NUMBER 
  IS
  BEGIN
    IF p_number <=1 THEN
      RETURN p_number;
    ELSE 
      RETURN p_number * factorialr(p_number -1);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.FACTORIALR', 'S', gc_error);
    RETURN NULL;
  END factorialr;

  FUNCTION sort_array (
    p_array  IN plsql_types.t_number_array,
    p_order  IN VARCHAR2 DEFAULT 'A'
  )
  RETURN plsql_types.t_number_array 
  IS
    v_sorted_array plsql_types.t_number_array;
    v_temp NUMBER;
    v_order VARCHAR2(1);
  BEGIN
    v_sorted_array := p_array;
    v_order := NVL(UPPER(p_order),'A');
    FOR p1 IN 1 .. v_sorted_array.LAST -1 LOOP
      FOR p2 IN p1+1 .. v_sorted_array.LAST LOOP
        IF (v_order = 'A' AND v_sorted_array(p2) < v_sorted_array(p1)) OR (v_order <> 'A' AND v_sorted_array(p2) > v_sorted_array(p1)) THEN
          v_temp := v_sorted_array(p1);
          v_sorted_array(p1) := v_sorted_array(p2);
          v_sorted_array(p2) := v_temp;
        END IF;
      END LOOP;
    END LOOP;
    RETURN v_sorted_array;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.SORT_ARRAY', 'S', gc_error);
      RETURN NULL;
  END sort_array;

  -- Sort a list of comma separated numbers into ascending or descending order
  FUNCTION sort_numbers (
    p_list  IN VARCHAR2, 
    p_order IN VARCHAR2 DEFAULT 'A'
  ) 
  RETURN VARCHAR2 
  IS
    v_result plsql_constants.maxvarchar2_t;
    v_sorted_array plsql_types.t_number_array;
    v_temp NUMBER;
    e_list_null exception;
  BEGIN
    IF p_list IS NULL THEN 
      RAISE e_list_null;
    END IF;
    v_sorted_array := sort_array(list_to_array(p_list), p_order);
    v_result := array_to_list(v_sorted_array);
    RETURN v_result;
  EXCEPTION
    WHEN e_list_null THEN 
      util_admin.log_message('List must not be null (empty).', sqlerrm, 'UTIL_NUMERIC.SORT_NUMBERS', 'S', gc_error);
      RETURN NULL;    
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.SORT_NUMBERS', 'S', gc_error);
      RETURN NULL;
  END sort_numbers;

  FUNCTION num_to_alphanumeric(
    p_number IN NUMBER
  ) 
  RETURN VARCHAR2
  IS
    v_result VARCHAR2(100);
    v_base NUMBER := 26; -- Number of letters in the alphabet
    v_calc NUMBER;
    v_remainder NUMBER;
  BEGIN
    IF p_number <= 0 THEN
        RAISE e_invalid_data;
    END IF;
    v_calc := p_number;
    WHILE v_calc > 0 LOOP
      v_remainder := MOD(v_calc  - 1, v_base) + 1; -- Adjust for 1-based indexing
      v_result := CHR(ASCII('A') + v_remainder - 1) || v_result;
      v_calc  := (v_calc - v_remainder) / v_base;
    END LOOP;
    RETURN v_result;
  EXCEPTION
    WHEN e_invalid_data THEN
      util_admin.log_message('You must enter a positive whole number. Invalid value: ' || to_char(p_number), sqlerrm, 'UTIL_NUMERIC.NUM_TO_ALPHANUMERIC', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.NUM_TO_ALPHANUMERIC', 'S', gc_error);  
      RETURN NULL;
  END num_to_alphanumeric;

  FUNCTION dectoalpha (
    p_number IN INTEGER, 
    p_range  IN INTEGER
  ) 
  RETURN VARCHAR2 
  IS
    c_max CONSTANT INTEGER := 30;
    c_alpha_max CONSTANT INTEGER := 26;
    v_alpha_range INTEGER;
    v_result VARCHAR2(c_max);
    v_power INTEGER;
    v_total INTEGER;
    v_n1 INTEGER;
  BEGIN
    /* Check p_number is a positive integer */
    IF p_number < 1 THEN
      RAISE e_invalid_data;
    END IF;
    
    /* Check range is within bounds of alphabet, between 1 and 26
        and reset values to within correct range if exceeded.
    */
    IF p_range < 1 THEN
      v_alpha_range :=1;
    ELSIF p_range > c_alpha_max THEN
      v_alpha_range := c_alpha_max;
    ELSE
      v_alpha_range := p_range;
    END IF;
    
    v_total := p_number;
    
    FOR n IN 1 .. c_max LOOP
      IF v_total <= 0 THEN
        EXIT;
      END IF;
      v_power := power(v_alpha_range,n-1);
      IF n = 1 THEN
        v_n1 := mod(v_total, v_alpha_range);
      ELSE
        v_n1 := floor(v_total / v_power);
      END IF;
      IF v_n1 < 1 THEN
        v_n1 := v_alpha_range;
      ELSIF v_n1 > v_alpha_range THEN
        v_n1 := mod(v_n1,v_alpha_range); 
        IF v_n1 < 1 THEN
          v_n1 := v_alpha_range;
        END IF;
      END IF;
      v_result := chr(v_n1+64) || v_result;
      v_total := v_total - (v_n1 * v_power);
    END LOOP;
    RETURN ltrim(v_result);
  EXCEPTION
    WHEN e_invalid_data THEN
      util_admin.log_message('You must enter a positive whole number. Invalid value: ' || to_char(p_number), sqlerrm, 'UTIL_NUMERIC.DECTOALPHA', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.DECTOALPHA', 'S', gc_error);
      RETURN NULL;
  END dectoalpha;

  FUNCTION alphatodec(
    p_code  IN VARCHAR2, 
    p_range IN INTEGER
  ) 
  RETURN NUMBER 
  IS
    c_max CONSTANT INTEGER := 26;
    v_range INTEGER;
    v_power INTEGER;
    p_total INTEGER :=0;
    v_upper_char VARCHAR2(1);
  BEGIN  

    /* Alphabetic code range must be between 1 and 26, reset out of range values */
    IF p_range < 1 THEN
      v_range := 1;
    ELSIF p_range > c_max THEN
      v_range := c_max;
    ELSE
      v_range := p_range;
    END IF;
    
    /* Check alphabetic code contains only letters within specified range, 
        e.g. if range is 5 letters expected are A to E.
    */
    v_upper_char := chr(65 + p_range -1);
    IF NOT alpha_valid(p_code,v_range) THEN
      RAISE e_invalid_data;
    END IF;
    
    FOR i IN REVERSE 1 .. length(p_code) LOOP
      IF i = 1 THEN
        v_power := 1;
      ELSE
        v_power := power(v_range,i-1);
      END IF;
      p_total := p_total + ((ascii(substr(p_code,length(p_code)+1-i,1))-64)*v_power);   
    END LOOP;
    RETURN p_total;
  EXCEPTION
    WHEN e_invalid_data THEN
      util_admin.log_message('Invalid alphabetic string ' || p_code || '. You may use letters A to ' || v_upper_char || ' only. Range specified: ' || to_char(p_range), sqlerrm, 'UTIL_NUMERIC.ALPHATODEC', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error for alphabetic code:' || p_code || ' range:' || to_char(p_range), sqlerrm, 'UTIL_NUMERIC.ALPHATODEC', 'S', gc_error);
      RETURN NULL;
  END alphatodec;
  
  FUNCTION pi 
  RETURN NUMBER 
  IS
    last_pi NUMBER := 0;
    delta   NUMBER := 0.000001;
    pi      NUMBER := 1;
    denom   NUMBER := 3;
    oper    NUMBER := -1;
    negone  NUMBER := -1;
    two     NUMBER := 2;
  BEGIN
    LOOP
      last_pi := pi;
      pi := pi + oper * 1/denom;
      EXIT WHEN (abs(last_pi-pi) <= delta );
      denom := denom + two;
      oper := oper * negone;
    END LOOP;
    RETURN pi*4;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.PI', 'S', gc_error);
      RETURN NULL;
  END pi;
  
  FUNCTION is_odd(
    p_number      IN NUMBER 
  ) RETURN BOOLEAN 
  IS 
  BEGIN
    RETURN mod(p_number,2) != 0;
  END is_odd;
  
  FUNCTION is_even(
    p_number      IN NUMBER 
  ) RETURN BOOLEAN 
  IS 
  BEGIN
    RETURN mod(p_number,2) = 0;
  END is_even;
  
  FUNCTION remove_duplicates_nosort_array(
    p_array       IN plsql_types.t_number_array
  ) RETURN plsql_types.t_number_array
  IS 
    v_current_value NUMBER;
    v_index PLS_INTEGER;
    v_noduplicates_array plsql_types.t_number_array := plsql_types.t_number_array();
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.REMOVE_DUPLICATES_NOSORT_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN 
    -- Check each value in the array
    v_index :=1;
    FOR p IN 1 .. p_array.COUNT LOOP 
      v_current_value := p_array(p);
      IF NOT v_current_value IS NULL THEN
        util_admin.log_message('p_array('||to_char(p)||')='||to_char(v_current_value),sqlerrm, v_debug_module, v_debug_mode, gc_info);
        IF v_index = 1 OR search.search_unsorted_array(v_current_value, v_noduplicates_array) = 0 THEN 
          -- Put first value into v_noduplicates_array, or current value checked not found in v_noduplicates_array so add it.
          util_admin.log_message('Adding value to v_noduplicates_array('||to_char(v_index)||')='||to_char(v_current_value),sqlerrm, v_debug_module, v_debug_mode, gc_info);
          v_noduplicates_array.EXTEND;
          v_noduplicates_array(v_index) := v_current_value;
          v_index := v_index +1;
        END IF;
      END IF;
    END LOOP;
    RETURN v_noduplicates_array;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END remove_duplicates_nosort_array;

  FUNCTION remove_duplicates_nosort_list(
    p_list       IN VARCHAR2
  ) RETURN VARCHAR2
  IS 
    v_noduplicates_nosort_list plsql_constants.maxvarchar2_t;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.REMOVE_DUPLICATES_NOSORT_LIST';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_list EXCEPTION;
  BEGIN 
    IF p_list IS NULL THEN 
      RAISE e_null_list;
    END IF;
    v_noduplicates_nosort_list := array_to_list(remove_duplicates_nosort_array(list_to_array(p_list)));
    RETURN v_noduplicates_nosort_list;
  EXCEPTION
    WHEN e_null_list THEN 
      util_admin.log_message('List is empty.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;      
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END remove_duplicates_nosort_list;
  
  FUNCTION remove_duplicates_array(
    p_array       IN plsql_types.t_number_array
  ) RETURN plsql_types.t_number_array
  IS 
    v_current_value NUMBER;
    v_index PLS_INTEGER;
    v_sorted_array plsql_types.t_number_array;
    v_noduplicates_array plsql_types.t_number_array := plsql_types.t_number_array();
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.REMOVE_DUPLICATES_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_array EXCEPTION;
  BEGIN 
    IF p_array IS NULL THEN 
      RAISE e_null_array;
    END IF;
    -- Sort array ascending
    v_sorted_array := sort_array(p_array); 
    v_index :=1;
    -- Check each value in the sorted array
    FOR p IN 1 .. v_sorted_array.COUNT LOOP 
      v_current_value := v_sorted_array(p);
      IF NOT v_current_value IS NULL THEN
        IF v_index = 1 OR v_noduplicates_array(v_noduplicates_array.LAST) != v_current_value THEN 
          -- First value, or value checked does not exist in v_noduplicates_array, so add it.
          util_admin.log_message('Adding value to v_noduplicates_array('||to_char(v_index)||')='||to_char(v_current_value),sqlerrm, v_debug_module, v_debug_mode, gc_info);
          v_noduplicates_array.EXTEND;
          v_noduplicates_array(v_index) := v_current_value;
          v_index := v_index +1;
        END IF;
      END IF;
    END LOOP;
    RETURN v_noduplicates_array;
  EXCEPTION
    WHEN e_null_array THEN 
      util_admin.log_message('The array must not be empty.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END remove_duplicates_array;
  
  FUNCTION remove_duplicates_list(
    p_list       IN VARCHAR2
  ) RETURN VARCHAR2
  IS 
    v_noduplicates_list plsql_constants.maxvarchar2_t;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.REMOVE_DUPLICATES_LIST';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_list EXCEPTION;
  BEGIN 
    IF p_list IS NULL THEN 
      RAISE e_null_list;
    END IF;
    v_noduplicates_list := array_to_list(remove_duplicates_array(list_to_array(p_list)));
    RETURN v_noduplicates_list;
  EXCEPTION
    WHEN e_null_list THEN 
      util_admin.log_message('List is empty.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;    
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END remove_duplicates_list;

  FUNCTION reverse_array(
    p_array       IN plsql_types.t_number_array
  ) RETURN plsql_types.t_number_array
  IS 
    v_temp_value NUMBER;
    v_reverse_array plsql_types.t_number_array := plsql_types.t_number_array();
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.REVERSE_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_array EXCEPTION;
  BEGIN 
    IF p_array IS NULL THEN 
      RAISE e_null_array;
    END IF;
     
    -- Populate array to be reverse with array passed to function
    v_reverse_array := p_array;
    
    -- Iterate from start of array to middle, incrementing position by 1
    -- at each pass. Swap the number from the first half of the table with 
    -- the number in the corresponding position in the second half, reversing 
    -- the sequence.
    FOR p IN 1 .. v_reverse_array.COUNT/2 LOOP 
      v_temp_value := v_reverse_array(p);
      v_reverse_array(p):= v_reverse_array(v_reverse_array.COUNT - p + 1);
      v_reverse_array(v_reverse_array.COUNT - p + 1) := v_temp_value;
    END LOOP;
    RETURN v_reverse_array;
  EXCEPTION
    WHEN e_null_array THEN 
      util_admin.log_message('The array must not be empty.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END reverse_array;
  
  FUNCTION reverse_list(
    p_list       IN VARCHAR2
  ) RETURN VARCHAR2
  IS 
    v_reverse_list plsql_constants.maxvarchar2_t;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.REVERSE_LIST';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_list EXCEPTION;
  BEGIN 
    IF p_list IS NULL THEN 
      RAISE e_null_list;
    END IF;
    v_reverse_list := array_to_list(reverse_array(list_to_array(p_list)));
    RETURN v_reverse_list;
  EXCEPTION
    WHEN e_null_list THEN 
      util_admin.log_message('List is empty.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;    
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END reverse_list;

END util_numeric;
/