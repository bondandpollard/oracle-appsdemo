-- Test Easter related holidays
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
    util_date.mardi_gras(&p_year), 'Mardi Gras is shrove tuesday'
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
    util_date.easter_friday(&p_year), 'Easter Friday'
  FROM dual
  UNION
  SELECT
    util_date.easter_saturday(&p_year), 'Easter Saturday'
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
    util_date.ascension_day(&p_year), 'Ascension Day'
  FROM dual
  UNION
  SELECT
      util_date.whitsunday(&p_year), 'Whitsunday'
  FROM dual
  UNION
  SELECT
    util_date.whit_monday(&p_year), 'Whit Monday'
  FROM dual
  UNION
  SELECT
    util_date.corpus_christi(&p_year), 'Corpus Christ'
  FROM dual;
