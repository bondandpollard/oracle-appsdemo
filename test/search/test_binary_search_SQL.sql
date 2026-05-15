-- test_binary_search_SQL
-- Not logarithmic search.
-- This is how to find the rightmost value in a list of values selected from 
-- a table in SQL.
-- For each EMP sort SAL and select last row matching target (rightmost)

SELECT sal
FROM emp
ORDER BY sal;

-- Rightmost (last matching value)
SELECT MAX(pos)
FROM (
  SELECT sal,
          ROW_NUMBER() OVER (ORDER BY sal) AS pos
  FROM emp
)
WHERE sal = :target
;
--FETCH FIRST 1 ROW ONLY;