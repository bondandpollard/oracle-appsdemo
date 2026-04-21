/*
** Copyright (c) 2023 Bond & Pollard Ltd. All rights reserved.  
** NAME   : unlock_schema.sql
**
** DESCRIPTION
**
**  Unlock a Schema to allow development.
**  Allow authentication for the user by setting a password.
**
** USAGE
**
** >sqlplus sys/[password]@//localhost/freepdb1 as sysdba @unlock_schema
**
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 16/04/2023   Ian Bond      Created script
*/
ACCEPT username PROMPT "Enter name of user to unlock: "
ALTER USER &username ACCOUNT UNLOCK;
ACCEPT v_pwd PROMPT "Create a new password:"
ALTER USER &username IDENTIFIED BY &V_PWD;



