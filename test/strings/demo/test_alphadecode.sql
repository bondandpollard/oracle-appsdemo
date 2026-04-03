-- Test_alphadecode
-- 1=A
-- 26=Z
-- 27=AA
-- 52=AZ
-- 53=BA
-- etc
SELECT :p1 || ' is decoded as integer ' "input"
,LENGTH(:p1) "length"
,demo_string.alphadecode(:p1) "decoded integer"
,' re-coded as : ' || demo_string.alphacode_calc(demo_string.alphadecode(LTRIM(:p1))) "check result"
FROM dual;
