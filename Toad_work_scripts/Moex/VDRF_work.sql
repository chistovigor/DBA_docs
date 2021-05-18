-- ASM info

SELECT * FROM V$ASM_DISKGROUP;
SELECT * FROM V$ASM_DISK ORDER BY FAILGROUP,MODE_STATUS,DISK_NUMBER; 
SELECT * FROM V$ASM_OPERATION;
SELECT * FROM V$ASM_ATTRIBUTE;
SELECT DG.NAME,A.VALUE FROM V$ASM_DISKGROUP DG, V$ASM_ATTRIBUTE A WHERE DG.GROUP_NUMBER=A.GROUP_NUMBER AND A.NAME='disk_repair_time';

-- space usage in ASM (for details see query inside FROM block)

  SELECT SUBSTR (alias_path,
                 2,
                   INSTR (alias_path,
                          '/',
                          1,
                          2)
                 - 2)
            Database,
         ROUND (SUM (alloc_bytes) / 1024 / 1024 / 1024, 1) "GB"
    FROM (    SELECT SYS_CONNECT_BY_PATH (alias_name, '/') alias_path, alloc_bytes
                FROM (SELECT g.name disk_group_name,
                             a.parent_index pindex,
                             a.name alias_name,
                             a.reference_index rindex,
                             f.space alloc_bytes,
                             f.TYPE TYPE
                        FROM v$asm_file f
                             RIGHT OUTER JOIN v$asm_alias a
                                USING (group_number, file_number)
                             JOIN v$asm_diskgroup g USING (group_number))
               WHERE TYPE IS NOT NULL
          START WITH (MOD (pindex, POWER (2, 24))) = 0
          CONNECT BY PRIOR rindex = pindex)
GROUP BY SUBSTR (alias_path,
                 2,
                   INSTR (alias_path,
                          '/',
                          1,
                          2)
                 - 2)
ORDER BY 2 DESC;

-- œÓËÒÍ ‡ÔËÒÂÈ ‡Û‰ËÚ‡

select * from unified_audit_trail where upper(SQL_TEXT) like '%V_FORTS_SECS_OP%' and EVENT_TIMESTAMP >= trunc(sysdate-7) order by EVENT_TIMESTAMP;

-- ‚˚·‡Ú¸ Á‡‚ËÒ¯ËÂ ÒÂÒÒËË

--» Œ ŒÕ◊¿“≈À‹ÕŒ œ–»—“–≈À»“‹ »’:

ALTER SYSTEM DISCONNECT SESSION 'sid,serial#' IMMEDIATE;

SELECT *
  FROM V$SESSION
 WHERE     EVENT IN
               ('SQL*Net break/reset to client',
                'SQL*Net message from client')
       AND STATUS IN ('SNIPED', 'KILLED')
       AND (    USERNAME IN (SELECT USERNAME
                               FROM DBA_USERS
                              WHERE PROFILE = 'CB_USERS_PROFILE')) order by LOGON_TIME;
       
select * from dba_users;


BEGIN
    FOR REC
        IN (SELECT SID, SERIAL# SNUM
              FROM V$SESSION
 WHERE     EVENT IN
               ('SQL*Net break/reset to client',
                'SQL*Net message from client')
       AND STATUS IN ('SNIPED', 'KILLED')
       AND (    USERNAME IN (SELECT USERNAME
                               FROM DBA_USERS
                              WHERE PROFILE = 'CB_USERS_PROFILE')
            AND PREV_EXEC_START < TRUNC (SYSDATE - 1)))
    LOOP
        EXECUTE IMMEDIATE
               'ALTER SYSTEM DISCONNECT SESSION '''
            || REC.SID
            || ','
            || REC.SNUM
            || ''' IMMEDIATE';
    END LOOP;
END;

--

/*
 ŒÀÀ≈√», ƒŒ¡–Œ√Œ ƒÕﬂ,
Õ¿ “≈ ”Ÿ»… ÃŒÃ≈Õ“ ≈∆≈ƒÕ≈¬ÕŒ ¬Œ«Õ» ¿≈“ Œÿ»¡ ¿
EQ.ORDERS_TO_MIRROR
END: ORA-08103: OBJECT NO LONGER EXISTS
ORA-06512: AT "CBMIRROR.EXECUTE_IMMEDIATE", LINE 5
Õ¿ ÃŒÃ≈Õ“ Œ ŒÀŒ 01:20 Ã— .
*/

SELECT COUNT (1) FROM CBMIRROR.ORDERS_BASE;

  SELECT *
    FROM DBA_TAB_PARTITIONS
   WHERE TABLE_NAME = 'ORDERS_BASE'
ORDER BY LAST_ANALYZED DESC NULLS FIRST;

SET TIMING ON

DECLARE
    SQLTEXT                VARCHAR2 (4000);
    DEGREEVALUE            VARCHAR2 (64);
    ESTIMATEPERCENTVALUE   VARCHAR2 (64);
    METHODOPTVALUE         VARCHAR2 (64);
BEGIN
    DEGREEVALUE :=
        SYS.DBMS_STATS.GET_PREFS ('DEGREE', 'CBMIRROR', 'ORDERS_BASE');
    ESTIMATEPERCENTVALUE :=
        SYS.DBMS_STATS.GET_PREFS ('ESTIMATE_PERCENT',
                                  'CBMIRROR',
                                  'ORDERS_BASE');
    METHODOPTVALUE :=
           ''''
        || SYS.DBMS_STATS.GET_PREFS ('METHOD_OPT', 'CBMIRROR', 'ORDERS_BASE')
        || '''';
    SQLTEXT :=
           'BEGIN'
        || CHR (10)
        || '  SYS.DBMS_STATS.GATHER_TABLE_STATS ('
        || CHR (10)
        || '     OWNNAME           => ''CBMIRROR'''
        || CHR (10)
        || '    ,TABNAME           => ''ORDERS_BASE'''
        || CHR (10)
        || '    ,ESTIMATE_PERCENT  => '
        || ESTIMATEPERCENTVALUE
        || CHR (10)
        || '    ,METHOD_OPT        => '
        || METHODOPTVALUE
        || CHR (10)
        || '    ,DEGREE            => '
        || DEGREEVALUE
        || CHR (10)
        || '    ,CASCADE           => TRUE'
        || CHR (10)
        || '    ,NO_INVALIDATE  => FALSE);'
        || CHR (10)
        || 'END;';

    EXECUTE IMMEDIATE (SQLTEXT);
END;
/


-- AUDIT

SELECT * FROM DBA_AUDIT_MGMT_LAST_ARCH_TS;

SELECT MIN (EVENT_TIMESTAMP), MAX (EVENT_TIMESTAMP) FROM UNIFIED_AUDIT_TRAIL;

SELECT * FROM UNIFIED_AUDIT_TRAIL;

SELECT *
  FROM UNIFIED_AUDIT_TRAIL
 WHERE EVENT_TIMESTAMP >= TRUNC (SYSDATE);

  SELECT AUDIT_TYPE, COUNT (1)
    FROM UNIFIED_AUDIT_TRAIL
   WHERE EVENT_TIMESTAMP >= TRUNC (SYSDATE)
GROUP BY AUDIT_TYPE
ORDER BY COUNT (1) DESC;

-- TEMP USAGE MONITORING ISING TEMP_SEG_USAGE_INSERT_JOB

  SELECT *
    FROM TEMP_SEG_USAGE
ORDER BY 1 DESC, 4 DESC                            -- WHERE STATUS = 'ACTIVE';
;
-- DB SIZE

  SELECT OWNER, SEGMENT_TYPE, ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 0) GB
    FROM DBA_SEGMENTS
   WHERE OWNER NOT LIKE 'SYS%'
GROUP BY OWNER, SEGMENT_TYPE
  HAVING ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 2) > 5
ORDER BY 1, 2, 3 DESC;

  SELECT ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 1)
    FROM DBA_SEGMENTS
   WHERE SEGMENT_NAME = 'ORDERS_BASE_UIDX'
GROUP BY SEGMENT_NAME;

  SELECT ROUND (SUM (BYTES) / 1024 / 1024 / 1024, 1)
    FROM DBA_SEGMENTS
   WHERE SEGMENT_NAME = 'CURR_ORDERS_BASE_UIDX'
GROUP BY SEGMENT_NAME;

-- OBJECTS

SELECT *
  FROM ALL_OBJECTS
 WHERE OBJECT_ID = 81176;

  SELECT *
    FROM ALL_OBJECTS
   WHERE OBJECT_NAME = 'CURR_ORDERS_BASE'
ORDER BY 3;

  SELECT *
    FROM ALL_TAB_PARTITIONS
   WHERE TABLE_NAME = 'CURR_ORDERS_BASE' AND SEGMENT_CREATED = 'YES'
ORDER BY 4;

  SELECT *
    FROM DBA_SEGMENTS
   WHERE SEGMENT_NAME = 'CURR_ORDERS_BASE'
ORDER BY PARTITION_NAME;

SELECT MIN (SCN_TO_TIMESTAMP (ORA_ROWSCN)),
       MAX (SCN_TO_TIMESTAMP (ORA_ROWSCN))
  FROM CBMIRROR.CURR_ORDERS_BASE PARTITION (CURR_ORDERS_BASE_P_20161222);

SELECT MIN (SCN_TO_TIMESTAMP (ORA_ROWSCN)),
       MAX (SCN_TO_TIMESTAMP (ORA_ROWSCN))
  FROM CBMIRROR.CURR_ORDERS_BASE PARTITION (CURR_ORDERS_BASE_P_20161219);                                                                                                                                                                                                                            --24-12-2016 6:05:26.000000000	27-12-2016 9:18:31.000000000

SELECT *
  FROM CBMIRROR.CURR_ORDERS_BASE PARTITION (CURR_ORDERS_BASE_P_20161222);

SELECT MAX (ENTRYDATE) FROM CBMIRROR.CURR_ORDERS_BASE;

SELECT MAX (ENTRYDATE) FROM CBMIRROR.ORDERS_BASE;

SELECT MAX (TRADEDATE) FROM CBMIRROR.CURR_TRADES_BASE;

SELECT MAX (TRADEDATE) FROM CBMIRROR.TRADES_BASE;

-- ILM

  SELECT *
    FROM DBA_ILMOBJECTS
   WHERE OBJECT_NAME = 'CURR_ORDERS_BASE'
ORDER BY SUBOBJECT_NAME;                                                                                                                   --POLICY_NAME

SELECT *
  FROM DBA_ILMDATAMOVEMENTPOLICIES
 WHERE POLICY_NAME = 'P353';

SELECT *
  FROM DBA_ILMPOLICIES
 WHERE POLICY_NAME = 'P353';

SELECT *
  FROM DBA_ILMEVALUATIONDETAILS
 WHERE POLICY_NAME = 'P353';                                                                                             --JOB_NAME = 'ILMJOB1768384'; --TASK_ID OR JOB_NAME

SELECT *
  FROM DBA_ILMRESULTS
 WHERE JOB_NAME = 'ILMJOB1768384';                                                                                                --JOB_NAME

SELECT *
  FROM DBA_SCHEDULER_JOB_RUN_DETAILS
 WHERE JOB_NAME = 'ILMJOB1768384';

-- DB LINKS

  SELECT *
    FROM DBA_DB_LINKS
ORDER BY 1, 2;

-- ASH

SELECT * FROM SESSION_INFO;                                                       --WHEN V$SESSION SELECT FAILS WITH PARTIAL MULTIBYTE CHARACTER ERROR

  SELECT *
    FROM V$ACTIVE_SESSION_HISTORY
   WHERE SQL_ID = '370RAXMCT1RF9'
ORDER BY 1;

SELECT * FROM DBA_HIST_ACTIVE_SESS_HISTORY;

  SELECT *
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE SQL_ID = 'C6A98UUU4B6NF' AND SAMPLE_TIME >= SYSDATE - 1
ORDER BY SAMPLE_TIME;

  SELECT *
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SESSION_ID IN (1389, 417)
         AND SAMPLE_TIME BETWEEN TO_DATE ('11072017 04:37:30',
                                          'DDMMYYYY HH24:MI:SS')
                             AND TO_DATE ('11072017 04:39:00',
                                          'DDMMYYYY HH24:MI:SS')
ORDER BY SAMPLE_TIME;

  SELECT *
    FROM DBA_HIST_ACTIVE_SESS_HISTORY
   WHERE     SESSION_ID IN (1389, 417)
         AND SAMPLE_TIME BETWEEN TO_DATE ('11072017 04:30:30',
                                          'DDMMYYYY HH24:MI:SS')
                             AND TO_DATE ('11072017 04:39:00',
                                          'DDMMYYYY HH24:MI:SS')
ORDER BY SAMPLE_TIME;

SELECT *
  FROM DBA_HIST_SQLTEXT
 WHERE SQL_ID = '7SXBWK3GV68N2';

SELECT *
  FROM DBA_HIST_SQLTEXT
 WHERE SQL_ID IN
           (SELECT SQL_ID
              FROM DBA_HIST_ACTIVE_SESS_HISTORY
             WHERE     SAMPLE_TIME BETWEEN TO_DATE ('11072017 04:37:30',
                                                    'DDMMYYYY HH24:MI:SS')
                                       AND TO_DATE ('11072017 04:39:00',
                                                    'DDMMYYYY HH24:MI:SS')
                   AND SQL_OPCODE = 189);

  SELECT *
    FROM DBA_HIST_SQLSTAT
   WHERE SQL_ID = '3VCRN45XYY8UU'
ORDER BY SNAP_ID;

SELECT *
  FROM DBA_HIST_SNAPSHOT
 WHERE SNAP_ID = 26724;                                                                             --ORDER BY 1;

  SELECT *
    FROM DBA_HIST_SQL_PLAN
   WHERE SQL_ID = '1RHYDV3JHR3SS' ORDER BY ID;

SELECT *
  FROM DBA_HIST_SQL_PLAN
 WHERE UPPER (OBJECT_NAME) LIKE '%FUTDEAL_BASE_0_IDX%';

SELECT *
  FROM DBA_HIST_ACTIVE_SESS_HISTORY
 WHERE SESSION_ID = 2349;

SELECT *
  FROM DBA_HIST_SQLTEXT
 WHERE UPPER (SQL_TEXT) LIKE '%SELECT /*+ DYNAMIC_SAMPLING(0) */%';

SELECT *
  FROM V$ACTIVE_SESSION_HISTORY
 WHERE     SESSION_ID = 801
       AND SAMPLE_TIME BETWEEN TO_DATE ('25.01.2017 01:00:00',
                                        'DD.MM.YYYY HH24:MI:SS')
                           AND TO_DATE ('25.01.2017 02:01:00',
                                        'DD.MM.YYYY HH24:MI:SS');

SET LINESIZE 8000 TERMOUT ON FEEDBACK OFF HEADING OFF ECHO OFF VERI OFF TRIMSPOOL ON TRIMOUT ON

SPOOL C:\TEMP\AWR_GWDBUPDTRADESORACLEDGW5.HTML

/*

SELECT 
   OUTPUT 
FROM TABLE( DBMS_WORKLOAD_REPOSITORY.ASH_GLOBAL_REPORT_HTML (
           496990843,
           1,
           TO_DATE ('05.12.2017 18:15:00', 'DD.MM.YYYY HH24:MI:SS'),
           TO_DATE ('05.12.2017 19:20:00', 'DD.MM.YYYY HH24:MI:SS'),
           L_MODULE   => 'GWDBUPDTRADESORACLE.SPUR_EXADATA%')
           );
  
SPOOL OFF
EXIT

*/

SELECT OUTPUT
  FROM TABLE (DBMS_WORKLOAD_REPOSITORY.ASH_REPORT_HTML (
                  L_DBID =>
                      863159942,
                  L_INST_NUM =>
                      1,
                  L_SQL_ID =>
                      '370RAXMCT1RF9',
                  L_BTIME =>
                      TO_DATE ('05.12.2017 18:15:00',
                               'DD.MM.YYYY HH24:MI:SS'),
                  L_ETIME =>
                      TO_DATE ('05.12.2017 19:20:00',
                               'DD.MM.YYYY HH24:MI:SS'),
                  L_MODULE =>
                      'ORACLE@MR01VM01.MOEX.COM (TNS V1-V3)%',
                  L_SID =>
                      999));

SPOOL OFF
EXIT


SELECT 'ALTER SYSTEM KILL SESSION ''' || SID || ',' || SERIAL# || ''';'
  FROM V$SESSION
 WHERE     EVENT = 'SQL*NET BREAK/RESET TO CLIENT'
       AND MACHINE = 'LOADERC.IMD.CBR.RU'
       AND LOGON_TIME < TRUNC (SYSDATE - 8);

SELECT *
  FROM V$SESSION
 WHERE     EVENT = 'SQL*NET BREAK/RESET TO CLIENT'
       AND MACHINE = 'LOADERC.IMD.CBR.RU'
       AND LOGON_TIME < TRUNC (SYSDATE - 8);

SELECT *
  FROM V$PROCESS
 WHERE ADDR IN (SELECT PADDR
                  FROM V$SESSION
                 WHERE STATUS = 'KILLED');