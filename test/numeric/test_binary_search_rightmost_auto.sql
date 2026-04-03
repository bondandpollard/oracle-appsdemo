-- Test binary search rightmost
-- Compile function test_binary_search_rightmost first
-- See test_func_binary_search_rightmost.sql
SET SERVEROUTPUT ON
DECLARE
  a VARCHAR2(255);
  p NUMBER;
  t NUMBER;
  exact BOOLEAN := FALSE;
BEGIN
  a := '1,1,2,2,2,14,14,14,14,16,16,18';
  dbms_output.put_line('TEST Binary Search Rightmost, EXACT match.');
  dbms_output.put_line('Array: ' || a);
  exact := TRUE;
  p := test_binary_search_rightmost(-12,a,exact);
  p := test_binary_search_rightmost(0,a,exact);
  p := test_binary_search_rightmost(1,a,exact);
  p := test_binary_search_rightmost(2,a,exact);
  p := test_binary_search_rightmost(3,a,exact);
  p := test_binary_search_rightmost(13,a,exact);
  p := test_binary_search_rightmost(14,a,exact);
  p := test_binary_search_rightmost(15,a,exact);
  p := test_binary_search_rightmost(16,a,exact);
  p := test_binary_search_rightmost(17,a,exact);
  p := test_binary_search_rightmost(18,a,exact);
  p := test_binary_search_rightmost(19,a,exact);
  dbms_output.put_line('TEST Binary Search Leftmost, NOT EXACT match.');
  dbms_output.put_line('Array: ' || a);
  exact := FALSE;
  p := test_binary_search_rightmost(-12,a,exact);
  p := test_binary_search_rightmost(0,a,exact);
  p := test_binary_search_rightmost(1,a,exact);
  p := test_binary_search_rightmost(2,a,exact);
  p := test_binary_search_rightmost(3,a,exact);
  p := test_binary_search_rightmost(13,a,exact);
  p := test_binary_search_rightmost(14,a,exact);
  p := test_binary_search_rightmost(15,a,exact);
  p := test_binary_search_rightmost(16,a,exact);
  p := test_binary_search_rightmost(17,a,exact);
  p := test_binary_search_rightmost(18,a,exact);
  p := test_binary_search_rightmost(19,a,exact);
  
  
  a := '1,2,3,4,7,8,10,11,13,14,15';
  dbms_output.put_line('TEST Binary Search Rightmost, NOT EXACT match.');
  dbms_output.put_line('Array: ' || a);
  p := test_binary_search_rightmost(5,a,exact);
   
END;