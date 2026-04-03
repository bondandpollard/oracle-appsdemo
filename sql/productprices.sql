/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : productprices.sql
**
** DESCRIPTION
**   Product prices report
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 21/07/2022   Ian Bond      Created report
*/

SELECT P.prodid,
       P.descrip,
       V.startdate,
       V.enddate,
       V.stdprice
FROM   product P,
       price V
WHERE  V.prodid = P.prodid
AND    V.startdate <= SYSDATE
AND    NVL(V.enddate,SYSDATE) >= SYSDATE;