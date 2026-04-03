-- Delete Order import test data
-- and error messages
ACCEPT v_start_date DATE PROMPT "Delete all orders created after this date (DD-MON-YYYY)"
BEGIN

  -- Delete error messages
  --
  DELETE FROM importerror WHERE TRUNC(error_time) >= TRUNC(to_date('&v_start_date','DD-MON-RR'));
 
  DELETE FROM applog WHERE trunc(logged_at) >= TRUNC(to_date('&v_start_date','DD-MON-RR'));
  
  -- Delete test items and ord data
  --
  DELETE FROM item 
  WHERE item.ordid IN 
  ( SELECT DISTINCT(I.ordid)
    FROM ord O, item I
    WHERE I.ordid = O.ordid
    AND O.orderdate >= TRUNC(to_date('&v_start_date','DD-MON-RR'))
  );
  DELETE FROM ord WHERE orderdate >= TRUNC(to_date('&v_start_date','DD-MON-RR'));
  
END;