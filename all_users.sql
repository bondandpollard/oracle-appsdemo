-- Report users

select name,
       ctime,
       ptime,
       exptime,
       spare6
from   user$
where spare6 is not null
order by name;
 

