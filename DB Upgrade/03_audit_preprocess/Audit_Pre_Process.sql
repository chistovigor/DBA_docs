Rem **********************************************************************
Rem    NAME
Rem      Audit_Pre_Process.sql
Rem
Rem    DESCRIPTION
Rem      This script can be used to update null DBID columns in audit tables
Rem      AUD$ and FGA_LOG$ in 10g and 11g databases prior to upgrading to
Rem      11gR1 or later.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim      07/27/11 - Take .1 MOS
Rem    cmlim      07/26/11 - Change rows_updated to reflect the # of rows just
Rem                        - updated (versus an accumulative # of updated rows)
Rem    cmlim      07/12/11 - Replaced count(rowid) with count(*)
Rem    cmlim      05/06/11 - Replaced original populate_dbid_audit with
Rem                          new one to speed up update

set echo on
set serveroutput on
set timing on

create or replace procedure populate_dbid_audit(tab_owner VARCHAR2,
                                                tab_name  VARCHAR2)
as
  cur_dbid  number := 0; 
  type ctyp is ref cursor; 
  rowid_cur ctyp; 
  rowid_tab dbms_sql.urowid_table;
  nrows number := 0;
  rows_updated number := 0;
  rows_not_updated number := 0;
  counter number := 0;
  current_time timestamp(6);
begin 

  execute immediate
    'select count(*) from ' || tab_owner || '.' || tab_name || 
    ' where dbid is null' into nrows;

  counter := ceil(nrows/1000000);
  dbms_output.put_line('.');
  dbms_output.put_line('-------------------------------------------------------------------------');
  IF (counter = 0) THEN
    dbms_output.put_line('There are not any null DBIDs in ' || tab_owner ||
                         '.' || tab_name || ' to update.');
    dbms_output.put_line('-------------------------------------------------------------------------');
    return;
  ELSE
    dbms_output.put_line('Will update at least ' || nrows || ' rows.');
    select current_timestamp into current_time from dual;
    dbms_output.put_line('Start DBID update in ' || tab_owner || '.' ||
                          tab_name || ' at: ' || current_time || '...');
  END IF;
   
  select dbid into cur_dbid from v$database;

  -- Populate column DBID in audit table if NULL.

  LOOP
    IF (counter = 0) THEN
      EXIT;
    END IF;

    OPEN rowid_cur FOR 'select rowid from ' || tab_owner || '.' || tab_name || 
                       ' where dbid is null and rownum <= 1000000';

    FETCH rowid_cur bulk collect into rowid_tab limit 100000;

    IF (rowid_tab.count = 0) THEN 
      EXIT; 
    END IF;

    LOOP 
      FORALL i in 1..rowid_tab.count 
        execute immediate 
          'UPDATE ' || tab_owner || '.' || tab_name || 
          ' SET dbid = ' || cur_dbid || 
          ' WHERE dbid IS NULL and rowid = :1' using rowid_tab(i); 
      COMMIT;
      IF (counter = 1 and nrows <= 100000) THEN
        rows_updated := rows_updated + rowid_tab.count;
        EXIT;
      END IF;
      nrows := nrows - 100000;
      rows_updated := rows_updated + 100000;
      FETCH rowid_cur bulk collect into rowid_tab limit 100000;
      IF (rowid_tab.count = 0) THEN 
        EXIT; 
      END IF;
    END LOOP;
    counter := counter - 1;
  END LOOP;
  CLOSE rowid_cur;
  COMMIT;

  dbms_output.put_line('Rows in table just updated: ' || rows_updated);
  execute immediate
    'select count(*) from ' || tab_owner || '.' || tab_name || 
    ' where dbid is null' into rows_not_updated;
  dbms_output.put_line('Total rows in table not yet updated: ' || rows_not_updated);
  select current_timestamp into current_time from dual;
  dbms_output.put_line('End update at: ' || current_time || '.');
  dbms_output.put_line('-------------------------------------------------------------------------');
  
EXCEPTION
  WHEN OTHERS THEN
    rollback;
END;
/

declare
  schema     varchar2(32);
begin
   -- First, check where is AUD$ present
   select u.name into schema from obj$ o, user$ u
          where o.name = 'AUD$' and
                o.type#=2 and
                o.owner# = u.user# and 
                o.remoteowner is NULL and
                o.linkname is NULL and
                u.name in ('SYS', 'SYSTEM');

   populate_dbid_audit(schema, 'AUD$');
   populate_dbid_audit('SYS', 'FGA_LOG$');
end;
/
  
drop procedure populate_dbid_audit;

Rem **********************************************************************

