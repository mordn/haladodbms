--801
drop table peldany;/
drop table konyvek;/
create table konyvek (
 ISBN number(10),
 cim varchar2(50),
 kiado varchar2(50),
 ev date,
 CONSTRAINT konyvek_pk primary key (ISBN));/
create table peldany (
 raktari_szam number(10),
 ISBN number(10),
 constraint peldany_pk primary key (raktari_szam),
 constraint peldany_fk foreign key (ISBN) references konyvek(ISBN));/

--802

create or replace package nyolcnullketto is
TYPE rekord IS RECORD (
    raktari_szam peldany.raktari_szam%Type,
    cim konyvek.cim%Type,
    kiado konyvek.kiado%Type,
    ev konyvek.ev%Type
  );
procedure beszur_konyv(p_isbn number, p_cim varchar2, p_kiado varchar2, p_ev date, p_raktari_szam number);
function torol_konyv(p_raktari_szam number) return number;
procedure listaz(p_isbn number, p_result out rekord);
nem_megfelelo_konyv exception;
letezo_raktari_szam exception;
nincs_ilyen_konyv exception;
end;/
create or replace package body nyolcnullketto as

CURSOR kurzor(p_isbn peldany.isbn%Type) IS 
    SELECT p.raktari_szam, k.cim, k.kiado, k.ev
    FROM peldany p
    INNER JOIN konyvek k on k.isbn = p.isbn
    WHERE p.isbn = p_isbn;
    
procedure beszur_konyv(p_isbn number, p_cim varchar2, p_kiado varchar2, p_ev date, p_raktari_szam number) as
konyv konyvek%rowtype;
begin
  begin
    insert into konyvek(ISBN, cim, kiado, ev) 
    values (p_isbn, p_cim, p_kiado, p_ev);
    exception
    when dup_val_on_index then
      select * into konyv
      from konyvek
      where isbn=p_isbn;
    IF konyv.cim != p_cim OR konyv.kiado != p_kiado OR konyv.ev != p_ev 
    THEN
      RAISE nem_megfelelo_konyv;
    END IF;
  end;
  begin
  insert into peldany (raktari_szam, ISBN) 
  values (p_raktari_szam, p_isbn);
  exception
    when dup_val_on_index then
      raise letezo_raktari_szam;
  end;
end;

function torol_konyv (p_raktari_szam number) return number as
  v_count number(5);
  v_isbn number(13);
begin
    delete from peldany
    where raktari_szam = p_raktari_szam
    returning isbn into v_isbn;
    select count(raktari_szam) into v_count
    from peldany
    where isbn = v_isbn;
    return v_count;
end;

procedure listaz (p_isbn number, p_result out rekord) as
  sor rekord;
  sor2 peldany%rowtype;
begin
	
select *
    into sor2
    from peldany 
    where ISBN = p_isbn;
    exception
    when no_data_found then 
      raise 
    nincs_ilyen_konyv;


    if not kurzor%isopen then 
    begin
      open kurzor(p_isbn);
      exception
      when no_data_found then 
        raise nincs_ilyen_konyv;
    end;
    end if;
    fetch kurzor into sor;
    if kurzor%found then
       p_result := sor;
    else
       p_result := null;
    end if;
end;
end;

--803
declare
valt NYOLCNULLKETTO.rekord;
szam number(10);
begin
  begin
    NYOLCNULLKETTO.beszur_konyv(911, 'asdasdasd', 'asd',sysdate,123);
    NYOLCNULLKETTO.beszur_konyv(911, 'hogyan bukjunk meg bdsmbol', 'Rácz Balázs',sysdate,100);
  exception
    when NYOLCNULLKETTO.nem_megfelelo_konyv then null;
    when NYOLCNULLKETTO.letezo_raktari_szam then null;   
  end;
  begin
    dbms_output.put_line(nyolcnullketto.TOROL_KONYV(123));
    dbms_output.put_line(NYOLCNULLKETTO.TOROL_KONYV(000));
  end;
  begin
    szam:=911;
    NYOLCNULLKETTO.listaz(szam, valt);
    exception
    when NYOLCNULLKETTO.nincs_ilyen_konyv then null;
  end;
end;