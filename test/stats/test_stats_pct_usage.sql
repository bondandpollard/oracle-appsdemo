SET SERVEROUTPUT ON
DECLARE
  v_stats_result plsql_types.t_stats_result;
  v_pct_disc NUMBER;
  v_pct_cont NUMBER;
BEGIN
  v_stats_result := stats.get_stats_list('1,2,3,4.1,5.001,6.7,10,20,999');
  v_pct_disc := stats.percentile_disc(v_stats_result.freq_tbl,0.7);
  dbms_output.put_line('PCT_DISC='||to_char(v_pct_disc));
  
  v_pct_cont := stats.percentile_cont(v_stats_result.freq_tbl,0.7);
  dbms_output.put_line('PCT_CONT='||to_char(v_pct_cont));
END;