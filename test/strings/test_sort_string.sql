-- Test function to sort a string into ascending or descending sequence
SELECT 'the quick brown fox jumps over the lazy dog' "sentence",
util_string.sort_string('the quick brown fox jumps over the lazy dog','A') "sort ascending",
util_string.sort_string('the quick brown fox jumps over the lazy dog','D') "sort descending",
util_string.sort_string('the quick brown fox jumps over the lazy dog') "sort not specified default Asc"
FROM dual;