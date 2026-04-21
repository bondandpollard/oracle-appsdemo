-- Find users with expired passwords
SELECT username, account_status
FROM dba_users
WHERE account_status LIKE '%EXPIRED%';