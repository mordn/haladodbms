--1001
CREATE OR REPLACE PROCEDURE tiznullegy(str in STRING) IS
  TYPE rekord IS RECORD(
    elso VARCHAR2(1000),
    masodik VARCHAR2(1000)
  );
  TYPE tabla_tipus IS TABLE OF rekord;
  tabla tabla_tipus;
  tul_keves_oszlop exception;
  tul_sok_oszlop exception;
  pragma exception_init(tul_keves_oszlop, -1007);  
  pragma exception_init(tul_sok_oszlop, -932); 
Begin
  if upper(substr(str, 0, 6)) != 'SELECT' THEN
    RAISE_APPLICATION_ERROR(-20911, 'Nem lekérdezés');
  END IF;
  Begin
    EXECUTE IMMEDIATE str 
    BULK COLLECT INTO tabla;
    FOR i IN tabla.FIRST..tabla.LAST LOOP
      dbms_output.put_line(tabla(i).elso || ' - - ' || tabla(i).masodik);
    END LOOP;
    exception 
    when tul_keves_oszlop   
       then DBMS_OUTPUT.PUT_LINE('Nem megfelelõ lekérdezés ' || SQLCODE || SQLERRM);
    when tul_sok_oszlop
       then DBMS_OUTPUT.PUT_LINE('Nem megfelelõ lekérdezés ' || SQLCODE || SQLERRM); 
  End;
END;