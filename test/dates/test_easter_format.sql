-- Easter date calculation
  SET SERVEROUTPUT ON
  ACCEPT p_year NUMBER FORMAT '9999' DEFAULT 2025 PROMPT 'Enter a year:';
  SELECT 'Easter in ' || &p_year || ' falls on: ' || to_char(util_date.easter_sunday(&p_year),'Dy Mon DD YYYY') "Easter Date" 
  FROM dual;
