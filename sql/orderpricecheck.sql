/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : orderpricecheck.sql
**
** DESCRIPTION
**   Check that the price on the order matches the stdprice on the price table.
**  
**   This report only includes order items with the incorrect prices, other items are
**   excluded.
**
**   See the report orderpricecheck_subq.sql for an example of how to include all order
**   item rows for orders that have the wrong price on any item.
**
**   Note that the Oracle demo seed data contains incorrect prices for some items.
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 11/08/2022   Ian Bond      Created report
*/

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

ACCEPT p_ordref_from PROMPT "Enter the starting Order Reference"
ACCEPT p_ordref_to PROMPT "Enter the ending Order Reference"
ACCEPT p_orderdate_from PROMPT "Enter the starting Order Date in format DD/MM/YYYY"
ACCEPT p_orderdate_to PROMPT "Enter the ending Order Date in format DD/MM/YYYY"

COLUMN ordid       HEADING 'Order ID'       FORMAT A8;
COLUMN ordref      HEADING 'Ord Ref'        FORMAT A10; 
COLUMN orderdate   HEADING 'Date Ordered'; 
COLUMN total       HEADING 'Total'          FORMAT 999,999.99;
COLUMN custid      HEADING 'Cust'           FORMAT A6;
COLUMN name        HEADING 'Name'           FORMAT A12;
COLUMN itemid      HEADING 'Item'           FORMAT 999;
COLUMN prodid      HEADING 'Product'        FORMAT A7;
COLUMN descrip     HEADING 'Description'    FORMAT A20;
COLUMN actualprice HEADING 'Price Paid'     FORMAT 9,999.99;
COLUMN stdprice    HEADING 'Std Price'      FORMAT 9,999.99;
COLUMN qty         HEADING 'Qty'            FORMAT 999,999;
COLUMN diff        HEADING 'Difference'     FORMAT 999,990.99;

BREAK ON ordid SKIP 2 NODUP

COMPUTE SUM OF itemtot ON ordid

SET PAGESIZE 66
SET NEWPAGE 0
SET LINESIZE 132

TTITLE CENTER 'Bond and Pollard Limited' SKIP 1 -
  CENTER ======================== SKIP 1-
  LEFT 'Order Price Check'  -
  RIGHT 'Page:' SQL.PNO SKIP 2
  
SELECT O.ordid,
       O.ordref,
       O.orderdate,
       O.total,
       O.custid,
       C.name,
       I.itemid,
       I.prodid,
       P.descrip,
       I.actualprice,
       V.stdprice,
       I.qty,
       (I.actualprice * I.qty) - (V.stdprice * I.qty) diff
FROM   ord O,
       customer C,
       item I,
       product P,
       price V
WHERE  ((O.ordref >= NVL('&p_ordref_from',O.ordref) AND O.ordref <= NVL('&p_ordref_to',O.ordref)) OR (O.ordref IS NULL AND '&p_ordref_from' IS NULL))
AND    O.orderdate >= NVL(to_date('&p_orderdate_from','DD/MM/YYYY'),O.orderdate) AND O.orderdate <= NVL(to_date('&p_orderdate_to','DD/MM/YYYY'),O.orderdate)
AND    C.custid = O.custid
AND    I.ordid (+) = O.ordid
AND    P.prodid (+) = I.prodid
AND    V.prodid = I.prodid
AND    V.startdate <= O.orderdate
AND    NVL(V.enddate,O.orderdate) >= O.orderdate
AND    V.stdprice <> I.actualprice
ORDER BY O.ordid, I.itemid;
