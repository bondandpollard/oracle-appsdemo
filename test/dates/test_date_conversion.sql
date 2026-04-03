SET SERVEROUTPUT ON
ACCEPT p_in_date PROMPT 'Enter a valid date: '
DECLARE
  l_date DATE;
BEGIN
  util_admin.log_message('Parameter Date is ' || '&p_in_date');
  l_date := to_date('&p_in_date','DD/MM/YYYY');
  util_admin.log_message('Date is ' || to_char(l_date));
END;