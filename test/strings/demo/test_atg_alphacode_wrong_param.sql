-- Test the ATG alphacode function (incorrect version of code that I submitted)
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
  v_code VARCHAR2(20);
  v_check_code VARCHAR2(20);
  v_num INTEGER;
  v_check_num INTEGER;
BEGIN
 
  v_param := &p1;
  v_code := demo_string.alphacode_atg_wrong(v_param);
  v_num := demo_string.alphadecode(v_code);
  v_check_code := demo_string.alphacode_calc(v_param);
  v_check_num := demo_string.alphadecode(v_check_code);
  dbms_output.put_line(to_char(v_param)||'='||v_code||' Decoded to number='||to_char(v_num));
  IF v_param <> v_num THEN
    dbms_output.put_line('ERROR: mismatch between number '||to_char(v_param)||' giving code '||v_code||' and its decoded result '||to_char(v_num)
      || '. The correct code is ' || v_check_code || ' decodes to number ' || to_char(v_check_num));
  ELSE 
    dbms_output.put_line('CORRECT!');
  END IF;
  
  
END;