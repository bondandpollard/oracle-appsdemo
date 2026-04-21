-- Test decimal to hex and base conversion functions
-- Test -ve nos, 0, +ve numbers, error values e.g. non hex chars, invalid base chars.
SET SERVEROUTPUT ON SIZE 1000000
ACCEPT p_base NUMBER DEFAULT 16 PROMPT "Enter the number base to be used 2 to 16: "
DECLARE 
  v_base_string VARCHAR2(15);
  v_base INTEGER;
  v_decimal INTEGER;
  v_decimal_check INTEGER;
BEGIN 
  v_base := &p_base;
  
  dbms_output.put_line('===============================================');
  dbms_output.put_line('The following conversions should work correctly.');
  dbms_output.put_line('===============================================');
  
  dbms_output.put_line('CHECK HEXADECIMAL CONVERSION.');
  
  v_decimal :=NULL;
  v_base_string := util_numeric.dectohex(v_decimal);
  dbms_output.put_line('DECTOHEX Decimal = NULL' || to_char(v_decimal) || ' Hex = ' || v_base_string);
  v_decimal_check := util_numeric.hextodec(v_base_string);
  IF v_decimal <> v_decimal_check THEN
    dbms_output.put_line('ERROR: Conversion of decimal value = ' || to_char(v_decimal) || ' gave incorrect check value = ' || to_char(v_decimal_check));
  ELSE
    dbms_output.put_line('SUCCESS: Conversion of decimal value = ' || to_char(v_decimal) || ' gave correct check value = ' || to_char(v_decimal_check));
  END IF;
  dbms_output.put_line('HEXTODEC Check hex value converted back to decimal = ' || to_char(v_decimal_check));
  
  v_decimal :=0;
  v_base_string := util_numeric.dectohex(v_decimal);
  dbms_output.put_line('DECTOHEX Decimal = ' || to_char(v_decimal) || ' Hex = ' || v_base_string);
  v_decimal_check := util_numeric.hextodec(v_base_string);
  IF v_decimal <> v_decimal_check THEN
    dbms_output.put_line('ERROR: Conversion of decimal value = ' || to_char(v_decimal) || ' gave incorrect check value = ' || to_char(v_decimal_check));
  ELSE
    dbms_output.put_line('SUCCESS: Conversion of decimal value = ' || to_char(v_decimal) || ' gave correct check value = ' || to_char(v_decimal_check));
  END IF;
  dbms_output.put_line('HEXTODEC Check hex value converted back to decimal = ' || to_char(v_decimal_check));
  
  v_decimal :=-1;
  v_base_string := util_numeric.dectohex(v_decimal);
  dbms_output.put_line('DECTOHEX Decimal = ' || to_char(v_decimal) || ' Hex = ' || v_base_string);
  v_decimal_check := util_numeric.hextodec(v_base_string);
  IF v_decimal <> v_decimal_check THEN
    dbms_output.put_line('ERROR: Conversion of decimal value = ' || to_char(v_decimal) || ' gave incorrect check value = ' || to_char(v_decimal_check));
  ELSE
    dbms_output.put_line('SUCCESS: Conversion of decimal value = ' || to_char(v_decimal) || ' gave correct check value = ' || to_char(v_decimal_check));
  END IF;
  dbms_output.put_line('HEXTODEC Check hex value converted back to decimal = ' || to_char(v_decimal_check));
  
  v_decimal :=1000;
  v_base_string := util_numeric.dectohex(v_decimal);
  dbms_output.put_line('DECTOHEX Decimal = ' || to_char(v_decimal) || ' Hex = ' || v_base_string);
  v_decimal_check := util_numeric.hextodec(v_base_string);
  IF v_decimal <> v_decimal_check THEN
    dbms_output.put_line('ERROR: Conversion of decimal value = ' || to_char(v_decimal) || ' gave incorrect check value = ' || to_char(v_decimal_check));
  ELSE
    dbms_output.put_line('SUCCESS: Conversion of decimal value = ' || to_char(v_decimal) || ' gave correct check value = ' || to_char(v_decimal_check));
  END IF;
  dbms_output.put_line('HEXTODEC Check hex value converted back to decimal = ' || to_char(v_decimal_check));
  
  v_base_string := NULL;
  v_decimal := util_numeric.hextodec(v_base_string);
  dbms_output.put_line('HEXTODEC Hex = NULL' || v_base_string || ' Decimal = ' || to_char(v_decimal));
  
  v_base_string := '0';
  v_decimal := util_numeric.hextodec(v_base_string);
  dbms_output.put_line('HEXTODEC Hex = ' || v_base_string || ' Decimal = ' || to_char(v_decimal));
  
  v_base_string := '-1';
  v_decimal := util_numeric.hextodec(v_base_string);
  dbms_output.put_line('HEXTODEC Hex = ' || v_base_string || ' Decimal = ' || to_char(v_decimal));
  
  v_base_string := '3E8';
  v_decimal := util_numeric.hextodec(v_base_string);
  dbms_output.put_line('HEXTODEC Hex = ' || v_base_string || ' Decimal = ' || to_char(v_decimal));
  
  dbms_output.put_line('CHECK BASE CONVERSION FOR BASE ' || to_char(v_base));
  
  v_decimal :=NULL;
  v_base_string := util_numeric.dectobase(v_decimal,v_base);
  dbms_output.put_line('DECTOBASE Decimal = NULL' || to_char(v_decimal) || ' BASE ' || to_char(v_base) || ' = ' || v_base_string);
  v_decimal_check := util_numeric.basetodec(v_base_string,v_base);
  IF v_decimal <> v_decimal_check THEN
    dbms_output.put_line('ERROR: Conversion of decimal value = ' || to_char(v_decimal) || ' gave incorrect check value = ' || to_char(v_decimal_check));
  ELSE
    dbms_output.put_line('SUCCESS: Conversion of decimal value = ' || to_char(v_decimal) || ' gave correct check value = ' || to_char(v_decimal_check));
  END IF;
  dbms_output.put_line('BASETODEC Check base value converted back to decimal = ' || to_char(v_decimal_check));
  
  v_decimal :=0;
  v_base_string := util_numeric.dectobase(v_decimal,v_base);
  dbms_output.put_line('DECTOBASE Decimal = ' || to_char(v_decimal) || ' BASE ' || to_char(v_base) || ' = ' || v_base_string);
  v_decimal_check := util_numeric.basetodec(v_base_string,v_base);
  IF v_decimal <> v_decimal_check THEN
    dbms_output.put_line('ERROR: Conversion of decimal value = ' || to_char(v_decimal) || ' gave incorrect check value = ' || to_char(v_decimal_check));
  ELSE
    dbms_output.put_line('SUCCESS: Conversion of decimal value = ' || to_char(v_decimal) || ' gave correct check value = ' || to_char(v_decimal_check));
  END IF;
  dbms_output.put_line('BASETODEC Check base value converted back to decimal = ' || to_char(v_decimal_check));
  
  v_decimal :=-1;
  v_base_string := util_numeric.dectobase(v_decimal,v_base);
  dbms_output.put_line('DECTOBASE Decimal = ' || to_char(v_decimal) || ' BASE ' || to_char(v_base) || ' = ' || v_base_string);
  v_decimal_check := util_numeric.basetodec(v_base_string,v_base);
  IF v_decimal <> v_decimal_check THEN
    dbms_output.put_line('ERROR: Conversion of decimal value = ' || to_char(v_decimal) || ' gave incorrect check value = ' || to_char(v_decimal_check));
  ELSE
    dbms_output.put_line('SUCCESS: Conversion of decimal value = ' || to_char(v_decimal) || ' gave correct check value = ' || to_char(v_decimal_check));
  END IF;
  dbms_output.put_line('BASETODEC Check base value converted back to decimal = ' || to_char(v_decimal_check)); 
  
  v_decimal :=1000;
  v_base_string := util_numeric.dectobase(v_decimal,v_base);
  dbms_output.put_line('DECTOBASE Decimal = ' || to_char(v_decimal) || ' BASE ' || to_char(v_base) || ' = ' || v_base_string);
  v_decimal_check := util_numeric.basetodec(v_base_string,v_base);
  IF v_decimal <> v_decimal_check THEN
    dbms_output.put_line('ERROR: Conversion of decimal value = ' || to_char(v_decimal) || ' gave incorrect check value = ' || to_char(v_decimal_check));
  ELSE
    dbms_output.put_line('SUCCESS: Conversion of decimal value = ' || to_char(v_decimal) || ' gave correct check value = ' || to_char(v_decimal_check));
  END IF;
  dbms_output.put_line('BASETODEC Check base value converted back to decimal = ' || to_char(v_decimal_check));
  
  v_base_string := NULL;
  v_decimal := util_numeric.basetodec(v_base_string,v_base);
  dbms_output.put_line('BASETODEC ' || v_base_string || 'NULL Base ' || to_char(v_base) || ' Decimal = ' || to_char(v_decimal));
  
  v_base_string := '0';
  v_decimal := util_numeric.basetodec(v_base_string,v_base);
  dbms_output.put_line('BASETODEC ' || v_base_string || ' Base ' || to_char(v_base) || ' Decimal = ' || to_char(v_decimal));

  v_base_string := '-1';
  v_decimal := util_numeric.basetodec(v_base_string,v_base);
  dbms_output.put_line('BASETODEC ' || v_base_string || ' Base ' || to_char(v_base) || ' Decimal = ' || to_char(v_decimal));
  
  v_base_string := '111111';
  v_decimal := util_numeric.basetodec(v_base_string,v_base);
  dbms_output.put_line('BASETODEC ' || v_base_string || ' Base ' || to_char(v_base) || ' Decimal = ' || to_char(v_decimal));
  
  dbms_output.put_line('===============================================');
  dbms_output.put_line('The following conversions should give an ERROR.');
  dbms_output.put_line('===============================================');
  
  v_base_string := '1A2F3G';
  v_decimal := util_numeric.hextodec(v_base_string);
  dbms_output.put_line('HEXTODEC Hex = ' || v_base_string || ' Decimal = ' || to_char(v_decimal));
  
  v_base :=8;
  v_base_string := '17508';
  v_decimal := util_numeric.basetodec(v_base_string,v_base);
  dbms_output.put_line('BASETODEC ' || v_base_string || ' Base ' || to_char(v_base) || ' Decimal = ' || to_char(v_decimal));
  
END;