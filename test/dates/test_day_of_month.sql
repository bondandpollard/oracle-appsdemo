-- Test functions to return dates of first and last occurrence of a specified day of the week
-- For example, the date of the first and last Wednesday in the month containing the specified date.
SELECT :p_dayno "week day",
util_date.dayname(util_date.month_day_first(add_months(sysdate,:p_month),:p_dayno)) "Day",
util_date.month_day_first(add_months(sysdate,:p_month),:p_dayno) "first date in month" ,
util_date.month_day_last(add_months(sysdate,:p_month),:p_dayno) "last date in month"
FROM dual;