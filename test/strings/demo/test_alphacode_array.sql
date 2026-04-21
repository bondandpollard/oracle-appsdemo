-- Test alphacode_array
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
SET SERVEROUTPUT ON SIZE 1000000
DECLARE 
  v_code VARCHAR2(20);
  v_check_code VARCHAR2(20);
  v_error VARCHAR2(40);
  v_error_count NUMBER :=0;
BEGIN
  FOR m IN 1 .. 20001 LOOP
    v_code := ltrim(demo_string.alphacode_array(m));
    v_check_code := demo_string.alphacode_calc(m);
    IF v_check_code <> v_code THEN
      v_error := 'ERROR Check Code misatch';
      v_error_count := v_error_count+1;
    ELSE
      v_error := 'CORRECT!';
    END IF;
    dbms_output.put_line(to_char(m)||'='||v_code||' Check='||v_check_code||' '||v_error);
  END LOOP;  
  IF v_error_count =0 THEN
    v_error := 'CONGRATULATIONS, No errors found!';
  ELSE
    v_error := 'There were '||to_char(v_error)||' errors found';
  END IF;
  dbms_output.put_line(v_error);
END;