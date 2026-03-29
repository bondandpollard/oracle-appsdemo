/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : recompile_plsql_packages.sql
**
** DESCRIPTION
**   Recompile all packages
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 25/07/2022   Ian Bond      Created script
** 06/08/2022   Ian Bond      Include set_env.sql to define all environment variables.
** 06/03/2023   Ian Bond      Remove prompt for password as this is done in set_env.sql
** 05/04/2025   Ian Bond      Fix issues with directories containing spaces and special characters such as ampersands.
*/

-- Handle special characters e.g. ampersand & in directory names and strings
  SET ESCAPE ON
  
/*
 ***********************************************************
 *   IMPORTANT                                             *
 *   You must set v_app_root to the directory in which you *
 *   installed your application                            *
 ***********************************************************
*/

  DEFINE v_app_root = "D:\\USERS\\IANBO\\DOCUMENTS\\BUSINESS\\BOND \& POLLARD LTD\\ADMIN\\IT\\APPLICATIONS\\ORACLE\\DEMO\\XEPDB1\\APPSDEMO"
  
  @'&v_app_root\\config\\set_env'
  
  @'&v_app_home\\install\\compile_packages' "&v_dbservice" "&v_dbconnect" "&v_app_owner" "&v_pwd" "&v_app_home" "&v_connect_user"

