SET SERVEROUTPUT ON
DECLARE
  v_stats_result util_numeric.t_stats_result;
  v_pct_disc NUMBER;
  v_pct_cont NUMBER;
BEGIN
  v_stats_result := util_numeric.get_stats_list('1,2,3,10,20,999');
  v_pct_disc := util_numeric.percentile_disc(v_stats_result.freq_tbl,0.75);
  dbms_output.put_line('PCT_DISC='||to_char(v_pct_disc));
  
  v_pct_cont := util_numeric.percentile_cont(v_stats_result.freq_tbl,0.75);
  dbms_output.put_line('PCT_CONT='||to_char(v_pct_cont));
END;