--502
declare
mikor varchar2(50);
mennyi number;

function otnullketto (ido date default sysdate, format varchar2 default 'hh24:mi:ss')
return varchar2 as
begin
return to_char(ido,format);
end;

procedure otnullkettoketto (fname IN oe.customers.cust_first_name%type,lname IN oe.CUSTOMERS.CUST_LAST_NAME%type, mikor out varchar2, hany out number)
as
mikor2 OE.orders.order_date%type;
begin
select max(order_date)
into mikor2
from oe.orders
where customer_id = (
  Select customer_id from OE.CUSTOMERS where cust_first_name =fname and cust_last_name=lname
);
mikor:=otnullketto(mikor2);

select count(*)
into hany
from oe.order_items
where order_id in (
  select order_id from oe.orders 
  where customer_id =(
      Select customer_id from oe.customers
      where cust_first_name = fname and cust_last_name = lname));
end;
begin
mikor:=otnullketto;
dbms_output.put_line(mikor);
otnullkettoketto('Constantin','Welles',hany=>mennyi,mikor => mikor);
dbms_output.put_line(mikor || ' ' || mennyi);
otnullkettoketto(null,null,mikor,mennyi);
dbms_output.put_line(mikor || ' ' || mennyi);

end;


--503
CREATE OR REPLACE PROCEDURE otszazharom(
  firstname    IN  OE.CUSTOMERS.CUST_FIRST_NAME%Type,
  lastname     IN  OE.CUSTOMERS.CUST_LAST_NAME%Type,
  gender       OUT OE.CUSTOMERS.GENDER%Type,
  dateofbirth  OUT OE.CUSTOMERS.DATE_OF_BIRTH%Type
)IS
Begin
  SELECT GENDER, DATE_OF_BIRTH INTO gender, dateofbirth
  FROM OE.CUSTOMERS
  WHERE CUST_FIRST_NAME = firstname AND CUST_LAST_NAME = lastname;
End;


--504

Declare
  gender        OE.CUSTOMERS.GENDER%Type;
  dateofbirth   OE.CUSTOMERS.DATE_OF_BIRTH%Type;
  customer      OE.CUSTOMERS%RowType;
Begin
  SELECT * INTO customer
    FROM OE.CUSTOMERS ;
  --  WHERE customer_id = 101;
  otszazharom(customer.CUST_FIRST_NAME, customer.CUST_LAST_NAME, gender, dateofbirth);
  DBMS_OUTPUT.PUT_LINE(gender || ', ' || to_char(dateofbirth, 'YYYY.MM.DD.'));
  EXCEPTION
  WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
    DBMS_OUTPUT.put_line(SQLCODE || SQLERRM);
End;


--505

--create table CUSTOMERS as (select * from oe.customers)
--alter table CUSTOMERS add constraint pk primary key (customer_id);
DROP TABLE u_jbre9h.csaladtagok;
CREATE TABLE u_jbre9h.csaladtagok(
  azon NUMBER(6,0),
  nev varchar2(100),
  CONSTRAINT PK_azon_nev
    PRIMARY KEY (azon, nev),
  CONSTRAINT FK_azon  
    FOREIGN KEY (azon) 
    REFERENCES CUSTOMERS(CUSTOMER_ID)
);


--506
create or replace function insert_csalad(idje in CSALADTAGOK.AZON%type, neve IN CSALADTAGOK.NEV%type)
return
csaladtagok%rowtype is
csaladtag csaladtagok%rowtype;
begin
insert into csaladtagok(azon,nev)
values(idje,neve)
returning azon,neve into csaladtag;
return csaladtag;
exception
when dup_val_on_index then
declare
firstname oe.customers.cust_first_name%type;
lastname oe.customers.cust_last_name%type;
begin
select cust_first_name,cust_last_name
into firstname,lastname
from oe.customers
where customer_id = idje;
dbms_output.put_line(firstname||' '||lastname||' nevu ugyfel ' ||neve||'nevu csaladtagja mar letezik');
return null;
end;
end;


--507
create or replace procedure otnullhet(fname in oe.customers.cust_first_name%type,lname in oe.customers.cust_last_name%type, csaladtagnev in csaladtagok.nev%type) as
csaladtag csaladtagok%rowtype;
azon oe.customers.customer_id%type;
begin
  select customer_id
  into azon
  from oe.customers
  where cust_first_name = fname and cust_last_name = lname;
  csaladtag:=insert_csalad(azon,csaladtagnev);
  dbms_output.put_line(csaladtag.azon|| ' ' || csaladtag.nev); 
end;

--508
declare
cin exception;
pragma exception_init(cin,-1400);
begin
  begin
  otnullhet('Osama','Bin-Laden',null);
  exception
  when cin then
  dbms_output.put_line('Nincs csaladnev megadva');
  end;
  
  begin
  otnullhet('Nincs','Ilyen','ugysem');
  exception
  when no_data_found then
  dbms_output.put_line('Nincs ilyen nev a customers tablaban');
  end;
  
  begin
  otnullhet('Daniel','Costner','Kappa');
  exception
  when too_many_rows then
  dbms_output.put_line('több ilyen ember van a customers tablaban');
  end;
end; 

--509
create or replace procedure otnullhet(fname in oe.customers.cust_first_name%type,lname in oe.customers.cust_last_name%type, csaladtagnev in csaladtagok.nev%type) as
csaladtag csaladtagok%rowtype;
azon oe.customers.customer_id%type;
cin exception;
pragma exception_init(cin,-1400);
begin
  select customer_id
  into azon
  from customers
  where cust_first_name = fname and cust_last_name = lname;
  csaladtag:=insert_csalad(azon,csaladtagnev);
  dbms_output.put_line(csaladtag.azon|| ' ' || csaladtag.nev); 
  exception
  when cin then
  dbms_output.put_line('Nincs csaladnev megadva');
  when no_data_found then
  dbms_output.put_line('Nincs ilyen nev a customers tablaban');
  when too_many_rows then
  dbms_output.put_line('több ilyen ember van a customers tablaban');
end;


