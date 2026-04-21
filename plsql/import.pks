CREATE OR REPLACE PACKAGE import AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : import
  ** Description   : Import CSV data
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date             Name                Description
  **------------------------------------------------------------------------
  ** 24/06/2022       Ian Bond            Program created
  ** 05/03/2025       Ian Bond            ord_imp: use shorthand to assign ordid_seq.NEXTVAL
  **                                      to l_ordid
  ** 16/02/2026       Ian Bond            Ord_imp handle null fields.
  ** 10/03/2026       Ian Bond            Add stats_imp to load CSV data into STATS_DATA
  ** 18/03/2026       Ian Bond            Amend stats_imp to handle CSV structure for multiple
  **                                      projects, grouped into header record followed by data.
  ** 24/03/2026       Ian Bond            Amend stats_imp to return table of project_id
  */
  

  /*
  **Global constants
  */
  gc_import_directory      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_directory;
  gc_import_error_dir      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_error_dir;
  gc_import_processed_dir  CONSTANT plsql_constants.filenamelength_t    := plsql_constants.import_processed_dir;
  gc_export_directory      CONSTANT plsql_constants.filenamelength_t    := plsql_constants.export_directory;
  gc_error                 CONSTANT plsql_constants.severity_error%TYPE := plsql_constants.severity_error;
  gc_info                  CONSTANT plsql_constants.severity_info%TYPE  := plsql_constants.severity_info;
  gc_warn                  CONSTANT plsql_constants.severity_warn%TYPE  := plsql_constants.severity_warn;

  /*
  ** Global exceptions
  */
  e_file_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_file_not_found,-20000);

  e_invalid_data EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_invalid_data,-20001);

  e_duplicate_ordref EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_duplicate_ordref,-20002);

  e_ordid_value_error EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_ordid_value_error,-20003);
  
  e_null_field EXCEPTION;
  PRAGMA EXCEPTION_INIT (e_ordid_value_error,-20004);
  
  
  /*
  ** TYPES
  */
  TYPE tb_project IS TABLE OF PLS_INTEGER;
 
  
  /*
  ** Public functions and procedures
  */
  
  /*
  ** demo_imp - Import data from a CSV file into the Demo table.
  **
  ** User Guide:
  ** 1. Copy a CSV format file in the format described below to the import directory DATA_HOME/received
  ** 2. Run import_demo in the com APP_HOME/com directory.
  ** 3. Check the CSV file has been processed, it will be in either DATA_IN_PROCESSED or DATA_IN_ERROR
  ** 4. Run SQl report import_errors to check the import error log.
  ** 5. If the CSV data was processed OK, the data will be in the tables as described below.
  **
  ** This function:
  **  1. Calls the package function UTIL_FILE.LOAD_CSV to load data from a CSV file into the 
  **     IMPORTCSV staging table. 
  **  2. The load_csv function returns an integer FILEID, which identifies the group of records loaded
  **     from the CSV file into the staging table.
  **  2.1. If the file was not found, report error and stop processing.
  **  3. Validate the data in IMPORTCSV matching FILEID.
  **  3.1. Set field KEY_VALUE in IMPORTCSV to a value that identifies the data, in this 
  **       case it  will be the first field in the CSV file, ENTRY_DATE.
  **  3.2. Record all validation errors found in the IMPORTERROR table, including the KEY_VALUE field.
  **  4. If data fails validation:
  **  4.1. Delete the data from the IMPORTCSV staging table.
  **  4.2. Move the CSV file to the error directory.
  **  4.3. Stop processing, exit with an error status.
  **  5. If data passes validation:
  **  5.1. Insert data into the Demo table.
  **  5.2. Delete old error messages from the IMPORTERROR table for the data successfully imported,
  **       using the KEY_VALUE column of IMPORTCSV.
  **  5.3. Delete the data from the IMPORTCSV staging table.
  **  5.4. Move the CSV to the processed directory.
  **  5.5. Exit with a success status.
  **
  ** CSV FILE
  ** Header 
  **  "Entry Date","Memorandum"
  ** Body 
  **   Field              Type    Size            Maps To
  **   ===========================================================
  **   Entry Date         Date    DD/MM/YYYY      DEMO.ENTRY_DATE
  **   Memorandum         Char                    DEMO.MEMORANDUM
  **
  ** TABLES
  **   DEMO           One row created per record in CSV file.
  **
  ** IN
  **   p_filename      - Name of file being imported
  ** RETURN
  **   BOOLEAN   Returns TRUE if all data imported successfully, otherwise FALSE
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION demo_imp (
    p_filename IN VARCHAR2
  ) RETURN BOOLEAN;

   
  /*
  ** ord_imp - Import order data from a CSV file into the ORD and ITEM tables
  **
  ** User Guide:
  ** 1. Copy a CSV format file in the format described below to the import directory DATA_HOME/received
  ** 2. Run import_order in the com APP_HOME/com directory.
  ** 3. Check the CSV file has been processed, it will be in either DATA_IN_PROCESSED or DATA_IN_ERROR
  ** 4. Run SQl report import_errors to check the import error log.
  ** 5. If the CSV data was processed OK, the data will be in the tables as described below.
  **
  ** The csv file containing the order data must be in the import directory DATA_IN.
  **
  ** This function:
  **  1. Calls the package function UTIL_FILE.LOAD_CSV to load order data from a CSV file into the 
  **     IMPORTCSV staging table. 
  **  2. The load_csv function returns an integer FILEID, which identifies the group of records loaded
  **     from the CSV file into the staging table.
  **  2.1. If the file was not found, report error and stop processing.
  **  3. Validate the data in IMPORTCSV matching FILEID.
  **  3.1. Set field KEY_VALUE in IMPORTCSV to a unique value, that identifies the order, in this 
  **       case it  will be the first field in the CSV file, ORDREF
  **  3.2. Record all validation errors found in the IMPORTERROR table, including the KEY_VALUE field.
  **  4. If data fails validation:
  **  4.1. Delete the data from the IMPORTCSV staging table.
  **  4.2. Move the CSV file to the error directory.
  **  4.3. Stop processing, exit with an error status.
  **  5. If data passes validation:
  **  5.1. Insert data into the ORD and ITEM tables.
  **  5.2. Delete old error messages from the IMPORTERROR table for the orders successfully imported,
  **       using the KEY_VALUE column of IMPORTCSV.
  **  5.3. Delete the data from the IMPORTCSV staging table.
  **  5.4. Move the CSV to the processed directory.
  **  5.5. Exit with a success status.
  **
  ** CSV FILE
  ** Header 
  **   "Ord Ref","Order Date","Comm","Customer","Ship Date","Product","Qty"
  ** Body 
  **   Field              Type    Size            Maps To
  **   ===========================================================
  **   Order Reference    Char    10              ORD.ORDREF
  **   Order Date         Date    DD/MM/YYYY      ORD.ORDERDATE
  **   Commission Plan    Char    1               ORD.COMMPLAN
  **   Customer           Number  6               ORD.CUSTID
  **   Ship Date          Date    DD/MM/YYYY      ORD.SHIPDATE
  **   Product ID         Number  6               ITEM.PRODID
  **   Order Qty          Number  8               ITEM.QTY
  **
  ** Input data: IMPORTCSV 
  **  The IMPORTCSV table may contain data for 1 or more orders,each with 1 or more
  **  associated items.
  **  The ORD header data is duplicated for each item
  **  Each order in the import file is uniquely identified by the first field
  **  "Order Ref". 
  **
  ** TABLES
  ** ORD Table 
  **  The trigger INSERT_ORD uses sequence ORDID_SEQ to generate a value for ORDID for each new order
  **  CUSTID must reference a row on the CUSTOMER table 
  **  TOTAL must be calculated as a sum of ITEM.ITEM_TOT
  **  Store the original order reference from the CSV file in the column ORDREF
  **
  ** ITEM table
  **  The primary key is ORDID from ORD plus ITEMID
  **  Generate the ITEMID as a sequential number starting at 1 for each order
  **  PRODID must reference a row on the PRODUCT table
  **  Lookup the current price on the PRICE table. Find the correct value of STDPRICE for the product,
  **  it must have a start date on or after the current date, and an end date after today's date.
  **  ITEMTOT is calculated as STDPRICE * QTY. Note that this contravenes 3rd normal form.
  **
  **
  ** IN
  **   p_filename      - Name of file being imported
  ** RETURN
  **   BOOLEAN   Returns TRUE if all data imported successfully, otherwise FALSE
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION ord_imp (
    p_filename IN VARCHAR2
  ) RETURN BOOLEAN;



  /*
  ** stats_imp - Import data from a CSV file into the STATS_DATA table.
  **
  ** User Guide:
  ** 1. Copy a CSV format file in the format described below to the import directory DATA_HOME/received
  ** 2. Run import_stats in the com APP_HOME/com directory.
  ** 3. Check the CSV file has been processed, it will be in either DATA_IN_PROCESSED or DATA_IN_ERROR
  ** 4. Run SQl report import_errors to check the import error log.
  ** 5. If the CSV data was processed OK, the data will be in the tables as described below.
  **
  ** The csv file containing the data must be in the import directory DATA_IN.
  **
  ** This function:
  **  1. Calls the package function UTIL_FILE.LOAD_CSV to load data from a CSV file into the 
  **     IMPORTCSV staging table. 
  **  2. The load_csv function returns an integer FILEID, which identifies the group of records loaded
  **     from the CSV file into the staging table.
  **  2.1. If the file was not found, report error and stop processing.
  **  3. Validate the data in IMPORTCSV matching FILEID.
  **  3.1. Set field KEY_VALUE in IMPORTCSV to a unique value, that identifies the data, in this 
  **       case it  will be the CSV header record field Project Description.
  **  3.2. Record all validation errors found in the IMPORTERROR table, including the KEY_VALUE field.
  **  4. If data fails validation:
  **  4.1. Delete the data from the IMPORTCSV staging table.
  **  4.2. Move the CSV file to the error directory.
  **  4.3. Stop processing, exit with an error status.
  **  5. If data passes validation:
  **  5.1. Insert data into the STATS_PROJECT and STATS_DATA tables.
  **  5.2. Delete old error messages from the IMPORTERROR table for the data successfully imported,
  **       using the KEY_VALUE column of IMPORTCSV.
  **  5.3. Delete the data from the IMPORTCSV staging table.
  **  5.4. Move the CSV to the processed directory.
  **  5.5. Exit with a success status.
  **
  ** CSV file
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
  ** TABLES
  **   STATS_PROJECT   Unique stats_project_id created for each CSV header record.
  **   STATS_DATA      Stats data for each project, values taken from CSV body records.
  **
  ** IN
  **   p_filename      - Name of file being imported
  ** RETURN
  **   NUMBER   t_project_id_tbl table of project_id listing all imported projects, 
  **            NUll if import fails
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION stats_imp (
    p_filename IN VARCHAR2
  ) RETURN tb_project;
  
END import;
/