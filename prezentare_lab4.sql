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
    
    for v_contor IN fib_table.FIRST..fib_table.COUNT LOOP
        if fib_table.exists(v_contor) THEN
            DBMS_OUTPUT.PUT_LINE(fib_table(v_contor));
        END IF;    
    END LOOP;
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


--Get data into nested table

DECLARE 
   CURSOR studenti_cursor IS SELECT * FROM studenti;
   TYPE linie_student IS TABLE OF studenti_cursor%ROWTYPE;
   tabela_studenti linie_student;
BEGIN
   open studenti_cursor;
   SELECT * BULK COLLECT INTO tabela_studenti FROM studenti ORDER BY studenti.nume;
   close studenti_cursor;
   for i in tabela_studenti.first..tabela_studenti.last loop
        if tabela_studenti.exists(i) then -- daca incerc sa afisez ceva ce nu exista se va produce o eroare
           DBMS_OUTPUT.PUT_LINE(i||' - '||tabela_studenti(i).nume);  -- afisam pozitia si valoarea
        end if;
    end loop;   
    DBMS_OUTPUT.PUT_LINE('Numar studenti: '||tabela_studenti.COUNT);
END;



DECLARE
    v_iterator NUMBER := 0;
BEGIN
    FOR v_contor IN 1..10 LOOP
        DBMS_OUTPUT.PUT_LINE('Contor : ' || v_contor);
        DBMS_OUTPUT.PUT_LINE('Iterator : ' || v_iterator);
        v_iterator := v_iterator + 1;
    END LOOP;    
END;

    
    