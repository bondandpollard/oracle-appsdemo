-- Test the subquery for orderpricecheck_subq
-- Select ORD with item row(s) that have actualprice that does not
-- match the stdprice on price for the prodid and effective date range
--
ACCEPT p_ordref_from PROMPT "Enter the starting Order Reference"
ACCEPT p_ordref_to PROMPT "Enter the ending Order Reference"
ACCEPT p_orderdate_from PROMPT "Enter the starting Order Date in format DD/MM/YYYY"
ACCEPT p_orderdate_to PROMPT "Enter the ending Order Date in format DD/MM/YYYY"

SELECT DISTINCT(O.ordid) 
FROM   ord   O,
       item  I,
       price V
WHERE  ((O.ordref >= NVL('&p_ordref_from',O.ordref) AND O.ordref <= NVL('&p_ordref_to',O.ordref)) OR (O.ordref IS NULL AND '&p_ordref_from' IS NULL))
AND    O.orderdate >= NVL(to_date('&p_orderdate_from','DD/MM/YYYY'),O.orderdate) AND O.orderdate <= NVL(to_date('&p_orderdate_to','DD/MM/YYYY'),O.orderdate)
AND    I.ordid (+) = O.ordid
AND    V.prodid = I.prodid
AND    V.startdate <= O.orderdate
AND    NVL(V.enddate,O.orderdate) >= O.orderdate
AND    V.stdprice <> I.actualprice
ORDER BY O.ordid