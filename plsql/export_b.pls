CREATE OR REPLACE PACKAGE BODY export AS

  /*
  ** Private functions and procedures
  */
  
  
  /*
  ** stats_csv
  ** Write frequency table and stats to CSV file
  */
  PROCEDURE stats_csv(
    p_file_id       IN utl_file.file_type,
    p_stats_result  IN util_numeric.t_stats_result,
    p_pct           IN NUMBER DEFAULT 0.5
  )
  IS 
    l_rec plsql_constants.maxvarchar2_t;
  BEGIN
   -- Frequency table headings
   l_rec := '"KEY","FREQUENCY"';
   utl_file.put_line(p_file_id,l_rec);

   -- Frequency table
    FOR i IN 1 .. p_stats_result.freq_tbl.COUNT LOOP 
      l_rec := p_stats_result.freq_tbl(i).key
              || gc_delim || to_char(p_stats_result.freq_tbl(i).frequency);
      utl_file.put_line(p_file_id,l_rec);
    END LOOP;
                
    -- Statistics
    l_rec := '"STATISTICS"';
    utl_file.put_line(p_file_id,l_rec);
    utl_file.put_line(p_file_id,'"Sum"' || gc_delim || to_char(p_stats_result.stats.sum_values));
    utl_file.put_line(p_file_id,'"N Total"' || gc_delim || to_char(p_stats_result.stats.n_total));  
    utl_file.put_line(p_file_id,'"Distinct N"' || gc_delim || to_char(p_stats_result.stats.distinct_n));
    utl_file.put_line(p_file_id,'"Mean"' || gc_delim || trim(to_char(p_stats_result.stats.mean,'9999999990.9999')));
    utl_file.put_line(p_file_id,'"Median"' || gc_delim || trim(to_char(p_stats_result.stats.median,'9999999990.9999')));
    FOR i IN 1 .. p_stats_result.stats.mode_values.COUNT LOOP 
      utl_file.put_line(p_file_id,'"Mode '  || to_char(i) || '"' || gc_delim || to_char(p_stats_result.stats.mode_values(i)));
    END LOOP;
    utl_file.put_line(p_file_id,'"Lowest"' || gc_delim || to_char(p_stats_result.stats.lowest));
    utl_file.put_line(p_file_id,'"Highest"' || gc_delim || to_char(p_stats_result.stats.highest));
    utl_file.put_line(p_file_id,'"Range"' || gc_delim || to_char(p_stats_result.stats.range));          
    utl_file.put_line(p_file_id,'"Variance Population"' || gc_delim || trim(to_char(p_stats_result.stats.variance_pop,'9999999990.9999')));
    utl_file.put_line(p_file_id,'"Variance Sample"' || gc_delim || trim(to_char(p_stats_result.stats.variance_samp,'9999999990.9999')));
    utl_file.put_line(p_file_id,'"Standard Deviation Population"' || gc_delim || trim(to_char(p_stats_result.stats.stddev_pop,'9999999990.9999')));
    utl_file.put_line(p_file_id,'"Standard Deviation Sample"' || gc_delim || trim(to_char(p_stats_result.stats.stddev_samp,'9999999990.9999')));
    utl_file.put_line(p_file_id,'"Interquartile Range"' || gc_delim || trim(to_char(p_stats_result.stats.iqr,'9999999990.9999')));  
    -- Percentiles
    utl_file.put_line(p_file_id,'"Percentile Discrete ('||to_char(p_pct,'0.99')||')"'|| gc_delim || trim(to_char(util_numeric.percentile_disc(p_stats_result.freq_tbl, p_pct),'9999999990.9999')));
    utl_file.put_line(p_file_id,'"Percentile Continuous ('||to_char(p_pct,'0.99')||')"' || gc_delim || trim(to_char(util_numeric.percentile_cont(p_stats_result.freq_tbl, p_pct),'9999999990.9999')));
  END stats_csv;

  /*
  ** Public functions and procedures
  */


  FUNCTION demo
    RETURN BOOLEAN 
  IS
    --
    CURSOR demo_cur IS
      SELECT to_char(D.entry_date,'DD/MM/YYYY') entry_date,
             D.memorandum
      FROM   demo D;
    --
    rec_demo demo_cur%ROWTYPE;
    l_file_id utl_file.file_type;
    l_filename plsql_constants.filenamelength_t;
    l_rec plsql_constants.maxvarchar2_t;
  BEGIN
    -- Create the CSV file named: demo_YYYMMDD.csv
    l_filename := 'demo_'||to_char(SYSDATE,'YYMMDD')||'.csv';
    l_file_id := utl_file.fopen(gc_export_directory, l_filename, 'W');

    -- Write CSV Header
    l_rec := '"Entry Date","Memorandum"';
    utl_file.put_line(l_file_id,l_rec);

    -- Write data to CSV file
    -- Separate each field with a delimiter
    -- Enclose strings in double quotes
    --
    OPEN demo_cur;
    LOOP
      FETCH demo_cur INTO rec_demo;
      EXIT WHEN demo_cur%NOTFOUND;
      l_rec :=                            rec_demo.entry_date
               || gc_delim || gc_quote || rec_demo.memorandum     || gc_quote 
               ;
      utl_file.put_line(l_file_id,l_rec);
    END LOOP;
    CLOSE demo_cur;
    utl_file.fclose(l_file_id);
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected Error',SQLERRM,'EXPORT.DEMO','B',gc_error);
      RETURN FALSE;
  END demo;

  FUNCTION orders 
    RETURN BOOLEAN 
  IS
    --
    CURSOR ord_cur IS
      SELECT O.ordid,
             NVL(O.ordref,'No ref') ordref,
             to_char(O.orderdate,'DD/MM/YYYY') orderdate,
             to_char(O.shipdate,'DD/MM/YYYY') shipdate,
             O.commplan,
             ltrim(to_char(O.total,'99999999.99')) ordtot,
             O.custid,
             C.name,
             E.ename,
             I.itemid,
             I.prodid,
             util_string.get_field(P.descrip,1,',') descrip,
             ltrim(to_char(I.actualprice,'9999999.99')) actprice,
             I.qty,
             ltrim(to_char(I.itemtot,'99999999.99')) itemtot 
      FROM   ord O,
             customer C,
             emp E,
             item I,
             product P
      WHERE  C.custid = O.custid
      AND    E.empno = C.repid
      AND    I.ordid (+) = O.ordid
      AND    P.prodid (+) = I.prodid
      ORDER BY O.ordid, I.itemid;
    --
    rec_ord ord_cur%ROWTYPE;
    l_file_id utl_file.file_type;
    l_filename plsql_constants.filenamelength_t;
    l_rec plsql_constants.maxvarchar2_t;
  BEGIN
    -- Create the CSV file named: orders_YYYMMDD.csv
    l_filename := 'orders_'||to_char(SYSDATE,'YYMMDD')||'.csv';
    l_file_id := utl_file.fopen(gc_export_directory, l_filename, 'W');

    -- Write CSV Header
    l_rec := '"Order ID","Order Ref","Order Date","Ship Date","Comm Plan","Total","Customer ID","Customer Name","Sales Rep","Item","Product ID","Description","Price","Qty","Item Total"';
    utl_file.put_line(l_file_id,l_rec);

    -- Write data to CSV file
    -- Separate each field with a delimiter
    -- Enclose strings in double quotes
    --
    OPEN ord_cur;
    LOOP
      FETCH ord_cur INTO rec_ord;
      EXIT WHEN ord_cur%NOTFOUND;
      l_rec :=                            rec_ord.ordid 
               || gc_delim || gc_quote || rec_ord.ordref      || gc_quote 
               || gc_delim ||             rec_ord.orderdate         
               || gc_delim ||             rec_ord.shipdate          
               || gc_delim || gc_quote || rec_ord.commplan    || gc_quote         
               || gc_delim ||             rec_ord.ordtot  
               || gc_delim ||             rec_ord.custid            
               || gc_delim || gc_quote || rec_ord.name        || gc_quote          
               || gc_delim || gc_quote || rec_ord.ename       || gc_quote       
               || gc_delim ||             rec_ord.itemid            
               || gc_delim ||             rec_ord.prodid            
               || gc_delim ||             rec_ord.descrip    
               || gc_delim ||             rec_ord.actprice 
               || gc_delim ||             rec_ord.qty               
               || gc_delim ||             rec_ord.itemtot
               ;
      utl_file.put_line(l_file_id,l_rec);
    END LOOP;
    CLOSE ord_cur;
    utl_file.fclose(l_file_id);
    RETURN TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected Error',SQLERRM,'EXPORT.ORDERS','B',gc_error);
      RETURN FALSE;
  END orders;
  
  FUNCTION stats(
    p_stats_result IN util_numeric.t_stats_result,
    p_name VARCHAR2 DEFAULT NULL,
    p_pct IN NUMBER DEFAULT 0.5
  )
    RETURN VARCHAR2
  IS
    l_file_id utl_file.file_type;
    l_tag VARCHAR2(15); -- add to filename as identifier
    l_filename plsql_constants.filenamelength_t;
    l_rec plsql_constants.maxvarchar2_t;
  BEGIN
    -- Tag in file name to identify file, remove special chars
    l_tag := TRIM(SUBSTR(NVL(regexp_replace(p_name, '[^A-Za-z0-9 ]', ''),'notag'),1,15));
    -- Create the CSV file
    l_filename := 'stats_'||l_tag||'_'||to_char(SYSDATE,'YYYYMMDD_HH24MMSS')||'.csv';
    l_file_id := utl_file.fopen(gc_export_directory, l_filename, 'W');
    
    -- CSV Header 
    utl_file.put_line(l_file_id,'"Name: "'||gc_delim||'"'||p_name||'"');
    
    IF p_stats_result.freq_tbl IS NULL THEN 
      -- No stats data
      utl_file.put_line(l_file_id,'ERROR: No statistics found.');
    ELSE
      -- Statistics data exists
      stats_csv(l_file_id, p_stats_result, p_pct); -- write frequency table and stats to CSV file
    END IF;
    
    utl_file.fclose(l_file_id);
    RETURN l_filename;
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected Error',SQLERRM,'EXPORT.STATS','B',gc_error);
      RETURN NULL;
  END stats;
    
  FUNCTION project_stats(
    p_project_id    IN stats_project.stats_project_id%TYPE,
    p_stats_result  IN util_numeric.t_stats_result,
    p_pct IN NUMBER DEFAULT 0.5
  )
    RETURN VARCHAR2
  IS
    l_proj_desc stats_project.description%TYPE;
    l_file_id utl_file.file_type;
    l_id VARCHAR2(15); -- include in filename 
    l_filename plsql_constants.filenamelength_t;
    l_rec plsql_constants.maxvarchar2_t;
    l_debug_msg applog.message%TYPE;
    l_debug_module applog.program_name%TYPE := 'EXPORT.PROJECT_STATS';
    l_debug_mode VARCHAR2(1) := 'B';
  BEGIN
    SELECT NVL(description,'No Project Description')
    INTO l_proj_desc
    FROM stats_project
    WHERE stats_project_id = p_project_id;
    
    -- Create the CSV file
    -- Tag in file name to identify project
    l_id := TO_CHAR(p_project_id);
    l_filename := 'stats_'||l_id||'_'||to_char(SYSDATE,'YYYYMMDD_HH24MMSS')||'.csv';
    l_file_id := utl_file.fopen(gc_export_directory, l_filename, 'W');
    
    -- CSV header (Title)
    utl_file.put_line(l_file_id,'"Project ID: "'||gc_delim||l_id||gc_delim||'"Name: "'||gc_delim||'"'||l_proj_desc||'"');
  
    IF p_stats_result.freq_tbl IS NULL THEN 
      -- No stats data
      utl_file.put_line(l_file_id,'ERROR: No statistics found. Check data for project_id ' || l_id || ' in table STATS_DATA');
    ELSE
      -- Statistics data exists
      stats_csv(l_file_id, p_stats_result, p_pct); -- write frequency table and stats to CSV file
    END IF;
    
    utl_file.fclose(l_file_id);
    RETURN l_filename;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      util_admin.log_message('Project not found, Project ID:'||TO_CHAR(p_project_id),SQLERRM,l_debug_module,'B',gc_error);
      RETURN NULL;   
    WHEN OTHERS THEN
      util_admin.log_message('Unexpected Error',SQLERRM,l_debug_module,'B',gc_error);
      RETURN NULL;
  END project_stats;

END export;
/
