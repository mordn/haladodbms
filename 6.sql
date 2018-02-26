--601
CREATE OR REPLACE TRIGGER hatszazegy
  BEFORE INSERT OR 
  UPDATE OF marital_status, gender 
  ON CUSTOMERS
  FOR EACH ROW
Begin
  IF (:NEW.gender = 'F' AND :NEW.marital_status NOT IN('hajadon', 'f�rjes', '�zvegy'))
      OR (:NEW.gender = 'M' AND :NEW.marital_status NOT IN('n�tlen', 'n�s', '�zvegy')) 
  Then
    RAISE_APPLICATION_ERROR(-20010, 'Nem megfelel� nem �s/vagy csal�di �llapot');
  End IF;
End;



--602
Declare
  kivetel EXCEPTION;
  PRAGMA EXCEPTION_INIT (kivetel, -20010);
Begin
  INSERT INTO CUSTOMERS(CUSTOMER_ID,CUST_FIRST_NAME, CUST_LAST_NAME, MARITAL_STATUS, GENDER)
    VALUES(1000,'Kup', 'Ica', 'hajadon', 'F'); -- j� insert
  
  UPDATE CUSTOMERS SET MARITAL_STATUS = 'f�rjes' 
  WHERE CUST_FIRST_NAME = 'Kup' AND CUST_LAST_NAME = 'Ica'; -- j� update
 
  Begin
    INSERT INTO CUSTOMERS(CUSTOMER_ID,CUST_FIRST_NAME, CUST_LAST_NAME, MARITAL_STATUS, GENDER)
      VALUES(1001,'F�', 'Zolt�n', 'asdasda', 'M');  -- rossz insert
  Exception
    When kivetel Then
      DBMS_OUTPUT.put_line(SQLCODE || SQLERRM);
  End;

  Begin
    UPDATE CUSTOMERS SET MARITAL_STATUS = 'eartge' 
    WHERE CUST_FIRST_NAME = 'Kup' AND CUST_LAST_NAME = 'Ica';  -- rossz update
  Exception
    When kivetel Then
      DBMS_OUTPUT.put_line(SQLCODE || SQLERRM);
  End;
End;

--603

DROP TABLE naplo;/
CREATE TABLE naplo(
  nev VARCHAR2(20),
  modositas_datuma DATE,
  tabla_neve VARCHAR2(20),
  muvelet VARCHAR2(200)
);/

CREATE OR REPLACE TRIGGER hatszazharom_customers
  AFTER INSERT OR DELETE OR UPDATE ON CUSTOMERS --csak 1 tabla lehet itt, ha eldobom a tablat akkor rep�l a trigger is
Declare
  muvelet VARCHAR2(200);
Begin
  if INSERTING then
    muvelet := ''INSERT'';
  elsif DELETING then
    muvelet := ''DELETE'';
  elsif UPDATING then
    muvelet:= ''UPDATE'';
  end if;
  INSERT INTO naplo(nev, modositas_datuma, tabla_neve, muvelet)
  VALUES(USER, SYSDATE, ''CUSTOMERS'', muvelet);
End;



CREATE OR REPLACE TRIGGER hatszazharom_product_info
  AFTER INSERT OR DELETE OR UPDATE ON PRODUCT_INFORMATION 
Declare
  muvelet VARCHAR2(200);
Begin
  if INSERTING then
    muvelet := ''INSERT'';
  elsif DELETING then
    muvelet := ''DELETE'';
  elsif UPDATING then
    muvelet:= ''UPDATE'';
  end if;
  INSERT INTO naplo(nev, modositas_datuma, tabla_neve, muvelet)
  VALUES(USER, SYSDATE, ''PRODUCT_INFORMATION'', muvelet);
End;