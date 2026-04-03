/*
** Copyright (c) 2023 Bond & Pollard Ltd. All rights reserved.  
** NAME   : lock_schema.sql
**
** DESCRIPTION
**
**  Lock the Owning Schema to prevent connections by malicious users.
**  Set to No Authentication, so no password is required.
**  Instead of getting a message saying the account is locked, which would give 
**  away its existence and importance, anyone attempting to connect as this user 
**  gets an invalid username/password error.
**
** USAGE
**
** >sqlplus sys/[password]@//localhost/xepdb1 as sysdba @lock_owning_schema
**
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 16/04/2023   Ian Bond      Created script
*/

  CONNECT SYS/&v_sys_pwd@&v_dbconnect AS SYSDBA
  ALTER USER &v_app_owner ACCOUNT LOCK;
  ALTER USER &v_app_owner NO AUTHENTICATION;






