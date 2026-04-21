/*
Fix issues with TNSLISTENER

PROBLEM
The listener is running, you can connect to the pluggabe database via sqlplus command line and all OK,
but you cannot connect using the client tools such as SQL Developer.

DIAGNOSTIC
C:\Users\ianbo>lsnrctl status

LSNRCTL for 64-bit Windows: Version 23.26.1.0.0 - Production on 15-APR-2026 16:49:09

Copyright (c) 1991, 2026, Oracle.  All rights reserved.

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=BONDPOLLARD.lan)(PORT=1521)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for 64-bit Windows: Version 23.26.1.0.0 - Production
Start Date                15-APR-2026 16:48:16
Uptime                    0 days 0 hr. 0 min. 53 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Default Service           FREE
Listener Parameter File   C:\app\ianbo\product\26ai\dbhomeFree\network\admin\listener.ora
Listener Log File         C:\app\ianbo\product\26ai\diag\tnslsnr\BONDPOLLARD\listener\alert\log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=BONDPOLLARD)(PORT=1521)))
The listener supports no services

CAUSE
Your database is not registering itself with the listener correctly.
Root misconfiguration:
local_listener = LISTENER_FREE (an alias that doesn’t resolve correctly in your setup)
Listener is actually running on BONDPOLLARD.lan:1521
So the database is trying to register with the wrong/undefined target

Result: no service registration → intermittent connectivity

FIX
Run the following commands as SYS with SYSDBA priv.
then restart the Listener.
Services, find Oracle TNSListener, right click, select restart.
*/
show parameter local_listener;
alter system set local_listener ='(ADDRESS=(PROTOCOL=TCP)(HOST=localhost)(PORT=1521))'scope=both;
alter system register;
show parameter local_listener;


