-- Applog report message from previous day onward
SELECT 
  logged_at,
  severity,
  program_name,
  message,
  user_name,
  applog_sqlerrm
FROM applog 
WHERE logged_at >= sysdate-1 
ORDER BY logged_at DESC;