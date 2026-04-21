/*
** Copyright (c) 2026 Bond & Pollard Ltd. All rights reserved.  
** NAME   : applog_latest.sql
**
** DESCRIPTION
**  Applog report messages from previous day onward
----------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 25/03/2026   Ian Bond      Created
*/
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