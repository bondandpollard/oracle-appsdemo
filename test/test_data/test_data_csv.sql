/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : test_data_csv.sql
**
** DESCRIPTION
**  This script creates data used to test the string functions that
**  extract fields from a delimited string.
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 30/06/2022   Ian Bond       Created script
*/
SET TERMOUT on
SET ECHO OFF

-- Semicolon Delimiter
INSERT INTO IMPORTCSV (CSV_REC) VALUES ('field1;field2;field3;field4;field5;field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES ('"field1";"field2";field3;"field4";field5;"field6"');
INSERT INTO IMPORTCSV (CSV_REC) VALUES ('"field1" ;"field2"; field3 ; "field4" ; "field5";field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES ('"field1" ;"field ;;;;;;2"; field"3 ; "field4" ; "field5";field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES ('"field1" ;"field ;;;;;;2; field"3 ; "field4" ; "field5";field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES ('"field1" ;"field ;;;;;;2"; "field"3" ; "field"""""4;f4" ; "field5";field6');


-- Comma Delimiter
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('field1,field2,field3,field4,field5,field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('"field1","field2",field3,"field4",field5,"field6"');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('"field1" ,"field2", field3 , "field4" , "field5",field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('"field1" ,"field ,,,;,,2", field"3 , "field4" , "field5",field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('"field1" ,"field ,,,,,,2, field"3 , "field4" , "field5",field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('"field1" ,"field ,,;,,,2", "field"3" , "field"""""4,f4" , "field5",field6');

-- Tab delimiter
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('field1'    ||CHR(9)|| 'field2'                     ||CHR(9)|| 'field3'      ||CHR(9)|| 'field4'           ||CHR(9)|| 'field5'   ||CHR(9)|| 'field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('"field1"'  ||CHR(9)|| '"field2"'                   ||CHR(9)|| 'field3'      ||CHR(9)|| '"field4"'         ||CHR(9)|| 'field5'   ||CHR(9)|| '"field6"');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('"field1"'  ||CHR(9)|| '"field2"'                   ||CHR(9)|| 'field3'      ||CHR(9)|| '"field4"'         ||CHR(9)|| '"field5"' ||CHR(9)|| 'field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('"field1"'  ||CHR(9)|| '"field ,,,;;;2"'            ||CHR(9)|| 'field"3'     ||CHR(9)|| '"field4"'         ||CHR(9)|| '"field5"' ||CHR(9)|| 'field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('"field1"'  ||CHR(9)|| '"field ,,,;;;2; field"3'                             ||CHR(9)|| '"field4"'         ||CHR(9)|| '"field5"' ||CHR(9)|| 'field6');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('"field1"'  ||CHR(9)|| '"field '||CHR(9)||',,,;;;2"'||CHR(9)|| '"field"3"'   ||CHR(9)|| '"field"""""4f4"'  ||CHR(9)|| '"field5"' ||CHR(9)|| 'field6');

-- Comma Delimiter: additional test data
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('102456,"Slotted Head Stainless Steel Screws, No 10, 2 1/4"",Box200,5.99');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('102533,"Slotted Head Stainless Steel Screws, No 10, 3"",Box200,6.50');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('102206,"Slotted Head Stainless Steel Screws, No 10, 3 1/4" ",Box200,7.99');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('104231,"Slotted Head Stainless Steel Screws, No 10, 3 1/2" ",Box200,8.49');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('109742,"Cross Head Steel Screws, No 10, 2"",Box100,3.99');
INSERT INTO IMPORTCSV (CSV_REC) VALUES  ('108555,"Cross Head Stainless Steel Screws, No 10, 2"",Box200,7.99');

COMMIT;
