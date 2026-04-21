-- Debugging
--
SELECT L.message,
  to_char(L.logged_at,'DD/MM/RR HH24:MM:SS.FF') "DATE TIME",
  L.user_name,
  L.applog_sqlerrm "SQLERRM",
  L.program_name,
  S.severity_desc "Severity",
  L.recid
FROM applog L,
     appseverity S
WHERE S.severity (+) = L.severity
ORDER BY L.recid;
