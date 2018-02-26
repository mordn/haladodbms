--701
declare
cursor kurzor is
  select product_name,quantity_on_hand from oe.warehouses
  inner join oe.inventories
  using (warehouse_id)
  inner join oe.product_information
  using (product_id)
  where warehouse_id = 6;
TYPE r_termek is record(
  nev OE.PRODUCT_INFORMATION.product_name%TYPE,
  darab OE.INVENTORIES.quantity_on_hand%TYPE
);
termek r_termek;
begin
open kurzor;
loop
  fetch kurzor into termek;
  exit when kurzor%NOTFOUND;
  dbms_output.put_line(termek.nev||' '||termek.darab);
end loop;
end;


--702
CREATE OR REPLACE PROCEDURE hetnullketto(
  raktar_id OE.inventories.warehouse_id%type
) 
is
  CURSOR kurzor IS 
    select product_id from inventories
    where warehouse_id = raktar_id 
    and product_id not in (
       select distinct product_id from inventories
       where warehouse_id !=raktar_id 
   )
  FOR UPDATE;
  valami oe.product_information.product_id%type;
Begin
  OPEN kurzor;
  LOOP
    FETCH kurzor INTO valami;
    EXIT WHEN kurzor%NOTFOUND;
    UPDATE product_information
      SET list_price = list_price * 1.1
      WHERE CURRENT OF kurzor;
  END LOOP;
  CLOSE kurzor;
End;

--703
Begin
  hetnullketto(1);
  commit;
end;

--704
create or replace procedure hetnullnegy(gyenge_kurzor IN sys_refcursor, szam OUT number, szoveg OUT varchar2)
as
begin
if gyenge_kurzor%isopen then
    fetch gyenge_kurzor into szam,szoveg; 
    if gyenge_kurzor%notfound then
    raise_application_error(-20001,''Nincs több sor'');
    end if;
else 
  raise_application_error(-20002,''Nincs nyitva a kurzor'');
end if;
end;

--705
declare
type rekord is record (szam number, szoveg varchar2(30));
type eros_kurzor is ref cursor return rekord;
kurzor eros_kurzor;
szam number;
nev varchar2(50);
hiba exception;
pragma exception_init(hiba, -20001);

begin
  begin
    open kurzor for 
       select department_id, department_name
       from hr.departments;
       HETNULLNEGY(kurzor, szam, nev);
       HETNULLNEGY(kurzor, szam, nev);
       HETNULLNEGY(kurzor, szam, nev);
    exception
    when hiba then
      DBMS_OUTPUT.put_line(SQLCODE || SQLERRM);
  end;
  
  begin
    open kurzor for 
      select employee_id, first_name
      from hr.employees;
      HETNULLNEGY(kurzor, szam, nev);
  
    exception
    when hiba then
      DBMS_OUTPUT.put_line(SQLCODE || SQLERRM);
  end;
end;