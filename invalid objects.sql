-- Check for invalid database objects
--
SELECT * FROM user_objects WHERE status <> 'VALID';