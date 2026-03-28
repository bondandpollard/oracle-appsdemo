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


CREATE OR REPLACE PACKAGE BODY orderrp AS
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


  FUNCTION currentprice ( 
    p_prodid IN NUMBER
  ) 
  RETURN NUMBER
  IS
    l_currentprice price.stdprice%TYPE;
  BEGIN
    SELECT MAX(stdprice) INTO l_currentprice
    FROM   price
    WHERE  prodid = p_prodid
    AND    startdate <= SYSDATE
    AND    NVL(enddate,SYSDATE) >= SYSDATE;
    RETURN NVL(l_currentprice,0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END currentprice;
  
  
  FUNCTION priceondate ( 
    p_prodid IN NUMBER,
    p_date   IN DATE DEFAULT SYSDATE
  ) 
  RETURN NUMBER
  IS
     l_price price.stdprice%TYPE;
     l_date DATE;
  BEGIN
    l_date := NVL(p_date, SYSDATE);
    SELECT MAX(stdprice) INTO l_price
    FROM   price
    WHERE  prodid = p_prodid
    AND    startdate <= l_date
    AND    NVL(enddate,SYSDATE) >= l_date;
    RETURN NVL(l_price,0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END priceondate;
  

  FUNCTION minprice ( 
    p_prodid IN NUMBER
  ) 
  RETURN NUMBER
  IS
    l_minprice price.stdprice%TYPE;
  BEGIN
    SELECT MAX(minprice) INTO l_minprice
    FROM   price
    WHERE  prodid = p_prodid
    AND    startdate <= SYSDATE
    AND    NVL(enddate,SYSDATE) >= SYSDATE;
    RETURN NVL(l_minprice,0);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 0;
  END minprice;

END orderrp;
/
