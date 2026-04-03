-- Test dectoalpha
-- Generate a code use alphabetic chars in range 1 to n.
-- This is an efficient algorithmic solution
-- 1=A
-- 2=B
-- 3=C
-- 26=Z
-- 27=AA
-- 28=AB
-- 52=AZ
-- 53=BA
-- 700=ZX
-- 702=ZZ
-- 703=AAA
-- 704=AAB
-- 18278=ZZZ
-- 18279=AAAA
-- 72385=DCBA
-- 475254=ZZZZ
-- 1143606698788=ELIZABETH
SET SERVEROUTPUT ON SIZE 1000000
ACCEPT p_range PROMPT "Enter a number representing the range of letters to use. For example 26 for all letter of the alphabet, 4 to use just A to D"
ACCEPT p_max PROMPT "Enter the number of codes you want to generate."
DECLARE 
  v_param INTEGER;
  v_code VARCHAR2(20);
  v_num INTEGER;
  v_error_count NUMBER :=0;
  v_range INTEGER;
  v_max INTEGER;
BEGIN 
  v_range := &p_range;
  v_max := &p_max;
  FOR m IN 1 .. v_max LOOP
    v_code := util_numeric.dectoalpha(m,v_range);
    v_num := util_numeric.alphatodec(v_code,v_range);
    dbms_output.put_line('Range is ' || v_range || ' ' || to_char(m)||'='||v_code||' Decoded to number='||to_char(v_num));
    IF m <> v_num THEN
      v_error_count := v_error_count +1;
      dbms_output.put_line('ERROR: mismatch between number '||to_char(m)||' giving code '||v_code||' and decoded result '||to_char(v_num));
    END IF;
  END LOOP;  
  IF v_error_count >0 THEN
    dbms_output.put_line('Test completed, errors found ='||to_char(v_error_count));
  ELSE
    dbms_output.put_line('Test completed, no errors found.');
  END IF;
END;