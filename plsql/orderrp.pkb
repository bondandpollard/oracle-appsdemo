CREATE OR REPLACE PACKAGE BODY orderrp AS

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
