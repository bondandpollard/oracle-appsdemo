CREATE OR REPLACE PACKAGE BODY util_file AS

  /*
  ** Private functions and procedures
  */

  /*
  ** file_exists - Check whether the named file exists
  **
  ** Check whether the named file exists, and return true if found, 
  ** otherwise false.
  **
  ** IN
  **   p_directory         - An Oracle Directory Name with associated 
  **                         file system path
  **   p_filename          - filename including extension
  ** RETURN
  **   BOOLEAN   TRUE if file found, otherwise FALSE
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION file_exists (
    p_directory IN VARCHAR2,
    p_filename  IN VARCHAR2
  ) 
  RETURN BOOLEAN 
  IS
    l_length NUMBER;
    l_block_size NUMBER;
    l_exists BOOLEAN := FALSE;
  BEGIN
    utl_file.fgetattr (p_directory,
                       p_filename,
                       l_exists,
                       l_length,
                       l_block_size);
    RETURN l_exists;
  END file_exists;

  
  /*
  ** get_line_next - Fetch next record from file
  **
  ** Read next record from the specified file and 
  ** store result in p_line_out.
  **
  ** IN
  **   p_file_in         - File Identifier
  **   p_line_out        - String containing contents of record
  ** RETURN
  **   BOOLEAN   TRUE if record retrieved, otherwise FALSE if no data.
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION get_line_next (
    p_file_in     IN   UTL_FILE.FILE_TYPE, 
    p_line_out    OUT  VARCHAR2
  ) 
  RETURN BOOLEAN
  IS
  BEGIN
    utl_file.get_line(p_file_in, p_line_out);
    RETURN TRUE;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      p_line_out := NULL;
      RETURN FALSE;
  END get_line_next;  


  /*
  ** Public functions and procedures
  */

  
  FUNCTION load_csv(
    p_filename IN VARCHAR2
  ) 
  RETURN INTEGER 
  IS
    l_rec_count INTEGER :=0;
    l_directory gc_import_directory%TYPE;
    l_filename plsql_constants.filenamelength_t;
    l_open_mode VARCHAR2(2);
    l_f1 UTL_FILE.FILE_TYPE;
    l_rec plsql_constants.maxvarchar2_t;
    l_fileid importcsv.fileid%TYPE;
  BEGIN
    -- The DBA must create the following directory and grant access privileges to it
    -- NB: The directory name must be in uppercase or you get the error ORA-29280 Invalid Directory Path
    l_directory := gc_import_directory;
    l_filename := p_filename;

    IF NOT file_exists(l_directory, l_filename) THEN
      RAISE e_file_not_found;
    END IF;

    l_open_mode := 'r';
    l_f1 := utl_file.fopen(l_directory,l_filename,l_open_mode,gc_max_linesize);

    SELECT importcsv_fileid_seq.NEXTVAL INTO l_fileid FROM dual;

    WHILE get_line_next(l_f1, l_rec) LOOP
        l_rec_count := l_rec_count +1;

        -- Index recid is generated from a sequence by the trigger insert_importcsv
        INSERT INTO importcsv (
            fileid,
            filename,
            csv_rec
            ) 
          VALUES (
            l_fileid,
            p_filename,
            l_rec
            );
    END LOOP;

    utl_file.fclose(l_f1);
    RETURN l_fileid;
  EXCEPTION
    WHEN E_FILE_NOT_FOUND THEN
      util_admin.log_message('File not found '||l_directory||gc_directory_delimiter||l_filename,SQLERRM,'UTIL_FILE.LOAD_CSV','B',gc_error);
      RETURN -1;
    WHEN NO_DATA_FOUND THEN
      utl_file.fclose(l_f1);
      RETURN 0;
    WHEN OTHERS THEN
      RETURN 0;
  END load_csv;


  FUNCTION delete_csv(
    p_fileid IN importcsv.fileid%TYPE
  ) 
  RETURN NUMBER 
  IS
    l_result NUMBER := 0;
  BEGIN
    DELETE FROM importcsv WHERE fileid = p_fileid;
    l_result := SQL%ROWCOUNT;
    RETURN l_result;
  EXCEPTION
    WHEN OTHERS THEN RETURN -1;
  END delete_csv;


  PROCEDURE rename_file(
    src_location   IN VARCHAR2,
    src_filename   IN VARCHAR2,
    dest_location  IN VARCHAR2,
    dest_filename  IN VARCHAR2,
    overwrite      IN BOOLEAN DEFAULT FALSE
  ) 
  IS
  BEGIN
    utl_file.frename(src_location,
                     src_filename,
                     dest_location,
                     dest_filename,
                     overwrite);
  EXCEPTION
    WHEN OTHERS THEN
      util_admin.log_message('Error renaming from '||src_location||gc_directory_delimiter||src_filename||' to '||dest_location||gc_directory_delimiter||dest_filename,SQLERRM,'UTIL_FILE.RENAME_FILE','B',gc_error);
  END rename_file;

END util_file;
/
