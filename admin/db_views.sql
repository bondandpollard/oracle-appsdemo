-- Top Ten Oracle V$ Views for DBAs.
-- There are over 800 V$ views, these are the most useful.
-- NB: You must be connected to a user with SYSTEM privileges.

-- V$SESSION
-- This is the most important view to start with when checking your database.
-- Most of the information you need is here in one easy-to-mine view.
-- Start here when looking into performance problems.
-- It gives a list of all users connected to the database, including
-- users, applications and connection pools.
-- Shows if the user is active, how long they have been active for, and gives 
-- snapshots of other views such as wait events. 
select * from v$session;

-- V$DATABASE
-- Get a quick view of the database setup.
-- Is archivelog turned on? It should be on in your production environment.
select * from v$database;

-- V$DATAFILE
-- List the database physical files.
select * from v$datafile;

-- V$INSTANCE
-- The database processes and memory structures running on a node (computer).
-- Node name, version, are logins allowed etc.
select * from v$instance;

-- V$LOCK
-- Shows you what resources are locked, whether they're blocking other users.
-- This is the lcoks on resources not rows. I may have 1000 rows locked, but
-- this view will contain a single entry for these locks.
select * from v$lock;

-- V$PARAMETER
-- This family of views shows how your database has been configured and 
-- whether the default values have been changed. It may help you track down
-- the root cause of performance issues where a parameter has been changed.
select * from v$parameter;
select * from v$parameter2;
select * from v$spparameter;

-- V$SESSTAT & V$STATNAME
-- V$SESSTAT will show the metrics for your current session, number of reads,
-- commits etc.
-- You need to join to V$STATNAME to get a meaningful description of the operation.
-- Rule of Thumb: Massive numbers are areas worth investigating.
select s.sid,
       s.statistic#,
       n.name,
       s.value,
       s.con_id 
from   v$sesstat s,
       v$statname n
where  n.statistic# = s.statistic#;

-- V$MYSTAT
-- Gives statistics for your current session.
select s.sid,
       s.statistic#,
       n.name,
       s.value,
       s.con_id 
from   v$mystat s,
       v$statname n
where  n.statistic# = s.statistic#;

-- V$SESSION_EVENT
-- Tracks wait events that cause processes to wait for CPU time.
-- It could be IO, locks or some other issue.
-- When a user complains about poor system performace then look
-- at their sessions statistics here.
select * from v$session_event;

-- V$ACTIVE_SESSION_HISTORY
-- Tracks every session, all the time and stores this information in the 
-- System Global Area.
-- This information will help you diagnose issues that happened in the past.
-- For example performance issues.
select * from v$active_session_history;

-- V$SQL_PLAN
-- When you run an explain plan command on a SQL statement, there's no guarantee 
-- that the plan you see will actually be used at execution time.
-- View the execution plans that were actually executed for your SQL.
select * from v$sql_plan;

-- V$SQL & V$SQLSTATS
-- Step 1: Use V$SQLSTATS to find the SQL statement you are interested in.
-- Step 2: If you need more information then drill down to V$SQL.
select * from v$sqlstats;

-- Use V$SQL to find all the SQL in your library cache with associated metrics:
-- Who parsed it, how many times it has been executed, pl/sql program that
-- initiated it, etc.
select * from v$sql;




