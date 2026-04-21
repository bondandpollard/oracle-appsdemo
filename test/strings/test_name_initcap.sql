-- Test function to format names in sentence case.
-- Handle names prefixed Mc, Mac etc.
select ename,
       util_string.name_initcap(ename) Name
from   emp
order by ename desc;