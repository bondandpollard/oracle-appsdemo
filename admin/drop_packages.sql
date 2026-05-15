/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : drop_packages.sql
**
** DESCRIPTION
**   Recompile all packages
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 06/04/2026   Ian Bond      Created script.
** 15/05/2026   Ian Bond      Add new packages plsql_types, search, stats
*/

DROP PACKAGE EXPORT;
DROP PACKAGE IMPORT;
DROP PACKAGE ORDERRP;
DROP PACKAGE PLSQL_CONSTANTS;
DROP PACKAGE PLSQL_TYPES;
DROP PACKAGE SEARCH;
DROP PACKAGE STATS;
DROP PACKAGE UTIL_ADMIN;
DROP PACKAGE UTIL_DATE;
DROP PACKAGE UTIL_FILE;
DROP PACKAGE UTIL_NUMERIC;
DROP PACKAGE UTIL_STRING;
