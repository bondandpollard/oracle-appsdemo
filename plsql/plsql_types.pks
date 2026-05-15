CREATE OR REPLACE PACKAGE plsql_types AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : plsql_numeric_types
  ** Description   : Define common types shared by packages here.
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                Description
  **------------------------------------------------------------------------
  ** 13/05/2026       Ian Bond            Program created
  */
 
  
  /*
  ** TYPES
  */
  TYPE t_number_array IS VARRAY(plsql_constants.max_arraysize) OF NUMBER;
  
  TYPE t_frequency_row IS RECORD (
    key         NUMBER,
    frequency   PLS_INTEGER
  );
  
  TYPE t_frequency_table IS TABLE OF t_frequency_row;
  
  TYPE t_num_table IS TABLE OF NUMBER;
  
  -- Used by get_stats to return all statistics for frequency table 
  -- Note this is nested, supporting multiple mode values in t_num_table
  TYPE t_stats_summary IS RECORD (
    sum_values      NUMBER,
    n_total         PLS_INTEGER,
    distinct_n      PLS_INTEGER,
    mean            NUMBER,
    median          NUMBER,
    mode_values     t_num_table,
    lowest          NUMBER,
    highest         NUMBER,
    range           NUMBER,
    variance_pop    NUMBER,
    variance_samp   NUMBER,
    stddev_pop      NUMBER,
    stddev_samp     NUMBER,
    iqr             NUMBER 
  );
  
  -- Get_stats uses this composite record to store the calculated
  -- statistics and frequency table from which they were generated.
  TYPE t_stats_result IS RECORD (
    stats       t_stats_summary,
    freq_tbl    t_frequency_table
  );
  
  
END plsql_types;
/