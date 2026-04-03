-- Test error handling in base conversion functions
set serveroutput on
select util_numeric.basetodec('&p',16) from dual;
select util_numeric.hextodec('&p') from dual;
