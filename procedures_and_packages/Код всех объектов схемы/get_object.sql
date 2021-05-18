SET LONG 2000000
SET HEAD OFF
SET ECHO OFF
SET PAGESIZE 0
SET VERIFY OFF
SET FEEDBACK OFF
SET TERMOUT OFF
set serveroutput on
SPOOL etc/&&2..txt


BEGIN

    FOR rec IN (SELECT a.object_name
                  FROM user_objects a
                 WHERE a.object_type = '&&4' AND a.generated = 'N'
                ORDER BY a.object_name)
    LOOP
	
	    DBMS_OUTPUT.put_line ('SET LONG 2000000
SET HEAD OFF
SET ECHO OFF
SET LINESIZE 250
SET TERMOUT OFF
COLUMN ddl_source FORMAT A250
');

        DBMS_OUTPUT.put_line (
               'SPOOL &&1/&&2/'
            || lower(rec.object_name) || '.txt'
            || '

SELECT DBMS_METADATA.get_ddl (''&&3'', '''
            || rec.object_name 
            || ''') as ddl_source from dual;
');
DBMS_OUTPUT.put_line ('SPOOL OFF');
    END LOOP;
END;
/

spool off

@etc/&&2..txt;


set serveroutput off;

SET FEEDBACK ON
SET HEADING ON
SET TERMOUT ON






