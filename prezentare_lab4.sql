set SERVEROUT on

-- Fib in Nested Table

DECLARE
    TYPE number_table IS TABLE OF NUMBER;
    fib_table number_table;
    max_nr_of_elements CONSTANT INTEGER := 12; 
BEGIN
    fib_table := number_table(1, 1);
    
    for v_contor IN 3..max_nr_of_elements LOOP
        fib_table.EXTEND;
        
        fib_table(fib_table.LAST) :=    fib_table(fib_table.LAST - 1) + 
                                        fib_table(fib_table.LAST - 2);
    END LOOP;
    
    for v_contor IN fib_table.FIRST..fib_table.LAST LOOP
        if fib_table.exists(v_contor) THEN
            DBMS_OUTPUT.PUT_LINE(fib_table(v_contor));
        END IF;    
    END LOOP;
END;

--Matrix example

DECLARE
    TYPE number_table IS TABLE OF NUMBER;
    TYPE number_matrix IS TABLE OF number_table;
    
    row1 number_table := number_table(1, 2, 3);
    row2 number_table := number_table(4, 5, 6);
    row3 number_table := number_table(7, 8, 9);
    
    matrix number_matrix := number_matrix(row1, row2, row3);
    
    suma_diagonala NUMBER := 0;
BEGIN
    
    for v_row_it IN matrix.FIRST..matrix.COUNT LOOP
        if matrix.exists(v_row_it) THEN
            for v_column_it IN matrix(v_row_it).FIRST..matrix(v_row_it).LAST LOOP
        
                if v_row_it = v_column_it AND matrix(v_row_it).exists(v_column_it) THEN
                    suma_diagonala := suma_diagonala + matrix(v_row_it)(v_column_it);
                END IF;
            END LOOP;    
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE(suma_diagonala);
END;


-- Deleting element

DECLARE
    TYPE nume IS TABLE OF VARCHAR2(10);
    laptopuri nume;
BEGIN
    laptopuri := nume('DELL', 'LENOVO', 'ASUS');
    laptopuri.delete(2);
    laptopuri(2) := 'MACBOOK';
    
    for v_contor IN laptopuri.FIRST..laptopuri.LAST LOOP
        if laptopuri.exists(v_contor) THEN
            DBMS_OUTPUT.PUT_LINE(laptopuri(v_contor));
        END IF;
    END LOOP;
END;

--Not null example

DECLARE
    TYPE exemple IS TABLE OF VARCHAR2(3) NOT NULL;
    v_exemple exemple;
BEGIN
    v_exemple := exemple();
    v_exemple.EXTEND;
    v_exemple(v_exemple.LAST) := NULL;
    DBMS_OUTPUT.PUT_LINE('Program doesn t get here');
END;

--Extend with nothing example

DECLARE
    TYPE exemple IS TABLE OF NUMBER NOT NULL;
    v_exemple exemple;
BEGIN
    v_exemple := exemple(1);
    v_exemple.EXTEND;
    DBMS_OUTPUT.PUT_LINE(v_exemple(v_exemple.LAST)); -- NO ERROR
    DBMS_OUTPUT.PUT_LINE(v_exemple.COUNT);
END;

--Last different from count

DECLARE
    TYPE exemple IS TABLE OF NUMBER NOT NULL;
    v_exemple exemple;
BEGIN
    v_exemple := exemple(1, 2);
    v_exemple.EXTEND;
    DBMS_OUTPUT.PUT_LINE(v_exemple(v_exemple.LAST));
    DBMS_OUTPUT.PUT_LINE(v_exemple.COUNT);
    v_exemple.DELETE(2);
    DBMS_OUTPUT.PUT_LINE(v_exemple.COUNT);
    DBMS_OUTPUT.PUT_LINE(v_exemple.LAST);
END;

--Delete and extend

DECLARE
    TYPE cuvinte IS TABLE OF varchar2(10);
    propozitie cuvinte;
BEGIN
    propozitie := cuvinte('Azi', 'am', 'prezentare');  
    propozitie.EXTEND(2,3);
    propozitie.delete(1);
    propozitie.TRIM;
    for i in propozitie.first..propozitie.last LOOP
        if propozitie.exists(i) THEN
           DBMS_OUTPUT.PUT_LINE(propozitie(i));
        end IF;
    END LOOP;
END;

--Get data into nested table

DECLARE 
   CURSOR studenti_cursor IS SELECT * FROM studenti ORDER BY studenti.nume;
   TYPE linie_student IS TABLE OF studenti_cursor%ROWTYPE;
   tabela_studenti linie_student;
BEGIN
   --open studenti_cursor;
   SELECT * BULK COLLECT INTO tabela_studenti FROM studenti ORDER BY studenti.nume;
   --close studenti_cursor;
   for i in tabela_studenti.first..tabela_studenti.last loop
        if tabela_studenti.exists(i) then -- daca incerc sa afisez ceva ce nu exista se va produce o eroare
           DBMS_OUTPUT.PUT_LINE(i||' - '||tabela_studenti(i).nume);  -- afisam pozitia si valoarea
        end if;
    end loop;   
    DBMS_OUTPUT.PUT_LINE('Numar studenti: '||tabela_studenti.COUNT);
END;

--Get data into nested table with next

DECLARE 
   CURSOR studenti_cursor IS SELECT * FROM studenti ORDER BY studenti.nume;
   TYPE linie_student IS TABLE OF studenti_cursor%ROWTYPE;
   tabela_studenti linie_student;
   v_index Number := 0;
BEGIN
   --open studenti_cursor;
   SELECT * BULK COLLECT INTO tabela_studenti FROM studenti ORDER BY studenti.nume;
   --close studenti_cursor;
   
   v_index := tabela_studenti.first;
   
   LOOP
       DBMS_OUTPUT.PUT_LINE(v_index||' - '||tabela_studenti(v_index).nume); 
       v_index := tabela_studenti.NEXT(v_index);
       EXIT WHEN v_index IS NULL;
   END LOOP;
 
    DBMS_OUTPUT.PUT_LINE('Numar studenti: '||tabela_studenti.COUNT);
END;

--Fetch method


DECLARE 
   CURSOR studenti_cursor IS SELECT * FROM studenti ORDER BY studenti.nume;
   TYPE linie_student IS TABLE OF studenti_cursor%ROWTYPE;
   tabela_studenti linie_student := linie_student();
BEGIN
   OPEN studenti_cursor;
   LOOP
    tabela_studenti.EXTEND;
    FETCH studenti_cursor INTO tabela_studenti(tabela_studenti.LAST);
    EXIT WHEN studenti_cursor%NOTFOUND;
   END LOOP;
   CLOSE studenti_cursor;
   
   for i in tabela_studenti.first..tabela_studenti.last loop
        if tabela_studenti.exists(i) then
           DBMS_OUTPUT.PUT_LINE(i||' - '||tabela_studenti(i).nume);
        end if;
    end loop;   
    DBMS_OUTPUT.PUT_LINE('Numar studenti: '||tabela_studenti.COUNT);
END;

--Multiset operations

DECLARE
    TYPE nume IS TABLE OF VARCHAR2(10);
    orase1 nume := nume('IASI', 'BUCURESTI', 'ORADEA');
    orase2 nume := nume('IASI', 'TIMISOARA');
    orase3 nume;
BEGIN
    orase3 := orase1 MULTISET UNION DISTINCT orase2;
    
    for v_contor IN orase3.FIRST..orase3.LAST LOOP
        if orase3.exists(v_contor) THEN
            DBMS_OUTPUT.PUT_LINE(orase3(v_contor));
        END IF;
    END LOOP;
END;

--Camp cu Nested Table

GRANT CREATE TYPE TO STUDENT; -- aceasta linie se executa din "SYS as SYSDBA"

CREATE OR REPLACE TYPE lista_prenume AS TABLE OF VARCHAR2(10);
/
CREATE TABLE persoane (nume varchar2(10), 
       prenume lista_prenume)
       NESTED TABLE prenume STORE AS lista;
/       

INSERT INTO persoane VALUES('Popescu', lista_prenume('Ionut', 'Razvan'));
INSERT INTO persoane VALUES('Ionescu', lista_prenume('Elena', 'Madalina'));
INSERT INTO persoane VALUES('Rizea', lista_prenume('Mircea', 'Catalin'));
/
SELECT * FROM persoane;


DECLARE    
    sir_prenume persoane.prenume%type;
BEGIN
    sir_prenume := lista_prenume('Cristi', 'Tudor', 'Virgil');
    INSERT INTO persoane VALUES ('Gurau', sir_prenume);
    DBMS_OUTPUT.PUT_LINE('Gata');
END;

----------------------------

DECLARE
    v_iterator NUMBER := 0;
BEGIN
    FOR v_contor IN 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE('Contor : ' || v_contor);
        DBMS_OUTPUT.PUT_LINE('Iterator : ' || v_iterator);
        v_iterator := v_iterator + 1;
    END LOOP;    
END;

    
    