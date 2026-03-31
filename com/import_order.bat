ECHO OFF
REM Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.
REM  
REM NAME: import_order.bat
REM
REM DESCRIPTION
REM   Import sales order data into the Oracle database.
REM
REM   Search the received directory for CSV files containing order data.
REM   For each CSV file found:
REM     Copy the CSV file to the DATA_IN import directory.
REM     Execute a PL/SQL function to validate the data and process as:
REM       If no errors:
REM         Load the data into the order database tables.
REM         Move the CSV file to the processed directory.
REM       Else if errors found:
REM         Log all errors in the table IMPORTERROR, recording the filename, error message, data, user, date and time.
REM         Move the CSV file to the error directory.
REM     Delete the CSV file from the received directory.
REM
REM ---------------------------------------------------------------------------------------
REM MODIFICATION HISTORY
REM
REM Date         Name          Description
REM ---------------------------------------------------------------------------------------
REM 21/07/2022   Ian Bond      Created script
REM 06/03/2023   Ian Bond      Use CONNECT_USER to connect to the database. This user
REM                            does not own any application schema objects.


REM Set the application environment variables
CALL ..\config\SET_ENV

FOR /R %DATA_HOME%\RECEIVED %%F IN (ORDER*.CSV) DO ( 
  ECHO CSV FILE FOUND: %%F
  
  REM Copy the csv to the data import directory
  COPY "%%F" "%DATA_HOME%\DATA_IN\%%~NXF"
  
  REM Execute the sqlplus script to load the data
  SQLPLUS %CONNECT_USER%/%CONNECT_PWD%@%DBCONNECT% @%APP_HOME%\SQL\IMPORT_ORDER.SQL "%%~NXF"
  
  REM Tidy up - delete the csv file from the received directory
  DEL "%%F"
)