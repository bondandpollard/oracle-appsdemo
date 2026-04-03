/*
** Copyright (c) 2023 Bond & Pollard Ltd. All rights reserved.  
** NAME   : demo_connect_user.sql
**
** DESCRIPTION
**
**   THIS IS A TEST SCRIPT.
**
**   Create demo_connect user for applications to connect to the 
**   database with the minimum necessary privileges.
**
**   The schema that owns the database objects must not be used by applications
**   and users, as it is would be a major security flaw. Anyone could easily
**   alter or drop tables or other objects.
**
**   Connect as user SYS as SYSDBA to run this script.
**   Create public synonyms for tables, views, packages
**   Create the demo_connect user
**   Grant privileges to demo_connect (tables, views, packages, directories)
**
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 05/03/2023   Ian Bond      Created script
*/

-- Public synonyms for Tables
CREATE OR REPLACE PUBLIC SYNONYM applog FOR appsdemo.applog;
CREATE OR REPLACE PUBLIC SYNONYM appseverity FOR appsdemo.appseverity;
CREATE OR REPLACE PUBLIC SYNONYM bonus FOR appsdemo.bonus;
CREATE OR REPLACE PUBLIC SYNONYM country FOR appsdemo.country;
CREATE OR REPLACE PUBLIC SYNONYM country_holiday FOR appsdemo.country_holiday;
CREATE OR REPLACE PUBLIC SYNONYM customer FOR appsdemo.customer;
CREATE OR REPLACE PUBLIC SYNONYM demo FOR appsdemo.demo;
CREATE OR REPLACE PUBLIC SYNONYM dept FOR appsdemo.dept;
CREATE OR REPLACE PUBLIC SYNONYM dummy FOR appsdemo.dummy;
CREATE OR REPLACE PUBLIC SYNONYM emp FOR appsdemo.emp;
CREATE OR REPLACE PUBLIC SYNONYM importcsv FOR appsdemo.importcsv;
CREATE OR REPLACE PUBLIC SYNONYM importerror FOR appsdemo.importerror;
CREATE OR REPLACE PUBLIC SYNONYM item FOR appsdemo.item;
CREATE OR REPLACE PUBLIC SYNONYM ord FOR appsdemo.ord;
CREATE OR REPLACE PUBLIC SYNONYM price FOR appsdemo.price;
CREATE OR REPLACE PUBLIC SYNONYM product FOR appsdemo.product;
CREATE OR REPLACE PUBLIC SYNONYM salgrade FOR appsdemo.salgrade;

-- Public synonyms for Views
CREATE OR REPLACE PUBLIC SYNONYM sales FOR appsdemo.sales;

-- Public synonyms for Packages
CREATE OR REPLACE PUBLIC SYNONYM utl_file FOR sys.utl_file;

CREATE OR REPLACE PUBLIC SYNONYM demo_string FOR appsdemo.demo_string;
CREATE OR REPLACE PUBLIC SYNONYM export FOR appsdemo.export;
CREATE OR REPLACE PUBLIC SYNONYM import FOR appsdemo.import;
CREATE OR REPLACE PUBLIC SYNONYM orderrp FOR appsdemo.orderrp;
CREATE OR REPLACE PUBLIC SYNONYM plsql_constants FOR appsdemo.plsql_constants;
CREATE OR REPLACE PUBLIC SYNONYM util_admin FOR appsdemo.util_admin;
CREATE OR REPLACE PUBLIC SYNONYM util_date FOR appsdemo.util_date;
CREATE OR REPLACE PUBLIC SYNONYM util_file FOR appsdemo.util_file;
CREATE OR REPLACE PUBLIC SYNONYM util_numeric FOR appsdemo.util_numeric;
CREATE OR REPLACE PUBLIC SYNONYM util_string FOR appsdemo.util_string;


-- Create the demo_connect user
DROP USER demo_connect CASCADE;

CREATE USER demo_connect IDENTIFIED BY mydemo23;

GRANT CONNECT TO demo_connect;

-- Grant demo_connect access to appdsemo tables
-- Need to create tables and public synonyms first
--
GRANT DELETE, INSERT, SELECT, UPDATE ON applog TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON appseverity TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON bonus TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON appsdemo.country TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON country_holiday TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON customer TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON demo TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON dept TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON dummy TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON emp TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON importcsv TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON importerror TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON item TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON ord TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON price TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON product TO demo_connect;
GRANT DELETE, INSERT, SELECT, UPDATE ON salgrade TO demo_connect;

-- Views
GRANT SELECT ON appsdemo.sales to demo_connect;

-- Grant demo_connect access to UTL_FILE package
GRANT EXECUTE ON sys.utl_file TO demo_connect;

-- Grant demo_connect access to appsdemo packages
GRANT EXECUTE ON appsdemo.demo_string TO demo_connect;
GRANT EXECUTE ON appsdemo.export TO demo_connect;
GRANT EXECUTE ON appsdemo.import TO demo_connect;
GRANT EXECUTE ON appsdemo.orderrp TO demo_connect;
GRANT EXECUTE ON appsdemo.plsql_constants TO demo_connect;
GRANT EXECUTE ON appsdemo.util_admin TO demo_connect;
GRANT EXECUTE ON appsdemo.util_date TO demo_connect;
GRANT EXECUTE ON appsdemo.util_file TO demo_connect;
GRANT EXECUTE ON appsdemo.util_numeric TO demo_connect;
GRANT EXECUTE ON appsdemo.util_string TO demo_connect;

-- Grant demo_connect access to Directories
GRANT READ, WRITE ON DIRECTORY data_in TO demo_connect;
GRANT READ, WRITE ON DIRECTORY data_in_error TO demo_connect;
GRANT READ, WRITE ON DIRECTORY data_in_processed TO demo_connect;
GRANT READ, write ON DIRECTORY data_out to demo_connect;




