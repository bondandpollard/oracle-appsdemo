/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
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
*/

SET SERVEROUTPUT ON
DECLARE 
  v_filename plsql_constants.filenamelength_t := '&1';
  v_csv_fname plsql_constants.filenamelength_t;
  v_stats_result util_numeric.t_stats_result :=util_numeric.t_stats_result();
  tb_project_id_tbl import.tb_project :=import.tb_project();
BEGIN
  util_admin.log_message('Data Import from file: '||v_filename);
  
  -- Import stats data from CSV file, returns table of project_id
  -- listing all projects created
  tb_project_id_tbl := import.stats_imp(v_filename);
  
  IF tb_project_id_tbl IS NOT NULL THEN
    FOR i IN 1 .. tb_project_id_tbl.COUNT LOOP
    
      -- For each imported project, create CSV file containing fequency table and statistics
      
      util_admin.log_message('Stats data imported OK for Project ID='||to_char(tb_project_id_tbl(i)));
    
      -- Generate statistics for imported project data
      v_stats_result := util_numeric.get_stats_project(tb_project_id_tbl(i));
 
      -- Export frequency table and stats for this project to CSV file
      v_csv_fname := export.project_stats(tb_project_id_tbl(i),v_stats_result);
      
      -- Display CSV file name
      util_admin.log_message('Statistics exported to file: '||v_csv_fname); 
   
    END LOOP;
    
  ELSE
    raise_application_error (-20099,'Import failed. View errors in IMPORTERROR for file '||v_filename);
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    util_admin.log_message('Error importing file '||v_filename,SQLERRM,'IMPORT_STATS.SQL','B','E');
END;
/
EXIT