DECLARE
   sql_stmt   VARCHAR (1000);
BEGIN
   FOR rec
      IN (SELECT DISTINCT
                    'drop table '
                 || table_name
                 || '.'
                 || owner
                 || ' cascade constraints;'
                    AS cmd
            FROM dba_tables
           WHERE owner IN ('ROUTER', 'ATMMONITOR') AND table_name LIKE '%20%'
                 AND TO_NUMBER (SUBSTR (TO_CHAR (table_name), 3, 4)) <=
                        (SELECT TO_NUMBER ( (TO_CHAR (SYSDATE, 'YYYY')) - 3)
                           FROM DUAL)
                 AND TO_NUMBER (SUBSTR (TO_CHAR (table_name), 7, 2)) <=
                        (SELECT TO_NUMBER ( (TO_CHAR (SYSDATE, 'MM')) - 1)
                           FROM DUAL))
   LOOP
      EXECUTE IMMEDIATE rec.cmd;
   END LOOP;
END;


Создание JOB

BEGIN
sys.dbms_scheduler.disable( '"SYS"."MONTHLY_CLEAN"' ); 
sys.dbms_scheduler.set_attribute( name => '"SYS"."MONTHLY_CLEAN"', attribute => 'job_action', value => 'DECLARE
   sql_stmt   VARCHAR (1100);
BEGIN
   FOR rec
      IN (SELECT DISTINCT
                    ''drop table ''
                 || table_name
                 || ''.''
                 || owner
                 || '' cascade constraints;''
                    AS cmd
            FROM dba_tables
           WHERE owner IN (''ROUTER'', ''ATMMONITOR'') AND table_name LIKE ''%20%''
                 AND TO_NUMBER (SUBSTR (TO_CHAR (table_name), 3, 4)) <=
                        (SELECT TO_NUMBER ( (TO_CHAR (SYSDATE, ''YYYY'')) - 3)
                           FROM DUAL)
                 AND TO_NUMBER (SUBSTR (TO_CHAR (table_name), 7, 2)) <=
                        (SELECT TO_NUMBER ( (TO_CHAR (SYSDATE, ''MM'')) - 1)
                           FROM DUAL))
   LOOP
      EXECUTE IMMEDIATE rec.cmd;
   END LOOP;
END;'); 
sys.dbms_scheduler.set_attribute( name => '"SYS"."MONTHLY_CLEAN"', attribute => 'repeat_interval', value => 'FREQ=MONTHLY;BYMONTHDAY=9;BYHOUR=22;BYMINUTE=0;BYSECOND=0'); 
sys.dbms_scheduler.enable( '"SYS"."MONTHLY_CLEAN"' ); 
END;