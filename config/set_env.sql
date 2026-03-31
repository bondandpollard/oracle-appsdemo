/* 
  NAME:    set_env.sql
  DESCRIPTION
           Created by setup to configure the Oracle application environent.
  SECURITY WARNING 
           You must keep the application owner/schema password secure. Do not allow any users
           or applications to connect to the database as the application owner.
           A separate connection user has been created for applications to
           connect to the database with.
  INSTRUCTIONS
           The setup program generates this script setting the following parameters:
           V_DBSERVICE    Database Service name, e.g. XEPDB1, or XEDEV, XEPROD etc.
           V_APP_OWNER    Application owner/schema e.g. APPSDEMO.
           V_PWD          Password for the application owner schema.
                          See security warning above.
           V_CONNECT_USER Users and applications connect to the database as this user, e.g. DEMO_CONNECT. 
                          This user does not own the application's schema objects, and has limited privileges.
           V_CONNECT_PWD  Password for V_CONNECT_USER.
           V_PORT         Oracle database listener port, default 1521.
           V_DBCONNECT    Connect to DB Service.
           V_APP_HOME     Application home directory path.
           V_DATA_HOME    Data home directory path (import / export, user files etc.)
*/
SET ESCAPE ON
DEFINE v_dbservice = XEPDB1
DEFINE v_app_owner = APPSDEMO
ACCEPT v_pwd PROMPT "Enter the password for APPSDEMO: " 
DEFINE v_connect_user = DEMO_CONNECT
ACCEPT v_connect_pwd PROMPT "Enter the password for the database connection user DEMO_CONNECT: " 
DEFINE v_port = 1521
DEFINE v_dbconnect = //localhost:1521/XEPDB1
-- Application Home directory.
-- Note that where directory names contain a special character such as &, you must precede each special character with the \ escape character.
-- You will need to SET ESCAPE ON first.
-- The directory name separator \ will also need to be preceded by a \ escape character.
DEFINE v_app_home = "d:\\users\\ianbo\\documents\\business\\bond \& pollard ltd\\admin\\it\\applications\\oracle\\demo\\XEPDB1\\APPSDEMO"
-- Data Home directory.
-- This is the location of the user data directories.
-- Do not include spaces or special characters such as & in the directory name.
DEFINE v_data_home = "d:\\user_data\\XEPDB1\\APPSDEMO\\data"
