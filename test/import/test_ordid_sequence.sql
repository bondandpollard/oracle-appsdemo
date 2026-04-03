-- Test ORDID sequence generation
--
DECLARE
  l_next_ordid NUMBER;
  l_ordid item.ordid%TYPE;
BEGIN
 SELECT ordid_seq.NEXTVAL INTO l_next_ordid FROM dual;
 util_admin.log_message('Next ORDID is :' || to_char(l_next_ordid));
 --l_ordid := l_next_ordid;
END;
 