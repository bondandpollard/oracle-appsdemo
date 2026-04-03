/* NAME:    auto_install.sql 
   DESCRIPTION
            Created by setup to automatically:
            1. Create schema (tables, indexes, constraints, triggers etc).
            2. Create a connection user with restricted privileges.
            3. Load seed data into the database tables.
            4. Compile all packages.
*/ 
-- Handle special characters e.g. ampersand & in directory names and strings.
-- You must escape the directory delimiters so use \\ not \ 
SET ESCAPE ON
DEFINE v_app_root="d:\\users\\ianbo\\documents\\business\\bond \& pollard ltd\\admin\\it\\applications\\oracle\\demo\\XEPDB1\\APPSDEMO"
@'&v_app_root\\config\\set_env'
ACCEPT v_sys_pwd CHAR PROMPT 'Enter SYS password: '
CONNECT SYS/&v_sys_pwd@&v_dbconnect AS SYSDBA
@'&v_app_home\\install\\install_schema'     "&v_dbservice" "&v_dbconnect" "&v_app_owner" "&v_pwd" "&v_connect_user" "&v_connect_pwd" "&v_app_home" "&v_data_home" 
@'&v_app_home\\install\\seed_data'          "&v_dbservice" "&v_dbconnect" "&v_app_owner" "&v_pwd"  
@'&v_app_home\\install\\compile_packages'   "&v_dbservice" "&v_dbconnect" "&v_app_owner" "&v_pwd" "&v_app_home" "&v_connect_user"  "&v_connect_pwd" 
@'&v_app_home\\install\\lock_schema'        "&v_dbservice" "&v_dbconnect" "&v_app_owner" "&v_sys_pwd" 
EXIT
