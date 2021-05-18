/* Formatted on 20.02.2018 20:09:47 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE ARDB_USER.CREATE_CCP_NORM_TEST
AS
    /******************************************************************************
       NAME:       CREATE_CCP_NORM_TEST
       PURPOSE: For create test schemas for stress testing of central contragent
       Task:
       http://jira.moex.com/browse/SPUR-152

       REVISIONS:
       Ver        Date        Author           Description
       ---------  ----------  ---------------  ------------------------------------
       1.0        20.02.2018  chistoviy        1. Procedure EXP_CCP_NORM_TEST for export schemas
                  20.02.2018  chistoviy        2. Procedure IMP_CCP_NORM_TEST for import schemas
       1.1        20.02.2018  chistoviy        2. Fuction CHECK_CURRENT_JOB for check if tests schemas exists before import
       1.2        21.02.2018  chistoviy        2. Fuction CHECK_ACTIVE_SESSIONS for check if import/export already running
    ******************************************************************************/
    C_FILE        CONSTANT VARCHAR2 (50) DEFAULT 'CCP_NORM_TEST';
    C_DIRECTORY   CONSTANT VARCHAR2 (50) DEFAULT 'DPUMP_BACKUP2';

    PROCEDURE EXP_CCP_NORM_TEST;

    PROCEDURE IMP_CCP_NORM_TEST;

    FUNCTION CHECK_CURRENT_JOB (V_PROCEDURE VARCHAR2)
        RETURN NUMBER;

    FUNCTION CHECK_ACTIVE_SESSIONS (V_MODE VARCHAR2 DEFAULT 'SHOW')
        RETURN NUMBER;
END;
/


/* Formatted on 20.02.2018 20:16:01 (QP5 v5.313) */
CREATE OR REPLACE PACKAGE BODY ARDB_USER.CREATE_CCP_NORM_TEST
AS
    FUNCTION CHECK_CURRENT_JOB (V_PROCEDURE VARCHAR2)
        RETURN NUMBER
    IS
        V_JOB_EXISTS    NUMBER;
        V_USER_EXISTS   NUMBER;
    BEGIN
        SELECT COUNT (1)
          INTO V_JOB_EXISTS
          FROM V$SESSION
         WHERE ACTION LIKE C_FILE || '%';

        IF V_JOB_EXISTS > 0
        THEN
            RETURN 1;
        ELSE
            SELECT COUNT (1)
              INTO V_USER_EXISTS
              FROM DBA_USERS
             WHERE USERNAME IN ('CCP_NORM_TEST',
                                'ST_DATA_SET_TEST',
                                'NCC_NORM_UI_TEST',
                                'LOADER_CCP_NORM_TEST');

            --IMPORT IMPOSIBLE WHEN SOME OR ALL TEST SCHEMAS CREATED ALREADY, EXIT'

            IF (V_USER_EXISTS > 0 AND V_PROCEDURE LIKE '%IMP_' || C_FILE)
            THEN
                RETURN 1;
            ELSE
                --BUT EXPORT POSIBLE WHEN SOME OR ALL TEST SCHEMAS CREATED ALREADY
                RETURN 0;
            END IF;
        END IF;
    END;

    FUNCTION CHECK_ACTIVE_SESSIONS (V_MODE VARCHAR2 DEFAULT 'SHOW')
        RETURN NUMBER
    IS
        V_USER_EXISTS   NUMBER;
    BEGIN
        DBMS_OUTPUT.ENABLE;

        SELECT COUNT (1)
          INTO V_USER_EXISTS
          FROM V$SESSION
         WHERE (   ACTION = 'procedure working'
                OR USERNAME IN ('CCP_NORM_TEST',
                                'ST_DATA_SET_TEST',
                                'NCC_NORM_UI_TEST',
                                'LOADER_CCP_NORM_TEST'));

        CASE
            WHEN V_MODE = 'SHOW'
            THEN
                RETURN V_USER_EXISTS;
            WHEN V_MODE <> 'SHOW'
            THEN
                RETURN 0;

                FOR REC IN (SELECT SID,
                                   SERIAL#,
                                   MACHINE,
                                   ACTION
                              FROM V$SESSION
                             WHERE ACTION = 'procedure working'
                            UNION ALL
                            SELECT SID,
                                   SERIAL#,
                                   MACHINE,
                                   ACTION
                              FROM V$SESSION
                             WHERE USERNAME IN ('CCP_NORM_TEST',
                                                'ST_DATA_SET_TEST',
                                                'NCC_NORM_UI_TEST',
                                                'LOADER_CCP_NORM_TEST'))
                LOOP
                    IF REC.ACTION <> 'procedure working'
                    THEN
                        DBMS_OUTPUT.PUT_LINE (
                               'ALTER SYSTEM KILL SESSION '''
                            || REC.SID
                            || ','
                            || REC.SERIAL#
                            || ''' IMMEDIATE;');
                    ELSE
                        DBMS_OUTPUT.PUT_LINE (
                               'WAIT UNTIL SESSION '
                            || REC.SID
                            || ','
                            || REC.SERIAL#
                            || ' FINISHED');
                    END IF;
                    RETURN -1;
                END LOOP;
        END CASE;
    END;


    PROCEDURE EXP_CCP_NORM_TEST
    IS
        C_SCHEMAS_LIST   CONSTANT VARCHAR2 (1000)
            := '''CCP_NORM'',''ST_DATA_SET'',''NCC_NORM_UI'',''LOADER_CCP_NORM''' ;
        --                              := '''NCC_NORM_UI'',''LOADER_CCP_NORM''' ;
        V_JOB_HANDLE              NUMBER;              -- Data Pump job handle
        V_JOB_EXISTS              NUMBER; -- Counter for check if the job exists already
        V_JOB_STATUS              NUMBER;  -- Check the job is running already
        V_PL_SQLINIT              VARCHAR2 (500); --variable for current procedure name
        IND                       NUMBER;                        -- Loop index
        SPOS                      NUMBER;          -- String starting position
        SLEN                      NUMBER;          -- String length for output
        PERCENT_DONE              NUMBER;        -- Percentage of job complete
        JOB_STATE                 VARCHAR2 (30); -- To keep track of job state
        LE                        KU$_LOGENTRY;  -- For WIP and error messages
        JS                        KU$_JOBSTATUS; -- The job status from get_status
        JD                        KU$_JOBDESC; -- The job description from get_status
        STS                       KU$_STATUS; -- The status object returned by get_status
    BEGIN
        DBMS_OUTPUT.ENABLE;

        SELECT FN_WHO_AM_I (1) INTO V_PL_SQLINIT FROM DUAL;

        DBMS_OUTPUT.PUT_LINE (V_PL_SQLINIT);

        DBMS_APPLICATION_INFO.SET_MODULE (
            REPLACE (V_PL_SQLINIT, 'PROCEDURE ARDB_USER.', ''),
            'procedure working');

        SELECT CHECK_CURRENT_JOB (V_PL_SQLINIT) INTO V_JOB_STATUS FROM DUAL;

        IF V_JOB_STATUS = 1
        THEN
            DBMS_OUTPUT.PUT_LINE ('JOB EXECUTING ALREADY, EXITING');
            DBMS_APPLICATION_INFO.SET_MODULE (
                REPLACE (V_PL_SQLINIT, 'PROCEDURE ARDB_USER.', ''),
                'PROCEDURE EXIT');
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO V_JOB_EXISTS
          FROM DBA_DATAPUMP_JOBS
         WHERE STATE <> 'RUNNING' AND JOB_NAME = C_FILE || '_EXP';

        IF V_JOB_EXISTS > 0
        THEN
            FOR REC
                IN (SELECT OWNER_NAME, JOB_NAME
                      FROM DBA_DATAPUMP_JOBS
                     WHERE STATE <> 'RUNNING' AND JOB_NAME = C_FILE || '_EXP')
            LOOP
                EXECUTE IMMEDIATE
                       'DROP TABLE '
                    || REC.OWNER_NAME
                    || '.'
                    || REC.JOB_NAME
                    || ' PURGE';
            END LOOP;

            DBMS_OUTPUT.PUT_LINE (
                   'EXPORT JOB '
                || C_FILE
                || '_EXP EXECUTED UNSUCCSESSFULY ALREADY');
            DBMS_OUTPUT.PUT_LINE (
                'DELETING THIS JOB, DISCONNECT FROM DB AND RUN PROCEDURE IN ANOTHER SESSION');
            RETURN;
        END IF;

        V_JOB_HANDLE :=
            DBMS_DATAPUMP.OPEN (OPERATION   => 'EXPORT',
                                JOB_MODE    => 'SCHEMA',
                                JOB_NAME    => C_FILE || '_EXP');
        DBMS_DATAPUMP.ADD_FILE (
            HANDLE      => V_JOB_HANDLE,
            DIRECTORY   => C_DIRECTORY,
            FILENAME    => C_FILE,
            FILETYPE    => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE,
            REUSEFILE   => 1);
        DBMS_DATAPUMP.ADD_FILE (
            HANDLE      => V_JOB_HANDLE,
            DIRECTORY   => C_DIRECTORY,
            FILENAME    => C_FILE,
            FILETYPE    => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);
        DBMS_DATAPUMP.METADATA_FILTER (HANDLE   => V_JOB_HANDLE,
                                       NAME     => 'SCHEMA_LIST',
                                       VALUE    => C_SCHEMAS_LIST);
        DBMS_DATAPUMP.SET_PARAMETER (HANDLE   => V_JOB_HANDLE,
                                     NAME     => 'COMPRESSION',
                                     VALUE    => 'ALL');
        DBMS_DATAPUMP.SET_PARAMETER (HANDLE   => V_JOB_HANDLE,
                                     NAME     => 'FLASHBACK_TIME',
                                     VALUE    => 'SYSDATE');

        BEGIN
            DBMS_DATAPUMP.START_JOB (HANDLE => V_JOB_HANDLE);
            DBMS_OUTPUT.PUT_LINE ('DATA PUMP JOB STARTED SUCCESSFULLY');
        EXCEPTION
            WHEN OTHERS
            THEN
                IF SQLCODE = DBMS_DATAPUMP.SUCCESS_WITH_INFO_NUM
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                        'DATA PUMP JOB STARTED WITH INFO AVAILABLE:');
                    DBMS_DATAPUMP.GET_STATUS (
                        V_JOB_HANDLE,
                        DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR,
                        0,
                        JOB_STATE,
                        STS);

                    IF (BITAND (STS.MASK, DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR) !=
                        0)
                    THEN
                        LE := STS.ERROR;

                        IF LE IS NOT NULL
                        THEN
                            IND := LE.FIRST;

                            WHILE IND IS NOT NULL
                            LOOP
                                DBMS_OUTPUT.PUT_LINE (LE (IND).LOGTEXT);
                                IND := LE.NEXT (IND);
                            END LOOP;
                        END IF;
                    END IF;
                ELSE
                    RAISE;
                END IF;
        END;

        -- THE EXPORT JOB SHOULD NOW BE RUNNING. IN THE FOLLOWING LOOP,
        -- THE JOB IS MONITORED UNTIL IT COMPLETES. IN THE MEANTIME, PROGRESS INFORMATION -- IS DISPLAYED.

        PERCENT_DONE := 0;
        JOB_STATE := 'UNDEFINED';

        WHILE (JOB_STATE != 'COMPLETED') AND (JOB_STATE != 'STOPPED')
        LOOP
            DBMS_DATAPUMP.GET_STATUS (
                V_JOB_HANDLE,
                  DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR
                + DBMS_DATAPUMP.KU$_STATUS_JOB_STATUS
                + DBMS_DATAPUMP.KU$_STATUS_WIP,
                -1,
                JOB_STATE,
                STS);
            JS := STS.JOB_STATUS;

            -- IF THE PERCENTAGE DONE CHANGED, DISPLAY THE NEW VALUE.

            IF JS.PERCENT_DONE != PERCENT_DONE
            THEN
                DBMS_OUTPUT.PUT_LINE (
                    '*** JOB PERCENT DONE = ' || TO_CHAR (JS.PERCENT_DONE));
                PERCENT_DONE := JS.PERCENT_DONE;
            END IF;

            -- DISPLAY ANY WORK-IN-PROGRESS (WIP) OR ERROR MESSAGES THAT WERE RECEIVED FOR
            -- THE JOB.

            IF (BITAND (STS.MASK, DBMS_DATAPUMP.KU$_STATUS_WIP) != 0)
            THEN
                LE := STS.WIP;
            ELSE
                IF (BITAND (STS.MASK, DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR) !=
                    0)
                THEN
                    LE := STS.ERROR;
                ELSE
                    LE := NULL;
                END IF;
            END IF;

            IF LE IS NOT NULL
            THEN
                IND := LE.FIRST;

                WHILE IND IS NOT NULL
                LOOP
                    DBMS_OUTPUT.PUT_LINE (LE (IND).LOGTEXT);
                    IND := LE.NEXT (IND);
                END LOOP;
            END IF;
        END LOOP;

        -- INDICATE THAT THE JOB FINISHED AND DETACH FROM IT.

        DBMS_OUTPUT.PUT_LINE ('JOB HAS COMPLETED');
        DBMS_OUTPUT.PUT_LINE ('FINAL JOB STATE = ' || JOB_STATE);
        DBMS_DATAPUMP.DETACH (V_JOB_HANDLE);

        COMMIT;
        DBMS_APPLICATION_INFO.SET_MODULE (
            REPLACE (V_PL_SQLINIT, 'PROCEDURE ARDB_USER.', ''),
            'PROCEDURE FINISHED');
    -- ANY EXCEPTIONS THAT PROPAGATED TO THIS POINT WILL BE CAPTURED. THE
    -- DETAILS WILL BE RETRIEVED FROM GET_STATUS AND DISPLAYED.
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.PUT_LINE ('EXCEPTION IN DATA PUMP JOB');
            DBMS_DATAPUMP.GET_STATUS (V_JOB_HANDLE,
                                      DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR,
                                      0,
                                      JOB_STATE,
                                      STS);

            IF (BITAND (STS.MASK, DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR) != 0)
            THEN
                LE := STS.ERROR;

                IF LE IS NOT NULL
                THEN
                    IND := LE.FIRST;

                    WHILE IND IS NOT NULL
                    LOOP
                        SPOS := 1;
                        SLEN := LENGTH (LE (IND).LOGTEXT);

                        IF SLEN > 255
                        THEN
                            SLEN := 255;
                        END IF;

                        WHILE SLEN > 0
                        LOOP
                            DBMS_OUTPUT.PUT_LINE (
                                SUBSTR (LE (IND).LOGTEXT, SPOS, SLEN));
                            SPOS := SPOS + 255;
                            SLEN := LENGTH (LE (IND).LOGTEXT) + 1 - SPOS;
                        END LOOP;

                        IND := LE.NEXT (IND);
                    END LOOP;
                END IF;
            END IF;
    END;

    PROCEDURE IMP_CCP_NORM_TEST
    IS
        V_JOB_HANDLE   NUMBER;                         -- DATA PUMP JOB HANDLE
        V_JOB_EXISTS   NUMBER;  -- COUNTER FOR CHECK IF THE JOB EXISTS ALREADY
        V_JOB_STATUS   NUMBER;             -- CHECK THE JOB IS RUNNING ALREADY
        V_PL_SQLINIT   VARCHAR2 (500);   --VARIABLE FOR CURRENT PROCEDURE NAME
        IND            NUMBER;                                   -- LOOP INDEX
        SPOS           NUMBER;                     -- STRING STARTING POSITION
        SLEN           NUMBER;                     -- STRING LENGTH FOR OUTPUT
        PERCENT_DONE   NUMBER;                   -- PERCENTAGE OF JOB COMPLETE
        JOB_STATE      VARCHAR2 (30);            -- TO KEEP TRACK OF JOB STATE
        LE             KU$_LOGENTRY;             -- FOR WIP AND ERROR MESSAGES
        JS             KU$_JOBSTATUS;        -- THE JOB STATUS FROM GET_STATUS
        JD             KU$_JOBDESC;     -- THE JOB DESCRIPTION FROM GET_STATUS
        STS            KU$_STATUS; -- THE STATUS OBJECT RETURNED BY GET_STATUS
    BEGIN
        DBMS_OUTPUT.ENABLE;

        SELECT FN_WHO_AM_I (1) INTO V_PL_SQLINIT FROM DUAL;

        SELECT CHECK_CURRENT_JOB (V_PL_SQLINIT) INTO V_JOB_STATUS FROM DUAL;

        DBMS_OUTPUT.PUT_LINE (V_PL_SQLINIT);

        DBMS_APPLICATION_INFO.SET_MODULE (
            REPLACE (V_PL_SQLINIT, 'PROCEDURE ARDB_USER.', ''),
            'PROCEDURE WORKING');

        IF V_JOB_STATUS = 1
        THEN
            DBMS_OUTPUT.PUT_LINE (
                'JOB EXECUTING ALREADY OR SOME TEST SCHEMAS EXISTS, EXITING');
            DBMS_APPLICATION_INFO.SET_MODULE (
                REPLACE (V_PL_SQLINIT, 'PROCEDURE ARDB_USER.', ''),
                'PROCEDURE EXIT');
            RETURN;
        END IF;

        SELECT COUNT (1)
          INTO V_JOB_EXISTS
          FROM DBA_DATAPUMP_JOBS
         WHERE STATE <> 'RUNNING' AND JOB_NAME = C_FILE || '_IMP';

        IF V_JOB_EXISTS > 0
        THEN
            FOR REC
                IN (SELECT OWNER_NAME, JOB_NAME
                      FROM DBA_DATAPUMP_JOBS
                     WHERE STATE <> 'RUNNING' AND JOB_NAME = C_FILE || '_IMP')
            LOOP
                EXECUTE IMMEDIATE
                       'DROP TABLE '
                    || REC.OWNER_NAME
                    || '.'
                    || REC.JOB_NAME
                    || ' PURGE';
            END LOOP;

            DBMS_OUTPUT.PUT_LINE (
                'IMPORT JOB ' || C_FILE || '_IMP EXECUTED ALREADY');
            DBMS_OUTPUT.PUT_LINE (
                'DELETING THIS JOB, DISCONNECT FROM DB AND RUN PROCEDURE IN ANOTHER SESSION');
            RETURN;
        END IF;

        V_JOB_HANDLE :=
            DBMS_DATAPUMP.OPEN (OPERATION   => 'IMPORT',
                                JOB_MODE    => 'FULL',
                                JOB_NAME    => C_FILE || '_IMP');
        DBMS_DATAPUMP.ADD_FILE (
            HANDLE      => V_JOB_HANDLE,
            DIRECTORY   => C_DIRECTORY,
            FILENAME    => C_FILE,
            FILETYPE    => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);
        DBMS_DATAPUMP.ADD_FILE (
            HANDLE      => V_JOB_HANDLE,
            DIRECTORY   => C_DIRECTORY,
            FILENAME    => 'IMP_' || C_FILE,
            FILETYPE    => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);

        DBMS_DATAPUMP.METADATA_TRANSFORM (HANDLE   => V_JOB_HANDLE,
                                          NAME     => 'OID',
                                          VALUE    => 0);
        DBMS_DATAPUMP.METADATA_REMAP (HANDLE      => V_JOB_HANDLE,
                                      NAME        => 'REMAP_SCHEMA',
                                      OLD_VALUE   => 'CCP_NORM',
                                      VALUE       => 'CCP_NORM_TEST');
        DBMS_DATAPUMP.METADATA_REMAP (HANDLE      => V_JOB_HANDLE,
                                      NAME        => 'REMAP_SCHEMA',
                                      OLD_VALUE   => 'ST_DATA_SET',
                                      VALUE       => 'ST_DATA_SET_TEST');
        DBMS_DATAPUMP.METADATA_REMAP (HANDLE      => V_JOB_HANDLE,
                                      NAME        => 'REMAP_SCHEMA',
                                      OLD_VALUE   => 'NCC_NORM_UI',
                                      VALUE       => 'NCC_NORM_UI_TEST');
        DBMS_DATAPUMP.METADATA_REMAP (HANDLE      => V_JOB_HANDLE,
                                      NAME        => 'REMAP_SCHEMA',
                                      OLD_VALUE   => 'LOADER_CCP_NORM',
                                      VALUE       => 'LOADER_CCP_NORM_TEST');
        DBMS_DATAPUMP.METADATA_REMAP (HANDLE      => V_JOB_HANDLE,
                                      NAME        => 'REMAP_TABLESPACE',
                                      OLD_VALUE   => 'SMALL_TABLES_DATA',
                                      VALUE       => 'TEST_DATA');


        BEGIN
            DBMS_DATAPUMP.START_JOB (HANDLE => V_JOB_HANDLE);
            DBMS_OUTPUT.PUT_LINE ('DATA PUMP JOB STARTED SUCCESSFULLY');
        EXCEPTION
            WHEN OTHERS
            THEN
                IF SQLCODE = DBMS_DATAPUMP.SUCCESS_WITH_INFO_NUM
                THEN
                    DBMS_OUTPUT.PUT_LINE (
                        'DATA PUMP JOB STARTED WITH INFO AVAILABLE:');
                    DBMS_DATAPUMP.GET_STATUS (
                        V_JOB_HANDLE,
                        DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR,
                        0,
                        JOB_STATE,
                        STS);

                    IF (BITAND (STS.MASK, DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR) !=
                        0)
                    THEN
                        LE := STS.ERROR;

                        IF LE IS NOT NULL
                        THEN
                            IND := LE.FIRST;

                            WHILE IND IS NOT NULL
                            LOOP
                                DBMS_OUTPUT.PUT_LINE (LE (IND).LOGTEXT);
                                IND := LE.NEXT (IND);
                            END LOOP;
                        END IF;
                    END IF;
                ELSE
                    RAISE;
                END IF;
        END;

        -- THE EXPORT JOB SHOULD NOW BE RUNNING. IN THE FOLLOWING LOOP,
        -- THE JOB IS MONITORED UNTIL IT COMPLETES. IN THE MEANTIME, PROGRESS INFORMATION -- IS DISPLAYED.

        PERCENT_DONE := 0;
        JOB_STATE := 'UNDEFINED';

        WHILE (JOB_STATE != 'COMPLETED') AND (JOB_STATE != 'STOPPED')
        LOOP
            DBMS_DATAPUMP.GET_STATUS (
                V_JOB_HANDLE,
                  DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR
                + DBMS_DATAPUMP.KU$_STATUS_JOB_STATUS
                + DBMS_DATAPUMP.KU$_STATUS_WIP,
                -1,
                JOB_STATE,
                STS);
            JS := STS.JOB_STATUS;

            -- IF THE PERCENTAGE DONE CHANGED, DISPLAY THE NEW VALUE.

            IF JS.PERCENT_DONE != PERCENT_DONE
            THEN
                DBMS_OUTPUT.PUT_LINE (
                    '*** JOB PERCENT DONE = ' || TO_CHAR (JS.PERCENT_DONE));
                PERCENT_DONE := JS.PERCENT_DONE;
            END IF;

            -- DISPLAY ANY WORK-IN-PROGRESS (WIP) OR ERROR MESSAGES THAT WERE RECEIVED FOR
            -- THE JOB.

            IF (BITAND (STS.MASK, DBMS_DATAPUMP.KU$_STATUS_WIP) != 0)
            THEN
                LE := STS.WIP;
            ELSE
                IF (BITAND (STS.MASK, DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR) !=
                    0)
                THEN
                    LE := STS.ERROR;
                ELSE
                    LE := NULL;
                END IF;
            END IF;

            IF LE IS NOT NULL
            THEN
                IND := LE.FIRST;

                WHILE IND IS NOT NULL
                LOOP
                    DBMS_OUTPUT.PUT_LINE (LE (IND).LOGTEXT);
                    IND := LE.NEXT (IND);
                END LOOP;
            END IF;
        END LOOP;

        -- INDICATE THAT THE JOB FINISHED AND DETACH FROM IT.

        DBMS_OUTPUT.PUT_LINE ('JOB HAS COMPLETED');
        DBMS_OUTPUT.PUT_LINE ('FINAL JOB STATE = ' || JOB_STATE);
        DBMS_DATAPUMP.DETACH (V_JOB_HANDLE);

        COMMIT;
        DBMS_APPLICATION_INFO.SET_MODULE (
            REPLACE (V_PL_SQLINIT, 'PROCEDURE ARDB_USER.', ''),
            'PROCEDURE FINISHED');

        --RECOMPILE IMPORTED TEST SCHEMAS

        SYS.UTL_RECOMP.RECOMP_PARALLEL (2, 'CCP_NORM_TEST');
        SYS.UTL_RECOMP.RECOMP_PARALLEL (2, 'ST_DATA_SET_TEST');
        SYS.UTL_RECOMP.RECOMP_PARALLEL (2, 'NCC_NORM_UI_TEST');
        SYS.UTL_RECOMP.RECOMP_PARALLEL (2, 'LOADER_CCP_NORM_TEST');
    -- ANY EXCEPTIONS THAT PROPAGATED TO THIS POINT WILL BE CAPTURED. THE
    -- DETAILS WILL BE RETRIEVED FROM GET_STATUS AND DISPLAYED.
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.PUT_LINE ('EXCEPTION IN DATA PUMP JOB');
            DBMS_DATAPUMP.GET_STATUS (V_JOB_HANDLE,
                                      DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR,
                                      0,
                                      JOB_STATE,
                                      STS);

            IF (BITAND (STS.MASK, DBMS_DATAPUMP.KU$_STATUS_JOB_ERROR) != 0)
            THEN
                LE := STS.ERROR;

                IF LE IS NOT NULL
                THEN
                    IND := LE.FIRST;

                    WHILE IND IS NOT NULL
                    LOOP
                        SPOS := 1;
                        SLEN := LENGTH (LE (IND).LOGTEXT);

                        IF SLEN > 255
                        THEN
                            SLEN := 255;
                        END IF;

                        WHILE SLEN > 0
                        LOOP
                            DBMS_OUTPUT.PUT_LINE (
                                SUBSTR (LE (IND).LOGTEXT, SPOS, SLEN));
                            SPOS := SPOS + 255;
                            SLEN := LENGTH (LE (IND).LOGTEXT) + 1 - SPOS;
                        END LOOP;

                        IND := LE.NEXT (IND);
                    END LOOP;
                END IF;
            END IF;
    END;
END;