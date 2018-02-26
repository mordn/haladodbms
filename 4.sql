--401
Declare
  FUNCTION egyesfeladat (
    azon OE.CUSTOMERS.CUSTOMER_ID%TYPE, 
    termek OE.ORDER_ITEMS.PRODUCT_ID%TYPE
  )
  Return number is
  darab number;
  Begin
    SELECT sum(ite.QUANTITY) 
    INTO darab
    FROM OE.CUSTOMERS cus 
     INNER JOIN OE.ORDERS ord ON cus.CUSTOMER_ID = ord.CUSTOMER_ID
     INNER JOIN OE.ORDER_ITEMS ite ON ord.ORDER_ID = ite.ORDER_ID
    WHERE cus.CUSTOMER_ID = azon AND ite.PRODUCT_ID = termek;
    return NVL(darab,0);
  End;
Begin
    FOR kurzor IN (
      SELECT CUSTOMER_ID, cust_first_name, cust_last_name
      FROM OE.CUSTOMERS
      WHERE CUST_LAST_NAME like 'T%')
    LOOP
      FOR kurzor2 IN (
        SELECT PRODUCT_ID, PRODUCT_NAME
        FROM OE.PRODUCT_INFORMATION
        WHERE LIST_PRICE < 500)
      LOOP     
        if (egyesfeladat(kurzor.customer_id,kurzor2.product_id)!=0) then
       DBMS_OUTPUT.PUT_LINE(kurzor.cust_first_name ||' '|| kurzor.cust_last_name ||' '|| egyesfeladat(kurzor.customer_id,kurzor2.product_id));
       end if;
      END LOOP; 
    END LOOP;
End;



--402
declare
x number(10,5);
y number(10,5);
z number(10,5);

procedure kettes(szam IN number,szinusza OUT number, koszinusza OUT number) is
begin
szinusza:=sin(szam/180*3.14); --mivel a sin függvény radiánt vár
koszinusza:=cos(szam/180*3.14);
end kettes;

begin
for x in 0..(360/15) loop
kettes(x*15,y,z);
dbms_output.put_line(x*15||','||y||','||z);
end loop;
end;




--403
CREATE OR REPLACE PROCEDURE negyszazharom(
  azon          IN  dolgozok.EMPLOYEE_ID%TYPE, 
  szazalek      IN  number,
  firstname     OUT dolgozok.FIRST_NAME%Type,
  lastname      OUT dolgozok.LAST_NAME%Type,
  newsalary     OUT number
) IS 
  
Begin
  UPDATE dolgozok
    SET salary = salary * (1 + szazalek / 100)
    WHERE employee_id = azon
    returning first_name, last_name, salary  into firstname, lastname, newsalary;
End;

--404
declare
  firstname      dolgozok.FIRST_NAME%Type;
  lastname       dolgozok.LAST_NAME%Type;
  salary         number;
  azon           DOLGOZOK.EMPLOYEE_ID%Type;
begin
  SELECT EMPLOYEE_ID 
  into azon
  from HR.EMPLOYEES
  where First_name = 'Steven' and Last_name='King';
    negyszazharom(azon, 50, firstname,lastname,salary);
  
  negyszazharom(129, -15, firstname,lastname,salary);
end;

--405

CREATE OR REPLACE FUNCTION negyszazot(honap IN number)
RETURN number IS
  darab number;
Begin
  SELECT count(*) INTO darab
  FROM OE.CUSTOMERS
  WHERE to_char(date_of_birth, 'MM') = honap;
  return darab;
End;

--406

SELECT negyszazot(12)
FROM DUAL;

--407

Begin
  DBMS_OUTPUT.put_line(negyszazot(12));
End;



