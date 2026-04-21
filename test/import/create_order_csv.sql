-- Generate some test data for the Order Import process
-- File created in DATA_OUT directory, named order_data YYMMDD.csv
--
SET SERVEROUTPUT ON
ACCEPT p_ordref_prefix DEFAULT 'TESTA' PROMPT "Enter Order Ref prefix max 5 characters: "
DECLARE
  l_file_id utl_file.file_type;
  l_filename plsql_constants.filenamelength_t;
  l_rec VARCHAR2(1000);
  l_ordref_prefix VARCHAR2(5);
  l_ordrefno NUMBER;
  l_delim CONSTANT VARCHAR2(1) := ',';
BEGIN
  l_filename := 'order_data '||to_char(SYSDATE,'YYMMDD')||'.csv';
  l_file_id := utl_file.fopen(plsql_constants.export_directory, l_filename, 'W');
  l_ordref_prefix := '&p_ordref_prefix';
  FOR l_ordrefno IN 1  .. 10000 LOOP
    dbms_output.put_line('Ref: '||to_char(l_ordrefno));
    l_rec := l_ordref_prefix||to_char(l_ordrefno)||l_delim||
      to_char(SYSDATE+l_ordrefno,'DD/MM/YYYY')||l_delim||
      'Z'||l_delim||
      '101'||l_delim||
      to_char(SYSDATE+l_ordrefno+3,'DD/MM/YYYY')||l_delim||
      '100890'||l_delim||
      to_char(l_ordrefno+33);
    utl_file.put_line(l_file_id,l_rec);
    
    l_rec := l_ordref_prefix||to_char(l_ordrefno)||l_delim||
      to_char(SYSDATE+l_ordrefno,'DD/MM/YYYY')||l_delim||
      'Z'||l_delim||
      '102'||l_delim||
      to_char(SYSDATE+l_ordrefno+3,'DD/MM/YYYY')||l_delim||
      '100870'||l_delim||
      to_char(l_ordrefno+12);
    utl_file.put_line(l_file_id,l_rec);

    l_rec := l_ordref_prefix||to_char(l_ordrefno)||l_delim||
      to_char(SYSDATE+l_ordrefno,'DD/MM/YYYY')||l_delim||
      'Z'||l_delim||
      '104'||l_delim||
      to_char(SYSDATE+l_ordrefno+3,'DD/MM/YYYY')||l_delim||
      '200380'||l_delim||
      to_char(l_ordrefno+12);
    utl_file.put_line(l_file_id,l_rec);
  END LOOP;
  utl_file.fclose(l_file_id);
END;