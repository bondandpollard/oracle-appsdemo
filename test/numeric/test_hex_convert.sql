SET SERVEROUTPUT ON SIZE 1000000
DECLARE 
  v_hexcode VARCHAR2(10);
  v_decimal INTEGER;
BEGIN 
  FOR M IN 0 .. 10000 LOOP
    v_hexcode := util_numeric.dectohex(M);
    v_decimal := util_numeric.hextodec(v_hexcode);
    dbms_output.put_line(to_char(M)||' is Hex '||v_hexcode|| ' Decimal is '||to_char(v_decimal));
  END LOOP;
END;