-- Test CSV field extract using data from table IMPORTCSV.
-- To populate IMPORTCSV with test data run test\test data\test_data_csv.sql

DECLARE  
  l_delim VARCHAR2(1) := ',';
  l_field1 VARCHAR2(100);
  l_field2 VARCHAR2(100);
  l_field3 VARCHAR2(100);
  l_field4 VARCHAR2(100);
  l_field5 VARCHAR2(100);
  l_csv_rec importcsv.csv_rec%TYPE;
BEGIN
  
  FOR rec_importcsv IN (SELECT key_value, csv_rec FROM importcsv) LOOP
    -- detect delimiter.
    l_csv_rec := rec_importcsv.csv_rec;
    l_field1 := util_string.get_field(l_csv_rec,1,l_delim);
    l_field2 := util_string.get_field(l_csv_rec,2,l_delim);
    l_field3 := util_string.get_field(l_csv_rec,3,l_delim);
    l_field4 := util_string.get_field(l_csv_rec,4,l_delim);
    l_field5 := util_string.get_field(l_csv_rec,5,l_delim);
    dbms_output.put_line('CSV Rec=' || l_csv_rec);
    dbms_output.put_line(' >>>>>>>>>> field 1 =' || l_field1);
    dbms_output.put_line(' >>>>>>>>>> field 2 =' || l_field2);
    dbms_output.put_line(' >>>>>>>>>> field 3 =' || l_field3);
    dbms_output.put_line(' >>>>>>>>>> field 4 =' || l_field4);
    dbms_output.put_line(' >>>>>>>>>> field 5 =' || l_field5);
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line('Error: ' || SQLERRM);
END;