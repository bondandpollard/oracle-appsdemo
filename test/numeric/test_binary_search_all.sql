-- Test all binary search functions
-- Compile test functions
-- test_func_binary_search_rightmost.sql
-- test_func_binary_search_leftmost.sql
SET SERVEROUTPUT ON
ACCEPT p_target NUMBER PROMPT 'Enter target value:'
ACCEPT p_target_to NUMBER PROMPT 'Enter target range to:'
DECLARE
  a VARCHAR2(255);
  p NUMBER;
  t NUMBER;
  t_to NUMBER;
  exact BOOLEAN := FALSE;
BEGIN
  a := '1,1,2,2,2,9.0,9.25,9.8175,14,14,14,14,16,16,18,18,18';
  t := &p_target;
  t_to := &p_target_to;
  
  dbms_output.put_line('Array: ' || a);
  dbms_output.put_line('Target: ' || to_char(t));
  dbms_output.put_line('Target To: ' || to_char(t_to));
  
  
  p := util_numeric.binary_chop_search(t,a);
  dbms_output.put_line('TEST binary_chop_search, result = ' || to_char(p));
  
  p := util_numeric.binary_search(t,a);
  dbms_output.put_line('TEST binary_search, result = ' || to_char(p));
  
  dbms_output.put_line('TEST Binary Search Leftmost, EXACT match.');
  exact := TRUE;
  p := test_binary_search_leftmost(t,a,exact);
 
  dbms_output.put_line('TEST Binary Search Leftmost, NOT EXACT match.');
  exact := FALSE;
  p := test_binary_search_leftmost(t,a,exact);
  
  dbms_output.put_line('TEST Binary Search Rightmost, EXACT match.');
  exact := TRUE;
  p := test_binary_search_rightmost(t,a,exact);
 
  dbms_output.put_line('TEST Binary Search Rightmost, NOT EXACT match.');
  exact := FALSE;
  p := test_binary_search_rightmost(t,a,exact);
  
  p := util_numeric.binary_rank(t,a);
  dbms_output.put_line('TEST binary_rank, result = ' || to_char(p));
  
  p := util_numeric.binary_search_predecessor(t,a);
  dbms_output.put_line('TEST binary_search_predecessor, result = ' || to_char(p));
  
  p := util_numeric.binary_search_successor(t,a);
  dbms_output.put_line('TEST binary_search_successor, result = ' || to_char(p));
  
  p := util_numeric.binary_search_nearest(t,a);
  dbms_output.put_line('TEST binary_search_nearest, result = ' || to_char(p));
  util_admin.log_message('*********');
  util_admin.log_message('NEW ARRAY');
  util_admin.log_message('*********');
  a := '1,2,3,4,5,6,7,8,9,10,10.1,10.3,10.567,14,15,16,17,18,19,20';
  util_admin.log_message('Array: ' || a);
  exact := TRUE;
  p := test_binary_search_rightmost(t,a,exact);
  util_admin.log_message('Position of ' || to_char(t) || ' is ' || to_char(p));
  p := util_numeric.binary_search_range(t, t_to,a);
  util_admin.log_message('TEST binary_search_range, from ' || to_char(t) || ' to ' || to_char(t_to) || ' result = ' || to_char(p));
  
END;