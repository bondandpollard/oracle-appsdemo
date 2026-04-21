CREATE OR REPLACE PACKAGE export AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : export
  ** Description   : Export data from database into CSV files
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                Description
  **------------------------------------------------------------------------
  ** 13/07/2022       Ian Bond            Program created
  ** 22/03/2026       Ian Bond            Add function to export statistics to CSV file.  
  ** 24/03/2026       Ian Bond            Create functions to export project stats.
  */
  
 
  /*
  ** Global constants
  */
  gc_import_directory      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_directory;
  gc_import_error_dir      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_error_dir;
  gc_import_processed_dir  CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_processed_dir;
  gc_export_directory      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.export_directory;
  gc_delim                 CONSTANT VARCHAR2(1)                         := ',';
  gc_quote                 CONSTANT VARCHAR2(1)                         := '"';
  gc_error                 CONSTANT plsql_constants.severity_error%TYPE := plsql_constants.severity_error;
  gc_info                  CONSTANT plsql_constants.severity_info%TYPE  := plsql_constants.severity_info;
  gc_warn                  CONSTANT plsql_constants.severity_warn%TYPE  := plsql_constants.severity_warn;

  /*
  ** Global exceptions
  */
  e_file_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_file_not_found,-20000);


  /*
  ** Public functions and procedures
  */

  /*
  ** demo - export demo data to a CSV file
  **
  **
  ** IN
  ** RETURN
  **   BOOLEAN   TRUE if data exported OK, FALSE if failed
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION demo RETURN BOOLEAN;

  /*
  ** orders - export order data to a CSV file
  **
  **
  ** IN
  ** RETURN
  **   BOOLEAN   TRUE if data exported OK, FALSE if failed
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION orders RETURN BOOLEAN;

  /*
  ** stats - export statistics to a CSV file
  ** 
  ** Export frequency table and statistics to a CSV file.
  **
  ** The CSV file is created in DATA_HOME/data_out
  ** File name: stats_[name]_YYYYMMDD_HHMMSS.csv
  **
  ** The CSV contains:
  **  Header info is the name passed in p_name
  **  Frequency Table 
  **  Statistics calculated from frequency table
  **
  ** IN
  **   p_stats_result           - Record containing stats and frequency table
  **   p_name                   - Name to include in CSV file head, used to name file
  **   p_pct                    - Optional percentile, number between 0 and 1, default 0.5
  **
  ** RETURN
  **   VARCHAR2  Filename of CSV file created, null if export failed
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION stats(
    p_stats_result IN util_numeric.t_stats_result,
    p_name VARCHAR2 DEFAULT NULL,
    p_pct IN NUMBER DEFAULT 0.5
  ) RETURN VARCHAR2;
  
  /*
  ** project_stats - export project statistics to a CSV file
  ** 
  ** Export frequency table and statistics for a project's 
  ** data to a CSV file.
  **
  ** Statistics data for each project are stored in tables:
  **  STATS_PROJECT 
  **  STATS_DATA
  **
  ** The CSV file is created in DATA_HOME/data_out
  ** File name: stats_[Project ID]_YYYYMMDD_HHMMSS.csv
  **
  ** The CSV contains:
  **  Header info identifying project id and description
  **  Frequency Table 
  **  Statistics calculated from frequency table
  **
  ** IN
  **   p_project_id             - Primary key identifying project data to export
  **   p_stats_result           - Record containing stats and frequency table
  **   p_pct                    - Optional percentile, number between 0 and 1, default 0.5
  **
  ** RETURN
  **   VARCHAR2  Filename of CSV file created, null if export failed
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION project_stats(
    p_project_id IN stats_project.stats_project_id%TYPE,
    p_stats_result IN util_numeric.t_stats_result,
    p_pct IN NUMBER DEFAULT 0.5
  ) RETURN VARCHAR2;


END export;
/
