-- Test the conversion of a series of integers to Hexadecimal.
--
SET SERVEROUTPUT ON
ACCEPT loopsize NUMBER DEFAULT 30 PROMPT "Enter number to count to: "
DECLARE
  l_base_value VARCHAR2(20);
  l_dec_value INTEGER;
  l_start INTEGER := -17;
  l_loopsize INTEGER;
  l_check VARCHAR2(20);
  l_check_flag BOOLEAN := true;
BEGIN
  l_loopsize := &loopsize;
  dbms_output.put_line('Convert decimal numbers from ' || to_char(l_start) || ' to ' || to_char(l_loopsize) || ' to base hexadecimal.');
  FOR I IN l_start .. l_loopsize LOOP
    l_base_value := util_numeric.dectohex(I);
    l_dec_value := util_numeric.hextodec(l_base_value);
    IF l_dec_value = I THEN
      l_check := 'PASS';
    ELSE
      l_check := '** FAIL **';
      l_check_flag := false;
      EXIT;
    END IF;
    dbms_output.put_line('*'||lpad(to_char(I),12)||' = '||lpad(l_base_value,12)||' Convert to decimal result= '||lpad(to_char(l_dec_value),12) || ' Result=' || l_check);
  END LOOP;
  IF l_check_flag THEN
    dbms_output.put_line('SUCCESS - All calculations correct.');
  ELSE
    dbms_output.put_line('ERROR - Incorrect base conversion.');
  END IF;
END;