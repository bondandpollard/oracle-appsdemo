-- Random number generation
SET SERVEROUTPUT ON
DECLARE
  c_base CONSTANT NUMBER := 16;
  l_rand INTEGER;
  l_base_str VARCHAR2(20);
  l_out VARCHAR2(32767);
  l_count INTEGER :=0;
BEGIN
  dbms_output.enable(NULL); /* Unlimited buffer size */
  FOR i IN 0 .. 10000 LOOP
    l_rand :=  abs(floor(dbms_random.normal*10))+1; -- random number between 1 and 10
    FOR j IN 1 .. l_rand*2 LOOP
      l_base_str := util_numeric.dectobase(l_rand+j,c_base);
      l_out := l_out || ' 0x' || l_base_str;
    END LOOP;
    dbms_output.put_line('Trying launch code sequence #' || to_char(i));
    dbms_output.put_line(l_out);
    l_out := NULL;
    l_count := l_count+1;
  END LOOP;
  dbms_output.put_line('Loops='||to_char(l_count));
EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('EXCEPTION Loops='||to_char(l_count));
    l_out := NULL;
END;