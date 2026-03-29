/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : set_directories.sql
**
** DESCRIPTION
**   Set the data directory paths for the application
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 23/07/2022   Ian Bond      Created script
** 06/03/2023   Ian Bond      Add grants for database connection user
** 05/04/2023   Ian Bond      Fix issues with directories containing spaces and special characters such as ampersands.
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
  
  CONNECT SYS@&v_dbconnect AS SYSDBA

/*
 ********************************************************************************************************  
 * Set the user data directory paths here. The paths apply globally to all schemas in the database.     *
 * NB: The directory path must be in uppercase, or you get the error ORA-29280 Invalid Directory Path   *
 ********************************************************************************************************
*/

  DEFINE v_data_in_dir  = "&v_data_home\\DATA_IN"
  DEFINE v_data_out_dir = "&v_data_home\\DATA_OUT"
  
  CREATE OR REPLACE DIRECTORY data_in AS '&v_data_in_dir';
  GRANT READ, WRITE ON DIRECTORY data_in TO &v_app_owner;
  GRANT READ, WRITE ON DIRECTORY data_in TO &v_connect_user;
  
  CREATE OR REPLACE DIRECTORY data_in_error AS '&v_data_in_dir\\ERROR';
  GRANT READ, WRITE ON DIRECTORY data_in_error TO &v_app_owner;
  GRANT READ, WRITE ON DIRECTORY data_in_error TO &v_connect_user;
   
  CREATE OR REPLACE DIRECTORY data_in_processed AS '&v_data_in_dir\\PROCESSED';
  GRANT READ, WRITE ON DIRECTORY data_in_processed TO &v_app_owner;
  GRANT READ, WRITE ON DIRECTORY data_in_processed TO &v_connect_user;

  CREATE OR REPLACE DIRECTORY data_out AS '&v_data_out_dir';
  GRANT WRITE ON DIRECTORY data_out TO &v_app_owner;
  GRANT WRITE ON DIRECTORY data_out TO &v_connect_user;
  
  COLUMN directory_path FORMAT A70
  COLUMN directory_name FORMAT A30
  SELECT directory_name, directory_path FROM dba_directories
  WHERE origin_con_id <> 1;
  