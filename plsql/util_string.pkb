CREATE OR REPLACE PACKAGE BODY util_string AS

  /*
  ** Private functions and procedures
  */

  /*
  ** text_replace - replace escaped chars with ASCII equivalent
  **
  ** Called by the textconvert function
  ** Swap backslash t for ASCII char 9  (tab)
  **      backslash n for ASCII char 10 (newline)
  **      backslash r for ASCII char 13 (carriage return)
  **
  ** IN
  **   p_instring         - Source string containing escaped chars
  **   p_replacewhat      - Escaped character string to be replaced
  ** RETURN
  **   VARCHAR2  String with escaped characters replaced with ASCII equivalent
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION text_replace(
    p_instring    IN VARCHAR2,
    p_replacewhat IN VARCHAR2
  ) 
  RETURN VARCHAR2
  IS
    c_max CONSTANT NUMBER := 500;
    l_outstring plsql_constants.maxvarchar2_t := '';
    l_replacewith VARCHAR2(1);
    l_npos NUMBER := 0;
    l_counter NUMBER := 0;
  BEGIN
    l_outstring := p_instring;

    CASE p_replacewhat
      WHEN gc_tab_str THEN
        l_replacewith := gc_tab;
      WHEN gc_newline_str THEN
        l_replacewith := gc_newline;
      WHEN gc_carriage_return_str THEN
        l_replacewith := gc_carriage_return;
    ELSE
        l_replacewith := ' ';
    END CASE;

    WHILE( instr(l_outstring, p_replacewhat) <> 0) LOOP
      l_counter := l_counter + 1;
      l_npos := instr(l_outstring, p_replacewhat);
      l_outstring := substr(l_outstring, 1,l_npos - 1)||l_replacewith||substr(l_outstring,  l_npos + 2);
      IF l_counter > c_max THEN
        l_outstring:='ERROR TEXTCONVERT';
        EXIT;
      END IF;
    END LOOP;

    RETURN l_outstring;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.' ,sqlerrm, 'UTIL_STRING.TEXT_REPLACE', 'S', gc_error);
      RETURN NULL;
  END text_replace;
  
  /*
  ** first_field_is_null - Check if first field in string is null
  **
  ** If the first char in a delimiter separated string of fields is a delimiter 
  ** then the first field is null.
  **
  ** IN
  **   p_string         - Source string list of comma separated fields
  **   p_delimiter      - Delimiter separating fields in p_string
  ** RETURN
  **   BOOLEAN          - TRUE if first char is a delimiter (first field is NULL)
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION first_field_is_null (
    p_string         IN VARCHAR2, 
    p_delimiter      IN VARCHAR2 DEFAULT ','
  ) 
  RETURN BOOLEAN
  IS
    first_field_is_null BOOLEAN := FALSE;
    e_null_string exception;
  BEGIN
    IF p_string IS NULL THEN 
      RAISE e_null_string;
    END IF;
    IF SUBSTR(p_string,1,1) = p_delimiter THEN 
      first_field_is_null := TRUE;
    END IF;
    RETURN first_field_is_null;
  EXCEPTION
    WHEN e_null_string THEN 
      util_admin.log_message('Error - string is NULL.' ,sqlerrm, 'UTIL_STRING.FIRST_FIELD_IS_NULL', 'S', gc_error);
      RETURN TRUE;   
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.' ,sqlerrm, 'UTIL_STRING.FIRST_FIELD_IS_NULL', 'S', gc_error);
      RETURN NULL;
  END first_field_is_null;

  /*
  ** Public functions and procedures
  */
  
  FUNCTION array_to_list_str (
    p_array_str    IN t_string_array
  ) RETURN VARCHAR2
  IS
    v_result plsql_constants.maxvarchar2_t;
    v_count INTEGER;
  BEGIN
    v_count := 0;
    FOR m IN 1 .. p_array_str.LAST LOOP
      IF p_array_str(m) IS NOT NULL THEN 
        v_count := v_count +1;
        IF v_count = 1 THEN
          v_result := to_char(p_array_str(m));
        ELSE
          v_result := v_result || ',' || to_char(p_array_str(m));
        END IF;
      END IF;
    END LOOP;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.' ,sqlerrm, 'UTIL_STRING.ARRAY_TO_LIST_STR', 'S', gc_error);
      RETURN NULL;
  END array_to_list_str;
 

  FUNCTION list_to_array_str (
    p_list_str    IN VARCHAR2
  ) RETURN t_string_array
  IS 
    v_array_str t_string_array;
    v_field_count NUMBER :=0;
    e_null_list EXCEPTION;
    e_list_size EXCEPTION;
  BEGIN
    IF p_list_str IS NULL THEN 
      RAISE e_null_list;
    END IF;
    v_array_str := t_string_array();
    v_field_count := util_string.count_fields(p_list_str);
    IF v_field_count > gc_max_array_size then
      RAISE e_list_size;
    END IF;
    FOR m IN 1 .. v_field_count LOOP
      v_array_str.EXTEND;
      v_array_str(m) := util_string.get_field(p_list_str,m,',');
    END LOOP;
    RETURN v_array_str;
  EXCEPTION
    WHEN e_list_size THEN
      util_admin.log_message('Error: List size exceeds array capacity, maximum ' || to_char(gc_max_array_size) || ' entries.', sqlerrm, 'UTIL_NUMERIC.LIST_TO_ARRAY_STR', 'S', gc_error);
      RETURN NULL;
    WHEN e_null_list THEN
      util_admin.log_message('Error: List is NULL.', sqlerrm, 'UTIL_NUMERIC.LIST_TO_ARRAY_STR', 'S', gc_error);
      RETURN NULL;
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.' ,sqlerrm, 'UTIL_STRING.LIST_TO_ARRAY_STR', 'S', gc_error);
      RETURN NULL;
  END list_to_array_str;
  

  FUNCTION delimiter_position (
    p_string         IN VARCHAR2, 
    p_start_position IN NUMBER, 
    p_delim_position IN NUMBER, 
    p_delimiter      IN VARCHAR2 DEFAULT ','
  ) 
  RETURN NUMBER 
  IS
    c_quote CONSTANT VARCHAR2(1) := '"';  
    v_start_position NUMBER;
    v_delim_pos NUMBER;
    v_delim_count NUMBER;
    v_current_char VARCHAR2(1);
    v_quotes_open BOOLEAN;
    v_delim_found BOOLEAN;
    v_quote_found BOOLEAN;
    v_first_field_is_null BOOLEAN;
    delimiter_length_error EXCEPTION;
    input_string_null EXCEPTION;
    v_debug_module applog.program_name%TYPE := 'util_string.delimiter_position';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := gc_debug_mode;
  BEGIN
    IF LENGTH(p_delimiter) <> 1 THEN
      RAISE delimiter_length_error;
    END IF;
    IF p_string IS NULL THEN
      RAISE input_string_null;
    END IF;
    v_quotes_open := FALSE;
    v_delim_found := FALSE;
    v_quote_found := FALSE;
    v_first_field_is_null := first_field_is_null(p_string,p_delimiter); -- Is first char in string a delimiter (= first field null)?
    v_delim_count := 0;
    v_delim_pos := 0;
    
    IF v_first_field_is_null THEN       
      util_admin.log_message('DEBUG: *** FIRST FIELD IS NULL ***',NULL,v_debug_module,v_debug_mode,gc_info);
    END IF;
       
    -- Start searching string from this position
 
    v_start_position := NVL(p_start_position,1);
    
    FOR I IN v_start_position..LENGTH(p_string) LOOP
      -- Current char in string
      v_current_char := substr(p_string,I,1);
      util_admin.log_message('DEBUG: I=' || to_char(I) || ' v_current_char=' || v_current_char,NULL,v_debug_module,v_debug_mode,gc_info);
      
      -- Flag whether most recent char found that is not a space or quote, is a delimiter
      IF v_current_char = p_delimiter THEN
        v_delim_found := TRUE;
      ELSIF NVL(v_current_char,' ') <> ' ' AND v_current_char <> c_quote THEN
        v_delim_found := FALSE;
      END IF;
     
      -- Flag whether most recent char found that is not a space or delimiter is a quote
      IF v_current_char = c_quote THEN
        v_quote_found := TRUE;
      ELSIF NVL(v_current_char,' ') <> ' ' AND v_current_char <> p_delimiter THEN
        v_quote_found := FALSE;
      END IF;

      IF v_current_char = c_quote AND (v_delim_found OR I=v_start_position) THEN
        -- Open quotes
        -- Current character is a quote either first in string or previous non-space char was a delimiter
        v_quotes_open := TRUE; 
      ELSIF v_current_char = p_delimiter AND v_quote_found THEN
        -- Close quotes
        -- Current character is a delimiter and previous non-space char was a quote
        v_quotes_open := FALSE;
      END IF;

      IF NOT v_quotes_open THEN
        -- Current char is NOT between a pair of open quotes. Ignore delimiters inside pairs of open quotes
        IF v_current_char = p_delimiter AND (I > v_start_position OR v_first_field_is_null) THEN 
          -- Increment count of delimiters found only if character matches delimiter and is not within a pair of quotes
          -- Ignore the first delimiter found if you are starting the search at a delimiter part way along the string
          -- Include delimiter at first char of string where first field is NULL.
          v_delim_count := v_delim_count +1;
          util_admin.log_message('DEBUG: Incrementing v_delim_count=' || to_char(v_delim_count),NULL,v_debug_module,v_debug_mode,gc_info);
          IF (p_start_position = 1 AND v_delim_count = p_delim_position) OR v_start_position > 1 THEN
            -- Nth delimiter found, mark position and stop searching
            v_delim_pos := I;
            util_admin.log_message('DEBUG: Delimiter no. ' || to_char(p_delim_position) || ' found at position=' || to_char(I),NULL,v_debug_module,v_debug_mode,gc_info);
            EXIT;
          END IF; 
        END IF;
      END IF;
    END LOOP;
    
    util_admin.log_message('DEBUG: RETURN v_delim_pos=' || to_char(v_delim_pos) || ' v_start_position=' || to_char(v_start_position) || ' p_delim_position=' 
      || to_char(p_delim_position) || ' v_delim_count=' || to_char(v_delim_count),NULL,v_debug_module,v_debug_mode,gc_info);

    RETURN v_delim_pos;
  EXCEPTION
    WHEN delimiter_length_error THEN
      util_admin.log_message('Delimiter must be 1 character long.' ,sqlerrm, 'UTIL_STRING.DELIMITER_POSITION', 'S', gc_error);
      RETURN NULL;
    WHEN input_string_null THEN
      util_admin.log_message('Input string is NULL.' ,sqlerrm, 'UTIL_STRING.DELIMITER_POSITION', 'S', gc_error);
      RETURN NULL; 
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.' ,sqlerrm, 'UTIL_STRING.DELIMITER_POSITION', 'S', gc_error);
      RETURN NULL;
  END delimiter_position;


  FUNCTION delimiter_position_nospace (
    p_string         IN VARCHAR2, 
    p_delim_position IN NUMBER, 
    p_delimiter      IN VARCHAR2 DEFAULT ','
  ) 
  RETURN NUMBER 
  IS
    c_quote CONSTANT VARCHAR2(1) := '"';  
    v_delim_pos NUMBER;
    v_delim_count NUMBER;
    v_char VARCHAR2(1);
    v_prev_char VARCHAR2(1);
    v_next_char VARCHAR2(1);
    v_inside_quotes BOOLEAN;
    v_quote_count NUMBER;
    delimiter_length_error EXCEPTION;
    input_string_null EXCEPTION;
  BEGIN
    IF LENGTH(p_delimiter) <> 1 THEN
      RAISE delimiter_length_error;
    END IF;
    IF p_string IS NULL THEN
      RAISE input_string_null;
    END IF;
    v_inside_quotes := FALSE;
    v_quote_count := 0;
    v_delim_count := 0;
    v_delim_pos := 0;
    FOR I IN 1..LENGTH(p_string) LOOP
      -- Current char in string
      v_char := substr(p_string,I,1);
      -- Previous char in string
      IF I > 1 THEN
        v_prev_char := substr(p_string,I-1,1);
      ELSE 
        -- At first char in string so previous is null
        v_prev_char := NULL;
      END IF;
      -- Next char in string
      v_next_char := substr(p_string,I+1,1);
      IF v_char = c_quote THEN
        IF (v_prev_char IS NULL OR v_prev_char = p_delimiter) OR (v_next_char = p_delimiter OR v_next_char IS NULL) THEN
          -- Increment count of quotes found only if open quote is first in string or preceded by a delimiter, or
          -- closing quote last in string or followed by a delimiter. Ignore all other quotes between pairs of quotes.
          v_quote_count := v_quote_count +1;
        END IF;
        IF MOD(v_quote_count,2) = 1 AND (v_prev_char IS NULL OR v_prev_char = p_delimiter) THEN
          -- Opening quote detected
          v_inside_quotes := TRUE;
        ELSIF v_next_char = p_delimiter OR v_next_char IS NULL THEN
          -- Closing quote detected
          v_inside_quotes := FALSE;
        END IF;
      END IF;
      IF NOT v_inside_quotes AND v_char = p_delimiter THEN
        -- Increment count of delimiters found only if character matches delimiter and is not within a pair of quotes
        v_delim_count := v_delim_count +1;
      END IF;
      IF v_delim_count = p_delim_position THEN
        -- Nth delimiter found, mark position and stop searching
        v_delim_pos := I;
        EXIT;
      END IF; 
    END LOOP;
    RETURN v_delim_pos;
  EXCEPTION
    WHEN delimiter_length_error THEN
      util_admin.log_message('Delimiter must be 1 character long.' ,sqlerrm, 'UTIL_STRING.DELIMITER_POSITION_NOSPACE', 'S', gc_error);
      RETURN NULL;
    WHEN input_string_null THEN
      util_admin.log_message('Input string is NULL.' ,sqlerrm, 'UTIL_STRING.DELIMITER_POSITION_NOSPACE', 'S', gc_error);
      RETURN NULL; 
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.' ,sqlerrm, 'UTIL_STRING.DELIMITER_POSITION_NOSPACE', 'S', gc_error);
      RETURN NULL;
  END delimiter_position_nospace;

  FUNCTION get_field (
    p_string    IN VARCHAR2, 
    p_position  IN NUMBER, 
    p_delimiter IN VARCHAR2 DEFAULT ','
  ) 
  RETURN VARCHAR2 
  IS
    c_quote CONSTANT VARCHAR2(1) := '"';
    v_pos1 NUMBER;
    v_pos2 NUMBER;
    v_field plsql_constants.maxvarchar2_t;
    v_first_char VARCHAR(1);
    v_last_char VARCHAR2(1);    
    v_first_field_is_null BOOLEAN := FALSE;
    v_debug_module applog.program_name%TYPE := 'util_string.get_field';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := gc_debug_mode;
  BEGIN
    -- TRUE of first char of string is a delimiter, so first field is NULL.
    v_first_field_is_null := first_field_is_null(p_string, p_delimiter);

    -- Find the position of the delimiter that marks the start of the field
    IF p_position = 1 THEN
      -- First field starts at position 1 in the string
      v_pos1 := 1;
    ELSE
      -- Nth field starts at the preceding delimiter. Field 3 starts after delimiter 2.
      -- Start searching from the 1st character
      v_pos1 := delimiter_position(p_string, 1,  p_position -1, p_delimiter);
    END IF;
    
    util_admin.log_message('DEBUG: v_pos1=' || to_char(v_pos1), sqlerrm, v_debug_module, v_debug_mode, gc_info);
    
    IF v_pos1 > 0 THEN
      -- First delimiter position found
      -- Find the position of the delimiter that marks the end of the field
      -- Search for the next delimiter from the delimiter at the start of the field

      IF v_first_field_is_null THEN 
        -- Skip over first delimiter if first field is null
        v_pos2 := delimiter_position(p_string, v_pos1+1, 1, p_delimiter);
      ELSE
        v_pos2 := delimiter_position(p_string, v_pos1, 1, p_delimiter);
      END IF;
          
      util_admin.log_message('DEBUG: v_pos2=' || to_char(v_pos2), sqlerrm, v_debug_module, v_debug_mode, gc_info);
      
      IF p_position > 1 THEN
        -- For the 2nd field onward the starting position of the field is the next character after the delimiter
        v_pos1 := v_pos1 +1;
      END IF;
      IF v_pos2 < 1 THEN
        -- Last field in the string so no end delimiter found
        v_pos2 := LENGTH(p_string)+1;
      END IF;

   
      -- Extract field from the string, using the delimiter positions
      IF p_position = 1 AND v_first_field_is_null THEN 
        -- First field is null (first character of string is a delimiter)
        v_field := NULL;
      ELSE
        v_field := TRIM(BOTH ' ' FROM substr(p_string, v_pos1, v_pos2 - v_pos1));
      END IF;
     
      -- If the field is enclosed by double quotes (first and last char are quotes)
      -- then remove the enclosing quotes.
      -- Do not strip the quotes that are part of the field, e.g. "Title "Subtitle""
      -- must give: Title "Subtitle" 

      -- ORIGINAL CODE: v_field := TRIM(c_quote FROM TRIM(substr(p_string, v_pos1, v_pos2 - v_pos1)));

      v_first_char := substr(v_field,1,1);
      v_last_char := substr(v_field,LENGTH(v_field),1);
      IF v_first_char = v_last_char AND v_last_char = c_quote THEN
        -- First and last chars form pair of quotes enclosing field
        -- Remove first and last chars (quotes)
        v_field := substr(v_field,2,LENGTH(v_field)-2);
      END IF;
    ELSE
      v_field := NULL;
    END IF;
    RETURN v_field;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_STRING.GET_FIELD', 'S', gc_error);
      RETURN NULL;
  END get_field;



  FUNCTION get_field_nospace (
    p_string    IN VARCHAR2, 
    p_position  IN NUMBER, 
    p_delimiter IN VARCHAR2 DEFAULT ','
  ) 
  RETURN VARCHAR2 
  IS
    c_quote CONSTANT VARCHAR2(1) := '"';
    v_pos1 NUMBER;
    v_pos2 NUMBER;
    v_field plsql_constants.maxvarchar2_t;
  BEGIN
    -- Find the position of the delimiter that marks the start of the field
    IF p_position = 1 THEN
      -- First field starts at position 1 in the string
      v_pos1 := 1;
    ELSE
      v_pos1 := delimiter_position_nospace(p_string, p_position -1, p_delimiter);
    END IF;

    IF v_pos1 > 0 THEN
      -- First delimiter position found
      IF p_position > 1 THEN
        -- For the 2nd field onward the starting position is the next character after the delimiter
        v_pos1 := v_pos1 +1;
      END IF;
      -- Find the position of the delimiter that marks the end of the field
      v_pos2 := delimiter_position_nospace(p_string, p_position, p_delimiter);
      IF v_pos2 < 1 THEN
        -- Last field in the string so no end delimiter found
        v_pos2 := LENGTH(p_string)+1;
      END IF;
      -- Strip the double quotes from the start and end of the field
      v_field := TRIM(c_quote FROM TRIM(substr(p_string, v_pos1, v_pos2 - v_pos1)));
    ELSE
      v_field := 'ERROR: Field not found';
    END IF;

    RETURN v_field;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_STRING.GET_FIELD_NOSPACE', 'S', gc_error);
      RETURN NULL;
  END get_field_nospace;


  FUNCTION get_delimiter (
    p_string IN VARCHAR2
  ) 
  RETURN VARCHAR2 
  IS
    c_tab CONSTANT VARCHAR2(1) := CHR(9);
    v_count_comma NUMBER :=0;
    v_count_semi NUMBER :=0;
    v_count_tab NUMBER :=0;
    v_delimiter VARCHAR2(1);
    v_current VARCHAR2(1);
  BEGIN
    FOR I IN 1..LENGTH(p_string) LOOP
      v_current := SUBSTR(p_string,I,1);
      IF v_current = ';' OR v_current = ',' OR v_current = c_tab THEN
        CASE v_current
          WHEN ';'   THEN v_count_semi := v_count_semi +1;
          WHEN ','   THEN v_count_comma := v_count_comma +1;
          ELSE v_count_tab := v_count_tab +1;
        END CASE;
      END IF;
    END LOOP;
    IF v_count_semi > v_count_comma AND v_count_semi > v_count_tab THEN
      v_delimiter := ';';
    ELSIF v_count_comma > v_count_semi AND v_count_comma > v_count_tab THEN
      v_delimiter := ',';
    ELSE
      v_delimiter := c_tab;
    END IF;
    RETURN v_delimiter;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_STRING.GET_DELIMITER', 'S', gc_error);
      RETURN NULL;
  END get_delimiter;


  FUNCTION count_fields(
    p_string    IN VARCHAR2, 
    p_delimiter IN VARCHAR2 DEFAULT ','
  ) 
  RETURN NUMBER 
  IS
    v_pos NUMBER;
    v_field_no INTEGER;
    v_count NUMBER :=0;
    v_debug_module applog.program_name%TYPE := 'util_string.count_fields';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := gc_debug_mode;
  BEGIN
    IF first_field_is_null(p_string, p_delimiter) THEN 
      util_admin.log_message('DEBUG: FIRST FIELD IS NULL',NULL,v_debug_module,v_debug_mode,gc_info);
    END IF;
    v_pos := 1;
    v_field_no := 1;
    WHILE v_pos <= length(p_string) AND v_pos > 0 LOOP
      v_count := v_count +1;
      IF first_field_is_null(p_string,p_delimiter) THEN 
        util_admin.log_message('DEBUG: BEFORE delimiter_position v_pos=' || to_char(v_pos) || ' v_count=' || to_char(v_count),NULL,v_debug_module,v_debug_mode,gc_info);
      END IF;
      v_pos := NVL(delimiter_position(p_string, 1, v_field_no, p_delimiter),length(p_string));
      IF v_pos <= 0 THEN 
        EXIT;
      END IF;
      v_field_no := v_field_no +1;
    END LOOP;
    
    util_admin.log_message('DEBUG: AFTER LOOP v_field_no=' || to_char(v_field_no),NULL,v_debug_module,v_debug_mode,gc_info);
    
    RETURN v_count;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_STRING.COUNT_FIELDS', 'S', gc_error);
      RETURN NULL;
  END count_fields;


  FUNCTION REPLACE(
    p_instring    IN VARCHAR2, 
    p_replacewhat IN VARCHAR2, 
    p_replacewith IN VARCHAR2
  ) 
  RETURN VARCHAR2 
  IS
    l_outstring plsql_constants.maxvarchar2_t := '';
    npos NUMBER := 0;
    l_space VARCHAR2(1);
    l_offset NUMBER;
    l_found BOOLEAN;
    l_to_search plsql_constants.maxvarchar2_t;
    l_search_pos NUMBER;
  BEGIN
    l_outstring := p_instring;
    l_offset := 1;
    l_found := TRUE;
    WHILE(l_found) LOOP
      -- Remaining portion of string to be searched and replaced, starting after position of last replacement
      l_to_search := substr(l_outstring,l_offset,LENGTH(l_outstring));

      -- Position of characters to be be replaced within portion of string being searched
      l_search_pos := instr(l_to_search , p_replacewhat);

      IF l_search_pos > 0 THEN
        -- Substring to replace was found
        -- npos is the start position of the substring to be replaced withing the entire string, not just
        -- the portion currently being searched and replaced
        npos := l_offset -1 + l_search_pos;

        -- If what your are replacing is part of a longer word, don't put a space after the replacement string
        IF substr(l_outstring,npos+LENGTH(p_replacewhat),1) <> ' ' THEN
          l_space := '';
        ELSE
          l_space := ' ';
        END IF;

        -- Replace the original substring with the new substring
        l_outstring := LTRIM(substr(l_outstring, 1, npos - 1))
                     ||p_replacewith||l_space||
                     LTRIM(substr(l_outstring, npos + LENGTH(p_replacewhat),LENGTH(l_outstring)));

        -- The offset is the position within the string following the group of characters just replaced
        l_offset := npos + nvl(LENGTH(p_replacewith),0);
      ELSE
        l_found :=FALSE;
      END IF;
    END LOOP;
    RETURN l_outstring;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.' ,sqlerrm, 'UTIL_STRING.REPLACE', 'S', gc_error);
      RETURN NULL;
  END REPLACE;


  FUNCTION textconvert(
    p_instring IN VARCHAR2
  ) 
  RETURN VARCHAR2 
  IS
    l_outstring plsql_constants.maxvarchar2_t := '';
  BEGIN
    l_outstring := p_instring;
    l_outstring := text_replace(l_outstring,gc_newline_str);
    l_outstring := text_replace(l_outstring,gc_tab_str);
    l_outstring := text_replace(l_outstring,gc_carriage_return_str);
    RETURN l_outstring;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected error.' ,sqlerrm, 'UTIL_STRING.TEXTCONVERT', 'S', gc_error);
      RETURN NULL;
  END textconvert;


  FUNCTION sort_string (
    p_string IN VARCHAR2, 
    p_order  IN VARCHAR2 DEFAULT 'A'
  ) 
  RETURN VARCHAR2 
  IS
    v_result plsql_constants.maxvarchar2_t;
    v_len NUMBER;
    v1 VARCHAR2(1);
    v2 VARCHAR2(1);
  BEGIN
    v_len := LENGTH(p_string);
    v_result := p_string;
    FOR p1 IN 1 .. v_len -1 LOOP
      FOR p2 IN p1+1 .. v_len LOOP
        v1 := substr(v_result,p1,1);
        v2 := substr(v_result,p2,1);
        IF (UPPER(p_order) = 'A' AND v2 < v1) OR (UPPER(p_order) <> 'A' AND v2 > v1) THEN
          v_result := substr(v_result,1,p1-1) || v2 || substr(v_result,p1+1,p2-p1-1) || v1 || substr(v_result,p2+1,v_len);
        END IF;
      END LOOP;
    END LOOP;
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_STRING.SORT_STRING', 'S', gc_error);
      RETURN NULL;
  END sort_string;


  FUNCTION sort_list (
    p_string IN VARCHAR2, 
    p_order  IN VARCHAR2 DEFAULT 'A'
  ) 
  RETURN VARCHAR2 
  IS
    v_result plsql_constants.maxvarchar2_t;
    v_array_str t_string_array;
    v_temp VARCHAR2(gc_array_string_size);
    v_debug_module applog.program_name%TYPE := 'util_string.sort_list';
    v_debug_msg applog.message%TYPE;
    v_debug_mode VARCHAR2(1) := 'X';
  BEGIN
    -- Convert list of string to array
    v_array_str := util_string.list_to_array_str(p_string);
    -- Sort array
    FOR p1 IN 1 .. v_array_str.LAST -1 LOOP
      FOR p2 IN p1+1 .. v_array_str.LAST LOOP
        IF (UPPER(p_order) = 'A' AND v_array_str(p2) < v_array_str(p1)) OR (UPPER(p_order) <> 'A' AND v_array_str(p2) > v_array_str(p1)) THEN
          v_temp := v_array_str(p1);
          v_array_str(p1) := v_array_str(p2);
          v_array_str(p2) := v_temp;
        END IF;
      END LOOP;
    END LOOP;

    -- Put sorted list into result string
    v_result := util_string.array_to_list_str(v_array_str);
 
    RETURN v_result;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, v_debug_module, 'S', gc_error);
      RETURN NULL;
  END sort_list;
  

  FUNCTION name_initcap (
    p_string IN VARCHAR2
  )
  RETURN VARCHAR2
  IS
  BEGIN
    RETURN
    CASE
        WHEN REGEXP_LIKE(p_string,'(Mac[A-Z]|Mc[A-Z])') THEN p_string
        WHEN REGEXP_LIKE(p_string,'(de[A-Z])') THEN p_string
        WHEN REGEXP_LIKE(p_string,'(van\\s[A-Z])') THEN p_string
        WHEN p_string LIKE '''%' THEN p_string
        WHEN INITCAP(p_string) LIKE '_''S%' THEN p_string
        ELSE REPLACE(INITCAP(p_string),'''S','''s')
    END;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected eror.' ,sqlerrm, 'UTIL_STRING.NAME_INITCAP', 'S', gc_error);
      RETURN NULL;
  END name_initcap;  
  
END util_string;
/