-- Test script for CSV functions
SELECT * FROM importcsv;

-- The GET_FIELD function can handle spaces between the fields and delimiters
--
SELECT csv_rec, decode(util_string.get_delimiter(csv_rec),CHR(9),'TAB',util_string.get_delimiter(csv_rec)) delimiter,
 util_string.get_field(csv_rec,1,util_string.get_delimiter(csv_rec)) AS f1,
 util_string.get_field(csv_rec,2,util_string.get_delimiter(csv_rec)) AS f2,
 util_string.get_field(csv_rec,3,util_string.get_delimiter(csv_rec)) AS f3,  
 util_string.get_field(csv_rec,4,util_string.get_delimiter(csv_rec)) AS f4,
 util_string.get_field(csv_rec,5,util_string.get_delimiter(csv_rec)) AS f5,
 util_string.get_field(csv_rec,6,util_string.get_delimiter(csv_rec)) AS f6,
 util_string.get_field(csv_rec,7,util_string.get_delimiter(csv_rec)) AS f7
FROM importcsv;

-- This function is confused by miltiple spaces between delimiters and fields
--
SELECT csv_rec, decode(util_string.get_delimiter(csv_rec),CHR(9),'TAB',util_string.get_delimiter(csv_rec)) delimiter,
 util_string.get_field_nospace(csv_rec,1,util_string.get_delimiter(csv_rec)) AS f1,
 util_string.get_field_nospace(csv_rec,2,util_string.get_delimiter(csv_rec)) AS f2,
 util_string.get_field_nospace(csv_rec,3,util_string.get_delimiter(csv_rec)) AS f3,  
 util_string.get_field_nospace(csv_rec,4,util_string.get_delimiter(csv_rec)) AS f4,
 util_string.get_field_nospace(csv_rec,5,util_string.get_delimiter(csv_rec)) AS f5,
 util_string.get_field_nospace(csv_rec,6,util_string.get_delimiter(csv_rec)) AS f6,
 util_string.get_field_nospace(csv_rec,7,util_string.get_delimiter(csv_rec)) AS f7
FROM importcsv;


-- Test GET_DELIMITER
SELECT csv_rec, decode(util_string.get_delimiter(csv_rec),CHR(9),'TAB',util_string.get_delimiter(csv_rec)) "Delimiter Detected" FROM importcsv;

SELECT util_string.get_field('field1,field2,"fie"x"y;s"ld" v;3","123,45"',4,',') FROM dual;
SELECT util_string.get_field('field1;field2;"fie"x"y;s"ld" v;3";"123,45"',4,';') FROM dual;
SELECT util_string.get_field('"Field;; 1";   "Field;2";"Field"3";"FIELD 4"";"Field 5"',:p_col,';') RESULT 
FROM dual;


SELECT util_string.get_field(csv_rec,1,','), 
util_string.get_field(csv_rec,2,','),
util_string.get_field(csv_rec,3,','),
util_string.get_field(csv_rec,4,',')
FROM importcsv;