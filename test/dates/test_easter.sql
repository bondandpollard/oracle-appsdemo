-- Test Easter related holidays
ACCEPT p_year prompt "Enter year format YYYY:"

  SELECT 
    util_date.carnival_monday(&p_year) "carnival monday",
    util_date.shrove_tuesday(&p_year) "shrove tuesday",
    util_date.mardi_gras(&p_year) "mardi gras is shrove tuesday",
    util_date.ash_wednesday(&p_year) "ash wednesday",
    util_date.palm_sunday(&p_year) "palm sunday",
    util_date.easter_friday(&p_year) "easter friday",
    util_date.easter_saturday(&p_year) "easter saturday",
    util_date.easter_sunday(&p_year) "easter sunday", 
    util_date.easter_monday(&p_year) "easter monday",
    util_date.ascension_day(&p_year) "ascension day",
    util_date.whitsunday(&p_year) "whitsunday",
    util_date.whit_monday(&p_year) "whit monday",
    util_date.corpus_christi(&p_year) "corpus christi"
  FROM dual;
