-- Test GET_FIELD field extract

SET SERVEROUTPUT ON
DECLARE 
  l_result VARCHAR2(32767);
  l_test_rec VARCHAR2(1000);
  l_field_count NUMBER;
  m NUMBER;
BEGIN
  
  l_test_rec := '"Field1",Field2,"Field,3","Field "4","Field5","LAST FIELD 6"';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := '"Field1",      Field2,       "Field,3","Field "4","Field5",            "LAST FIELD 6"';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := NULL;
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := ',';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := ',,,,,,,,,,';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := ',,,,,"FIELD",,,,,';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := ',"Field 2"';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := '1';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := '"Field1",Field2,"Field,3","Field "4",Field5","LAST FIELD 6"';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := '104231,"Slotted Head Stainless Steel Screws, No 10, 3 1/2" ",Box200,8.49,LAST FIELD';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := ',FIELD 2, "FIELD 3", FIELD 4, LAST FIELD 5';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := ',,FIELD 3, "FIELD 4", FIELD 5, LAST FIELD 6';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  l_test_rec := ',,,,,,FIELD 7, "FIELD 8", FIELD 9, LAST FIELD 10';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;

  l_test_rec := '"!","2"",,,,FIELD 6, "FIELD 7", FIELD 8,,"SECOND LAST FIELD #10 LAST IS NULL!",';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  -- EDGE CASE FAIL if first field NULL.
  l_test_rec := ',"!","3"",,,,FIELD 7, "FIELD 8", FIELD 9,,,,,"FIELD #14 SIX NULL FIELDS FOLLOW",,,,,,';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  -- EDGE CASE FAIL if first field NULL **** First char in str in a delim, so first first should be treated as NULL, not all chars to next delim ****
  l_test_rec := ',,"!","4"",,,,FIELD 8, "FIELD 9", FIELD 10,,,,,"LAST FIELD 15"';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || l_field_count);
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  -- EDGE CASE FAIL if first field NULL **** First char in str in a delim, so first first should be treated as NULL, not all chars to next delim ****
  l_test_rec := ',,,FIELD 4,"FIELD 5",,"FIELD 7"';
  l_field_count := util_string.count_fields(l_test_rec);
  util_admin.log_message('Test Record=' || l_test_rec);
  util_admin.log_message('Field Count=' || to_char(l_field_count)); 
  FOR m IN 1 .. l_field_count LOOP
    util_admin.log_message('Position of delim(' || to_char(m) || ') =' || to_char(util_string.delimiter_position(l_test_rec,1,m,',')));
  END LOOP;
  FOR m IN 1 .. l_field_count LOOP
   util_admin.log_message('Field '|| to_char(m) || '=' ||   util_string.get_field(l_test_rec, m, ','));
  END LOOP;
  
  
  
END;