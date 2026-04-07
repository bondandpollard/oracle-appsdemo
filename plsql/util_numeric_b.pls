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
    p_array IN t_number_array
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
    p_array IN t_number_array,
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
  ) RETURN t_number_array
  IS 
    v_array t_number_array;
    v_field_count NUMBER :=0;
    e_null_list EXCEPTION;
    e_list_size EXCEPTION;
  BEGIN
    IF p_list IS NULL THEN 
      RAISE e_null_list;
    END IF;
    v_array := t_number_array();
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
    p_array IN t_number_array
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
    p_array  IN t_number_array,
    p_order  IN VARCHAR2 DEFAULT 'A'
  )
  RETURN t_number_array 
  IS
    v_sorted_array t_number_array;
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
    v_sorted_array t_number_array;
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
  
  FUNCTION binary_chop_search(
    p_key   IN NUMBER,
    p_list  IN VARCHAR2
  ) RETURN NUMBER
  IS
    v_list_array t_number_array;
    v_lower_bound INTEGER;
    v_upper_bound INTEGER;
    v_interval INTEGER;
    v_half INTEGER;
    v_position INTEGER :=1;
    found BOOLEAN := FALSE;
    v_insert_position INTEGER :=1;
    v_debug_msg applog.message%TYPE;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.BINARY_CHOP_SEARCH';
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
    v_list_array := list_to_array(p_list);
    
    -- Check there are no null values
    IF array_contains_null(v_list_array) THEN 
      RAISE e_null_value;
    END IF;
    
    -- Sort the array ascending, as binary chop only works with sorted array.
    v_list_array := sort_array(v_list_array);
    
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
    p_array    IN t_number_array
  ) RETURN NUMBER
  IS 
    l PLS_INTEGER; -- Left bound of array to search
    r PLS_INTEGER; -- Right bound of array to search
    n PLS_INTEGER; -- For VARRAY count = last element of array
    t PLS_INTEGER; -- Search target value
    m PLS_INTEGER; -- Mid position of range [l,r]
    p PLS_INTEGER; -- Position of target
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
  
    IF array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    IF NOT is_sorted_array(p_array) THEN 
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
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_ARRAY', 'S', gc_error);
      RETURN NULL;
  END binary_search_array;
  
  
  FUNCTION binary_search(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2
  ) RETURN NUMBER
  IS
  BEGIN
    RETURN binary_search_array(p_target,list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH', 'S', gc_error);
      RETURN NULL;
  END binary_search;
 
  FUNCTION binary_rank_array(
    p_target   IN NUMBER,
    p_array    IN t_number_array
  ) RETURN NUMBER
  IS 
    p NUMBER :=0;
    r NUMBER :=0;
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    IF NOT is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    
    -- Position of target value in array (not exact match, so if value not found gives position it should be in list
    p := util_numeric.binary_search_leftmost_array(p_target, p_array, FALSE);
    -- Rank is number of elements in array less than target value.
    IF p > 0 THEN
      r := p-1; --Rank is target found in array (otherwise it is 0)
    END IF;
    RETURN r;  
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'UTIL_NUMERIC.BINARY_RANK_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, 'UTIL_NUMERIC.BINARY_RANK_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BINARY_RANK_ARRAY', 'S', gc_error);
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
    RETURN util_numeric.binary_rank_array(p_target, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BINARY_RANK', 'S', gc_error);
      RETURN NULL;
  END binary_rank;
  
  FUNCTION binary_search_leftmost_array(
    p_target        IN NUMBER,
    p_array         IN t_number_array,
    p_exact_match   IN BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER
  IS 
    l PLS_INTEGER; -- Left bound of array to search
    r PLS_INTEGER; -- Right bound of array to search
    n PLS_INTEGER; -- For VARRAY count = last element of array
    t PLS_INTEGER; -- Search target value
    m PLS_INTEGER; -- Mid position of range [l,r]
    p PLS_INTEGER; -- Position of target
    v_debug_msg applog.message%TYPE;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.BINARY_SEARCH_LEFTMOST_ARRAY';
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    IF NOT is_sorted_array(p_array) THEN 
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
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.BINARY_SEARCH_LEFTMOST';
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    RETURN util_numeric.binary_search_leftmost_array(p_target, util_numeric.list_to_array(p_list), p_exact_match);
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END binary_search_leftmost;
  
  FUNCTION binary_search_rightmost_array(
    p_target      IN NUMBER,
    p_array       IN t_number_array,
    p_exact_match IN BOOLEAN DEFAULT TRUE
  ) RETURN NUMBER
  IS 
    l PLS_INTEGER; -- Left bound of array to search
    r PLS_INTEGER; -- Right bound of array to search
    n PLS_INTEGER; -- For VARRAY count = last element of array
    t PLS_INTEGER; -- Search target value
    m PLS_INTEGER; -- Mid position of range [l,r]
    p PLS_INTEGER; -- Position of target
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.BINARY_SEARCH_RIGHTMOST_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    IF NOT is_sorted_array(p_array) THEN 
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
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.BINARY_SEARCH_RIGHTMOST';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    RETURN util_numeric.binary_search_rightmost_array(p_target, util_numeric.list_to_array(p_list), p_exact_match);
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END binary_search_rightmost;
 
  FUNCTION binary_search_predecessor_array(
    p_target   IN NUMBER,
    p_array    IN t_number_array
  ) RETURN NUMBER
  IS
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    IF NOT is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    
    RETURN util_numeric.binary_rank_array(p_target, p_array);
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_PREDECESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_PREDECESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_PREDECESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
  END binary_search_predecessor_array;
  
  FUNCTION binary_search_predecessor(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2
  ) RETURN NUMBER
  IS
  BEGIN
    RETURN util_numeric.binary_search_predecessor_array(p_target, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_PREDECESSOR', 'S', gc_error);
      RETURN NULL;
  END binary_search_predecessor;

  FUNCTION binary_search_successor_array(
    p_target   IN NUMBER,
    p_array    IN t_number_array
  ) RETURN NUMBER
  IS
    v_position NUMBER;
    v_result NUMBER;
    v_found BOOLEAN := FALSE;
    v_count NUMBER;
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    IF NOT is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    v_count := p_array.COUNT;
    -- Determine if target exists in p_list
    v_position := util_numeric.binary_search_rightmost_array(p_target, p_array, TRUE);
    IF v_position > 0 THEN
      v_found := TRUE;
    END IF;
    v_result := util_numeric.binary_search_rightmost_array(p_target, p_array, FALSE);
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
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_SUCCESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_SUCCESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_SUCCESSOR_ARRAY', 'S', gc_error);
      RETURN NULL;
  END binary_search_successor_array;
  
  FUNCTION binary_search_successor(
    p_target   IN NUMBER,
    p_list     IN VARCHAR2
  ) RETURN NUMBER
  IS 
  BEGIN
    RETURN util_numeric.binary_search_successor_array(p_target, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_SUCCESSOR', 'S', gc_error);
      RETURN NULL;
  END binary_search_successor;
 
  FUNCTION binary_search_nearest_array(
    p_target       IN NUMBER,
    p_array        IN t_number_array
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
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.BINARY_SEARCH_NEAREST_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    IF NOT is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    v_count := p_array.COUNT;
    v_target_pos := util_numeric.binary_search_rightmost_array(p_target, p_array, TRUE);
    v_predecessor_pos := util_numeric.binary_search_predecessor_array(p_target, p_array);
    IF v_predecessor_pos > 0 THEN 
      v_predecessor_value := p_array(v_predecessor_pos);
      v_predecessor_diff := p_target - v_predecessor_value;
    END IF;
    v_successor_pos := util_numeric.binary_search_successor_array(p_target, p_array);
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
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.BINARY_SEARCH_NEAREST';
    v_debug_msg applog.message%type;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    RETURN util_numeric.binary_search_nearest_array(p_target, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END binary_search_nearest;

  FUNCTION binary_search_range_array(
    p_range_from   IN NUMBER,
    p_range_to     IN NUMBER,
    p_array        IN t_number_array
  ) RETURN NUMBER
  IS
    v_low_rank NUMBER;
    v_hi_rank NUMBER;
    v_result NUMBER;
    e_null_value EXCEPTION;
    e_unsorted_array EXCEPTION;
  BEGIN
    IF array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    IF NOT is_sorted_array(p_array) THEN 
      RAISE e_unsorted_array;
    END IF;
    v_low_rank := util_numeric.binary_rank_array(p_range_from, p_array);
    v_hi_rank := util_numeric.binary_rank_array(p_range_to, p_array);
    v_result := (v_hi_rank - v_low_rank) +1;
    RETURN v_result;
  EXCEPTION
    WHEN e_null_value THEN 
      util_admin.log_message('Array must not contain null values.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_RANGE_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN e_unsorted_array THEN 
      util_admin.log_message('Array must be pre-sorted into ascending sequence.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_RANGE_ARRAY', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_RANGE_ARRAY', 'S', gc_error);
      RETURN NULL;
  END binary_search_range_array;
  
  FUNCTION binary_search_range(
    p_range_from   IN NUMBER,
    p_range_to     IN NUMBER,
    p_list         IN VARCHAR2
  ) RETURN NUMBER
  IS
  BEGIN
    RETURN util_numeric.binary_search_range_array(p_range_from, p_range_to, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, 'UTIL_NUMERIC.BINARY_SEARCH_RANGE', 'S', gc_error);
      RETURN NULL;
  END binary_search_range;

  FUNCTION search_unsorted_array(
    p_target       IN NUMBER,
    p_array        IN t_number_array
  ) RETURN NUMBER
  IS
    v_index INTEGER;
    v_position INTEGER;
    v_searching BOOLEAN;
    v_found BOOLEAN;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.SEARCH_UNSORTED_ARRAY';
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
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.SEARCH_UNSORTED';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    RETURN util_numeric.search_unsorted_array(p_target, util_numeric.list_to_array(p_list));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END search_unsorted;
  
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
  
  FUNCTION median_array(
    p_array       IN t_number_array
  ) RETURN NUMBER
  IS
    v_median NUMBER;
    v_count NUMBER;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.MEDIAN_ARRAY';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    v_count := p_array.COUNT;
    -- IF odd number of elements in array, median is mid value
    IF is_odd(v_count) THEN 
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
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.MEDIAN';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    -- Convert list to array, sort ascending, and calculate median value.
    RETURN util_numeric.median_array(util_numeric.sort_array(util_numeric.list_to_array(p_list)));
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END median;
  
  FUNCTION remove_duplicates_nosort_array(
    p_array       IN t_number_array
  ) RETURN t_number_array
  IS 
    v_current_value NUMBER;
    v_index NUMBER;
    v_noduplicates_array t_number_array := t_number_array();
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
        IF v_index = 1 OR search_unsorted_array(v_current_value, v_noduplicates_array) = 0 THEN 
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
    p_array       IN t_number_array
  ) RETURN t_number_array
  IS 
    v_current_value NUMBER;
    v_index NUMBER;
    v_sorted_array t_number_array;
    v_noduplicates_array t_number_array := t_number_array();
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

  FUNCTION populate_frequency_table (
    p_array IN t_number_array
  ) RETURN t_frequency_table
  IS 
    v_frequency_table t_frequency_table := t_frequency_table();
    v_sorted_array t_number_array;
    v_array_size PLS_INTEGER;
    v_index PLS_INTEGER;
    v_current_key PLS_INTEGER;
    v_current_count PLS_INTEGER;
    v_error_value VARCHAR2(20);
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.POPULATE_FREQUENCY_TABLE';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_array EXCEPTION;
    e_null_value EXCEPTION;
    e_non_integer EXCEPTION;
  BEGIN 
    IF p_array IS NULL THEN 
      RAISE e_null_array;
    END IF;
    
    IF array_contains_null(p_array) THEN 
      RAISE e_null_value;
    END IF;
    
    -- Sort array into ascending sequence
    -- This is required for sequential count of each key to work
    v_sorted_array := sort_array(p_array,'A');
    v_array_size := v_sorted_array.COUNT;
    
    v_index := 1;
    WHILE v_index <= v_array_size LOOP 
      -- Strict integer check 
      IF v_sorted_array(v_index) != TRUNC(v_sorted_array(v_index)) THEN 
        v_error_value := TO_CHAR(v_sorted_array(v_index));
        RAISE e_non_integer;
      END IF;
      
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
    p_frequency_table IN t_frequency_table
  ) RETURN PLS_INTEGER
  IS 
    v_sum PLS_INTEGER :=0;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.FREQUENCY_TABLE_SUM';
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
    p_frequency_table IN t_frequency_table
  ) RETURN PLS_INTEGER
  IS 
    v_count PLS_INTEGER :=0;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.FREQUENCY_TABLE_COUNT';
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
    p_frequency_table IN t_frequency_table
  ) RETURN NUMBER
  IS 
    v_mean NUMBER :=0;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.FREQUENCY_TABLE_MEAN';
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
    p_frequency_table IN t_frequency_table,
    p_rank IN PLS_INTEGER
  ) RETURN NUMBER
  IS
    v_cum PLS_INTEGER := 0;
    i PLS_INTEGER;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.VALUE_AT_RANK';
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
    p_frequency_table IN t_frequency_table
  ) RETURN NUMBER
  IS 
    v_n PLS_INTEGER;
    v_r1 PLS_INTEGER;
    v_r2 PLS_INTEGER;
    v_x1 NUMBER;
    v_x2 NUMBER;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.FREQUENCY_TABLE_MEDIAN';
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
    
    IF is_odd(v_n) THEN 
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
    p_frequency_table IN t_frequency_table
  ) RETURN t_int_table
  IS 
    tb_modes t_int_table := t_int_table();
    v_max_frequency PLS_INTEGER :=0;
    v_index PLS_INTEGER;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.FREQUENCY_TABLE_MODE';
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
    p_frequency_table IN t_frequency_table
  ) RETURN PLS_INTEGER
  IS 
    v_highest PLS_INTEGER :=0;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.FREQUENCY_TABLE_HIGHEST';
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
    p_frequency_table IN t_frequency_table
  ) RETURN PLS_INTEGER
  IS 
    v_lowest PLS_INTEGER :=0;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.FREQUENCY_TABLE_LOWEST';
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
    p_frequency_table IN t_frequency_table
  ) RETURN PLS_INTEGER
  IS 
    v_range PLS_INTEGER :=0;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.FREQUENCY_TABLE_RANGE';
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
    p_frequency_table IN t_frequency_table
  ) RETURN NUMBER
  IS 
    v_freq_count PLS_INTEGER :=0;
    v_mean NUMBER;
    v_ss NUMBER :=0; -- Sum of squares about the Mean
    v_index PLS_INTEGER;
    v_diff NUMBER;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.VARIANCE_POP';
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
    p_frequency_table IN t_frequency_table
  ) RETURN NUMBER
  IS
    v_var NUMBER;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.STDDEV_POP';
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
    p_frequency_table IN t_frequency_table
  ) RETURN NUMBER
  IS
    v_freq_count PLS_INTEGER :=0;
    v_mean NUMBER;
    v_ss  NUMBER :=0; -- Sum of squares about the Mean
    v_index PLS_INTEGER;
    v_diff NUMBER;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.VARIANCE_SAMP';
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
    p_frequency_table IN t_frequency_table
  ) RETURN NUMBER
  IS
    v_var NUMBER;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.STDDEV_SAMP';
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
    p_frequency_table IN t_frequency_table,
    p_pct             IN NUMBER 
  ) RETURN PLS_INTEGER
  IS 
    v_freq_count PLS_INTEGER;
    v_rank PLS_INTEGER;
    v_cum PLS_INTEGER := 0;
    i PLS_INTEGER;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.PERCENTILE_DISC';
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
    p_frequency_table IN t_frequency_table,
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
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.PERCENTILE_CONT';
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
     p_frequency_table IN t_frequency_table
  ) RETURN NUMBER
  IS 
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.IQR';
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
    p_array IN t_number_array
  ) RETURN t_stats_result
  IS 
    tb_frequency_table t_frequency_table;
    rec_stats t_stats_summary;
    rec_stats_result t_stats_result;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.GET_STATS';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_array EXCEPTION;
    e_null_values EXCEPTION;
  BEGIN 
    IF p_array IS NULL OR p_array.COUNT = 0 THEN 
      RAISE e_null_array;
    END IF;
    
    IF array_contains_null(p_array) THEN 
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
    rec_stats.mode_values     := frequency_table_mode(tb_frequency_table); -- table of INT
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
    p_array IN t_number_array
  ) RETURN t_stats_result
  IS 
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.GET_STATS_ARRAY';
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
  ) RETURN t_stats_result
  IS 
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.GET_STATS_LIST';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
    e_null_list EXCEPTION;
  BEGIN
    IF p_list IS NULL THEN 
      RAISE e_null_list;
    END IF;
    RETURN get_stats_array(list_to_array(p_list));
  EXCEPTION
    WHEN e_null_list THEN 
      util_admin.log_message('List must not be null, or contain null values.', sqlerrm, v_debug_module, 'S', gc_error);
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.', sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END get_stats_list;
  
  FUNCTION get_stats_project(
    p_project_id IN stats_project.stats_project_id%TYPE
  ) RETURN t_stats_result
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
    v_array t_number_array := t_number_array();
    v_check_project stats_project.stats_project_id%TYPE;
    v_debug_module applog.program_name%TYPE := 'UTIL_NUMERIC.GET_STATS_PROJECT';
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
    p_stats_result IN t_stats_result
  )
  IS 
  BEGIN 
    util_admin.log_message('----------------------------------------------------------');
    util_admin.log_message('FREQUENCY TABLE');
    util_admin.log_message('----------------------------------------------------------');
    FOR i IN 1 .. p_stats_result.freq_tbl.COUNT LOOP 
      util_admin.log_message( 'KEY='||to_char(p_stats_result.freq_tbl(i).KEY)||
                              ' Frequency='||to_char(p_stats_result.freq_tbl(i).frequency));
    END LOOP;
    util_admin.log_message('----------------------------------------------------------');
  END display_frequency_table;
  
  PROCEDURE display_stats(
    p_stats_result IN t_stats_result,
    p_pct IN NUMBER DEFAULT 0.5
  )
  IS
  BEGIN
    util_admin.log_message('STATISTICS');
    util_admin.log_message('Sum='||to_char(p_stats_result.stats.sum_values));
    util_admin.log_message('N Total='||to_char(p_stats_result.stats.n_total));
    util_admin.log_message('Distinct N='||to_char(p_stats_result.stats.distinct_n));
    util_admin.log_message('Mean='||trim(to_char(p_stats_result.stats.mean,'9999999990.9999')));
    util_admin.log_message('Median='||trim(to_char(p_stats_result.stats.median,'9999999990.9999')));
    FOR i IN 1 .. p_stats_result.stats.mode_values.COUNT LOOP 
      util_admin.log_message('Mode '||to_char(i)||' = '||to_char(p_stats_result.stats.mode_values(i) ) );
    END LOOP;
    util_admin.log_message('Lowest='||to_char(p_stats_result.stats.lowest));
    util_admin.log_message('Highest='||to_char(p_stats_result.stats.highest));
    util_admin.log_message('Range='||to_char(p_stats_result.stats.range));
    util_admin.log_message('Variance Population='||trim(to_char(p_stats_result.stats.variance_pop,'9999999990.9999')));
    util_admin.log_message('Variance Sample='||trim(to_char(p_stats_result.stats.variance_samp,'9999999990.9999')));
    util_admin.log_message('Standard Deviation Population='||trim(to_char(p_stats_result.stats.stddev_pop,'9999999990.9999')));
    util_admin.log_message('Standard Deviation Sample='||trim(to_char(p_stats_result.stats.stddev_samp,'9999999990.9999')));
    util_admin.log_message('Interquartile Range='||trim(to_char(p_stats_result.stats.iqr,'9999999990.9999')));
    
    -- Percentiles
    util_admin.log_message('Percentile Discrete ('||to_char(p_pct,'0.99')||')='||trim(to_char(percentile_disc(p_stats_result.freq_tbl, p_pct),'9999999990.9999')));
    util_admin.log_message('Percentile Continuous ('||to_char(p_pct,'0.99')||')='||trim(to_char(percentile_cont(p_stats_result.freq_tbl, p_pct),'9999999990.9999')));   
  END display_stats;
  
END util_numeric;
/