-- Extra delimiter on end, use count_fields to fix this
SET SERVEROUTPUT ON

SELECT util_string.sort_list(',,,,Pear,Apple,Orange,,,,,,,,,,,,,,,,,,,Banana,Mango,Pineapple,Grape,Cherry,Peach,Kiwi Fruit,,,,,,,,,,,,,,,,,,Tomato,,,','A')
FROM dual
UNION ALL
SELECT util_string.sort_list(',,,,Pear,Apple,Orange,,,,,,,,,,,,,,,,,,,Banana,Mango,Pineapple,Grape,Cherry,Peach,Kiwi Fruit,,,,,,,,,,,,,,,,,,Tomato,,,','D')
FROM dual
UNION ALL
SELECT util_string.sort_list('Pear,Apple,Orange,Banana,Mango,Pineapple,Grape,Cherry,Peach,Kiwi Fruit','A')
FROM dual
UNION ALL
SELECT util_string.sort_list('Pear,Apple,Orange,Banana,Mango,Pineapple,Grape,Cherry,Peach,Kiwi Fruit')
FROM dual;

--SELECT util_string.sort_list('&p')
--FROM dual;