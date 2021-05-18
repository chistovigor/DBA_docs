set feedback off
set serveroutput on
set pagesize 0
set ver off
set echo off

spool /home/oracle/reorganize_indexes.log

-- Script Header Section
-- ==============================================

-- functions and procedures

CREATE OR REPLACE PROCEDURE mgmt$reorg_sendMsg (msg IN VARCHAR2) IS
    msg1 VARCHAR2(1020);
    len INTEGER := length(msg);
    i INTEGER := 1;
BEGIN
    dbms_output.enable (1000000);

    LOOP
      msg1 := SUBSTR (msg, i, 255);
      dbms_output.put_line (msg1);
      len := len - 255;
      i := i + 255;
    EXIT WHEN len <= 0;
    END LOOP;
END mgmt$reorg_sendMsg;
/

CREATE OR REPLACE PROCEDURE mgmt$reorg_errorExit (msg IN VARCHAR2) IS
BEGIN
    mgmt$reorg_sendMsg (msg);
    mgmt$reorg_sendMsg ('errorExit!');
END mgmt$reorg_errorExit;
/

CREATE OR REPLACE PROCEDURE mgmt$reorg_errorExitOraError (msg IN VARCHAR2, errMsg IN VARCHAR2) IS
BEGIN
    mgmt$reorg_sendMsg (msg);
    mgmt$reorg_sendMsg (errMsg);
    mgmt$reorg_sendMsg ('errorExitOraError!');
END mgmt$reorg_errorExitOraError;
/

CREATE OR REPLACE PROCEDURE mgmt$reorg_checkDBAPrivs 
AUTHID CURRENT_USER IS
    granted_role REAL := 0;
    user_name user_users.username%type;
BEGIN
SELECT USERNAME INTO user_name FROM USER_USERS;
    EXECUTE IMMEDIATE 'SELECT 1 FROM SYS.DBA_ROLE_PRIVS WHERE GRANTED_ROLE = ''DBA'' AND GRANTEE = :1'
      INTO granted_role       USING user_name;
EXCEPTION
    WHEN OTHERS THEN
       IF SQLCODE = -01403 OR SQLCODE = -00942  THEN
      mgmt$reorg_sendMsg ( 'WARNING checking privileges... User Name: ' || user_name);
      mgmt$reorg_sendMsg ( 'User does not have DBA privs. ' );
      mgmt$reorg_sendMsg ( 'The script will fail if it tries to perform operations for which the user lacks the appropriate privilege. ' );
      END IF;
END mgmt$reorg_checkDBAPrivs;
/

CREATE OR REPLACE PROCEDURE mgmt$reorg_setUpJobTable (script_id IN INTEGER, job_table IN VARCHAR2, step_num OUT INTEGER)
AUTHID CURRENT_USER IS
    ctsql_text VARCHAR2(200) := 'CREATE TABLE ' || job_table || '(SCRIPT_ID NUMBER, LAST_STEP NUMBER, unique (SCRIPT_ID))';
    itsql_text VARCHAR2(200) := 'INSERT INTO ' || job_table || ' (SCRIPT_ID, LAST_STEP) values (:1, :2)';
    stsql_text VARCHAR2(200) := 'SELECT last_step FROM ' || job_table || ' WHERE script_id = :1';

    TYPE CurTyp IS REF CURSOR;  -- define weak REF CURSOR type
    stsql_cur CurTyp;  -- declare cursor variable

BEGIN
    step_num := 0;
    BEGIN
      EXECUTE IMMEDIATE ctsql_text;
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;

    BEGIN
      OPEN stsql_cur FOR  -- open cursor variable
        stsql_text USING  script_id;
      FETCH stsql_cur INTO step_num;
      IF stsql_cur%FOUND THEN
        NULL;
      ELSE
        EXECUTE IMMEDIATE itsql_text USING script_id, step_num;
        COMMIT;
        step_num := 1;
      END IF;
      CLOSE stsql_cur;
    EXCEPTION
      WHEN OTHERS THEN
        mgmt$reorg_errorExit ('ERROR selecting or inserting from table: ' || job_table);
        return;
    END;

    return;

EXCEPTION
      WHEN OTHERS THEN
        mgmt$reorg_errorExit ('ERROR accessing table: ' || job_table);
        return;
END mgmt$reorg_setUpJobTable;
/

CREATE OR REPLACE PROCEDURE mgmt$reorg_deleteJobTableEntry(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN INTEGER, highest_step IN INTEGER)
AUTHID CURRENT_USER IS
    delete_text VARCHAR2(200) := 'DELETE FROM ' || job_table || ' WHERE SCRIPT_ID = :1';
BEGIN

    IF step_num <= highest_step THEN
      return;
    END IF;

    BEGIN
      EXECUTE IMMEDIATE delete_text USING script_id;
      IF SQL%NOTFOUND THEN
        mgmt$reorg_errorExit ('ERROR deleting entry from table: ' || job_table);
        return;
      END IF;
    EXCEPTION
        WHEN OTHERS THEN
          mgmt$reorg_errorExit ('ERROR deleting entry from table: ' || job_table);
          return;
    END;

    COMMIT;
END mgmt$reorg_deleteJobTableEntry;
/

CREATE OR REPLACE PROCEDURE mgmt$reorg_setStep (script_id IN INTEGER, job_table IN VARCHAR2, step_num IN INTEGER)
AUTHID CURRENT_USER IS
    update_text VARCHAR2(200) := 'UPDATE ' || job_table || ' SET last_step = :1 WHERE script_id = :2';
BEGIN
    -- update job table
    EXECUTE IMMEDIATE update_text USING step_num, script_id;
    IF SQL%NOTFOUND THEN
      mgmt$reorg_sendMsg ('NOTFOUND EXCEPTION of sql_text: ' || update_text);
      mgmt$reorg_errorExit ('ERROR accessing table: ' || job_table);
      return;
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
      mgmt$reorg_errorExit ('ERROR accessing table: ' || job_table);
      return;
END mgmt$reorg_setStep;
/

CREATE OR REPLACE PROCEDURE mgmt$step_1_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 1 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('COMMIT');
      EXECUTE IMMEDIATE 'COMMIT';
      mgmt$reorg_sendMsg ('ALTER SESSION ENABLE PARALLEL DML');
      EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_1_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_2_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 2 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER SESSION SET sort_area_size = 131072 sort_area_retained_size = 131072 ');
      EXECUTE IMMEDIATE 'ALTER SESSION SET sort_area_size = 131072 sort_area_retained_size = 131072 ';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_2_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_3_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 3 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131203" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131203" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_3_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_4_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 4 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131203" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131203" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_4_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_5_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 5 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131203"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131203"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_5_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_6_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 6 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131202" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131202" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_6_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_7_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 7 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131202" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131202" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_7_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_8_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 8 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131202"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131202"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_8_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_9_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 9 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131201" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131201" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_9_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_10_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 10 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131201" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131201" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_10_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_11_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 11 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131201"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131201"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_11_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_12_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 12 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131103" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131103" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_12_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_13_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 13 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131103" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131103" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_13_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_14_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 14 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131103"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131103"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_14_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_15_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 15 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131102" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131102" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_15_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_16_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 16 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131102" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131102" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_16_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_17_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 17 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131102"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131102"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_17_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_18_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 18 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131101" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131101" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_18_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_19_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 19 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131101" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131101" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_19_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_20_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 20 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131101"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131101"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_20_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_21_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 21 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131003" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131003" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_21_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_22_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 22 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131003" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131003" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_22_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_23_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 23 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131003"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131003"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_23_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_24_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 24 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131002" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131002" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_24_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_25_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 25 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131002" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131002" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_25_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_26_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 26 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131002"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131002"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_26_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_27_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 27 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131001" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131001" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_27_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_28_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 28 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20131001" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20131001" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_28_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_29_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 29 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131001"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20131001"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_29_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_30_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 30 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130903" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130903" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_30_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_31_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 31 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130903" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130903" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_31_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_32_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 32 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130903"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130903"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_32_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_33_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 33 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130902" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130902" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_33_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_34_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 34 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130902" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130902" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_34_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_35_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 35 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130902"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130902"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_35_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_36_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 36 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130901" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130901" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_36_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_37_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 37 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130901" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130901" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_37_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_38_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 38 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130901"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130901"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_38_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_39_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 39 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130803" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130803" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_39_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_40_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 40 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130803" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130803" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_40_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_41_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 41 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130803"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130803"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_41_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_42_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 42 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130802" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130802" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_42_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_43_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 43 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130802" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130802" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_43_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_44_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 44 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130802"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130802"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_44_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_45_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 45 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130801" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130801" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_45_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_46_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 46 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130801" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130801" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_46_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_47_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 47 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130801"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130801"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_47_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_48_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 48 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130703" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130703" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_48_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_49_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 49 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130703" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130703" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_49_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_50_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 50 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130703"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130703"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_50_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_51_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 51 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130702" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130702" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_51_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_52_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 52 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130702" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130702" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_52_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_53_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 53 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130702"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130702"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_53_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_54_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 54 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130701" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130701" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_54_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_55_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 55 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130701" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130701" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_55_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_56_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 56 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130701"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130701"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_56_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_57_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 57 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130603" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130603" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_57_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_58_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 58 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130603" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130603" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_58_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_59_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 59 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130603"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130603"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_59_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_60_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 60 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130602" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130602" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_60_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_61_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 61 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130602" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130602" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_61_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_62_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 62 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130602"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130602"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_62_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_63_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 63 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130601" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130601" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_63_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_64_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 64 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130601" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130601" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_64_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_65_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 65 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130601"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130601"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_65_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_66_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 66 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130503" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130503" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_66_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_67_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 67 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130503" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130503" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_67_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_68_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 68 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130503"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130503"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_68_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_69_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 69 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130502" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130502" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_69_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_70_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 70 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130502" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130502" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_70_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_71_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 71 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130502"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130502"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_71_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_72_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 72 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130501" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130501" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_72_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_73_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 73 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130501" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130501" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_73_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_74_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 74 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130501"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130501"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_74_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_75_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 75 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130403" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130403" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_75_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_76_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 76 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130403" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130403" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_76_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_77_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 77 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130403"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130403"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_77_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_78_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 78 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130402" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130402" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_78_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_79_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 79 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130402" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130402" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_79_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_80_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 80 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130402"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130402"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_80_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_81_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 81 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130401" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130401" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_81_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_82_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 82 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130401" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130401" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_82_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_83_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 83 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130401"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130401"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_83_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_84_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 84 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130303" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130303" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_84_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_85_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 85 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130303" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130303" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_85_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_86_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 86 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130303"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130303"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_86_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_87_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 87 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130302" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130302" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_87_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_88_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 88 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130302" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130302" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_88_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_89_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 89 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130302"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130302"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_89_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_90_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 90 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130301" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130301" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_90_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_91_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 91 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130301" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130301" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_91_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_92_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 92 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130301"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130301"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_92_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_93_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 93 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130203" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130203" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_93_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_94_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 94 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130203" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130203" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_94_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_95_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 95 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130203"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130203"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_95_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_96_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 96 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130202" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130202" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_96_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_97_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 97 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130202" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130202" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_97_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_98_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 98 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130202"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130202"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_98_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_99_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 99 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130201" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130201" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_99_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_100_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 100 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130201" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130201" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_100_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_101_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 101 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130201"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130201"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_101_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_102_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 102 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130103" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130103" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_102_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_103_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 103 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130103" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130103" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_103_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_104_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 104 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130103"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130103"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_104_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_105_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 105 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130102" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130102" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_105_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_106_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 106 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130102" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130102" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_106_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_107_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 107 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130102"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130102"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_107_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_108_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 108 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130101" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130101" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_108_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_109_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 109 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20130101" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20130101" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_109_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_110_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 110 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130101"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20130101"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_110_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_111_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 111 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20121203" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20121203" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_111_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_112_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 112 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20121203" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20121203" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_112_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_113_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 113 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20121203"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20121203"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_113_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_114_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 114 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20121202" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20121202" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_114_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_115_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 115 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20121202" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20121202" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_115_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_116_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 116 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20121202"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20121202"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_116_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_117_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 117 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20121201" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20121201" REBUILD TABLESPACE "ANNUAL_INDEX"  PARALLEL 3';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_117_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_118_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 118 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('ALTER INDEX "ROUTER"."AP20121201" NOPARALLEL');
      EXECUTE IMMEDIATE 'ALTER INDEX "ROUTER"."AP20121201" NOPARALLEL';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_118_41;
/

CREATE OR REPLACE PROCEDURE mgmt$step_119_41(script_id IN INTEGER, job_table IN VARCHAR2, step_num IN OUT INTEGER)
AUTHID CURRENT_USER IS
    sqlerr_msg VARCHAR2(100);
BEGIN
    IF step_num <> 119 THEN
      return;
    END IF;

    mgmt$reorg_setStep (41, 'MGMT$REORG_CHECKPOINT', step_num);
    step_num := step_num + 1;
    BEGIN
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20121201"'', estimate_percent=>NULL, degree=>3); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"ROUTER"'', ''"AP20121201"'', estimate_percent=>NULL, degree=>3); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_119_41;
/

CREATE OR REPLACE PROCEDURE mgmt$reorg_cleanup_41 (script_id IN INTEGER, job_table IN VARCHAR2, step_num IN INTEGER, highest_step IN INTEGER)
AUTHID CURRENT_USER IS
BEGIN
    IF step_num <= highest_step THEN
      return;
    END IF;

    mgmt$reorg_sendMsg ('Starting cleanup of recovery tables');

    mgmt$reorg_deleteJobTableEntry(script_id, job_table, step_num, highest_step);

    mgmt$reorg_sendMsg ('Completed cleanup of recovery tables');
END mgmt$reorg_cleanup_41;
/

CREATE OR REPLACE PROCEDURE mgmt$reorg_commentheader_41 IS
BEGIN
     mgmt$reorg_sendMsg ('--   Target database:	ARCHDB');
     mgmt$reorg_sendMsg ('--   Script generated at:	17-ЯНВ-2014   10:36');
END mgmt$reorg_commentheader_41;
/

-- Script Execution Controller
-- ==============================================

variable step_num number;
exec mgmt$reorg_commentheader_41;
exec mgmt$reorg_sendMsg ('Starting reorganization');
show user;
exec mgmt$reorg_checkDBAPrivs;
exec mgmt$reorg_setupJobTable (41, 'MGMT$REORG_CHECKPOINT', :step_num);

exec mgmt$step_1_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_2_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_3_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_4_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_5_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_6_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_7_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_8_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_9_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_10_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_11_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_12_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_13_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_14_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_15_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_16_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_17_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_18_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_19_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_20_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_21_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_22_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_23_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_24_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_25_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_26_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_27_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_28_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_29_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_30_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_31_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_32_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_33_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_34_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_35_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_36_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_37_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_38_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_39_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_40_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_41_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_42_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_43_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_44_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_45_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_46_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_47_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_48_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_49_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_50_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_51_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_52_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_53_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_54_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_55_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_56_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_57_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_58_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_59_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_60_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_61_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_62_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_63_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_64_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_65_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_66_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_67_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_68_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_69_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_70_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_71_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_72_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_73_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_74_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_75_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_76_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_77_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_78_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_79_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_80_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_81_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_82_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_83_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_84_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_85_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_86_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_87_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_88_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_89_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_90_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_91_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_92_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_93_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_94_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_95_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_96_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_97_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_98_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_99_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_100_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_101_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_102_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_103_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_104_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_105_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_106_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_107_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_108_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_109_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_110_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_111_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_112_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_113_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_114_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_115_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_116_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_117_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_118_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);
exec mgmt$step_119_41(41, 'MGMT$REORG_CHECKPOINT', :step_num);

exec mgmt$reorg_sendMsg ('Completed Reorganization.  Starting cleanup phase.');

exec mgmt$reorg_cleanup_41 (41, 'MGMT$REORG_CHECKPOINT', :step_num, 119);

exec mgmt$reorg_sendMsg ('Starting cleanup of generated procedures');

DROP PROCEDURE mgmt$step_1_41;
DROP PROCEDURE mgmt$step_2_41;
DROP PROCEDURE mgmt$step_3_41;
DROP PROCEDURE mgmt$step_4_41;
DROP PROCEDURE mgmt$step_5_41;
DROP PROCEDURE mgmt$step_6_41;
DROP PROCEDURE mgmt$step_7_41;
DROP PROCEDURE mgmt$step_8_41;
DROP PROCEDURE mgmt$step_9_41;
DROP PROCEDURE mgmt$step_10_41;
DROP PROCEDURE mgmt$step_11_41;
DROP PROCEDURE mgmt$step_12_41;
DROP PROCEDURE mgmt$step_13_41;
DROP PROCEDURE mgmt$step_14_41;
DROP PROCEDURE mgmt$step_15_41;
DROP PROCEDURE mgmt$step_16_41;
DROP PROCEDURE mgmt$step_17_41;
DROP PROCEDURE mgmt$step_18_41;
DROP PROCEDURE mgmt$step_19_41;
DROP PROCEDURE mgmt$step_20_41;
DROP PROCEDURE mgmt$step_21_41;
DROP PROCEDURE mgmt$step_22_41;
DROP PROCEDURE mgmt$step_23_41;
DROP PROCEDURE mgmt$step_24_41;
DROP PROCEDURE mgmt$step_25_41;
DROP PROCEDURE mgmt$step_26_41;
DROP PROCEDURE mgmt$step_27_41;
DROP PROCEDURE mgmt$step_28_41;
DROP PROCEDURE mgmt$step_29_41;
DROP PROCEDURE mgmt$step_30_41;
DROP PROCEDURE mgmt$step_31_41;
DROP PROCEDURE mgmt$step_32_41;
DROP PROCEDURE mgmt$step_33_41;
DROP PROCEDURE mgmt$step_34_41;
DROP PROCEDURE mgmt$step_35_41;
DROP PROCEDURE mgmt$step_36_41;
DROP PROCEDURE mgmt$step_37_41;
DROP PROCEDURE mgmt$step_38_41;
DROP PROCEDURE mgmt$step_39_41;
DROP PROCEDURE mgmt$step_40_41;
DROP PROCEDURE mgmt$step_41_41;
DROP PROCEDURE mgmt$step_42_41;
DROP PROCEDURE mgmt$step_43_41;
DROP PROCEDURE mgmt$step_44_41;
DROP PROCEDURE mgmt$step_45_41;
DROP PROCEDURE mgmt$step_46_41;
DROP PROCEDURE mgmt$step_47_41;
DROP PROCEDURE mgmt$step_48_41;
DROP PROCEDURE mgmt$step_49_41;
DROP PROCEDURE mgmt$step_50_41;
DROP PROCEDURE mgmt$step_51_41;
DROP PROCEDURE mgmt$step_52_41;
DROP PROCEDURE mgmt$step_53_41;
DROP PROCEDURE mgmt$step_54_41;
DROP PROCEDURE mgmt$step_55_41;
DROP PROCEDURE mgmt$step_56_41;
DROP PROCEDURE mgmt$step_57_41;
DROP PROCEDURE mgmt$step_58_41;
DROP PROCEDURE mgmt$step_59_41;
DROP PROCEDURE mgmt$step_60_41;
DROP PROCEDURE mgmt$step_61_41;
DROP PROCEDURE mgmt$step_62_41;
DROP PROCEDURE mgmt$step_63_41;
DROP PROCEDURE mgmt$step_64_41;
DROP PROCEDURE mgmt$step_65_41;
DROP PROCEDURE mgmt$step_66_41;
DROP PROCEDURE mgmt$step_67_41;
DROP PROCEDURE mgmt$step_68_41;
DROP PROCEDURE mgmt$step_69_41;
DROP PROCEDURE mgmt$step_70_41;
DROP PROCEDURE mgmt$step_71_41;
DROP PROCEDURE mgmt$step_72_41;
DROP PROCEDURE mgmt$step_73_41;
DROP PROCEDURE mgmt$step_74_41;
DROP PROCEDURE mgmt$step_75_41;
DROP PROCEDURE mgmt$step_76_41;
DROP PROCEDURE mgmt$step_77_41;
DROP PROCEDURE mgmt$step_78_41;
DROP PROCEDURE mgmt$step_79_41;
DROP PROCEDURE mgmt$step_80_41;
DROP PROCEDURE mgmt$step_81_41;
DROP PROCEDURE mgmt$step_82_41;
DROP PROCEDURE mgmt$step_83_41;
DROP PROCEDURE mgmt$step_84_41;
DROP PROCEDURE mgmt$step_85_41;
DROP PROCEDURE mgmt$step_86_41;
DROP PROCEDURE mgmt$step_87_41;
DROP PROCEDURE mgmt$step_88_41;
DROP PROCEDURE mgmt$step_89_41;
DROP PROCEDURE mgmt$step_90_41;
DROP PROCEDURE mgmt$step_91_41;
DROP PROCEDURE mgmt$step_92_41;
DROP PROCEDURE mgmt$step_93_41;
DROP PROCEDURE mgmt$step_94_41;
DROP PROCEDURE mgmt$step_95_41;
DROP PROCEDURE mgmt$step_96_41;
DROP PROCEDURE mgmt$step_97_41;
DROP PROCEDURE mgmt$step_98_41;
DROP PROCEDURE mgmt$step_99_41;
DROP PROCEDURE mgmt$step_100_41;
DROP PROCEDURE mgmt$step_101_41;
DROP PROCEDURE mgmt$step_102_41;
DROP PROCEDURE mgmt$step_103_41;
DROP PROCEDURE mgmt$step_104_41;
DROP PROCEDURE mgmt$step_105_41;
DROP PROCEDURE mgmt$step_106_41;
DROP PROCEDURE mgmt$step_107_41;
DROP PROCEDURE mgmt$step_108_41;
DROP PROCEDURE mgmt$step_109_41;
DROP PROCEDURE mgmt$step_110_41;
DROP PROCEDURE mgmt$step_111_41;
DROP PROCEDURE mgmt$step_112_41;
DROP PROCEDURE mgmt$step_113_41;
DROP PROCEDURE mgmt$step_114_41;
DROP PROCEDURE mgmt$step_115_41;
DROP PROCEDURE mgmt$step_116_41;
DROP PROCEDURE mgmt$step_117_41;
DROP PROCEDURE mgmt$step_118_41;
DROP PROCEDURE mgmt$step_119_41;

DROP PROCEDURE mgmt$reorg_cleanup_41;
DROP PROCEDURE mgmt$reorg_commentheader_41;

exec mgmt$reorg_sendMsg ('Completed cleanup of generated procedures');

exec mgmt$reorg_sendMsg ('Script execution complete');

spool off
set pagesize 24
set serveroutput off
set feedback on
set echo on
set ver on
