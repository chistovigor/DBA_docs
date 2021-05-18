/* Formatted on 03.02.2015 15:28:54 (QP5 v5.227.12220.39754) */
DECLARE
   JobHandle    NUMBER;
   job_status   VARCHAR2 (9);                          -- COMPLETED or STOPPED
--q           VARCHAR2 (1) := CHR (39);
BEGIN         /* open a new schema level import job using a default DB link */
   JobHandle :=
      DBMS_DATAPUMP.open (operation     => 'IMPORT',
                          job_mode      => 'TABLE',
                          remote_link   => 'ATM_DB');

   DBMS_DATAPUMP.add_file (
      JobHandle,
      filename    => 'testlog2',
      directory   => 'DATA_PUMP_DIR',
      filetype    => DBMS_DATAPUMP.ku$_file_type_log_file);

   DBMS_DATAPUMP.metadata_remap (handle      => JobHandle,
                                 name        => 'REMAP_SCHEMA',
                                 old_value   => 'ROUTER',
                                 VALUE       => 'ROUTER_ENC');

   DBMS_DATAPUMP.metadata_remap (handle      => JobHandle,
                                 name        => 'REMAP_TABLESPACE',
                                 old_value   => 'ANNUAL_DATAENC',
                                 VALUE       => 'ANNUAL_TABLE_ENC');

   DBMS_DATAPUMP.metadata_remap (handle      => JobHandle,
                                 name        => 'REMAP_TABLESPACE',
                                 old_value   => 'ANNUAL_INDEXENC',
                                 VALUE       => 'ANNUAL_INDEX_ENC');

   DBMS_DATAPUMP.metadata_filter (handle        => JobHandle,
                                  name          => 'NAME_EXPR',
                                  VALUE         => '=''AA201411''',
                                  object_type   => 'TABLE');

   DBMS_DATAPUMP.set_parameter (JobHandle, 'TABLE_EXISTS_ACTION', 'REPLACE');

   DBMS_DATAPUMP.start_job (JobHandle);

   DBMS_DATAPUMP.wait_for_job (JobHandle, job_status);
END;