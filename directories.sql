-- User Directories
--
COLUMN owner FORMAT A20
COLUMN directory_path FORMAT A70
COLUMN directory_name FORMAT A30

SELECT * FROM dba_directories WHERE origin_con_id <> 1;