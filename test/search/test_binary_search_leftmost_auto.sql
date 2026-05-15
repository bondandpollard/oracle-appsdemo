-- Test leftmost binary search
-- Compile function test_binary_search_leftmost first
-- See test_func_binary_search_leftmost.pls
SET SERVEROUTPUT ON
DECLARE
  a VARCHAR2(255);
  p NUMBER;
  t NUMBER;
  exact BOOLEAN := FALSE;
BEGIN
  a := '1,1,2,2,2,14,14,14,14,16,16,18';
  dbms_output.put_line('TEST Binary Search Leftmost, EXACT match.');
  dbms_output.put_line('Array: ' || a);
  exact := TRUE;
  p := test_binary_search_leftmost(-1,a,exact);
  p := test_binary_search_leftmost(0,a,exact);
  p := test_binary_search_leftmost(1,a,exact);
  p := test_binary_search_leftmost(2,a,exact);
  p := test_binary_search_leftmost(3,a,exact);
  p := test_binary_search_leftmost(13,a,exact);
  p := test_binary_search_leftmost(14,a,exact);
  p := test_binary_search_leftmost(15,a,exact);
  p := test_binary_search_leftmost(16,a,exact);
  p := test_binary_search_leftmost(17,a,exact);
  p := test_binary_search_leftmost(18,a,exact);
  p := test_binary_search_leftmost(19,a,exact);
  dbms_output.put_line('TEST Binary Search Leftmost, NOT EXACT match.');
  dbms_output.put_line('Array: ' || a);
  exact := FALSE;
  p := test_binary_search_leftmost(-1,a,exact);
  p := test_binary_search_leftmost(0,a,exact);
  p := test_binary_search_leftmost(1,a,exact);
  p := test_binary_search_leftmost(2,a,exact);
  p := test_binary_search_leftmost(3,a,exact);
  p := test_binary_search_leftmost(13,a,exact);
  p := test_binary_search_leftmost(14,a,exact);
  p := test_binary_search_leftmost(15,a,exact);
  p := test_binary_search_leftmost(16,a,exact);
  p := test_binary_search_leftmost(17,a,exact);
  p := test_binary_search_leftmost(18,a,exact);
  p := test_binary_search_leftmost(19,a,exact);
  
  
  a := '1,2,3,4,7,8,10,11,13,14,15';
  dbms_output.put_line('TEST Binary Search Leftmost, NOT EXACT match.');
  dbms_output.put_line('Array: ' || a);
  p := test_binary_search_leftmost(5,a,exact);
   
END;