-- Test count_fields with CSV format table columns, used for data import.
SET SERVEROUTPUT ON
ACCEPT p_rows NUMBER DEFAULT 10 PROMPT "Enter number of rows to create in IMPORTCSV:"

DECLARE
  l_rowcount INTEGER :=1;
  l_keyval importcsv.key_value%TYPE;
  l_csv_field importcsv.csv_rec%TYPE;
  l_quote VARCHAR2(1);
  l_delim VARCHAR2(1) := ',';
  l_field_rand INTEGER;
  l_count NUMBER;
BEGIN
  l_rowcount := &p_rows;
  l_quote := chr(39);
  FOR i IN 1 .. l_rowcount LOOP
    l_keyval := 'COUNTTEST' || to_char(i);
    l_field_rand :=  abs(floor(dbms_random.normal*10))+1; -- random number between 1 and 10
    l_csv_field := 'START';
    FOR j IN 1 .. l_field_rand LOOP
      l_csv_field := l_csv_field || l_delim || to_char(j);
    END LOOP;
    l_csv_field := l_quote ||l_csv_field || l_quote;
    INSERT INTO importcsv (
      csv_rec,
      key_value
      )
      VALUES (
        l_csv_field,
        l_keyval
      );
  END LOOP;
  
  FOR rec_importcsv IN (SELECT key_value, csv_rec FROM importcsv) LOOP
    l_count := util_string.count_fields(rec_importcsv.csv_rec);
    dbms_output.put_line('Import key: ' || rec_importcsv.key_value || ' CSV record: ' || rec_importcsv.csv_rec || ' Field count = ' || to_char(l_count));
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Error: ' || SQLERRM);
END;