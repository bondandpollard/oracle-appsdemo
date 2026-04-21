-- Test function to:
--   Replace \n with ASCII char 10 (new line)
--   Replace \t with ASCII char 9  (tab)
--   Replace \r with ASCII char 13 (Carriage Return)
--
-- To test this function, enter a string e.g.
-- "Line 1 \n\r Line 2 \t\tText follows 2 tabs \n\r Line 3"
--
-- Paste the resulting output string into text editor, such as Notepad, and the text should
-- now be formatted with newlines, carriage returns and tabs
/*
[Line 1 

 Line 2 		Text follows 2 tabs 

 Line 3]
*/
SELECT :p_input "input string"
, '['||util_string.textconvert(:p_input)||']' "output string"
, ASCII(substr(util_string.textconvert(:p_input),instr(util_string.textconvert(:p_input),CHR(10),1))) "char 10 \n of output ascii"
, decode(instr(util_string.textconvert(:p_input),CHR(10)),0,'NOT FOUND','FOUND') "New line Found"
, ASCII(substr(util_string.textconvert(:p_input),instr(util_string.textconvert(:p_input),CHR(9),1))) "char 9  \t of output ascii"
, decode(instr(util_string.textconvert(:p_input),CHR(9)),0,'NOT FOUND','FOUND') "Tab Found"
, ASCII(substr(util_string.textconvert(:p_input),instr(util_string.textconvert(:p_input),CHR(13),1))) "carriage return \r is ascii 13"
, decode(instr(util_string.textconvert(:p_input),CHR(13)),0,'NOT FOUND','FOUND') "Carriage return found"
, LENGTH(:p_input) "length"
FROM dual;