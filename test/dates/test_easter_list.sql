-- Test Easter related holidays

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

SET PAGESIZE 66
SET NEWPAGE 0
SET LINESIZE 132

TTITLE CENTER 'Bond and Pollard Limited' SKIP 1 -
  CENTER ======================== SKIP 1-
  LEFT 'Holidays Based on Easter'  -
  RIGHT 'Page:' SQL.PNO SKIP 2

ACCEPT p_year prompt "Enter year format YYYY:"

  SELECT 
    util_date.carnival_monday(&p_year) "Date",'Carnival Monday' "Festival"
  FROM dual
  UNION
  SELECT
    util_date.shrove_tuesday(&p_year), 'Shrove Tuesday'
  FROM dual
  UNION
  SELECT
    util_date.mardi_gras(&p_year), 'Mardi Gras / Shrove Tuesday'
  FROM dual
  UNION
  SELECT
    util_date.ash_wednesday(&p_year), 'Ash Wednesday'
  FROM dual
  UNION
  SELECT
    util_date.palm_sunday(&p_year), 'Palm Sunday'
  FROM dual
  UNION
  SELECT
    util_date.good_friday(&p_year), 'Good Friday'
  FROM dual
  UNION
  SELECT
    util_date.easter_sunday(&p_year), 'Easter Sunday'
  FROM dual
  UNION
  SELECT
    util_date.easter_monday(&p_year), 'Easter Monday'
  FROM dual
  UNION
  SELECT
    util_date.easter_friday(&p_year), 'Easter Friday / Friday after Easter'
  FROM dual
  UNION
  SELECT
    util_date.easter_saturday(&p_year), 'Easter Saturday / Saturday after Easter'
  FROM dual
  UNION
  SELECT
    util_date.ascension_day(&p_year), 'Ascension Day'
  FROM dual
  UNION
  SELECT
      util_date.whitsun(&p_year), 'Whitsun / Pentecost'
  FROM dual
  UNION
  SELECT
    util_date.whit_monday(&p_year), 'Whit Monday'
  FROM dual
  UNION
  SELECT
    util_date.corpus_christi(&p_year), 'Corpus Christi'
  FROM dual;
