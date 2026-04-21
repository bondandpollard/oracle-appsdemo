-- test_remove_duplicates
-- Remove duplicate values from an array, and list
SET SERVEROUTPUT ON
ACCEPT p_list PROMPT "Enter a list of numbers separated by commas, with duplicate values"
DECLARE
  v_noduplicate_list VARCHAR2(32767);
  v_unsorted_nodup_list VARCHAR2(32767);
  v_median NUMBER;
BEGIN
  -- Test remove duplicates with list sorted.
  v_noduplicate_list := util_numeric.remove_duplicates_list('&p_list');
  util_admin.log_message('List with duplicates removed is: '||v_noduplicate_list);
  
  -- Test remove duplicates without sorting.
  -- 3,2,1,2,1,2
  v_unsorted_nodup_list := util_numeric.remove_duplicates_nosort_list('&p_list');
  util_admin.log_message('UNSORTED List with duplicates removed is: '||v_unsorted_nodup_list);
END;
