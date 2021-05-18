set feedback off
set serveroutput on
set pagesize 0
set ver off
set echo off

spool /mnt/oracle/product/11.2.0/dbhome_2/dbs/reorg41.log

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
      mgmt$reorg_sendMsg ('ALTER TABLE "TCTDBS"."ACQUIRERLOG" MOVE PARTITION "ACQUIRERLOG_P18"   UPDATE GLOBAL INDEXES');
      EXECUTE IMMEDIATE 'ALTER TABLE "TCTDBS"."ACQUIRERLOG" MOVE PARTITION "ACQUIRERLOG_P18"   UPDATE GLOBAL INDEXES';
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
      mgmt$reorg_sendMsg ('ALTER INDEX "TCTDBS"."AQ_CARD_TIME" REBUILD PARTITION "ACQUIRERLOG_P18"  ');
      EXECUTE IMMEDIATE 'ALTER INDEX "TCTDBS"."AQ_CARD_TIME" REBUILD PARTITION "ACQUIRERLOG_P18"  ';
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
      mgmt$reorg_sendMsg ('ALTER INDEX "TCTDBS"."AQ_EODSERNO" REBUILD PARTITION "ACQUIRERLOG_P18"  ');
      EXECUTE IMMEDIATE 'ALTER INDEX "TCTDBS"."AQ_EODSERNO" REBUILD PARTITION "ACQUIRERLOG_P18"  ';
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
      mgmt$reorg_sendMsg ('ALTER INDEX "TCTDBS"."AQ_LTIMESTAMP" REBUILD PARTITION "ACQUIRERLOG_P18"  ');
      EXECUTE IMMEDIATE 'ALTER INDEX "TCTDBS"."AQ_LTIMESTAMP" REBUILD PARTITION "ACQUIRERLOG_P18"  ';
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
      mgmt$reorg_sendMsg ('ALTER INDEX "TCTDBS"."AQ_MERCHANT" REBUILD PARTITION "ACQUIRERLOG_P18"  ');
      EXECUTE IMMEDIATE 'ALTER INDEX "TCTDBS"."AQ_MERCHANT" REBUILD PARTITION "ACQUIRERLOG_P18"  ';
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
      mgmt$reorg_sendMsg ('ALTER INDEX "TCTDBS"."AQ_TERMINAL" REBUILD PARTITION "ACQUIRERLOG_P18"  ');
      EXECUTE IMMEDIATE 'ALTER INDEX "TCTDBS"."AQ_TERMINAL" REBUILD PARTITION "ACQUIRERLOG_P18"  ';
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
      mgmt$reorg_sendMsg ('ALTER INDEX "TCTDBS"."AQ_TIMEAMNT" REBUILD PARTITION "ACQUIRERLOG_P18"  ');
      EXECUTE IMMEDIATE 'ALTER INDEX "TCTDBS"."AQ_TIMEAMNT" REBUILD PARTITION "ACQUIRERLOG_P18"  ';
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
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_TABLE_STATS(''"TCTDBS"'', ''"ACQUIRERLOG"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_TABLE_STATS(''"TCTDBS"'', ''"ACQUIRERLOG"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;';
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
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_CARD_TIME"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_CARD_TIME"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;';
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
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_EODSERNO"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_EODSERNO"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;';
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
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_LTIMESTAMP"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_LTIMESTAMP"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;';
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
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_MERCHANT"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_MERCHANT"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;';
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
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_SERNO"'', estimate_percent=>NULL); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_SERNO"'', estimate_percent=>NULL); END;';
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
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_TERMINAL"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_TERMINAL"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;';
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
      mgmt$reorg_sendMsg ('BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_TIMEAMNT"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;');
      EXECUTE IMMEDIATE 'BEGIN DBMS_STATS.GATHER_INDEX_STATS(''"TCTDBS"'', ''"AQ_TIMEAMNT"'', partname=>''"ACQUIRERLOG_P18"'', estimate_percent=>NULL); END;';
    EXCEPTION
      WHEN OTHERS THEN
        sqlerr_msg := SUBSTR(SQLERRM, 1, 100);
        mgmt$reorg_errorExitOraError('ERROR executing steps ',  sqlerr_msg);
        step_num := -1;
        return;
    END;
END mgmt$step_15_41;
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
     mgmt$reorg_sendMsg ('--   Target database:	ARCHDB.raiffeisen.ru');
     mgmt$reorg_sendMsg ('--   Script generated at:	18-NOV-2014   12:34');
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

exec mgmt$reorg_sendMsg ('Completed Reorganization.  Starting cleanup phase.');

exec mgmt$reorg_cleanup_41 (41, 'MGMT$REORG_CHECKPOINT', :step_num, 15);

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
