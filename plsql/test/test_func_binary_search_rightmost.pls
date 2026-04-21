CREATE OR REPLACE FUNCTION test_binary_search_rightmost(p_target IN NUMBER, p_array IN VARCHAR2, p_exact BOOLEAN DEFAULT TRUE) RETURN number IS
 l_position NUMBER;
 l_match_desc VARCHAR2(20);
BEGIN
  IF p_exact THEN 
    l_match_desc := 'Exact Match: ';
  ELSE
    l_match_desc := 'NOT Exact Match: ';
  END IF;
  l_position := util_numeric.binary_search_rightmost(p_target,p_array,p_exact);
  dbms_output.put_line(l_match_desc || 'Rightmost Position of ' || to_char(p_target) || ' in ' || p_array || ' = ' || to_char(l_position));
  RETURN l_position;
END test_binary_search_rightmost;