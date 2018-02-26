--901
create or replace type keresztnevek is table of varchar2(30);

--902
Create or replace procedure kilencnullketto(nevek in keresztnevek) is --asszociativ tombot kap
  Type nevek_tipus is table of NUMBER index by VARCHAR2(30); --kollekciotipus letrehozasa
  nevek2 nevek_tipus; --kollekciovaltozo deklaralasa
  i VARCHAR2(30); --indexe, ami stringekbol all
Begin
  i := nevek.first;  --i:beagyazott tabla elsõ elemének indexe
  while i is not null loop
    if nevek2.exists(nevek(i)) then
      nevek2(nevek(i)):=nevek2(nevek(i))+1;
    else
      nevek2(nevek(i)):=1;
    End if;
    i:= nevek.next(i);
  End loop;
  
  i := nevek2.first;
  while i is not null loop
    DBMS_OUTPUT.PUT_LINE(i || ': ' || nevek2(i));
    i:= nevek2.next(i);
  End loop;  
End;

--903
declare
  nevek keresztnevek;
begin
  select cust_first_name 
  bulk collect into nevek
  from OE.CUSTOMERS;
  kilencnullketto(nevek);
end;

--904
CREATE OR REPLACE TYPE termek_nevek IS TABLE OF varchar2(50);/
CREATE OR REPLACE FUNCTION kilencnullnegy (
  nev IN OE.WAREHOUSES.warehouse_name%Type) 
RETURN termek_nevek
AS
  v_termek_nevek termek_nevek;
Begin
  SELECT distinct product_name
  BULK COLLECT INTO v_termek_nevek
  FROM OE.WAREHOUSES
    inner JOIN OE.INVENTORIES 
      using (warehouse_id)
    inner JOIN OE.PRODUCT_INFORMATION
      using (product_id) 


  WHERE warehouse_name = nev;
  return v_termek_nevek;
End;

--905
declare
nev termek_nevek;
i varchar2(50);
begin
nev:=kilencnullnegy('Bombay');
i:=nev.first;
while i is not null
  loop
    dbms_output.put_line(nev(i));
    i:=nev.next(i);
  end loop;
end;

--906
declare
  type job_title is table of HR.JOBS.job_title%type;
  type min_salary is table of HR.JOBS.min_salary%type;
  type max_salary is table of HR.JOBS.max_salary%type;
  title job_title;
  minsalary min_salary;
  maxsalary max_salary;
  please_integer PLS_INTEGER;
begin
  select job_title, min_salary, max_salary 
    bulk collect into title, minsalary, maxsalary
    from hr.jobs;
  for i in 1..title.count
    loop
      if minsalary(i) > maxsalary(i) / 2 then
        title.DELETE(i);
      end if;
    end loop;
  please_integer := title.first;
  loop
    exit when please_integer is null;
    DBMS_OUTPUT.PUT_LINE(title(please_integer));
    please_integer := title.next(please_integer);
  end loop;
  forall i in INDICES OF title
    update employees emp
    set emp.salary = emp.salary + maxsalary(i) * 0.1
    where emp.job_id = (
      select jobs.job_id
      from HR.JOBS jobs
      where job_title = title(i)
    );
  commit;
end;

--907
Create or replace type rekord is object(
  nev VARCHAR2(100),
  datum DATE
);/
Create or replace TYPE dinamikus_tomb IS VARRAY(10) OF rekord;/
Create or replace function kilencnullhet(nev VARCHAR2) return dinamikus_tomb is
  tomb dinamikus_tomb;
Begin
  Select * 
  bulk collect into tomb 
  from (
    Select rekord(HR.EMPLOYEES.first_name || ' ' || HR.EMPLOYEES.last_name,
    HR.EMPLOYEES.hire_date) 
    from HR.EMPLOYEES
    inner join HR.DEPARTMENTS using (department_id)
    where HR.DEPARTMENTS.department_name=nev
    order by HR.EMPLOYEES.hire_date)
  where ROWNUM <= 10;
  return tomb;
End;

--908
DECLARE
  tomb dinamikus_tomb;
BEGIN
  tomb := KILENCNULLHET('IT');
  for i in 1 .. tomb.count loop
    DBMS_OUTPUT.PUT_LINE(i ||': ' || tomb(i).nev || tomb(i).datum);
  end loop;
END;