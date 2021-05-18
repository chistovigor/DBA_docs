create or replace procedure check_redef AS

CURSOR tables_c is
SELECT table_name from tables_in_tbs FOR UPDATE;
BEGIN
        FOR table_rec in tables_c       LOOP
        BEGIN
        DBMS_REDEFINITION.CAN_REDEF_TABLE('&owner',table_rec.table_name,dbms_redefinition.cons_use_rowid);
        UPDATE tables_in_tbs SET can_redef = 'YES' WHERE CURRENT OF tables_c;
        EXCEPTION
        WHEN OTHERS THEN
        UPDATE tables_in_tbs SET can_redef = 'NO' WHERE CURRENT OF tables_c;
        END;
        END LOOP;
end check_redef;
/
show errors;

