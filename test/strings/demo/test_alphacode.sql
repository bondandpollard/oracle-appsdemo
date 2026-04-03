-- Test alphacode 
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
-- 475254=ZZZZ
-- Create an algorithm instead of using a loop to generate the codes
-- NB: You need to include a check where number divisible by 26 with no remainder
-- then adjust each column value.
SET SERVEROUTPUT ON
DECLARE 
  v_code VARCHAR2(4);
  v_check NUMBER;
  v_check_code VARCHAR2(4);
  v_error_count NUMBER :=0;
  v_error_message VARCHAR2(40);
BEGIN
  FOR m IN 1 .. 18279 LOOP
    v_code := demo_string.alphacode(m);
    v_check := demo_string.alphadecode(v_code);
    v_check_code := demo_string.alphacode_range(m,26);
    IF v_check <> m OR v_code <> v_check_code THEN
      v_error_count := v_error_count +1;
      v_error_message := 'ERROR';
    ELSE
      v_error_message := 'CORRECT';
    END IF;
    dbms_output.put_line(to_char(m)||'='||v_code||' Check Code='||v_check_code||' '||v_error_message);
  END LOOP;
  dbms_output.put_line('Test completed. '||to_char(v_error_count)||' errors found.');
END;