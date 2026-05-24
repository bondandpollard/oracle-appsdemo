/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** This software is free to use and modify at your own risk.
**
** NAME   : import_stats.sql
**
** DESCRIPTION
**   Call a PL/SQL package function to:
**     Load statistics data from CSV file into the staging table IMPORTCSV
**     Validate the data, recording all errors in table IMPORTERROR
**     If no errors
**       Load the imported data into the STATS_DATA table
**       Move the CSV file to the processed directory
**     Else if errors found
**       Move the CSV file to the error directory
**       Exit with an error status
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 10/03/2026   Ian Bond      Created
** 24/03/2026   Ian Bond      Create CSV files for multiple imported projects
** 14/05/2026   Ian Bond      Function export.stats renamed to export.stats_export to avoid conflict with stats package
**                            Statistic functions moved from util_numeric to stats package.
**                            Types moved to plsql_types.
** 24/05/2026   Ian Bond      Add explicit COMMIT if PL/SQL function import.stats_imp returns with tb_project_id_tbl not NULL
**                            (import OK, table of new projects returned).
**                            Do not rely on SQL*Plus EXITCOMMIT parameter being set to ON.
*/

SET SERVEROUTPUT ON
DECLARE 
  v_filename plsql_constants.filenamelength_t := '&1';
  v_csv_fname plsql_constants.filenamelength_t;
  v_stats_result plsql_types.t_stats_result :=plsql_types.t_stats_result();
  tb_project_id_tbl import.tb_project :=import.tb_project();
  v_project_id stats_project.stats_project_id%TYPE;
  e_import_error EXCEPTION;
  e_get_stats_error EXCEPTION;
  e_export_stats_error EXCEPTION;
BEGIN
  util_admin.log_message('Data Import from file: '||v_filename);
  
  -- Import stats data from CSV file, returns table of project_id
  -- listing all projects created
  tb_project_id_tbl := import.stats_imp(v_filename);
  
  IF tb_project_id_tbl IS NOT NULL THEN
  
    COMMIT; /* import.stats_imp did not raise an exception, and returned a table of newly created project data,
               so issue a commit here */
    
    FOR i IN 1 .. tb_project_id_tbl.COUNT LOOP
    
      -- For each imported project, create CSV file containing fequency table and statistics
      
      v_project_id := tb_project_id_tbl(i);
      
      util_admin.log_message('Stats data imported OK for Project ID ['||TO_CHAR(v_project_id)||']');
    
      -- Generate statistics for imported project data
      v_stats_result := stats.get_stats_project(v_project_id);
      IF v_stats_result.stats.sum_values IS NULL THEN
        RAISE e_get_stats_error;
      END IF;
      
      -- Export frequency table and stats for this project to CSV file
      v_csv_fname := export.project_stats(v_project_id,v_stats_result);
      IF v_csv_fname IS NULL THEN 
        RAISE e_export_stats_error;
      END IF;
      
      -- Display CSV file name
      util_admin.log_message('Statistics for Project ID ['||TO_CHAR(v_project_id)||'] exported to file: '||v_csv_fname); 
   
    END LOOP;  
  ELSE
    raise e_import_error;
  END IF;
EXCEPTION
  WHEN e_import_error THEN
    util_admin.log_message('Import failed (IMPORT.STATS_IMP). View errors in table IMPORTERROR for file: '||v_filename,SQLERRM,'IMPORT_STATS.SQL','B','E');
  WHEN e_get_stats_error THEN
    util_admin.log_message('No statistics results returned by function STATS.GET_STATS_PROJECT for Project ID ['||TO_CHAR(v_project_id)||'] imported from file: '||v_filename,SQLERRM,'IMPORT_STATS.SQL','B','E');
  WHEN e_export_stats_error THEN
    util_admin.log_message('Export failed (EXPORT.PROJECT_STATS) for Project ID ['||TO_CHAR(v_project_id)||'] imported from file: '||v_filename,SQLERRM,'IMPORT_STATS.SQL','B','E');
  WHEN OTHERS THEN
    util_admin.log_message('Unexpected Error importing file '||v_filename,SQLERRM,'IMPORT_STATS.SQL','B','E');
END;
/
EXIT