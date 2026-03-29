/*
** Copyright (c) 2023 Bond & Pollard Ltd. All rights reserved.  
** NAME   : create_developer.sql
**
** DESCRIPTION
**
**   Create a user with developer privileges for the owning schema. 
**
**
**   Connect as user SYS as SYSDBA to run this script.
**   Create the user
**   Grant privileges to user (tables, views, packages, directories)
**
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 20/04/2023   Ian Bond      Created script
** 12/03/2025   Ian Bond      Amend to prompt for owning schema name etc.
*/

ACCEPT v_owner PROMPT "Enter the schema owner name: "
ACCEPT v_owner_pwd PROMPT "Enter password for schema owner: "
ACCEPT v_user PROMPT "Enter the username to be created: "
ACCEPT v_user_pwd PROMPT "Enter a password for the user: "

-- Create the user
DROP USER &v_user CASCADE;
CREATE USER &v_user IDENTIFIED BY &v_user_pwd;

GRANT CONNECT, CREATE SYNONYM TO &v_user;

-- Grant user access to Directories
GRANT READ, WRITE ON DIRECTORY data_in TO &v_user;
GRANT READ, WRITE ON DIRECTORY data_in_error TO &v_user;
GRANT READ, WRITE ON DIRECTORY data_in_processed TO &v_user;
GRANT READ, write ON DIRECTORY data_out to &v_user;

-- Grant user access to UTL_FILE package
GRANT EXECUTE ON sys.utl_file TO &v_user;

connect &v_owner/&v_owner_pwd
-- Grant user access to tables
--
GRANT DELETE, INSERT, SELECT, UPDATE ON applog TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON appseverity TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON bonus TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON appsdemo.country TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON country_holiday TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON customer TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON demo TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON dept TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON dummy TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON emp TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON importcsv TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON importerror TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON item TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON ord TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON price TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON product TO &v_user;
GRANT DELETE, INSERT, SELECT, UPDATE ON salgrade TO &v_user;

-- Views
GRANT SELECT ON sales to &v_user;



-- Grant user access to owner packages
GRANT EXECUTE ON demo_string TO &v_user;
GRANT EXECUTE ON export TO &v_user;
GRANT EXECUTE ON import TO &v_user;
GRANT EXECUTE ON orderrp TO &v_user;
GRANT EXECUTE ON plsql_constants TO &v_user;
GRANT EXECUTE ON util_admin TO &v_user;
GRANT EXECUTE ON util_date TO &v_user;
GRANT EXECUTE ON util_file TO &v_user;
GRANT EXECUTE ON util_numeric TO &v_user;
GRANT EXECUTE ON util_string TO &v_user;


CONNECT  &v_user/&v_user_pwd

-- Create synonyms for owner tables

-- NB: sql*plus handles escape character substitution differently
-- so this works in sql*plus with SET ESCAPE ON: 
-- CREATE SYNONYM applog FOR &v_owner\.applog;
-- SQL Developer expects the following format:
CREATE SYNONYM applog FOR &v_owner..applog;
CREATE SYNONYM appseverity FOR &v_owner..appseverity;
CREATE SYNONYM bonus FOR &v_owner..bonus;
CREATE SYNONYM country FOR &v_owner..country;
CREATE SYNONYM country_holiday FOR &v_owner..country_holiday;
CREATE SYNONYM customer FOR &v_owner..customer;
CREATE SYNONYM demo FOR &v_owner..demo;
CREATE SYNONYM dept FOR &v_owner..dept;
CREATE SYNONYM dummy FOR &v_owner..dummy;
CREATE SYNONYM emp FOR &v_owner..emp;
CREATE SYNONYM importcsv FOR &v_owner..importcsv;
CREATE SYNONYM importerror FOR &v_owner..importerror;
CREATE SYNONYM item FOR &v_owner..item;
CREATE SYNONYM ord FOR &v_owner..ord;
CREATE SYNONYM price FOR &v_owner..price;
CREATE SYNONYM product FOR &v_owner..product;
CREATE SYNONYM salgrade FOR &v_owner..salgrade;

-- Create synonyms for PL/SQL packages
CREATE SYNONYM demo_string FOR &v_owner..demo_string;
CREATE SYNONYM export FOR &v_owner..export;
CREATE SYNONYM import FOR &v_owner..import;
CREATE SYNONYM orderrp FOR &v_owner..orderrp;
CREATE SYNONYM plsql_constants FOR &v_owner..plsql_constants;
CREATE SYNONYM util_admin FOR &v_owner..util_admin;
CREATE SYNONYM util_date FOR &v_owner..util_date;
CREATE SYNONYM util_file FOR &v_owner..util_file;
CREATE SYNONYM util_numeric FOR &v_owner..util_numeric;
CREATE SYNONYM util_string FOR &v_owner..util_string;




