/* Formatted on 25-05-2016 17:08:42 (QP5 v5.287) */
CREATE OR REPLACE PROCEDURE COPY_SCHEMA (
   V_DEST_SCHEMA      VARCHAR2,
   V_SOURCE_SCHEMA    VARCHAR2 DEFAULT 'LOADER_CASH',
   V_DEST_TBSP        VARCHAR2 DEFAULT 'SMALL_TABLES_DATA',
   V_COPY_ROWS        BOOLEAN DEFAULT TRUE)
   AUTHID CURRENT_USER
IS
   JOBHANDLE_EXP    NUMBER;
   JOBHANDLE_IMP    NUMBER;
   JOB_STATUS       VARCHAR2 (9);                      -- COMPLETED or STOPPED
   V_SOURCE_TBSP    VARCHAR2 (40);
   V_OBJECTS_SIZE   NUMBER;
   V_LOG_DIR        VARCHAR2 (200);
   V_SCHEMA_CHECK   NUMBER;
   V_SQL            VARCHAR2 (4000);
BEGIN
     SELECT SUM (BYTES) / 1024 / 1024 MB, TABLESPACE_NAME
       INTO V_OBJECTS_SIZE, V_SOURCE_TBSP
       FROM DBA_SEGMENTS
      WHERE OWNER = V_SOURCE_SCHEMA
   GROUP BY TABLESPACE_NAME;

   SELECT DIRECTORY_PATH
     INTO V_LOG_DIR
     FROM ALL_DIRECTORIES
    WHERE DIRECTORY_NAME = 'DATA_PUMP_DIR';

   SELECT COUNT (USERNAME)
     INTO V_SCHEMA_CHECK
     FROM DBA_USERS
    WHERE UPPER (USERNAME) = UPPER (V_DEST_SCHEMA);

   IF V_SCHEMA_CHECK > 0
   THEN
      DBMS_OUTPUT.PUT_LINE (
         'destination schema already exists, stop execution !');
      RETURN;
   END IF;

   IF V_OBJECTS_SIZE > 2048
   THEN
      DBMS_OUTPUT.PUT_LINE (
         'size too big for automatic copy, stop execution !');
      RETURN;
   END IF;

   /* open a new schema level export job */

   JOBHANDLE_EXP :=
      DBMS_DATAPUMP.OPEN (OPERATION => 'EXPORT', JOB_MODE => 'SCHEMA');

   DBMS_DATAPUMP.ADD_FILE (
      JOBHANDLE_EXP,
      FILENAME    => 'exp_' || V_SOURCE_SCHEMA,
      DIRECTORY   => 'DATA_PUMP_DIR',
      FILETYPE    => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE,
      REUSEFILE   => 1);

   DBMS_DATAPUMP.ADD_FILE (
      JOBHANDLE_EXP,
      FILENAME    => 'exp_' || V_SOURCE_SCHEMA,
      DIRECTORY   => 'DATA_PUMP_DIR',
      FILETYPE    => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);

   DBMS_DATAPUMP.METADATA_FILTER (
      HANDLE   => JOBHANDLE_EXP,
      NAME     => 'SCHEMA_EXPR',
      VALUE    => '=''' || V_SOURCE_SCHEMA || '''');

   DBMS_DATAPUMP.SET_PARAMETER (HANDLE   => JOBHANDLE_EXP,
                                NAME     => 'COMPRESSION',
                                VALUE    => 'ALL');

   IF V_COPY_ROWS = TRUE
   THEN
      NULL;
   ELSE
      DBMS_DATAPUMP.DATA_FILTER (HANDLE   => JOBHANDLE_EXP,
                                 NAME     => 'INCLUDE_ROWS',
                                 VALUE    => 0);
   END IF;

   DBMS_DATAPUMP.START_JOB (JOBHANDLE_EXP);

   DBMS_DATAPUMP.WAIT_FOR_JOB (JOBHANDLE_EXP, JOB_STATUS);

   DBMS_OUTPUT.PUT_LINE (
         'export completed, log of export (at mr01vm01.moex.com server): '
      || V_LOG_DIR
      || '/'
      || 'exp_'
      || V_SOURCE_SCHEMA
      || '.log');

   /* open a new schema level import job */

   JOBHANDLE_IMP :=
      DBMS_DATAPUMP.OPEN (OPERATION => 'IMPORT', JOB_MODE => 'SCHEMA');

   DBMS_DATAPUMP.ADD_FILE (
      JOBHANDLE_IMP,
      FILENAME    => 'exp_' || V_SOURCE_SCHEMA,
      DIRECTORY   => 'DATA_PUMP_DIR',
      FILETYPE    => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE);

   DBMS_DATAPUMP.ADD_FILE (
      JOBHANDLE_IMP,
      FILENAME    => 'imp_' || V_SOURCE_SCHEMA,
      DIRECTORY   => 'DATA_PUMP_DIR',
      FILETYPE    => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);

   DBMS_DATAPUMP.METADATA_REMAP (HANDLE      => JOBHANDLE_IMP,
                                 NAME        => 'REMAP_SCHEMA',
                                 OLD_VALUE   => V_SOURCE_SCHEMA,
                                 VALUE       => V_DEST_SCHEMA);

   DBMS_DATAPUMP.METADATA_REMAP (HANDLE      => JOBHANDLE_IMP,
                                 NAME        => 'REMAP_TABLESPACE',
                                 OLD_VALUE   => V_SOURCE_TBSP,
                                 VALUE       => V_DEST_TBSP);

   DBMS_DATAPUMP.START_JOB (JOBHANDLE_IMP);

   DBMS_DATAPUMP.WAIT_FOR_JOB (JOBHANDLE_IMP, JOB_STATUS);

   -- create types in source schema

   FOR SRC_TYPE
      IN (  SELECT OBJECT_TYPE, OBJECT_NAME, OWNER
              FROM ALL_OBJECTS
             WHERE     UPPER (OWNER) = UPPER (V_SOURCE_SCHEMA)
                   AND OBJECT_TYPE = 'TYPE'
          ORDER BY OBJECT_NAME)
   LOOP
      SELECT REPLACE (
                DBMS_METADATA.GET_DDL (SRC_TYPE.OBJECT_TYPE,
                                       SRC_TYPE.OBJECT_NAME,
                                       SRC_TYPE.OWNER),
                V_SOURCE_SCHEMA,
                V_DEST_SCHEMA)
        INTO V_SQL
        FROM DUAL;

      EXECUTE IMMEDIATE V_SQL;

   END LOOP;

   DBMS_UTILITY.COMPILE_SCHEMA (SCHEMA => V_DEST_SCHEMA);

   DBMS_OUTPUT.PUT_LINE (
         'import completed, log of import (at mr01vm01.moex.com server): '
      || V_LOG_DIR
      || '/'
      || 'imp_'
      || V_SOURCE_SCHEMA
      || '.log');
END;



/*

В схеме ARDB_USER создана процедура COPY_SCHEMA, которую нужно запускать ОТ ИМЕНИ ПОЛЬЗОВАТЕЛЯ ARDB_USER ее описание:
1) Можно создавать новые схемы из схемы LOADER_CASH (параметр V_SOURCE_SCHEMA данной процедуры по умолчанию) в ТП SMALL_TABLES_DATA (параметр V_DEST_TBSP данной процедуры по умолчанию)
2) Возможно копирование в двух вариантах:
2.1
полное копирование (включая строки таблиц) - при этом большие (больше 2Гб) или содержащие данные в нескольких ТП схемы не копируются, т.к. подобное копирование с помощью данной процедуры потенциально не завершится успешно:
exec COPY_SCHEMA('TEST_USER_1');
где TEST_USER_1 - схема, в которую нужно скопировать LOADER_CASH 
2.2
копирование метаданных (НЕ включая строки таблиц) - при этом большие (больше 2Гб) или содержащие данные в нескольких ТП схемы не копируются, т.к. подобное копирование с помощью данной процедуры потенциально не завершится успешно:
exec COPY_SCHEMA(V_DEST_SCHEMA=>'TEST_USER_1',V_COPY_ROWS=>FALSE);
где TEST_USER_1 - схема, в которую нужно скопировать LOADER_CASH
3) Возможно также запускать процедуру для копирования схем, отличных от LOADER_CASH в ТП, отличные от SMALL_TABLES_DATA (на схему-источник в этом случае наложены вышеуказанные ограничения по размеру и ТП)
exec COPY_SCHEMA(V_DEST_SCHEMA=>'TEST_USER_2',V_SOURCE_SCHEMA=>'USER1',V_DEST_TBSP=>'TBSP1');
в примере выше пользователь USER1 копируется в схему TEST_USER_2 с размещением объектов в ТП TBSP1

*/