-- check_order_total.sql
-- Check the calculated item total on ITEM
--
SELECT O.ordid,
       O.custid,
       O.total,
       I.itemid,
       I.prodid,
       I.actualprice,
       I.qty,
       I.itemtot,
       I.qty * I.actualprice
FROM   ord    O,
       item   I
WHERE  O.ordid < 622
AND    I.ordid = O.ordid
ORDER BY O.ordid;