-- Get current user info

SELECT * FROM v$session 
WHERE username = (SELECT sys_context('USERENV', 'CURRENT_USER') FROM dual);

