-- test_is_odd
SET SERVEROUTPUT ON
ACCEPT p_number NUMBER PROMPT "Enter a number"
DECLARE
  v_odd_or_even VARCHAR2(8);
BEGIN
  IF util_numeric.is_odd(&p_number) THEN 
    util_admin.log_message('IS_ODD The number '||to_char(&p_number)||' is ODD.');
  ELSE
    util_admin.log_message('IS_ODD The number '||to_char(&p_number)||' is EVEN.'); 
  END IF;
  IF util_numeric.is_even(&p_number) THEN 
    util_admin.log_message('IS_EVEN The number '||to_char(&p_number)||' is EVEN.');
  ELSE
    util_admin.log_message('IS_EVEN The number '||to_char(&p_number)||' is ODD.'); 
  END IF;
  FOR m IN 1..999 LOOP
    v_odd_or_even := 
      CASE util_numeric.is_odd(m)
        WHEN TRUE THEN ' is ODD'
        ELSE ' is EVEN'
      END;
    util_admin.log_message(to_char(m)||v_odd_or_even);
  END LOOP;
END;
