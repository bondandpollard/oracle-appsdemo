-- test_binary_search_sort_list
-- Test the binary search functions.
-- This program is a wrapper that calls the various functions required
-- to convert lists to arrays, sort the array, and search for values in
-- arrays using logarithmic searches.
--
-- Inputs:
--  Unsorted list of numbers separated by commas.
--  Target number.
-- Sort the list, then search for the position of the target value using a binary search.
-- Display the position of the target value in the sorted list.
SET SERVEROUTPUT ON
ACCEPT p_number_list PROMPT "Enter an unsorted list of numbers to search, separated by commas"
ACCEPT p_target NUMBER PROMPT "Enter a target number to find"
DECLARE
  v_unsorted_array util_numeric.t_number_array;
  v_sorted_array util_numeric.t_number_array;
  v_position NUMBER;
BEGIN
  util_admin.log_message('Unsorted list=' || '&p_number_list');
  v_unsorted_array := util_numeric.list_to_array('&p_number_list');
  util_admin.log_message('Unsorted Array is:');
  FOR m IN 1 .. v_unsorted_array.LAST
  LOOP
    util_admin.log_message('v_unsorted_array('||to_char(m)||') = '||to_char(v_unsorted_array(m)));
  END LOOP;
  v_sorted_array := util_numeric.sort_array(v_unsorted_array,'A');
  util_admin.log_message('Sorted Array is:');
  FOR m IN 1 .. v_sorted_array.LAST
  LOOP
    util_admin.log_message('v_sorted_array('||to_char(m)||') = '||to_char(v_sorted_array(m)));
  END LOOP;
  v_position := util_numeric.binary_search_array('&p_target', v_sorted_array);
  util_admin.log_message('Position='||to_char(v_position));
END;