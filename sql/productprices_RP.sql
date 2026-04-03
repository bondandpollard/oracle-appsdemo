/*
** Copyright (c) 2022 Bond & Pollard Ltd. All rights reserved.  
** NAME   : productprices_RP.sql
**
** DESCRIPTION
**   Product prices report
**   Demonstrate use of a Rules Package to simplify queries and reduce coding
** 
**------------------------------------------------------------------------------------------------------------------------------
** MODIFICATION HISTORY
**
** Date         Name          Description
**------------------------------------------------------------------------------------------------------------------------------
** 05/08/2022   Ian Bond      Created script
*/

SELECT P.prodid,
       P.descrip,
       orderrp.currentprice(P.prodid) Actual_Price,
       orderrp.minprice(P.prodid) Minimum_Price
FROM product P;
