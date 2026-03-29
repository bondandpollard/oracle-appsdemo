-- Check the user's privileges and roles.
-- Ensure that the secondary connection schema is locked down
-- with limited privileges.

SELECT * FROM session_privs;

SELECT * FROM session_roles;