/*
** Copyright (c) 2026 Bond & Pollard Ltd. All rights reserved.  
** NAME   : stats_list.sql
**
** DESCRIPTION
**  Calculate statistics for a list of numbers.
**  The user is prompted for:
**    List of numbers to calculate stats from
**    Percentile to calculate, a number between 0 and 1
**
**  A frequency table is generated from the data, and the statistics are
**  displayed.
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 24/03/2026   Ian Bond      Created
*/
SET SERVEROUTPUT ON
ACCEPT p_list PROMPT "Enter a list of numbers separated by commas"
ACCEPT p_percentile NUMBER PROMPT "Percentile (number > 0 and < 1)?"

DECLARE
  v_stats_result util_numeric.t_stats_result;
BEGIN
  util_admin.log_message('Input list is: ' || '&p_list');
  v_stats_result := util_numeric.get_stats_list('&p_list');
  util_numeric.display_frequency_table(v_stats_result);
  util_numeric.display_stats(v_stats_result,&p_percentile);  
EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('See error messages above.');
END;