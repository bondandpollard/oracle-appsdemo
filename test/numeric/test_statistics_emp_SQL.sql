-- test_statistics_emp_SQL
-- Use to check that the statistical functions in UTIL_NUMERIC
-- give the same results as SQL.
-- Run test_statistics_emp.sql to cross-check results.
-- Also run procedure EMP_STATS which uses the UTIL_NUMERIC package
-- to generate stats.
select sal, count(sal), sal*count(sal) TOTAL from emp
group by sal
order by sal;

ACCEPT p_pct NUMBER PROMPT "Enter Percentile a number > 0 and <=1"

select sum(sal) SUM
,count(sal) COUNT
,avg(sal) MEAN
,median(sal) MEDIAN
,min(sal) LOWEST
,max(sal) HIGHEST
,max(sal) - min(sal) RANGE
,var_pop(sal) VAR_POP
,var_samp(sal) VAR_SAMP
,stddev_pop(sal) STDDEV_POP
,stddev_samp(sal) STDDEV_SAMP
,PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY sal) - PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY sal) IQR
,PERCENTILE_DISC(&p_pct) WITHIN GROUP (ORDER BY sal) PERCENTILE_DISC
,PERCENTILE_CONT(&p_pct) WITHIN GROUP (ORDER BY sal) PERCENTILE_CONT
from emp;


-- Mode
Select sal, count(sal) from emp group by sal order by count(sal);


