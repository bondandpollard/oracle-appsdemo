-- Test assignment of value to ORDID to trap
-- out of range errors.
--
SET SERVEROUTPUT ON
ACCEPT p_ord PROMPT "Enter an Order ID between 0 and 99999"
DECLARE
  l_ordid ord.ordid%TYPE;
BEGIN
  l_ordid := to_number(&p_ord);
  util_admin.log_message('Order ID is '||to_char(l_ordid),SQLERRM,'TEST_ORDID_RANGE','B');
EXCEPTION
  WHEN OTHERS THEN
     util_admin.log_message('Order ID out of range '||to_char(&p_ord),SQLERRM,'TEST_ORDID_RANGE','B','E');
END;