-- Test the incorrect ATG alphacode function
-- This is a simple, but poory written solution
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
  v_max INTEGER;
  v_errors INTEGER :=0;
BEGIN
  v_max := &p_max;
  FOR m IN 1 .. v_max LOOP
    v_code := NVL(demo_string.alphacode_atg_wrong(m),'ERROR');
    v_num := demo_string.alphadecode(v_code);
    v_check_code := demo_string.alphacode_calc(m);
    v_check_num := demo_string.alphadecode(v_check_code);
    dbms_output.put_line(v_code);
    IF v_code <> v_check_code THEN
      v_errors := v_errors+1;
      dbms_output.put_line('ERROR: mismatch between number '||to_char(m)||' giving code '||v_code||' and its decoded result '||to_char(v_num)
      || '. The correct code is ' || v_check_code || ' decodes to number ' || to_char(v_check_num));
    END IF;
  END LOOP;  
  dbms_output.put_line('Total of '||to_char(v_max)||' numbers checked, with '||to_char(v_errors)||' errors found. Error rate='||to_char(v_errors/v_max*100,'99.99')||'%');
END;