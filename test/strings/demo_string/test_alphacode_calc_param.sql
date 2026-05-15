-- Test alphacode_calc prompt for parameter
-- This is an efficient algorithmic solution
-- Maximum integer value is : 8197445666148052002118041599 giving code: JRAWBYNAKNYOYZERNNYM
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
DECLARE 
  v_param INTEGER;
  v_code VARCHAR2(30);
  v_num INTEGER;
BEGIN
  v_param := &p1;
  v_code := demo_string.alphacode_calc(v_param);
  v_num := demo_string.alphadecode(v_code);
  dbms_output.put_line(to_char(v_param)||'='||v_code||' Length='||length(v_code)||' Decoded to number='||to_char(v_num));
  IF v_param <> v_num THEN
    dbms_output.put_line('ERROR input value does not match decoded result');
  ELSE
    dbms_output.put_line('CONGRATULATIONS, The result is correct!');
  END IF;
END;