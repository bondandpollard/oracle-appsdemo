-- Debugging
--
SELECT L.message,
  to_char(L.logged_at,'DD/MM/YYYY HH24:MI:SS.FF') "HH24:MI:SS.FF not HH24:MM that is hour and monnth!",
  L.user_name,
  L.applog_sqlerrm "SQLERRM",
  L.program_name,
  S.severity_desc "Severity",
  L.recid
FROM applog L,
     appseverity S
WHERE S.severity (+) = L.severity
ORDER BY L.recid;
