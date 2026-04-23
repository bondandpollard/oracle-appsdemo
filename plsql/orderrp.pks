CREATE OR REPLACE PACKAGE orderrp AS
  /*
  ** (c) Bond and Pollard Ltd 2022
  ** This software is free to use and modify at your own risk.
  ** 
  ** Module Name   : orderrp
  ** Description   : Order Rules Package
  ** 
  **------------------------------------------------------------------------
  ** Modification History
  **  
  ** Date            Name                 Description
  **------------------------------------------------------------------------
  ** 05/08/2022     Ian Bond              Program created
  ** 23/04/2026     Ian Bond              Comment added as test
  **   
  */


  /*
  ** Global constants
  */


  /*
  ** Global variables
  */


  /*
  ** Global exceptions
  */



  /*
  ** Public functions and procedures
  */

  /*
  ** currentprice - return the current price of a product
  **
  ** Returns the product price that is effective 
  ** at the current date.
  **
  ** IN
  **   p_prodid         - Product ID
  ** RETURN
  **   NUMBER the current price of the product
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION currentprice ( 
    p_prodid IN NUMBER
  ) RETURN NUMBER;

  /*
  ** priceondate - return the product price effective at specified date
  **
  ** Returns the product price that is effective 
  ** at the specified date.
  **
  ** IN
  **   p_prodid         - Product ID
  **   p_date           - Effective date of product price, default current date
  ** RETURN
  **   NUMBER the price of the product
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION priceondate ( 
    p_prodid IN NUMBER,
    p_date   IN DATE DEFAULT SYSDATE
  ) RETURN NUMBER;
  
  /*
  ** minprice - return the minimum price of a product
  **
  ** Returns the product's minimum price that is effective 
  ** at the current date.
  **
  ** IN
  **   p_prodid         - Product ID
  ** RETURN
  **   NUMBER the minimum price of the product
  ** EXCEPTIONS
  **   <exception_name1>      - <brief description>
  */
  FUNCTION minprice ( 
    p_prodid IN NUMBER
  ) RETURN NUMBER;


END orderrp;
/
