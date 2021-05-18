--APPLY script

--script 01

DECLARE
    V_DAYSTOIGNORE   NUMBER DEFAULT 0;
    V_SCHEMANAME     VARCHAR2 (20) DEFAULT 'OWS';
    V_DEGREE         NUMBER DEFAULT 16;
BEGIN
    DBMS_OUTPUT.ENABLE;

    DBMS_STATS.SET_GLOBAL_PREFS ('PUBLISH', 'FALSE');

    FOR REC
        IN (  SELECT OWNER, TABLE_NAME, BLOCKS
                FROM DBA_TABLES
               WHERE     OWNER = V_SCHEMANAME
                     AND (       TABLE_NAME NOT LIKE '%$%'
                             AND TABLE_NAME NOT LIKE 'OLD\_%' ESCAPE '\'
                             AND TABLE_NAME NOT LIKE 'SYS\_IOT\_%' ESCAPE '\'
                             AND LAST_ANALYZED IS NULL
                          OR LAST_ANALYZED < SYSDATE - V_DAYSTOIGNORE)
            ORDER BY BLOCKS, TABLE_NAME)
    LOOP
        DBMS_OUTPUT.PUT_LINE (REC.OWNER || '.' || REC.TABLE_NAME);
        DBMS_STATS.GATHER_TABLE_STATS (
            OWNNAME            => REC.OWNER,
            TABNAME            => REC.TABLE_NAME,
            ESTIMATE_PERCENT   => DBMS_STATS.AUTO_SAMPLE_SIZE,
            DEGREE             => V_DEGREE,
            CASCADE            => TRUE);
    END LOOP;

    --EXECUTE IMMEDIATE 'alter system set optimizer_use_pending_statistics = TRUE scope = memory sid = ''*''';

END;
/

--check pending statistics

select * from dba_tab_pending_stats;
select DBMS_STATS.GET_PREFS ('PUBLISH') from dual;
sho parameter optimizer_use_pending_statistics

--script 02 (run after checking system load only !!!)

DECLARE
    V_SCHEMANAME     VARCHAR2 (20) DEFAULT 'OWS';
BEGIN
    FOR REC IN (SELECT OWNER, TABLE_NAME
                  FROM DBA_TAB_STATISTICS
                 WHERE OWNER = 'OWS' AND STATTYPE_LOCKED IS NOT NULL)
    LOOP
        DBMS_OUTPUT.PUT_LINE (
               'unlock stats for the table '
            || REC.OWNER
            || '.'
            || REC.TABLE_NAME);
    END LOOP;
DBMS_STATS.SET_GLOBAL_PREFS ('PUBLISH', 'TRUE');
execute immediate 'alter system set optimizer_use_pending_statistics = FALSE scope = memory sid = ''*''';
dbms_stats.publish_pending_stats(V_SCHEMANAME,NULL);
END;
/

--in case of error:
ERROR at line 1:
ORA-20005: object statistics are locked (stattype = ALL)

unlock locked statistics before running script 02 (V_SCHEMANAME = 'OWS'):
select * from dba_tab_statistics where owner = 'OWS' and STATTYPE_LOCKED is not null order by LAST_ANALYZED desc;
exec DBMS_STATS.UNLOCK_TABLE_STATS('OWS','Q$INTRANET');

DECLARE
    V_SCHEMANAME   VARCHAR2 (20) DEFAULT 'OWS';
BEGIN
    DBMS_OUTPUT.ENABLE;

    FOR REC IN (SELECT OWNER, TABLE_NAME
                  FROM DBA_TAB_STATISTICS
                 WHERE OWNER = V_SCHEMANAME AND STATTYPE_LOCKED IS NOT NULL)
    LOOP
        DBMS_OUTPUT.PUT_LINE (
               'unlock stats for the table '
            || REC.OWNER
            || '.'
            || REC.TABLE_NAME);
        DBMS_STATS.UNLOCK_TABLE_STATS (REC.OWNER, REC.TABLE_NAME);
    END LOOP;

    DBMS_STATS.SET_GLOBAL_PREFS ('PUBLISH', 'TRUE');

    EXECUTE IMMEDIATE 'alter system set optimizer_use_pending_statistics = FALSE scope = memory sid = ''*''';

    DBMS_STATS.PUBLISH_PENDING_STATS (V_SCHEMANAME, NULL);
END;
/


--ROLLBACK script

DECLARE
    V_SCHEMANAME     VARCHAR2 (20) DEFAULT 'OWS';
BEGIN
DBMS_STATS.SET_GLOBAL_PREFS ('PUBLISH', 'TRUE');
execute immediate 'alter system set optimizer_use_pending_statistics = FALSE scope = memory sid = ''*''';
dbms_stats.delete_pending_stats(V_SCHEMANAME,NULL);
END;
/

--export pending stats in another DB

alter session set nls_length_semantics=byte;
1) exec DBMS_STATS.CREATE_STAT_TABLE(ownname => 'OWS', stattab => 'PENDING_STATTAB');
2) exec DBMS_STATS.EXPORT_PENDING_STATS('OWS',NULL,'PENDING_STATTAB','OWS_STAT_201904','OWS');
3) select count(1) from OWS.PENDING_STATTAB;
4) export in the dump: expdp \"/ as sysdba\" schemas=OWS include=TABLE:\"=\'PENDING_STATTAB\'\" directory=STATS dumpfile=PENDING_STATTAB logfile=PENDING_STATTAB compression=all
5) import dump file: impdp \"/ as sysdba\" schemas=OWS dumpfile=PENDING_STATTAB logfile=imp_PENDING_STATTAB
6) import statistics for the schema:
EXEC DBMS_STATS.IMPORT_SCHEMA_STATS(OWNNAME => 'OWS', STATTAB => 'PENDING_STATTAB', STATID => 'OWS_STAT_201904');