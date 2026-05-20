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
  ** 14/05/2026       Ian Bond            Function stats renamed to stats_export to prevent scope clash with stats package which
  **                                      gives compile error PLS-00225: subprogram or cursor 'STATS' reference is out of scope
  ** 20/05/2026       Ian Bond            Fix time format HH24MI not HH24MM. Add function project_stats_data.
  **                                      demo and orders functions amended to return filename.
  */
  
 
  /*
  ** Global constants
  */
  gc_import_directory      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_directory;
  gc_import_error_dir      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_error_dir;
  gc_import_processed_dir  CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_processed_dir;
  gc_export_directory      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.export_directory;
  gc_delim                 CONSTANT plsql_constants.csv_delimiter%TYPE  := plsql_constants.csv_delimiter;
  gc_quote                 CONSTANT plsql_constants.double_quote%TYPE   := plsql_constants.double_quote;
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
  **   VARCHAR2  Filename of CSV file created, null if export failed
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION demo RETURN VARCHAR2;

  /*
  ** orders - export order data to a CSV file
  **
  **
  ** IN
  ** RETURN
  **   VARCHAR2  Filename of CSV file created, null if export failed
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION orders RETURN VARCHAR2;

  /*
  ** stats_export - export statistics to a CSV file
  ** 
  ** Export frequency table and statistics to a CSV file.
  **
  ** The CSV file is created in DATA_HOME/data_out
  ** File name: stats_[name]_YYYYMMDD_HHMISS.csv
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
  FUNCTION stats_export(
    p_stats_result IN plsql_types.t_stats_result,
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
  ** File name: stats_[Project ID]_YYYYMMDD_HHMISS.csv
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
    p_stats_result IN plsql_types.t_stats_result,
    p_pct IN NUMBER DEFAULT 0.5
  ) RETURN VARCHAR2;
  
  /*
  ** project_stats_data - export project statistics data to a CSV file
  ** 
  **
  ** Statistics data for each project are stored in tables:
  **  STATS_PROJECT 
  **  STATS_DATA
  **
  ** The CSV file is created in DATA_HOME/data_out
  ** File name: stats_data_[Project ID]_YYYYMMDD_HHMISS.csv
  **
  ** CSV file format
  ** For each project, there will be a group of records consisting of a header
  ** record with the project description, followed by 1 or more body records containing 
  ** statistics data.
  **
  ** Header Record
  **   Field              Type    Size            Description
  **   ========================================================================
  **   Record Type        Char                    PROJECT identifies the header
  **   Project Desc       Char    100             Maps to STATS_PROJECT.DESCRIPTION
  **
  ** Body Record (1 to N records per header)
  **   ========================================================================
  **   Data Description   Char                    STATS_DATA.DESCRIPTION
  **   Data               Char                    STATS_DATA.STATS_VALUE
  **
  **  e.g.
  **    PROJECT,PL/SQL Exam Results
  **    Fred,90
  **    Jim,93
  **    Ann,97
  **    Ian,98
  **    Steve F,100
  **    Bruce Scott,99
  **    Tiger,95
  **    Mary,91
  **    Connor McD,100
  **
  ** IN
  **   p_project_id             - Primary key identifying project data to export
  **
  ** RETURN
  **   VARCHAR2  Filename of CSV file created, null if export failed
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION project_stats_data(
    p_project_id IN stats_project.stats_project_id%TYPE
  ) RETURN VARCHAR2;

END export;
/
