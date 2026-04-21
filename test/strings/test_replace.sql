-- Test a custom version of the string replace function
-- Replace all occurrences of a string with a new string.
-- Result should match Oracle function.
-- 
-- Test case 1
-- Original String : "The quick brown fox who is quick jumps quickly over the dog who is not so quick."
-- Replace What : "e"
-- Replace With : "superduper"
--
-- Test case 2 null replace with
-- Original String : "There was a man called Lee"
-- Replace What : "e"
-- Replace With : ""
--
-- Test case 3 repeating same letter 
-- Original String : "There was a man called Lee"
-- Replace What : "e"
-- Replace With : "eee"

SELECT :sentence "Original String"
, util_string.REPLACE(:sentence,:replace_this,:with_this) "My version of REPLACE is first row, Oracle second row"
FROM dual
UNION ALL
SELECT :sentence "Original String"
, REPLACE(:sentence,:replace_this,:with_this) "REPLACE Function"
FROM dual;

