/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : sales_lowprice_loss.sql
**
** DESCRIPTION
**   Report lost sales revenue due to undercharging customers, where the actual sold price is 
**   less than the standard price.
**
**   Use GROUP BY to report the total amount of lost revenue by customer and order.
**
**   Use a HAVING clause to only include customers orders where the total value was too low.
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

COLUMN custid      HEADING 'Cust'           FORMAT A6;
COLUMN name        HEADING 'Name'           FORMAT A12;
COLUMN ordid       HEADING 'Order ID'       FORMAT A8;
COLUMN ordref      HEADING 'Ord Ref'        FORMAT A10; 
COLUMN orderdate   HEADING 'Date Ordered'; 
COLUMN total       HEADING 'Order Total'          FORMAT 999,999.99;
COLUMN loss        HEADING 'Lost Revenue'     FORMAT 999,990.99;

BREAK ON ordid SKIP 2 NODUP

COMPUTE SUM OF itemtot ON ordid

SET PAGESIZE 66
SET NEWPAGE 0
SET LINESIZE 132

TTITLE CENTER 'Bond and Pollard Limited' SKIP 1 -
  CENTER ======================== SKIP 1-
  LEFT 'Lost Revenue due to undercharging (price errors)'  -
  RIGHT 'Page:' SQL.PNO SKIP 2
  
SELECT O.custid,
       C.name,
       O.ordid,
       O.ordref,
       O.orderdate,
       SUM(I.actualprice * I.qty) total,
       SUM((I.actualprice * I.qty) - (V.stdprice * I.qty)) loss
FROM   ord O,
       customer C,
       item I,
       price V
WHERE  ((O.ordref >= NVL('&p_ordref_from',O.ordref) AND O.ordref <= NVL('&p_ordref_to',O.ordref)) OR (O.ordref IS NULL AND '&p_ordref_from' IS NULL))
AND    O.orderdate >= NVL(to_date('&p_orderdate_from','DD/MM/YYYY'),O.orderdate) AND O.orderdate <= NVL(to_date('&p_orderdate_to','DD/MM/YYYY'),O.orderdate)
AND    C.custid = O.custid
AND    I.ordid (+) = O.ordid
AND    V.prodid = I.prodid
AND    V.startdate <= O.orderdate
AND    NVL(V.enddate,O.orderdate) >= O.orderdate
AND    O.ordid IN (
               SELECT DISTINCT(O.ordid)
               FROM   ord   O,
                      item  I,
                      price X -- Different alias to Price in outer query to avoid confusion 
               WHERE  ((O.ordref >= NVL('&p_ordref_from',O.ordref) AND O.ordref <= NVL('&p_ordref_to',O.ordref)) OR (O.ordref IS NULL AND '&p_ordref_from' IS NULL))
               AND    O.orderdate >= NVL(to_date('&p_orderdate_from','DD/MM/YYYY'),O.orderdate) AND O.orderdate <= NVL(to_date('&p_orderdate_to','DD/MM/YYYY'),O.orderdate)
               AND    I.ordid (+) = O.ordid
               AND    X.prodid = I.prodid
               AND    X.startdate <= O.orderdate
               AND    NVL(X.enddate,O.orderdate) >= O.orderdate
               AND    X.stdprice <> I.actualprice
               )
GROUP BY O.custid,
         C.name,
         O.ordid,
         O.ordref,
         O.orderdate
HAVING   SUM((I.actualprice * I.qty) - (V.stdprice * I.qty)) < 0  -- Include only customer orders that  we undercharged on
ORDER BY O.custid,
         O.ordid;
