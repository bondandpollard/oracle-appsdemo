CREATE OR REPLACE PACKAGE util_file AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : util_file
  ** Description   : External file handling
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date            Name                 Description
  **------------------------------------------------------------------------
  ** 13/06/2022      Ian Bond             Program created
  **   
  */


  /*
  ** Global constants
  */
  
  gc_max_linesize          CONSTANT INTEGER                             := plsql_constants.max_linesize;
  gc_import_directory      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_directory;
  gc_import_error_dir      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_error_dir;
  gc_import_processed_dir  CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_processed_dir;
  gc_export_directory      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.export_directory;
  gc_directory_delimiter   CONSTANT plsql_constants.dirdelimlength_t    := plsql_constants.directory_delimiter;
  gc_error                 CONSTANT plsql_constants.severity_error%TYPE := plsql_constants.severity_error;
  gc_info                  CONSTANT plsql_constants.severity_info%TYPE  := plsql_constants.severity_info;
  gc_warn                  CONSTANT plsql_constants.severity_warn%TYPE  := plsql_constants.severity_warn;

  /*
  ** Global exceptions
  */
  
  e_file_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_file_not_found,-20000);


  /*
  ** Public functions
  */

  /*
  ** load_csv - load CSV file into a staging table
  **
  **   This function loads the contents of a specified CSV file into a staging table, IMPORTCSV.
  **   Additonal functions may then be called to fetch the data from the staging table, validate it,
  **   and load it into the required database tables.
  **   See the package IMPORT for examples.
  **
  **   Process overview:
  **    1. Copy the CSV file containing data to be imported into the data import folder, directory DATA_IN.
  **    2. Call a function in the import package that will:
  **    2.1. Call this function, load_csv, passing the csv file name. The data is loaded into the table IMPORTCSV,
  **         and a FILEID identifying the imported CSV data is returned.
  **    2.2. Validate the imported data.
  **    2.3. Report all errors found.
  **    2.4. If errors found, exit with an error status.
  **    2.4. If no errors then load data into the required database tables.
  **    
  **   This function will:
  **    1. Load the contents of the CSV file into the staging table IMPORTCSV.
  **    2. Generate a unique FILEID to identify the group of records loaded from the CSV file. 
  **    3. Give each row in IMPORTCSV a unique, automatically generated identity RECID.
  **    4. Return a postive integer value of FILEID if the data is loaded successfully, or -1 if the file is not found.
  **
  **
  ** IN
  **   p_filename       - filename including extension
  ** RETURN
  **   INTEGER  Number of records loaded
  ** EXCEPTIONS
  **   e_file_not_found      - Specified file not found, no data loaded.
  */
  FUNCTION load_csv(
    p_filename IN VARCHAR2
  ) RETURN INTEGER;


  /*
  ** delete_csv - Delete rows from the import staging table
  **
  ** Delete rows with the specified fileid from the import staging table 
  ** IMPORTCSV
  **
  ** IN
  **   p_fileid        - File identifier of CSV file
  ** RETURN
  **   NUMBER   Count of rows deleted
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION delete_csv(
    p_fileid IN importcsv.fileid%TYPE
  ) RETURN NUMBER;


  /*
  ** rename_file - Rename specified file 
  **
  ** Rename the specified operating system file, 
  ** optionally moving it to a different directory.
  **
  ** IN
  **   src_location         - Source directory name e.g. 'DATA_IN'
  **   src_filename         - Filename including extension
  **   dest_location        - Destination directory e.g. 'DATA_IN_PROCESSED'
  **   dest_filename        - Destination filename (new name of file)
  **   overwrite            - TRUE if you want to overwrite existing file.
  **                          If FALSE and named file exists and error occurs.
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  PROCEDURE rename_file(
    src_location   IN VARCHAR2,
    src_filename   IN VARCHAR2,
    dest_location  IN VARCHAR2,
    dest_filename  IN VARCHAR2,
    overwrite      IN BOOLEAN DEFAULT FALSE);

END util_file;
/