-- Test Easter related holidays
ACCEPT p_year prompt "Enter year format YYYY:"

  SELECT 
    util_date.carnival_monday(&p_year) "Carnival Monday",
    util_date.shrove_tuesday(&p_year) "Shrove Tuesday",
    util_date.mardi_gras(&p_year) "Mardi Gras is Shrove Tuesday",
    util_date.ash_wednesday(&p_year) "Ash Wednesday",
    util_date.palm_sunday(&p_year) "Palm Sunday",
    util_date.good_friday(&p_year) "Good Friday",
    util_date.easter_sunday(&p_year) "Easter Sunday", 
    util_date.easter_monday(&p_year) "Easter Monday",
    util_date.easter_friday(&p_year) "Easter Friday",   
    util_date.easter_saturday(&p_year) "Easter Saturday",
    util_date.ascension_day(&p_year) "Ascension Day",
    util_date.whitsun(&p_year) "Whitsun (Pentecost)",
    util_date.whit_monday(&p_year) "Whit Monday",
    util_date.corpus_christi(&p_year) "Corpus Christi"
  FROM dual;
