-- Check the current system date and time
-- Note the format for time is H24:MI
-- NOT H24:MM which would display hour and month!
--
SELECT to_char(sysdate,'DD/MM/RR HH24:MI:SS') FROM dual;