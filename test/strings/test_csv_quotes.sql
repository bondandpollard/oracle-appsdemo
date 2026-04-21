-- test_csv_quotes
-- Test get_field function handles embedded quotes correctly
-- e.g. 
-- 12345,04/04/1969,"This is the title: "Subtitle"",123.45
-- The 3rd field has a double quote as its final character that must be included in the string
--    This is the title: "Subtitle"
--
SET SERVEROUTPUT ON
SELECT csv_rec, 
       util_string.get_field(csv_rec,1,','),
       util_string.get_field(csv_rec,2,','),
       util_string.get_field(csv_rec,3,',')
FROM importcsv 
WHERE filename LIKE '%quote%';

