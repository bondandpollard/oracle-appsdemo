-- test_fibonacci
-- Test fibonacci function.
SET SERVEROUTPUT ON
ACCEPT p_count NUMBER PROMPT "How many Fibonacci numbers do you want to calculate?"
DECLARE
  v_fibonacci_array plsql_types.t_number_array := plsql_types.t_number_array();
BEGIN
  v_fibonacci_array := util_numeric.fibonacci(&p_count);
  FOR i IN 1 .. &p_count LOOP
    util_admin.log_message(to_char(i)||': '||to_char(v_fibonacci_array(i)));
  END LOOP;
END;