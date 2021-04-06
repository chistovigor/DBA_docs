DBA Scripts

-- Segments fragmentation analysis (see https://jira.network.ae/jira/browse/PRD-10173)

create table opt_segments_stats (statstr varchar2(4000));

DECLARE
   log_str   dtype.name%TYPE;

   PROCEDURE calc_space (p_segname           IN VARCHAR2,
                         p_owner             IN VARCHAR2,
                         p_type              IN VARCHAR2,
                         p_partition         IN VARCHAR2,
                         p_tablespace_name   IN VARCHAR2)
   AS
      l_free_blks            NUMBER;
      l_total_blocks         NUMBER;
      l_total_bytes          NUMBER;
      l_unused_blocks        NUMBER;
      l_unused_bytes         NUMBER;
      l_LastUsedExtFileId    NUMBER;
      l_LastUsedExtBlockId   NUMBER;
      l_LAST_USED_BLOCK      NUMBER;
      l_segment_space_mgmt   VARCHAR2 (255);
      l_unformatted_blocks   NUMBER;
      l_unformatted_bytes    NUMBER;
      l_fs1_blocks           NUMBER;
      l_fs1_bytes            NUMBER;
      l_fs2_blocks           NUMBER;
      l_fs2_bytes            NUMBER;
      l_fs3_blocks           NUMBER;
      l_fs3_bytes            NUMBER;
      l_fs4_blocks           NUMBER;
      l_fs4_bytes            NUMBER;
      l_full_blocks          NUMBER;
      l_full_bytes           NUMBER;

      PROCEDURE LOG (p_num IN VARCHAR2)
      IS
      BEGIN
         log_str := log_str||TRIM (p_num)||';';
      END;
   BEGIN
      log_str := '';
      LOG (p_segname);
      LOG (p_type);
      LOG (NVL (p_partition, ' '));
      LOG (p_tablespace_name);
      DBMS_SPACE.space_usage (p_owner,
                              p_segname,
                              p_type,
                              l_unformatted_blocks,
                              l_unformatted_bytes,
                              l_fs1_blocks,
                              l_fs1_bytes,
                              l_fs2_blocks,
                              l_fs2_bytes,
                              l_fs3_blocks,
                              l_fs3_bytes,
                              l_fs4_blocks,
                              l_fs4_bytes,
                              l_full_blocks,
                              l_full_bytes,
                              p_partition);

      LOG (l_unformatted_blocks);
      LOG (l_fs1_blocks);
      LOG (l_fs2_blocks);
      LOG (l_fs3_blocks);
      LOG (l_fs4_blocks);
      LOG (l_full_blocks);

      DBMS_SPACE.
       unused_space (segment_owner               => p_owner,
                     segment_name                => p_segname,
                     segment_type                => p_type,
                     partition_name              => p_partition,
                     total_blocks                => l_total_blocks,
                     total_bytes                 => l_total_bytes,
                     unused_blocks               => l_unused_blocks,
                     unused_bytes                => l_unused_bytes,
                     LAST_USED_EXTENT_FILE_ID    => l_LastUsedExtFileId,
                     LAST_USED_EXTENT_BLOCK_ID   => l_LastUsedExtBlockId,
                     LAST_USED_BLOCK             => l_LAST_USED_BLOCK);

      LOG (l_total_blocks);
      LOG (l_total_bytes);
      LOG (TRUNC (l_total_bytes / 1024 / 1024));
      LOG (l_unused_blocks);
      LOG (l_unused_bytes);
      LOG (l_LastUsedExtFileId);
      LOG (l_LastUsedExtBlockId);
      LOG (l_LAST_USED_BLOCK);
   END;
BEGIN
   FOR i
      IN (SELECT segment_name, partition_name, segment_type,tablespace_name
            FROM dba_segments
           WHERE owner='OWS' and (segment_type like 'TABLE%' or segment_type like 'INDEX%') AND extents > 1)
   LOOP
      calc_space (i.segment_name,
                  USER,
                  i.segment_type,
                  i.partition_name,
                  i.tablespace_name);
      insert into opt_segments_stats(trunc(sysdate)||': '||log_str);
--      STND.PROCESS_MESSAGE ('$', trunc(sysdate)||': '||log_str);
      commit;
   END LOOP;
END;
/


https://asktom.oracle.com/pls/apex/asktom.search?tag=block-level-info

FS1 means 0-25% free space within a block
FS2 means 25-50% free space within a block
FS3 means 50-75% free space within a block
FS4 means 75-100% free space within a block


You may calculate fragmentation in percents using the following formulas:

Segment fragmentation:
N_seg=(fs4*0.875+fs3*0.625+fs2*0.375+fs1*0.125+unf_blocks)/total_blocks *100%
where fs1...fs4 values from the report
0.875, 0.625, 0.375, 0.125 the weight coefficients characterizing the influence of a particular fs group on fragmentation, are calculated as the average values of the intervals 75-100, 50-75, 25-50, 0-25, respectively;
unf blocks - amount of unformatted blocks
total blocks - amount of total blocks in a segment;
Tablespace fragmentation
N_tbs=100%*∑(i=m)^n▒〖N(seg_m )*Sseg_m/Stbs〗
where N_seg - the fragmentation value of the segment calculated by the formula above;
Sseg- segment size;
Stbs- tablespace size

-- Maximum resources utilization in the DB for AWR snaps

select * from DBA_HIST_RESOURCE_LIMIT; 

-- Licenced database features usage

SET DEFINE OFF;
CREATE OR REPLACE FORCE VIEW FEATURE_USAGE
AS
select product
     , decode(usage, 'NO_USAGE','NO', usage ) "Used"
     , last_sample_date
     , first_usage_date
     , last_usage_date
------- following sql is based on options_packs_usage_statistics.sql  --> MOS Note 1317265.1
from (
with
MAP as (
-- mapping between features tracked by DBA_FUS and their corresponding database products (options or packs)
select '' PRODUCT, '' feature, '' MVERSION, '' CONDITION from dual union all
SELECT 'Active Data Guard'                                   , 'Active Data Guard - Real-Time Query on Physical Standby' , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Active Data Guard'                                   , 'Global Data Services'                                    , '^12\.'                      , ' '       from dual union all
SELECT 'Advanced Analytics'                                  , 'Data Mining'                                             , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'ADVANCED Index Compression'                              , '^12\.'                      , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'Advanced Index Compression'                              , '^12\.'                      , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'Backup HIGH Compression'                                 , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Backup LOW Compression'                                  , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Backup MEDIUM Compression'                               , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Backup ZLIB Compression'                                 , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Data Guard'                                              , '^11\.2|^12\.'               , 'C001'    from dual union all
SELECT 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '^11\.2\.0\.[1-3]\.'         , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '^(11\.2\.0\.[4-9]\.|12\.)'  , 'INVALID' from dual union all -- licensing required by Optimization for Flashback Data Archive
SELECT 'Advanced Compression'                                , 'HeapCompression'                                         , '^11\.2|^12\.1'              , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'HeapCompression'                                         , '^12\.[2-9]'                 , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Heat Map'                                                , '^12\.1'                     , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'Heat Map'                                                , '^12\.[2-9]'                 , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Hybrid Columnar Compression Row Level Locking'           , '^12\.'                      , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Information Lifecycle Management'                        , '^12\.'                      , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Oracle Advanced Network Compression Service'             , '^12\.'                      , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Oracle Utility Datapump (Export)'                        , '^11\.2|^12\.'               , 'C001'    from dual union all
SELECT 'Advanced Compression'                                , 'Oracle Utility Datapump (Import)'                        , '^11\.2|^12\.'               , 'C001'    from dual union all
SELECT 'Advanced Compression'                                , 'SecureFile Compression (user)'                           , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'SecureFile Deduplication (user)'                         , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'ASO native encryption and checksumming'                  , '^11\.2|^12\.'               , 'INVALID' from dual union all -- no longer part of Advanced Security
SELECT 'Advanced Security'                                   , 'Backup Encryption'                                       , '^11\.2'                     , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Backup Encryption'                                       , '^12\.'                      , 'INVALID' from dual union all -- licensing required only by encryption to disk
SELECT 'Advanced Security'                                   , 'Data Redaction'                                          , '^12\.'                      , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Encrypted Tablespaces'                                   , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Oracle Utility Datapump (Export)'                        , '^11\.2|^12\.'               , 'C002'    from dual union all
SELECT 'Advanced Security'                                   , 'Oracle Utility Datapump (Import)'                        , '^11\.2|^12\.'               , 'C002'    from dual union all
SELECT 'Advanced Security'                                   , 'SecureFile Encryption (user)'                            , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Transparent Data Encryption'                             , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Change Management Pack'                              , 'Change Management Pack'                                  , '^11\.2'                     , ' '       from dual union all
SELECT 'Configuration Management Pack for Oracle Database'   , 'EM Config Management Pack'                               , '^11\.2'                     , ' '       from dual union all
SELECT 'Data Masking Pack'                                   , 'Data Masking Pack'                                       , '^11\.2'                     , ' '       from dual union all
SELECT '.Database Gateway'                                   , 'Gateways'                                                , '^12\.'                      , ' '       from dual union all
SELECT '.Database Gateway'                                   , 'Transparent Gateway'                                     , '^12\.'                      , ' '       from dual union all
SELECT 'Database In-Memory'                                  , 'In-Memory Aggregation'                                   , '^12\.'                      , ' '       from dual union all
SELECT 'Database In-Memory'                                  , 'In-Memory Column Store'                                  , '^12\.1\.0\.2\.0'            , 'BUG'     from dual union all
SELECT 'Database In-Memory'                                  , 'In-Memory Column Store'                                  , '^12\.1\.0\.2\.[^0]|^12\.2'  , ' '       from dual union all
SELECT 'Database Vault'                                      , 'Oracle Database Vault'                                   , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Database Vault'                                      , 'Privilege Capture'                                       , '^12\.'                      , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'ADDM'                                                    , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'AWR Baseline'                                            , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'AWR Baseline Template'                                   , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'AWR Report'                                              , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Automatic Workload Repository'                           , '^12\.'                      , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Baseline Adaptive Thresholds'                            , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Baseline Static Computations'                            , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Diagnostic Pack'                                         , '^11\.2'                     , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'EM Performance Page'                                     , '^12\.'                      , ' '       from dual union all
SELECT '.Exadata'                                            , 'Exadata'                                                 , '^11\.2|^12\.'               , ' '       from dual union all
SELECT '.GoldenGate'                                         , 'GoldenGate'                                              , '^12\.'                      , ' '       from dual union all
SELECT '.HW'                                                 , 'Hybrid Columnar Compression'                             , '^12\.1'                     , 'BUG'     from dual union all
SELECT '.HW'                                                 , 'Hybrid Columnar Compression'                             , '^12\.[2-9]'                 , ' '       from dual union all
SELECT '.HW'                                                 , 'Hybrid Columnar Compression Row Level Locking'           , '^12\.'                      , ' '       from dual union all
SELECT '.HW'                                                 , 'Sun ZFS with EHCC'                                       , '^12\.'                      , ' '       from dual union all
SELECT '.HW'                                                 , 'ZFS Storage'                                             , '^12\.'                      , ' '       from dual union all
SELECT '.HW'                                                 , 'Zone maps'                                               , '^12\.'                      , ' '       from dual union all
SELECT 'Label Security'                                      , 'Label Security'                                          , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Multitenant'                                         , 'Oracle Multitenant'                                      , '^12\.'                      , 'C003'    from dual union all -- licensing required only when more than one PDB containers are created
SELECT 'Multitenant'                                         , 'Oracle Pluggable Databases'                              , '^12\.'                      , 'C003'    from dual union all -- licensing required only when more than one PDB containers are created
SELECT 'OLAP'                                                , 'OLAP - Analytic Workspaces'                              , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'OLAP'                                                , 'OLAP - Cubes'                                            , '^12\.'                      , ' '       from dual union all
SELECT 'Partitioning'                                        , 'Partitioning (user)'                                     , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Partitioning'                                        , 'Zone maps'                                               , '^12\.'                      , ' '       from dual union all
SELECT '.Pillar Storage'                                     , 'Pillar Storage'                                          , '^12\.'                      , ' '       from dual union all
SELECT '.Pillar Storage'                                     , 'Pillar Storage with EHCC'                                , '^12\.'                      , ' '       from dual union all
SELECT '.Provisioning and Patch Automation Pack'             , 'EM Standalone Provisioning and Patch Automation Pack'    , '^11\.2'                     , ' '       from dual union all
SELECT 'Provisioning and Patch Automation Pack for Database' , 'EM Database Provisioning and Patch Automation Pack'      , '^11\.2'                     , ' '       from dual union all
SELECT 'RAC or RAC One Node'                                 , 'Quality of Service Management'                           , '^12\.'                      , ' '       from dual union all
SELECT 'Real Application Clusters'                           , 'Real Application Clusters (RAC)'                         , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Real Application Clusters One Node'                  , 'Real Application Cluster One Node'                       , '^12\.'                      , ' '       from dual union all
SELECT 'Real Application Testing'                            , 'Database Replay: Workload Capture'                       , '^11\.2|^12\.'               , 'C004'    from dual union all
SELECT 'Real Application Testing'                            , 'Database Replay: Workload Replay'                        , '^11\.2|^12\.'               , 'C004'    from dual union all
SELECT 'Real Application Testing'                            , 'SQL Performance Analyzer'                                , '^11\.2|^12\.'               , 'C004'    from dual union all
SELECT '.Secure Backup'                                      , 'Oracle Secure Backup'                                    , '^12\.'                      , 'INVALID' from dual union all  -- does not differentiate usage of Oracle Secure Backup Express, which is free
SELECT 'Spatial and Graph'                                   , 'Spatial'                                                 , '^11\.2'                     , 'INVALID' from dual union all  -- does not differentiate usage of Locator, which is free
SELECT 'Spatial and Graph'                                   , 'Spatial'                                                 , '^12\.'                      , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'Automatic Maintenance - SQL Tuning Advisor'              , '^12\.'                      , 'INVALID' from dual union all  -- system usage in the maintenance window
SELECT 'Tuning Pack'                                         , 'Automatic SQL Tuning Advisor'                            , '^11\.2|^12\.'               , 'INVALID' from dual union all  -- system usage in the maintenance window
SELECT 'Tuning Pack'                                         , 'Real-Time SQL Monitoring'                                , '^11\.2'                     , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'Real-Time SQL Monitoring'                                , '^12\.'                      , 'INVALID' from dual union all  -- default
SELECT 'Tuning Pack'                                         , 'SQL Access Advisor'                                      , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Monitoring and Tuning pages'                         , '^12\.'                      , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Profile'                                             , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Tuning Advisor'                                      , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Tuning Set (user)'                                   , '^12\.'                      , 'INVALID' from dual union all -- no longer part of Tuning Pack
SELECT 'Tuning Pack'                                         , 'Tuning Pack'                                             , '^11\.2'                     , ' '       from dual union all
SELECT '.WebLogic Server Management Pack Enterprise Edition' , 'EM AS Provisioning and Patch Automation Pack'            , '^11\.2'                     , ' '       from dual union all
select '' PRODUCT, '' FEATURE, '' MVERSION, '' CONDITION from dual
),
FUS as (
-- the current data set to be used: DBA_FEATURE_USAGE_STATISTICS or CDB_FEATURE_USAGE_STATISTICS for Container Databases(CDBs)
select
    0 as CON_ID,
    NULL as CON_NAME,
    -- Detect and mark with Y the current DBA_FUS data set = Most Recent Sample based on LAST_SAMPLE_DATE
      case when DBID || '#' || VERSION || '#' || to_char(LAST_SAMPLE_DATE, 'YYYYMMDDHH24MISS') =
                first_value (DBID    )         over (partition by 0 order by LAST_SAMPLE_DATE desc nulls last, DBID desc) || '#' ||
                first_value (VERSION )         over (partition by 0 order by LAST_SAMPLE_DATE desc nulls last, DBID desc) || '#' ||
                first_value (to_char(LAST_SAMPLE_DATE, 'YYYYMMDDHH24MISS'))
                                               over (partition by 0 order by LAST_SAMPLE_DATE desc nulls last, DBID desc)
           then 'Y'
           else 'N'
    end as CURRENT_ENTRY,
    NAME            ,
    LAST_SAMPLE_DATE,
    DBID            ,
    VERSION         ,
    DETECTED_USAGES ,
    TOTAL_SAMPLES   ,
    CURRENTLY_USED  ,
    FIRST_USAGE_DATE,
    LAST_USAGE_DATE ,
    AUX_COUNT       ,
    FEATURE_INFO
from DBA_FEATURE_USAGE_STATISTICS xy
),
PFUS as (
-- Product-Feature Usage Statitsics = DBA_FUS entries mapped to their corresponding database products
select
    CON_ID,
    CON_NAME,
    PRODUCT,
    NAME as FEATURE_BEING_USED,
    case  when CONDITION = 'BUG'
               --suppressed due to exceptions/defects
               then '3.SUPPRESSED_DUE_TO_BUG'
          when     detected_usages > 0                 -- some usage detection - current or past
               and CURRENTLY_USED = 'TRUE'             -- usage at LAST_SAMPLE_DATE
               and CURRENT_ENTRY  = 'Y'                -- current record set
               and (    trim(CONDITION) is null        -- no extra conditions
                     or CONDITION_MET     = 'TRUE'     -- extra condition is met
                    and CONDITION_COUNTER = 'FALSE' )  -- extra condition is not based on counter
               then '6.CURRENT_USAGE'
          when     detected_usages > 0                 -- some usage detection - current or past
               and CURRENTLY_USED = 'TRUE'             -- usage at LAST_SAMPLE_DATE
               and CURRENT_ENTRY  = 'Y'                -- current record set
               and (    CONDITION_MET     = 'TRUE'     -- extra condition is met
                    and CONDITION_COUNTER = 'TRUE'  )  -- extra condition is     based on counter
               then '5.PAST_OR_CURRENT_USAGE'          -- FEATURE_INFO counters indicate current or past usage
          when     detected_usages > 0                 -- some usage detection - current or past
               and (    trim(CONDITION) is null        -- no extra conditions
                     or CONDITION_MET     = 'TRUE'  )  -- extra condition is met
               then '4.PAST_USAGE'
          when CURRENT_ENTRY = 'Y'
               then '2.NO_CURRENT_USAGE'   -- detectable feature shows no current usage
          else '1.NO_PAST_USAGE'
    end as USAGE,
    LAST_SAMPLE_DATE,
    DBID            ,
    VERSION         ,
    DETECTED_USAGES ,
    TOTAL_SAMPLES   ,
    CURRENTLY_USED  ,
    case  when CONDITION like 'C___' and CONDITION_MET = 'FALSE'
               then to_date('')
          else FIRST_USAGE_DATE
    end as FIRST_USAGE_DATE,
    case  when CONDITION like 'C___' and CONDITION_MET = 'FALSE'
               then to_date('')
          else LAST_USAGE_DATE
    end as LAST_USAGE_DATE,
    EXTRA_FEATURE_INFO
from (
select m.PRODUCT, m.CONDITION, m.MVERSION,
       -- if extra conditions (coded on the MAP.CONDITION column) are required, check if entries satisfy the condition
       case
             when CONDITION = 'C001' and (   regexp_like(to_char(FEATURE_INFO), 'compression used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                                          or regexp_like(to_char(FEATURE_INFO), 'compression used: *TRUE', 'i')                 )
                  then 'TRUE'  -- compression has been used
             when CONDITION = 'C002' and (   regexp_like(to_char(FEATURE_INFO), 'encryption used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                                          or regexp_like(to_char(FEATURE_INFO), 'encryption used: *TRUE', 'i')                  )
                  then 'TRUE'  -- encryption has been used
             when CONDITION = 'C003' and CON_ID=1 and AUX_COUNT > 1
                  then 'TRUE'  -- more than one PDB are created
             when CONDITION = 'C004' and 'N'= 'N'
                  then 'TRUE'  -- not in oracle cloud
             else 'FALSE'
       end as CONDITION_MET,
       -- check if the extra conditions are based on FEATURE_INFO counters. They indicate current or past usage.
       case
             when CONDITION = 'C001' and     regexp_like(to_char(FEATURE_INFO), 'compression used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                  then 'TRUE'  -- compression counter > 0
             when CONDITION = 'C002' and     regexp_like(to_char(FEATURE_INFO), 'encryption used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                  then 'TRUE'  -- encryption counter > 0
             else 'FALSE'
       end as CONDITION_COUNTER,
       case when CONDITION = 'C001'
                 then   regexp_substr(to_char(FEATURE_INFO), 'compression used:(.*?)(times|TRUE|FALSE)', 1, 1, 'i')
            when CONDITION = 'C002'
                 then   regexp_substr(to_char(FEATURE_INFO), 'encryption used:(.*?)(times|TRUE|FALSE)', 1, 1, 'i')
            when CONDITION = 'C003'
                 then   'AUX_COUNT=' || AUX_COUNT
            when CONDITION = 'C004' and 'N'= 'Y'
                 then   'feature included in Oracle Cloud Services Package'
            else ''
       end as EXTRA_FEATURE_INFO,
       f.CON_ID          ,
       f.CON_NAME        ,
       f.CURRENT_ENTRY   ,
       f.NAME            ,
       f.LAST_SAMPLE_DATE,
       f.DBID            ,
       f.VERSION         ,
       f.DETECTED_USAGES ,
       f.TOTAL_SAMPLES   ,
       f.CURRENTLY_USED  ,
       f.FIRST_USAGE_DATE,
       f.LAST_USAGE_DATE ,
       f.AUX_COUNT       ,
       f.FEATURE_INFO
  from MAP m
  join FUS f on m.FEATURE = f.NAME and regexp_like(f.VERSION, m.MVERSION)
  where nvl(f.TOTAL_SAMPLES, 0) > 0                        -- ignore features that have never been sampled
)
  where nvl(CONDITION, '-') != 'INVALID'                   -- ignore features for which licensing is not required without further conditions
    and not (CONDITION = 'C003' and CON_ID not in (0, 1))  -- multiple PDBs are visible only in CDB$ROOT; PDB level view is not relevant
)
select
    grouping_id(CON_ID) as gid,
    CON_ID   ,
    decode(grouping_id(CON_ID), 1, '--ALL--', max(CON_NAME)) as CON_NAME,
    PRODUCT  ,
    decode(max(USAGE),
          '1.NO_PAST_USAGE'        , 'NO_USAGE'             ,
          '2.NO_CURRENT_USAGE'     , 'NO_USAGE'             ,
          '3.SUPPRESSED_DUE_TO_BUG', 'SUPPRESSED_DUE_TO_BUG',
          '4.PAST_USAGE'           , 'PAST_USAGE'           ,
          '5.PAST_OR_CURRENT_USAGE', 'PAST_OR_CURRENT_USAGE',
          '6.CURRENT_USAGE'        , 'CURRENT_USAGE'        ,
          'UNKNOWN') as USAGE,
    max(LAST_SAMPLE_DATE) as LAST_SAMPLE_DATE,
    min(FIRST_USAGE_DATE) as FIRST_USAGE_DATE,
    max(LAST_USAGE_DATE)  as LAST_USAGE_DATE
  from PFUS
  where USAGE in ('2.NO_CURRENT_USAGE', '4.PAST_USAGE', '5.PAST_OR_CURRENT_USAGE', '6.CURRENT_USAGE')   -- ignore '1.NO_PAST_USAGE', '3.SUPPRESSED_DUE_TO_BUG'
  group by rollup(CON_ID), PRODUCT
  having not (max(CON_ID) in (-1, 0) and grouping_id(CON_ID) = 1)            -- aggregation not needed for non-container databases
order by GID desc, CON_ID, decode(substr(PRODUCT, 1, 1), '.', 2, 1), PRODUCT );
 
 
CREATE OR REPLACE FORCE VIEW FEATURE_USAGE_DETAILS
AS
select product
     , feature_being_used
     , usage
     , last_sample_date
     , dbid
     , ( select name from v$database ) dbname
     , version
     , detected_usages
     , total_samples
     , currently_used
     , first_usage_date
     , last_usage_date
     , extra_feature_info
------- following sql is based on options_packs_usage_statistics.sql  --> MOS Note 1317265.1
from (
with
MAP as (
-- mapping between features tracked by DBA_FUS and their corresponding database products (options or packs)
select '' PRODUCT, '' feature, '' MVERSION, '' CONDITION from dual union all
SELECT 'Active Data Guard'                                   , 'Active Data Guard - Real-Time Query on Physical Standby' , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Active Data Guard'                                   , 'Global Data Services'                                    , '^12\.'                      , ' '       from dual union all
SELECT 'Advanced Analytics'                                  , 'Data Mining'                                             , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'ADVANCED Index Compression'                              , '^12\.'                      , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'Advanced Index Compression'                              , '^12\.'                      , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'Backup HIGH Compression'                                 , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Backup LOW Compression'                                  , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Backup MEDIUM Compression'                               , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Backup ZLIB Compression'                                 , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Data Guard'                                              , '^11\.2|^12\.'               , 'C001'    from dual union all
SELECT 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '^11\.2\.0\.[1-3]\.'         , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Flashback Data Archive'                                  , '^(11\.2\.0\.[4-9]\.|12\.)'  , 'INVALID' from dual union all -- licensing required by Optimization for Flashback Data Archive
SELECT 'Advanced Compression'                                , 'HeapCompression'                                         , '^11\.2|^12\.1'              , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'HeapCompression'                                         , '^12\.[2-9]'                 , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Heat Map'                                                , '^12\.1'                     , 'BUG'     from dual union all
SELECT 'Advanced Compression'                                , 'Heat Map'                                                , '^12\.[2-9]'                 , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Hybrid Columnar Compression Row Level Locking'           , '^12\.'                      , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Information Lifecycle Management'                        , '^12\.'                      , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Oracle Advanced Network Compression Service'             , '^12\.'                      , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'Oracle Utility Datapump (Export)'                        , '^11\.2|^12\.'               , 'C001'    from dual union all
SELECT 'Advanced Compression'                                , 'Oracle Utility Datapump (Import)'                        , '^11\.2|^12\.'               , 'C001'    from dual union all
SELECT 'Advanced Compression'                                , 'SecureFile Compression (user)'                           , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Compression'                                , 'SecureFile Deduplication (user)'                         , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'ASO native encryption and checksumming'                  , '^11\.2|^12\.'               , 'INVALID' from dual union all -- no longer part of Advanced Security
SELECT 'Advanced Security'                                   , 'Backup Encryption'                                       , '^11\.2'                     , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Backup Encryption'                                       , '^12\.'                      , 'INVALID' from dual union all -- licensing required only by encryption to disk
SELECT 'Advanced Security'                                   , 'Data Redaction'                                          , '^12\.'                      , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Encrypted Tablespaces'                                   , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Oracle Utility Datapump (Export)'                        , '^11\.2|^12\.'               , 'C002'    from dual union all
SELECT 'Advanced Security'                                   , 'Oracle Utility Datapump (Import)'                        , '^11\.2|^12\.'               , 'C002'    from dual union all
SELECT 'Advanced Security'                                   , 'SecureFile Encryption (user)'                            , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Advanced Security'                                   , 'Transparent Data Encryption'                             , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Change Management Pack'                              , 'Change Management Pack'                                  , '^11\.2'                     , ' '       from dual union all
SELECT 'Configuration Management Pack for Oracle Database'   , 'EM Config Management Pack'                               , '^11\.2'                     , ' '       from dual union all
SELECT 'Data Masking Pack'                                   , 'Data Masking Pack'                                       , '^11\.2'                     , ' '       from dual union all
SELECT '.Database Gateway'                                   , 'Gateways'                                                , '^12\.'                      , ' '       from dual union all
SELECT '.Database Gateway'                                   , 'Transparent Gateway'                                     , '^12\.'                      , ' '       from dual union all
SELECT 'Database In-Memory'                                  , 'In-Memory Aggregation'                                   , '^12\.'                      , ' '       from dual union all
SELECT 'Database In-Memory'                                  , 'In-Memory Column Store'                                  , '^12\.1\.0\.2\.0'            , 'BUG'     from dual union all
SELECT 'Database In-Memory'                                  , 'In-Memory Column Store'                                  , '^12\.1\.0\.2\.[^0]|^12\.2'  , ' '       from dual union all
SELECT 'Database Vault'                                      , 'Oracle Database Vault'                                   , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Database Vault'                                      , 'Privilege Capture'                                       , '^12\.'                      , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'ADDM'                                                    , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'AWR Baseline'                                            , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'AWR Baseline Template'                                   , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'AWR Report'                                              , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Automatic Workload Repository'                           , '^12\.'                      , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Baseline Adaptive Thresholds'                            , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Baseline Static Computations'                            , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'Diagnostic Pack'                                         , '^11\.2'                     , ' '       from dual union all
SELECT 'Diagnostics Pack'                                    , 'EM Performance Page'                                     , '^12\.'                      , ' '       from dual union all
SELECT '.Exadata'                                            , 'Exadata'                                                 , '^11\.2|^12\.'               , ' '       from dual union all
SELECT '.GoldenGate'                                         , 'GoldenGate'                                              , '^12\.'                      , ' '       from dual union all
SELECT '.HW'                                                 , 'Hybrid Columnar Compression'                             , '^12\.1'                     , 'BUG'     from dual union all
SELECT '.HW'                                                 , 'Hybrid Columnar Compression'                             , '^12\.[2-9]'                 , ' '       from dual union all
SELECT '.HW'                                                 , 'Hybrid Columnar Compression Row Level Locking'           , '^12\.'                      , ' '       from dual union all
SELECT '.HW'                                                 , 'Sun ZFS with EHCC'                                       , '^12\.'                      , ' '       from dual union all
SELECT '.HW'                                                 , 'ZFS Storage'                                             , '^12\.'                      , ' '       from dual union all
SELECT '.HW'                                                 , 'Zone maps'                                               , '^12\.'                      , ' '       from dual union all
SELECT 'Label Security'                                      , 'Label Security'                                          , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Multitenant'                                         , 'Oracle Multitenant'                                      , '^12\.'                      , 'C003'    from dual union all -- licensing required only when more than one PDB containers are created
SELECT 'Multitenant'                                         , 'Oracle Pluggable Databases'                              , '^12\.'                      , 'C003'    from dual union all -- licensing required only when more than one PDB containers are created
SELECT 'OLAP'                                                , 'OLAP - Analytic Workspaces'                              , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'OLAP'                                                , 'OLAP - Cubes'                                            , '^12\.'                      , ' '       from dual union all
SELECT 'Partitioning'                                        , 'Partitioning (user)'                                     , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Partitioning'                                        , 'Zone maps'                                               , '^12\.'                      , ' '       from dual union all
SELECT '.Pillar Storage'                                     , 'Pillar Storage'                                          , '^12\.'                      , ' '       from dual union all
SELECT '.Pillar Storage'                                     , 'Pillar Storage with EHCC'                                , '^12\.'                      , ' '       from dual union all
SELECT '.Provisioning and Patch Automation Pack'             , 'EM Standalone Provisioning and Patch Automation Pack'    , '^11\.2'                     , ' '       from dual union all
SELECT 'Provisioning and Patch Automation Pack for Database' , 'EM Database Provisioning and Patch Automation Pack'      , '^11\.2'                     , ' '       from dual union all
SELECT 'RAC or RAC One Node'                                 , 'Quality of Service Management'                           , '^12\.'                      , ' '       from dual union all
SELECT 'Real Application Clusters'                           , 'Real Application Clusters (RAC)'                         , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Real Application Clusters One Node'                  , 'Real Application Cluster One Node'                       , '^12\.'                      , ' '       from dual union all
SELECT 'Real Application Testing'                            , 'Database Replay: Workload Capture'                       , '^11\.2|^12\.'               , 'C004'    from dual union all
SELECT 'Real Application Testing'                            , 'Database Replay: Workload Replay'                        , '^11\.2|^12\.'               , 'C004'    from dual union all
SELECT 'Real Application Testing'                            , 'SQL Performance Analyzer'                                , '^11\.2|^12\.'               , 'C004'    from dual union all
SELECT '.Secure Backup'                                      , 'Oracle Secure Backup'                                    , '^12\.'                      , 'INVALID' from dual union all  -- does not differentiate usage of Oracle Secure Backup Express, which is free
SELECT 'Spatial and Graph'                                   , 'Spatial'                                                 , '^11\.2'                     , 'INVALID' from dual union all  -- does not differentiate usage of Locator, which is free
SELECT 'Spatial and Graph'                                   , 'Spatial'                                                 , '^12\.'                      , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'Automatic Maintenance - SQL Tuning Advisor'              , '^12\.'                      , 'INVALID' from dual union all  -- system usage in the maintenance window
SELECT 'Tuning Pack'                                         , 'Automatic SQL Tuning Advisor'                            , '^11\.2|^12\.'               , 'INVALID' from dual union all  -- system usage in the maintenance window
SELECT 'Tuning Pack'                                         , 'Real-Time SQL Monitoring'                                , '^11\.2'                     , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'Real-Time SQL Monitoring'                                , '^12\.'                      , 'INVALID' from dual union all  -- default
SELECT 'Tuning Pack'                                         , 'SQL Access Advisor'                                      , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Monitoring and Tuning pages'                         , '^12\.'                      , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Profile'                                             , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Tuning Advisor'                                      , '^11\.2|^12\.'               , ' '       from dual union all
SELECT 'Tuning Pack'                                         , 'SQL Tuning Set (user)'                                   , '^12\.'                      , 'INVALID' from dual union all -- no longer part of Tuning Pack
SELECT 'Tuning Pack'                                         , 'Tuning Pack'                                             , '^11\.2'                     , ' '       from dual union all
SELECT '.WebLogic Server Management Pack Enterprise Edition' , 'EM AS Provisioning and Patch Automation Pack'            , '^11\.2'                     , ' '       from dual union all
select '' PRODUCT, '' FEATURE, '' MVERSION, '' CONDITION from dual
),
FUS as (
-- the current data set to be used: DBA_FEATURE_USAGE_STATISTICS or CDB_FEATURE_USAGE_STATISTICS for Container Databases(CDBs)
select
    0 as CON_ID,
    NULL as CON_NAME,
    -- Detect and mark with Y the current DBA_FUS data set = Most Recent Sample based on LAST_SAMPLE_DATE
      case when DBID || '#' || VERSION || '#' || to_char(LAST_SAMPLE_DATE, 'YYYYMMDDHH24MISS') =
                first_value (DBID    )         over (partition by 0 order by LAST_SAMPLE_DATE desc nulls last, DBID desc) || '#' ||
                first_value (VERSION )         over (partition by 0 order by LAST_SAMPLE_DATE desc nulls last, DBID desc) || '#' ||
                first_value (to_char(LAST_SAMPLE_DATE, 'YYYYMMDDHH24MISS'))
                                               over (partition by 0 order by LAST_SAMPLE_DATE desc nulls last, DBID desc)
           then 'Y'
           else 'N'
    end as CURRENT_ENTRY,
    NAME            ,
    LAST_SAMPLE_DATE,
    DBID            ,
    VERSION         ,
    DETECTED_USAGES ,
    TOTAL_SAMPLES   ,
    CURRENTLY_USED  ,
    FIRST_USAGE_DATE,
    LAST_USAGE_DATE ,
    AUX_COUNT       ,
    FEATURE_INFO
from DBA_FEATURE_USAGE_STATISTICS xy
),
PFUS as (
-- Product-Feature Usage Statitsics = DBA_FUS entries mapped to their corresponding database products
select
    CON_ID,
    CON_NAME,
    PRODUCT,
    NAME as FEATURE_BEING_USED,
    case  when CONDITION = 'BUG'
               --suppressed due to exceptions/defects
               then '3.SUPPRESSED_DUE_TO_BUG'
          when     detected_usages > 0                 -- some usage detection - current or past
               and CURRENTLY_USED = 'TRUE'             -- usage at LAST_SAMPLE_DATE
               and CURRENT_ENTRY  = 'Y'                -- current record set
               and (    trim(CONDITION) is null        -- no extra conditions
                     or CONDITION_MET     = 'TRUE'     -- extra condition is met
                    and CONDITION_COUNTER = 'FALSE' )  -- extra condition is not based on counter
               then '6.CURRENT_USAGE'
          when     detected_usages > 0                 -- some usage detection - current or past
               and CURRENTLY_USED = 'TRUE'             -- usage at LAST_SAMPLE_DATE
               and CURRENT_ENTRY  = 'Y'                -- current record set
               and (    CONDITION_MET     = 'TRUE'     -- extra condition is met
                    and CONDITION_COUNTER = 'TRUE'  )  -- extra condition is     based on counter
               then '5.PAST_OR_CURRENT_USAGE'          -- FEATURE_INFO counters indicate current or past usage
          when     detected_usages > 0                 -- some usage detection - current or past
               and (    trim(CONDITION) is null        -- no extra conditions
                     or CONDITION_MET     = 'TRUE'  )  -- extra condition is met
               then '4.PAST_USAGE'
          when CURRENT_ENTRY = 'Y'
               then '2.NO_CURRENT_USAGE'   -- detectable feature shows no current usage
          else '1.NO_PAST_USAGE'
    end as USAGE,
    LAST_SAMPLE_DATE,
    DBID            ,
    VERSION         ,
    DETECTED_USAGES ,
    TOTAL_SAMPLES   ,
    CURRENTLY_USED  ,
    FIRST_USAGE_DATE,
    LAST_USAGE_DATE,
    EXTRA_FEATURE_INFO
from (
select m.PRODUCT, m.CONDITION, m.MVERSION,
       -- if extra conditions (coded on the MAP.CONDITION column) are required, check if entries satisfy the condition
       case
             when CONDITION = 'C001' and (   regexp_like(to_char(FEATURE_INFO), 'compression used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                                          or regexp_like(to_char(FEATURE_INFO), 'compression used: *TRUE', 'i')                 )
                  then 'TRUE'  -- compression has been used
             when CONDITION = 'C002' and (   regexp_like(to_char(FEATURE_INFO), 'encryption used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                                          or regexp_like(to_char(FEATURE_INFO), 'encryption used: *TRUE', 'i')                  )
                  then 'TRUE'  -- encryption has been used
             when CONDITION = 'C003' and CON_ID=1 and AUX_COUNT > 1
                  then 'TRUE'  -- more than one PDB are created
             when CONDITION = 'C004' and 'N'= 'N'
                  then 'TRUE'  -- not in oracle cloud
             else 'FALSE'
       end as CONDITION_MET,
       -- check if the extra conditions are based on FEATURE_INFO counters. They indicate current or past usage.
       case
             when CONDITION = 'C001' and     regexp_like(to_char(FEATURE_INFO), 'compression used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                  then 'TRUE'  -- compression counter > 0
             when CONDITION = 'C002' and     regexp_like(to_char(FEATURE_INFO), 'encryption used:[ 0-9]*[1-9][ 0-9]*time', 'i')
                  then 'TRUE'  -- encryption counter > 0
             else 'FALSE'
       end as CONDITION_COUNTER,
       case when CONDITION = 'C001'
                 then   regexp_substr(to_char(FEATURE_INFO), 'compression used:(.*?)(times|TRUE|FALSE)', 1, 1, 'i')
            when CONDITION = 'C002'
                 then   regexp_substr(to_char(FEATURE_INFO), 'encryption used:(.*?)(times|TRUE|FALSE)', 1, 1, 'i')
            when CONDITION = 'C003'
                 then   'AUX_COUNT=' || AUX_COUNT
            when CONDITION = 'C004' and 'N'= 'Y'
                 then   'feature included in Oracle Cloud Services Package'
            else ''
       end as EXTRA_FEATURE_INFO,
       f.CON_ID          ,
       f.CON_NAME        ,
       f.CURRENT_ENTRY   ,
       f.NAME            ,
       f.LAST_SAMPLE_DATE,
       f.DBID            ,
       f.VERSION         ,
       f.DETECTED_USAGES ,
       f.TOTAL_SAMPLES   ,
       f.CURRENTLY_USED  ,
       f.FIRST_USAGE_DATE,
       f.LAST_USAGE_DATE ,
       f.AUX_COUNT       ,
       f.FEATURE_INFO
  from MAP m
  join FUS f on m.FEATURE = f.NAME and regexp_like(f.VERSION, m.MVERSION)
  where nvl(f.TOTAL_SAMPLES, 0) > 0                        -- ignore features that have never been sampled
)
  where nvl(CONDITION, '-') != 'INVALID'                   -- ignore features for which licensing is not required without further conditions
    and not (CONDITION = 'C003' and CON_ID not in (0, 1))  -- multiple PDBs are visible only in CDB$ROOT; PDB level view is not relevant
)
select
    CON_ID            ,
    CON_NAME          ,
    PRODUCT           ,
    FEATURE_BEING_USED,
    decode(USAGE,
          '1.NO_PAST_USAGE'        , 'NO_PAST_USAGE'        ,
          '2.NO_CURRENT_USAGE'     , 'NO_CURRENT_USAGE'     ,
          '3.SUPPRESSED_DUE_TO_BUG', 'SUPPRESSED_DUE_TO_BUG',
          '4.PAST_USAGE'           , 'PAST_USAGE'           ,
          '5.PAST_OR_CURRENT_USAGE', 'PAST_OR_CURRENT_USAGE',
          '6.CURRENT_USAGE'        , 'CURRENT_USAGE'        ,
          'UNKNOWN') as USAGE,
    LAST_SAMPLE_DATE  ,
    DBID              ,
    VERSION           ,
    DETECTED_USAGES   ,
    TOTAL_SAMPLES     ,
    CURRENTLY_USED    ,
    FIRST_USAGE_DATE  ,
    LAST_USAGE_DATE   ,
    EXTRA_FEATURE_INFO
  from PFUS
  where USAGE in ('2.NO_CURRENT_USAGE', '3.SUPPRESSED_DUE_TO_BUG', '4.PAST_USAGE', '5.PAST_OR_CURRENT_USAGE', '6.CURRENT_USAGE')  -- ignore '1.NO_PAST_USAGE'
order by CON_ID, decode(substr(PRODUCT, 1, 1), '.', 2, 1), PRODUCT, FEATURE_BEING_USED, LAST_SAMPLE_DATE desc, PFUS.USAGE );


Monitoring


  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/access.sql
-- Author       : Tim Hall
-- Description  : Lists all objects being accessed in the schema.
-- Call Syntax  : @access (schema-name or all) (object-name or all)
-- Requirements : Access to the v$views.
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 255
SET VERIFY OFF

COLUMN object FORMAT A30

  SELECT a.object,
         a.TYPE,
         a.sid,
         b.serial#,
         b.username,
         b.osuser,
         b.program
    FROM v$access a, v$session b
   WHERE     a.sid = b.sid
         AND a.owner = DECODE (UPPER ('&1'), 'ALL', a.object, UPPER ('&1'))
         AND a.object = DECODE (UPPER ('&2'), 'ALL', a.object, UPPER ('&2'))
ORDER BY a.object;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/active_sessions.sql
-- Author       : Tim Hall
-- Description  : Displays information on all active database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @active_sessions
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000

COLUMN username FORMAT A15
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20

  SELECT NVL (s.username, '(oracle)') AS username,
         s.osuser,
         s.sid,
         s.serial#,
         p.spid,
         s.lockwait,
         s.status,
         s.module,
         s.machine,
         s.program,
         TO_CHAR (s.logon_Time, 'DD-MON-YYYY HH24:MI:SS') AS logon_time
    FROM v$session s, v$process p
   WHERE s.paddr = p.addr AND s.status = 'ACTIVE'
ORDER BY s.username, s.osuser;

SET PAGESIZE 14
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/cache_hit_ratio.sql
-- Author       : Tim Hall
-- Description  : Displays cache hit ratio for the database.
-- Comments     : The minimum figure of 89% is often quoted, but depending on the type of system this may not be possible.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @cache_hit_ratio
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
PROMPT
PROMPT Hit ratio should exceed 89%

SELECT SUM (DECODE (a.name, 'consistent gets', a.VALUE, 0)) "Consistent Gets",
       SUM (DECODE (a.name, 'db block gets', a.VALUE, 0)) "DB Block Gets",
       SUM (DECODE (a.name, 'physical reads', a.VALUE, 0)) "Physical Reads",
       ROUND (
            (  (  SUM (DECODE (a.name, 'consistent gets', a.VALUE, 0))
                + SUM (DECODE (a.name, 'db block gets', a.VALUE, 0))
                - SUM (DECODE (a.name, 'physical reads', a.VALUE, 0)))
             / (  SUM (DECODE (a.name, 'consistent gets', a.VALUE, 0))
                + SUM (DECODE (a.name, 'db block gets', a.VALUE, 0))))
          * 100,
          2)
          "Hit Ratio %"
  FROM v$sysstat a;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/call_stack.sql
-- Author       : Tim Hall
-- Description  : Displays the current call stack.
-- Requirements : Access to DBMS_UTILITY.
-- Call Syntax  : @call_stack
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_stack  VARCHAR2(2000);
BEGIN
  v_stack := Dbms_Utility.Format_Call_Stack;
  Dbms_Output.Put_Line(v_stack);
END;
/
  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/code_dep.sql
-- Author       : Tim Hall
-- Description  : Displays all dependencies of specified object.
-- Call Syntax  : @code_dep (schema-name or all) (object-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 255
SET PAGESIZE 1000
BREAK ON referenced_type SKIP 1

COLUMN referenced_type FORMAT A20
COLUMN referenced_owner FORMAT A20
COLUMN referenced_name FORMAT A40
COLUMN referenced_link_name FORMAT A20

SELECT a.referenced_type,
       a.referenced_owner,
       a.referenced_name,
       a.referenced_link_name
FROM   all_dependencies a
WHERE  a.owner = DECODE(UPPER('&1'), 'ALL', a.referenced_owner, UPPER('&1'))
AND    a.name  = UPPER('&2')
ORDER BY 1,2,3;

SET VERIFY ON
SET PAGESIZE 22


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/code_dep_distinct.sql
-- Author       : Tim Hall
-- Description  : Displays a tree of dependencies of specified object.
-- Call Syntax  : @code_dep_distinct (schema-name) (object-name) (object_type or all)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 255
SET PAGESIZE 1000

COLUMN referenced_object FORMAT A50
COLUMN referenced_type FORMAT A20
COLUMN referenced_link_name FORMAT A20

SELECT DISTINCT a.referenced_owner || '.' || a.referenced_name AS referenced_object,
       a.referenced_type,
       a.referenced_link_name
FROM   all_dependencies a
WHERE  a.owner NOT IN ('SYS','SYSTEM','PUBLIC')
AND    a.referenced_owner NOT IN ('SYS','SYSTEM','PUBLIC')
AND    a.referenced_type != 'NON-EXISTENT'
AND    a.referenced_type = DECODE(UPPER('&3'), 'ALL', a.referenced_type, UPPER('&3'))
START WITH a.owner = UPPER('&1')
AND        a.name  = UPPER('&2')
CONNECT BY a.owner = PRIOR a.referenced_owner
AND        a.name  = PRIOR a.referenced_name
AND        a.type  = PRIOR a.referenced_type;

SET VERIFY ON
SET PAGESIZE 22


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/code_dep_on.sql
-- Author       : Tim Hall
-- Description  : Displays all objects dependant on the specified object.
-- Call Syntax  : @code_dep_on (schema-name or all) (object-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 255
SET PAGESIZE 1000
BREAK ON type SKIP 1

COLUMN owner FORMAT A20

SELECT a.type,
       a.owner,
       a.name
FROM   all_dependencies a
WHERE  a.referenced_owner = DECODE(UPPER('&1'), 'ALL', a.referenced_owner, UPPER('&1'))
AND    a.referenced_name  = UPPER('&2')
ORDER BY 1,2,3;

SET PAGESIZE 22
SET VERIFY ON


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/code_dep_tree.sql
-- Author       : Tim Hall
-- Description  : Displays a tree of dependencies of specified object.
-- Call Syntax  : @code_dep_tree (schema-name) (object-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 255
SET PAGESIZE 1000

COLUMN referenced_object FORMAT A50
COLUMN referenced_type FORMAT A20
COLUMN referenced_link_name FORMAT A20

SELECT RPAD(' ', level*2, ' ') || a.referenced_owner || '.' || a.referenced_name AS referenced_object,
       a.referenced_type,
       a.referenced_link_name
FROM   all_dependencies a
WHERE  a.owner NOT IN ('SYS','SYSTEM','PUBLIC')
AND    a.referenced_owner NOT IN ('SYS','SYSTEM','PUBLIC')
AND    a.referenced_type != 'NON-EXISTENT'
START WITH a.owner = UPPER('&1')
AND        a.name  = UPPER('&2')
CONNECT BY a.owner = PRIOR a.referenced_owner
AND        a.name  = PRIOR a.referenced_name
AND        a.type  = PRIOR a.referenced_type;

SET VERIFY ON
SET PAGESIZE 22

 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/column_defaults.sql
-- Author       : Tim Hall
-- Description  : Displays the default values where present for the specified table.
-- Call Syntax  : @column_defaults (table-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 100
SET VERIFY OFF

SELECT a.column_name "Column", a.data_default "Default"
  FROM all_tab_columns a
 WHERE a.table_name = UPPER ('&1') AND a.data_default IS NOT NULL
/

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/controlfiles.sql
-- Author       : Tim Hall
-- Description  : Displays information about controlfiles.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @controlfiles
-- Last Modified: 21/12/2004
-- -----------------------------------------------------------------------------------

SET LINESIZE 100
COLUMN name FORMAT A80

SELECT name,
       status
FROM   v$controlfile
ORDER BY name;

SET LINESIZE 80

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/datafiles.sql
-- Author       : Tim Hall
-- Description  : Displays information about datafiles.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @datafiles
-- Last Modified: 17-AUG-2005
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN file_name FORMAT A70

SELECT file_id,
       file_name,
       ROUND(bytes/1024/1024/1024) AS size_gb,
       ROUND(maxbytes/1024/1024/1024) AS max_size_gb,
       autoextensible,
       increment_by,
       status
FROM   dba_data_files
ORDER BY file_name;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/db_cache_advice.sql
-- Author       : Tim Hall
-- Description  : Predicts how changes to the buffer cache will affect physical reads.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @db_cache_advice
-- Last Modified: 12/02/2004
-- -----------------------------------------------------------------------------------

COLUMN size_for_estimate          FORMAT 999,999,999,999 heading 'Cache Size (MB)'
COLUMN buffers_for_estimate       FORMAT 999,999,999 heading 'Buffers'
COLUMN estd_physical_read_factor  FORMAT 999.90 heading 'Estd Phys|Read Factor'
COLUMN estd_physical_reads        FORMAT 999,999,999,999 heading 'Estd Phys| Reads'

SELECT size_for_estimate,
       buffers_for_estimate,
       estd_physical_read_factor,
       estd_physical_reads
  FROM v$db_cache_advice
 WHERE     name = 'DEFAULT'
       AND block_size = (SELECT VALUE
                           FROM v$parameter
                          WHERE name = 'db_block_size')
       AND advice_status = 'ON';


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/db_info.sql
-- Author       : Tim Hall
-- Description  : Displays general information about the database.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @db_info
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET PAGESIZE 1000
SET LINESIZE 100
SET FEEDBACK OFF

SELECT *
FROM   v$database;

SELECT *
FROM   v$instance;

SELECT *
FROM   v$version;

SELECT a.name,
       a.value
FROM   v$sga a;

SELECT Substr(c.name,1,60) "Controlfile",
       NVL(c.status,'UNKNOWN') "Status"
FROM   v$controlfile c
ORDER BY 1;

SELECT Substr(d.name,1,60) "Datafile",
       NVL(d.status,'UNKNOWN') "Status",
       d.enabled "Enabled",
       LPad(To_Char(Round(d.bytes/1024000,2),'9999990.00'),10,' ') "Size (M)"
FROM   v$datafile d
ORDER BY 1;

SELECT l.group# "Group",
       Substr(l.member,1,60) "Logfile",
       NVL(l.status,'UNKNOWN') "Status"
FROM   v$logfile l
ORDER BY 1,2;

PROMPT
SET PAGESIZE 14
SET FEEDBACK ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/db_links.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database links.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_links
-- Last Modified: 11/05/2007
-- -----------------------------------------------------------------------------------
SET LINESIZE 150

COLUMN db_link FORMAT A30
COLUMN host FORMAT A30

SELECT owner,
       db_link,
       username,
       host
FROM   dba_db_links
ORDER BY owner, db_link;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/db_links_open.sql
-- Author       : Tim Hall
-- Description  : Displays information on all open database links.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @db_links_open
-- Last Modified: 11/05/2007
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN db_link FORMAT A30

SELECT db_link,
       owner_id,
       logged_on,
       heterogeneous,
       protocol,
       open_cursors,
       in_transaction,
       update_sent,
       commit_point_strength
FROM   v$dblink
ORDER BY db_link;

SET LINESIZE 80


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/db_properties.sql
-- Author       : Tim Hall
-- Description  : Displays all database property values.
-- Call Syntax  : @db_properties
-- Last Modified: 15/09/2006
-- -----------------------------------------------------------------------------------
COLUMN property_value FORMAT A50

SELECT property_name,
       property_value
FROM   database_properties
ORDER BY property_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/df_free_space.sql
-- Author       : Tim Hall
-- Description  : Displays free space information about datafiles.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @df_free_space.sql
-- Last Modified: 17-AUG-2005
-- -----------------------------------------------------------------------------------

SET LINESIZE 120
COLUMN file_name FORMAT A60

  SELECT a.file_name,
         ROUND (a.bytes / 1024 / 1024) AS size_mb,
         ROUND (a.maxbytes / 1024 / 1024) AS maxsize_mb,
         ROUND (b.free_bytes / 1024 / 1024) AS free_mb,
         ROUND ( (a.maxbytes - a.bytes) / 1024 / 1024) AS growth_mb,
         100 - ROUND ( ( (b.free_bytes + a.growth) / a.maxbytes) * 100)
            AS pct_used
    FROM (SELECT file_name,
                 file_id,
                 bytes,
                 GREATEST (bytes, maxbytes) AS maxbytes,
                 GREATEST (bytes, maxbytes) - bytes AS growth
            FROM dba_data_files) a,
         (  SELECT file_id, SUM (bytes) AS free_bytes
              FROM dba_free_space
          GROUP BY file_id) b
   WHERE a.file_id = b.file_id
ORDER BY file_name;


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/directories.sql
-- Author       : Tim Hall
-- Description  : Displays information about all directories.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @directories
-- Last Modified: 04/10/2006
-- -----------------------------------------------------------------------------------
COLUMN owner FORMAT A20
COLUMN directory_name FORMAT A25
COLUMN directory_path FORMAT A50

SELECT *
FROM   dba_directories
ORDER BY owner, directory_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/dispatchers.sql
-- Author       : Tim Hall
-- Description  : Displays dispatcher statistics.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @dispatchers
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

  SELECT a.name "Name",
         a.status "Status",
         a.accept "Accept",
         a.messages "Total Mesgs",
         a.bytes "Total Bytes",
         a.owned "Circs Owned",
         a.idle "Total Idle Time",
         a.busy "Total Busy Time",
         ROUND (a.busy / (a.busy + a.idle), 2) "Load"
    FROM v$dispatcher a
ORDER BY 1;

SET PAGESIZE 14
SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/error_stack.sql
-- Author       : Tim Hall
-- Description  : Displays contents of the error stack.
-- Call Syntax  : @error_stack
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  v_stack  VARCHAR2(2000);
BEGIN
  v_stack := Dbms_Utility.Format_Error_Stack;
  Dbms_Output.Put_Line(v_stack);
END;
/

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/errors.sql
-- Author       : Tim Hall
-- Description  : Displays the source line and the associated error after compilation failure.
-- Comments     : Essentially the same as SHOW ERRORS.
-- Call Syntax  : @errors (source-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SELECT To_Char(a.line) || ' - ' || a.text error
FROM   user_source a,
       user_errors b
WHERE  a.name = Upper('&&1')
AND    a.name = b.name
AND    a.type = b.type
AND    a.line = b.line
ORDER BY a.name, a.line;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/explain.sql
-- Author       : Tim Hall
-- Description  : Displays a tree-style execution plan of the specified statement after it has been explained.
-- Requirements : Access to the plan table.
-- Call Syntax  : @explain (statement-id)
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET PAGESIZE 100
SET LINESIZE 200
SET VERIFY OFF

COLUMN plan             FORMAT A50
COLUMN object_name      FORMAT A30
COLUMN object_type      FORMAT A15
COLUMN bytes            FORMAT 9999999999
COLUMN cost             FORMAT 9999999
COLUMN partition_start  FORMAT A20
COLUMN partition_stop   FORMAT A20

SELECT LPAD(' ', 2 * (level - 1)) ||
       DECODE (level,1,NULL,level-1 || '.' || pt.position || ' ') ||
       INITCAP(pt.operation) ||
       DECODE(pt.options,NULL,'',' (' || INITCAP(pt.options) || ')') plan,
       pt.object_name,
       pt.object_type,
       pt.bytes,
       pt.cost,
       pt.partition_start,
       pt.partition_stop
FROM   plan_table pt
START WITH pt.id = 0
  AND pt.statement_id = '&1'
CONNECT BY PRIOR pt.id = pt.parent_id
  AND pt.statement_id = '&1';
  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/file_io.sql
-- Author       : Tim Hall
-- Description  : Displays the amount of IO for each datafile.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @file_io
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET PAGESIZE 1000

  SELECT SUBSTR (d.name, 1, 50) "File Name",
         f.phyblkrd "Blocks Read",
         f.phyblkwrt "Blocks Writen",
         f.phyblkrd + f.phyblkwrt "Total I/O"
    FROM v$filestat f, v$datafile d
   WHERE d.file# = f.file#
ORDER BY f.phyblkrd + f.phyblkwrt DESC;

SET PAGESIZE 18

  -- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/fk_columns.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays information on all FKs for the specified schema and table.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @fk_columns (schema-name or all) (table-name or all)
-- Last Modified: 22/09/2005
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 1000
COLUMN column_name FORMAT A30
COLUMN r_column_name FORMAT A30

  SELECT c.constraint_name,
         cc.table_name,
         cc.column_name,
         rcc.table_name AS r_table_name,
         rcc.column_name AS r_column_name,
         cc.position
    FROM dba_constraints c
         JOIN dba_cons_columns cc
            ON c.owner = cc.owner AND c.constraint_name = cc.constraint_name
         JOIN
         dba_cons_columns rcc
            ON     c.owner = rcc.owner
               AND c.r_constraint_name = rcc.constraint_name
               AND cc.position = rcc.position
   WHERE     c.owner = DECODE (UPPER ('&1'), 'ALL', c.owner, UPPER ('&1'))
         AND c.table_name =
                DECODE (UPPER ('&2'), 'ALL', c.table_name, UPPER ('&2'))
ORDER BY c.constraint_name, cc.table_name, cc.position;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/fks.sql
-- Author       : Tim Hall
-- Description  : Displays the constraints on a specific table and those referencing it.
-- Call Syntax  : @fks (table-name) (schema)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
PROMPT
SET VERIFY OFF
SET FEEDBACK OFF
SET LINESIZE 255
SET PAGESIZE 1000

PROMPT
PROMPT Constraints Owned By Table
PROMPT ==========================
SELECT c.constraint_name "Constraint",
       Decode(c.constraint_type,'P','Primary Key',
                                'U','Unique Key',
                                'C','Check',
                                'R','Foreign Key',
                                c.constraint_type) "Type",
       c.r_owner "Ref Table",
       c.r_constraint_name "Ref Constraint"
FROM   all_constraints c
WHERE  c.table_name = Upper('&&1')
AND    c.owner      = Upper('&&2');


PROMPT
PROMPT Constraints Referencing Table
PROMPT =============================
SELECT c1.table_name "Table",
       c1.constraint_name "Foreign Key",
       c1.r_constraint_name "References"
FROM   all_constraints c1 
WHERE  c1.owner      = Upper('&&2')
AND    c1.r_constraint_name IN (SELECT c2.constraint_name
                                FROM   all_constraints c2
                                WHERE  c2.table_name = Upper('&&1')
                                AND    c2.owner      = Upper('&&2')
                                AND    c2.constraint_type IN ('P','U'));

SET VERIFY ON
SET FEEDBACK ON
SET PAGESIZE 1000
PROMPT

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/free_space.sql
-- Author       : Tim Hall
-- Description  : Displays space usage for each datafile.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @free_space
-- Last Modified: 15-JUL-2000 - Created.
--                12-OCT-2012 - Amended to include auto-extend and maxsize.
-- -----------------------------------------------------------------------------------
SET PAGESIZE 100
SET LINESIZE 265

COLUMN tablespace_name FORMAT A20
COLUMN file_name FORMAT A50

  SELECT df.tablespace_name,
         df.file_name,
         df.size_mb,
         f.free_mb,
         df.max_size_mb,
         f.free_mb + (df.max_size_mb - df.size_mb) AS max_free_mb,
         RPAD (
               ' '
            || RPAD (
                  'X',
                  ROUND (
                       (  df.max_size_mb
                        - (f.free_mb + (df.max_size_mb - df.size_mb)))
                     / max_size_mb
                     * 10,
                     0),
                  'X'),
            11,
            '-')
            AS used_pct
    FROM (SELECT file_id,
                 file_name,
                 tablespace_name,
                 TRUNC (bytes / 1024 / 1024) AS size_mb,
                 TRUNC (GREATEST (bytes, maxbytes) / 1024 / 1024)
                    AS max_size_mb
            FROM dba_data_files) df,
         (  SELECT TRUNC (SUM (bytes) / 1024 / 1024) AS free_mb, file_id
              FROM dba_free_space
          GROUP BY file_id) f
   WHERE df.file_id = f.file_id(+)
ORDER BY df.tablespace_name, df.file_name;

PROMPT
SET PAGESIZE 14


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/health.sql
-- Author       : Tim Hall
-- Description  : Lots of information about the database so you can asses the general health of the system.
-- Requirements : Access to the V$ & DBA views and several other monitoring scripts.
-- Call Syntax  : @health (username/password@service)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SPOOL Health_Checks.txt

conn &1
@db_info
@sessions
@ts_full
@max_extents

SPOOL OFF

-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/hidden_parameters.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays a list of one or all the hidden parameters.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @hidden_parameters (parameter-name or all)
-- Last Modified: 28-NOV-2006
-- -----------------------------------------------------------------------------------
SET VERIFY OFF linesize 300
COLUMN parameter      FORMAT a37
COLUMN description    FORMAT a30 WORD_WRAPPED
COLUMN session_value  FORMAT a15
COLUMN instance_value FORMAT a15
 
  SELECT a.ksppinm AS parameter,
         a.ksppdesc AS description,
         b.ksppstvl AS session_value,
         c.ksppstvl AS instance_value
    FROM x$ksppi a, x$ksppcv b, x$ksppsv c
   WHERE     a.indx = b.indx
         AND a.indx = c.indx
         AND a.ksppinm LIKE '/_%' ESCAPE '/'
         AND a.ksppinm = DECODE (LOWER ('&1'), 'all', a.ksppinm, LOWER ('&1'))
ORDER BY a.ksppinm;

-- http://www.dba-oracle.com/t_12c_hidden_undocumented_parameters.htm
-- 	How To Query And Change The Oracle Hidden Parameters In Oracle 10g ,11g and 12c (Doc ID 315631.1)

SET VERIFY OFF
COLUMN parameter      FORMAT a37
COLUMN Default_Value  FORMAT a10
COLUMN session_value  FORMAT a10
COLUMN instance_value FORMAT a10

SELECT A.KSPPINM
           "Parameter",
       B.KSPPSTDF
           "Default_Value",
       B.KSPPSTVL
           "session_value",
       C.KSPPSTVL
           "instance_value",
       DECODE (BITAND (A.KSPPIFLG / 256, 1), 1, 'TRUE', 'FALSE')
           IS_SESSION_MODIFIABLE,
       DECODE (BITAND (A.KSPPIFLG / 65536, 3),
               1, 'IMMEDIATE',
               2, 'DEFERRED',
               3, 'IMMEDIATE',
               'FALSE')
           IS_SYSTEM_MODIFIABLE,
           A.KSPPDESC DESCRIPTION
  FROM X$KSPPI A, X$KSPPCV B, X$KSPPSV C
 WHERE     A.INDX = B.INDX
       AND A.INDX = C.INDX
       AND A.KSPPINM LIKE '/_%' ESCAPE '/'
	   AND A.KSPPINM = '&1';

--------------------------------------------------------------------------------
--
-- File name:   pvalid.sql
-- Purpose:     Show valid parameter values from V$PARAMETER_VALID_VALUES
--              underlying X$ table X$KSPVLD_VALUES
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @pvalid <param_name>
--
-- 	        @pvalid optimizer
--
--------------------------------------------------------------------------------

COL pvalid_default HEAD DEFAULT FOR A7
COL pvalid_value   HEAD VALUE   FOR A30
COL pvalid_name    HEAD PARAMETER FOR A50
COL pvalid_par#    HEAD PAR# FOR 99999

BREAK ON pvalid_par# skip 1

PROMPT Display valid values for multioption parameters matching "&1"...

SELECT 
--	INST_ID, 
	PARNO_KSPVLD_VALUES     pvalid_par#,
	NAME_KSPVLD_VALUES      pvalid_name, 
	ORDINAL_KSPVLD_VALUES   ORD, 
	VALUE_KSPVLD_VALUES	pvalid_value,
	DECODE(ISDEFAULT_KSPVLD_VALUES, 'FALSE', '', 'DEFAULT' ) pvalid_default
FROM 
	X$KSPVLD_VALUES 
WHERE 
	LOWER(NAME_KSPVLD_VALUES) LIKE LOWER('%&1%')
ORDER BY
	pvalid_par#,
	pvalid_default,
  ord,
	pvalid_Value;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/high_water_mark.sql
-- Author       : Tim Hall
-- Description  : Displays the High Water Mark for the specified table, or all tables.
-- Requirements : Access to the Dbms_Space.
-- Call Syntax  : @high_water_mark (table_name or all) (schema-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET VERIFY OFF

DECLARE
  CURSOR cu_tables IS
    SELECT a.owner,
           a.table_name
    FROM   all_tables a
    WHERE  a.table_name = Decode(Upper('&&1'),'ALL',a.table_name,Upper('&&1'))
    AND    a.owner      = Upper('&&2');

  op1  NUMBER;
  op2  NUMBER;
  op3  NUMBER;
  op4  NUMBER;
  op5  NUMBER;
  op6  NUMBER;
  op7  NUMBER;
BEGIN

  Dbms_Output.Disable;
  Dbms_Output.Enable(1000000);
  Dbms_Output.Put_Line('TABLE                             UNUSED BLOCKS     TOTAL BLOCKS  HIGH WATER MARK');
  Dbms_Output.Put_Line('------------------------------  ---------------  ---------------  ---------------');
  FOR cur_rec IN cu_tables LOOP
    Dbms_Space.Unused_Space(cur_rec.owner,cur_rec.table_name,'TABLE',op1,op2,op3,op4,op5,op6,op7);
    Dbms_Output.Put_Line(RPad(cur_rec.table_name,30,' ') ||
                         LPad(op3,15,' ')                ||
                         LPad(op1,15,' ')                ||
                         LPad(Trunc(op1-op3-1),15,' ')); 
  END LOOP;

END;
/

SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/hot_blocks.sql
-- Author       : Tim Hall
-- Description  : Detects hot blocks.
-- Call Syntax  : @hot_blocks
-- Last Modified: 17/02/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET VERIFY OFF

SELECT *
  FROM (SELECT o.owner,
               o.object_name,
               o.subobject_name,
               bh.tch,
               bh.obj,
               bh.file#,
               bh.dbablk,
               bh.class,
               bh.state
          FROM x$bh bh, dba_objects o
         WHERE     o.data_object_id = bh.obj
               AND hladdr IN
                      (SELECT addr
                         FROM (  SELECT name,
                                        addr,
                                        gets,
                                        misses,
                                        sleeps
                                   FROM v$latch_children
                                  WHERE     name = 'cache buffers chains'
                                        AND misses > 0
                               ORDER BY misses DESC)
                        WHERE ROWNUM < 11))
 WHERE ROWNUM < 11;
 

SELECT *
FROM   (SELECT name,
               addr,
               gets,
               misses,
               sleeps
        FROM   v$latch_children
        WHERE  name = 'cache buffers chains'
        AND    misses > 0
        ORDER BY misses DESC)
WHERE  rownum < 11;

ACCEPT address PROMPT "Enter ADDR: "

COLUMN owner FORMAT A15
COLUMN object_name FORMAT A30
COLUMN subobject_name FORMAT A20

SELECT *
FROM   (SELECT o.owner,
               o.object_name,
               o.subobject_name,
               bh.tch,
               bh.obj,
               bh.file#,
               bh.dbablk,
               bh.class,
               bh.state
        FROM   x$bh bh,
               dba_objects o
        WHERE  o.data_object_id = bh.obj
        AND    hladdr = '&address'
        ORDER BY tch DESC)
WHERE  rownum < 11;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/identify_trace_file.sql
-- Author       : Tim Hall
-- Description  : Displays the name of the trace file associated with the current session.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @identify_trace_file
-- Last Modified: 17-AUG-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 100
COLUMN trace_file FORMAT A60

SELECT s.sid,
       s.serial#,
       pa.value || '/' || LOWER(SYS_CONTEXT('userenv','instance_name')) ||    
       '_ora_' || p.spid || '.trc' AS trace_file
FROM   v$session s,
       v$process p,
       v$parameter pa
WHERE  pa.name = 'user_dump_dest'
AND    s.paddr = p.addr
AND    s.audsid = SYS_CONTEXT('USERENV', 'SESSIONID');

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/index_extents.sql
-- Author       : Tim Hall
-- Description  : Displays number of extents for all indexes belonging to the specified table, or all tables.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @index_extents (table_name or all) (schema-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

SELECT i.index_name,
       Count(e.segment_name) extents,
       i.max_extents,
       t.num_rows "ROWS",
       Trunc(i.initial_extent/1024) "INITIAL K",
       Trunc(i.next_extent/1024) "NEXT K",
       t.table_name
FROM   all_tables t,
       all_indexes i,
       dba_extents e
WHERE  i.table_name   = t.table_name
AND    i.owner        = t.owner
AND    e.segment_name = i.index_name
AND    e.owner        = i.owner
AND    i.table_name   = Decode(Upper('&&1'),'ALL',i.table_name,Upper('&&1'))
AND    i.owner        = Upper('&&2')
GROUP BY t.table_name,
         i.index_name,
         i.max_extents,
         t.num_rows,
         i.initial_extent,
         i.next_extent
HAVING   Count(e.segment_name) > 5
ORDER BY Count(e.segment_name) DESC;

SET PAGESIZE 18
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/index_monitoring_status.sql
-- Author       : Tim Hall
-- Description  : Shows the monitoring status for the specified table indexes.
-- Call Syntax  : @index_monitoring_status (schema) (table-name or all)
-- Last Modified: 04/02/2005
-- -----------------------------------------------------------------------------------
SET VERIFY OFF

SELECT table_name,
       index_name,
       monitoring
FROM   v$object_usage
WHERE  table_name = UPPER('&1')
AND    index_name = DECODE(UPPER('&2'), 'ALL', index_name, UPPER('&2'));

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/index_partitions.sql
-- Author       : Tim Hall
-- Description  : Displays partition information for the specified index, or all indexes.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @index_patitions (index_name or all) (schema-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET FEEDBACK OFF
SET VERIFY OFF

SELECT a.index_name,
       a.partition_name,
       a.tablespace_name,
       a.initial_extent,
       a.next_extent,
       a.pct_increase,
       a.num_rows
FROM   dba_ind_partitions a
WHERE  a.index_name  = Decode(Upper('&&1'),'ALL',a.index_name,Upper('&&1'))
AND    a.index_owner = Upper('&&2')
ORDER BY a.index_name, a.partition_name
/

PROMPT
SET PAGESIZE 14
SET FEEDBACK ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/index_usage.sql
-- Author       : Tim Hall
-- Description  : Shows the usage for the specified table indexes.
-- Call Syntax  : @index_usage (table-name) (index-name or all)
-- Last Modified: 04/02/2005
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 200

SELECT table_name,
       index_name,
       used,
       start_monitoring,
       end_monitoring
FROM   v$object_usage
WHERE  table_name = UPPER('&1')
AND    index_name = DECODE(UPPER('&2'), 'ALL', index_name, UPPER('&2'));

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/invalid_objects.sql
-- Author       : Tim Hall
-- Description  : Lists all invalid objects in the database.
-- Call Syntax  : @invalid_objects
-- Requirements : Access to the DBA views.
-- Last Modified: 18/12/2005
-- -----------------------------------------------------------------------------------
COLUMN object_name FORMAT A30
SELECT owner,
       object_type,
       object_name,
       status
FROM   dba_objects
WHERE  status = 'INVALID'
ORDER BY owner, object_type, object_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/jobs.sql
-- Author       : Tim Hall
-- Description  : Displays information about all scheduled jobs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @jobs
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 1000 PAGESIZE 1000

COLUMN log_user FORMAT A15
COLUMN priv_user FORMAT A15
COLUMN schema_user FORMAT A15
COLUMN interval FORMAT A40
COLUMN what FORMAT A50
COLUMN nls_env FORMAT A50
COLUMN misc_env FORMAT A50

SELECT a.job,
       a.log_user,
       a.priv_user,
       a.schema_user,
       TO_CHAR (a.last_date, 'DD-MON-YYYY HH24:MI:SS') AS last_date,
       --TO_CHAR (a.this_date, 'DD-MON-YYYY HH24:MI:SS') AS this_date,
       TO_CHAR (a.next_date, 'DD-MON-YYYY HH24:MI:SS') AS next_date,
       a.broken,
       a.interval,
       a.failures,
       a.what,
       a.total_time,
       a.nls_env,
       a.misc_env
  FROM dba_jobs a;

SET LINESIZE 80 PAGESIZE 14


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/jobs_running.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information for running jobs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @jobs_running
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN owner FORMAT A20

SELECT owner,
       job_name,
       running_instance,
       elapsed_time
FROM   dba_scheduler_running_jobs
ORDER BY owner, job_name;


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/latch_hit_ratios.sql
-- Author       : Tim Hall
-- Description  : Displays current latch hit ratios.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @latch_hit_ratios
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN latch_hit_ratio FORMAT 990.00
 
SELECT l.name,
       l.gets,
       l.misses,
       ( (1 - (l.misses / l.gets)) * 100) AS latch_hit_ratio
  FROM v$latch l
 WHERE l.gets != 0
UNION
SELECT l.name,
       l.gets,
       l.misses,
       100 AS latch_hit_ratio
  FROM v$latch l
 WHERE l.gets = 0
ORDER BY 4;

  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/latch_holders.sql
-- Author       : Tim Hall
-- Description  : Displays information about all current latch holders.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @latch_holders
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

  SELECT l.name "Latch Name",
         lh.pid "PID",
         lh.sid "SID",
         l.gets "Gets (Wait)",
         l.misses "Misses (Wait)",
         l.sleeps "Sleeps (Wait)",
         l.immediate_gets "Gets (No Wait)",
         l.immediate_misses "Misses (Wait)"
    FROM v$latch l, v$latchholder lh
   WHERE l.addr = lh.laddr
ORDER BY l.name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/latches.sql
-- Author       : Tim Hall
-- Description  : Displays information about all current latches.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @latches
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

  SELECT l.latch#,
         l.name,
         l.gets,
         l.misses,
         l.sleeps,
         l.immediate_gets,
         l.immediate_misses,
         l.spin_gets
    FROM v$latch l
ORDER BY l.name;
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/library_cache.sql
-- Author       : Tim Hall
-- Description  : Displays library cache statistics.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @library_cache
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

  SELECT a.namespace "Name Space",
         a.gets "Get Requests",
         a.gethits "Get Hits",
         ROUND (a.gethitratio, 2) "Get Ratio",
         a.pins "Pin Requests",
         a.pinhits "Pin Hits",
         ROUND (a.pinhitratio, 2) "Pin Ratio",
         a.reloads "Reloads",
         a.invalidations "Invalidations"
    FROM v$librarycache a
ORDER BY 1;

SET PAGESIZE 14
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/license.sql
-- Author       : Tim Hall
-- Description  : Displays session usage for licensing purposes.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @license
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SELECT *
FROM   v$license;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/locked_objects.sql
-- Author       : DR Timothy S Hall
-- Description  : Lists all locked objects.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @locked_objects
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN owner FORMAT A20
COLUMN username FORMAT A20
COLUMN object_owner FORMAT A20
COLUMN object_name FORMAT A30
COLUMN locked_mode FORMAT A15

  SELECT lo.session_id AS sid,
         s.serial#,
         NVL (lo.oracle_username, '(oracle)') AS username,
         o.owner AS object_owner,
         o.object_name,
         DECODE (lo.locked_mode,
                 0, 'None',
                 1, 'Null (NULL)',
                 2, 'Row-S (SS)',
                 3, 'Row-X (SX)',
                 4, 'Share (S)',
                 5, 'S/Row-X (SSX)',
                 6, 'Exclusive (X)',
                 lo.locked_mode)
            locked_mode,
         lo.os_user_name
    FROM v$locked_object lo
         JOIN dba_objects o ON o.object_id = lo.object_id
         JOIN v$session s ON lo.session_id = s.sid
ORDER BY 1,2,3,4;

SET PAGESIZE 14
SET VERIFY ON


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/locked_objects_internal.sql
-- Author       : Tim Hall
-- Description  : Lists all locks on the specific object.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @locked_objects_internal (object-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 1000 VERIFY OFF

COLUMN lock_type FORMAT A20
COLUMN mode_held FORMAT A10
COLUMN mode_requested FORMAT A10
COLUMN lock_id1 FORMAT A50
COLUMN lock_id2 FORMAT A30

SELECT li.session_id AS sid,
       s.serial#,
       li.lock_type,
       li.mode_held,
       li.mode_requested,
       li.lock_id1,
       li.lock_id2
  FROM dba_lock_internal li JOIN v$session s ON li.session_id = s.sid
 WHERE UPPER (lock_id1) LIKE '%&1%';

SET VERIFY ON
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/logfiles.sql
-- Author       : Tim Hall
-- Description  : Displays information about redo log files.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @logfiles
-- Last Modified: 21/12/2004
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN member FORMAT A50
COLUMN first_change# FORMAT 99999999999999999999
COLUMN next_change# FORMAT 99999999999999999999

  SELECT l.thread#,
         lf.group#,
         lf.MEMBER,
         TRUNC (l.bytes / 1024 / 1024) AS size_mb,
         l.status,
         l.archived,
         lf.TYPE,
         lf.is_recovery_dest_file AS rdf,
         l.sequence#,
         l.first_change#,
         l.next_change#
    FROM v$logfile lf JOIN v$log l ON l.group# = lf.group#
ORDER BY l.thread#, lf.group#, lf.MEMBER;

SET LINESIZE 80

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/longops.sql
-- Author       : Tim Hall
-- Description  : Displays information on all long operations.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @longops
-- Last Modified: 03/07/2003
-- -----------------------------------------------------------------------------------

COLUMN sid FORMAT 999
COLUMN serial# FORMAT 9999999
COLUMN machine FORMAT A30
COLUMN progress_pct FORMAT 99999999.00
COLUMN elapsed FORMAT A10
COLUMN remaining FORMAT A10

SELECT s.sid,
       s.serial#,
       s.machine,
       ROUND (sl.elapsed_seconds / 60) || ':' || MOD (sl.elapsed_seconds, 60)
          elapsed,
       ROUND (sl.time_remaining / 60) || ':' || MOD (sl.time_remaining, 60)
          remaining,
       case when sl.totalwork <> 0 then ROUND (sl.sofar / sl.totalwork * 100, 2) else 0 end progress_pct
  FROM v$session s, v$session_longops sl
 WHERE s.sid = sl.sid AND s.serial# = sl.serial#;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/lru_latch_ratio.sql
-- Author       : Tim Hall
-- Description  : Displays current LRU latch ratios.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @lru_latch_hit_ratio
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
COLUMN "Ratio %" FORMAT 990.00
 
PROMPT
PROMPT Values greater than 3% indicate contention.

  SELECT a.child#, (a.SLEEPS / a.GETS) * 100 "Ratio %"
    FROM v$latch_children a
   WHERE a.name = 'cache buffers lru chain' AND a.GETS <> 0
ORDER BY 1;


SET PAGESIZE 14

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/max_extents.sql
-- Author       : Tim Hall
-- Description  : Displays all tables and indexes nearing their MAX_EXTENTS setting.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @max_extents
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

PROMPT
PROMPT Tables and Indexes nearing MAX_EXTENTS
PROMPT **************************************
SELECT e.owner,
       e.segment_type,
       Substr(e.segment_name, 1, 30) segment_name,
       Trunc(s.initial_extent/1024) "INITIAL K",
       Trunc(s.next_extent/1024) "NEXT K",
       s.max_extents,
       Count(*) as extents
FROM   dba_extents e,
       dba_segments s
WHERE  e.owner        = s.owner
AND    e.segment_name = s.segment_name
AND    e.owner        NOT IN ('SYS', 'SYSTEM')
GROUP BY e.owner, e.segment_type, e.segment_name, s.initial_extent, s.next_extent, s.max_extents
HAVING Count(*) > s.max_extents - 10
ORDER BY e.owner, e.segment_type, Count(*) DESC;
     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/min_datafile_size.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays smallest size the datafiles can shrink to without a reorg.
-- Requirements : Access to the V$ and DBA views.
-- Call Syntax  : @min_datafile_size
-- Last Modified: 07/09/2007
-- -----------------------------------------------------------------------------------

COLUMN block_size NEW_VALUE v_block_size

SELECT TO_NUMBER(value) AS block_size
FROM   v$parameter
WHERE  name = 'db_block_size';

COLUMN tablespace_name FORMAT A20
COLUMN file_name FORMAT A50
COLUMN current_bytes FORMAT 999999999999999
COLUMN shrink_by_bytes FORMAT 999999999999999
COLUMN resize_to_bytes FORMAT 999999999999999
SET VERIFY OFF
SET LINESIZE 200

  SELECT a.tablespace_name,
         a.file_name,
         a.bytes AS current_bytes,
         a.bytes - b.resize_to AS shrink_by_bytes,
         b.resize_to AS resize_to_bytes
    FROM dba_data_files a,
         (  SELECT file_id,
                   MAX ( (block_id + blocks - 1) * &v_block_size) AS resize_to
              FROM dba_extents
          GROUP BY file_id) b
   WHERE a.file_id = b.file_id
ORDER BY a.tablespace_name, a.file_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/monitor.sql
-- Author       : Tim Hall
-- Description  : Displays SQL statements for the current database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @monitor
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 255
COL SID FORMAT 999
COL STATUS FORMAT A8
COL PROCESS FORMAT A10
COL SCHEMANAME FORMAT A16
COL OSUSER  FORMAT A16
COL SQL_TEXT FORMAT A120 HEADING 'SQL QUERY'
COL PROGRAM	FORMAT A30

SELECT s.sid,
       s.status,
       s.process,
       s.schemaname,
       s.osuser,
       a.sql_text,
       p.program
  FROM v$session s, v$sqlarea a, v$process p
 WHERE     s.SQL_HASH_VALUE = a.HASH_VALUE
       AND s.SQL_ADDRESS = a.ADDRESS
       AND s.PADDR = p.ADDR;

SET VERIFY ON
SET LINESIZE 255

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/monitor_memory.sql
-- Author       : Tim Hall
-- Description  : Displays memory allocations for the current database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @monitor_memory
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN username FORMAT A20
COLUMN module FORMAT A20

  SELECT NVL (a.username, '(oracle)') AS username,
         a.module,
         a.program,
         TRUNC (b.VALUE / 1024 / 1024) AS memory_mb
    FROM v$session a, v$sesstat b, v$statname c
   WHERE     a.sid = b.sid
         AND b.statistic# = c.statistic#
         AND c.name = 'session pga memory'
         AND a.program IS NOT NULL
ORDER BY b.VALUE DESC;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/monitoring_status.sql
-- Author       : Tim Hall
-- Description  : Shows the monitoring status for the specified tables.
-- Call Syntax  : @monitoring_status (schema) (table-name or all)
-- Last Modified: 21/03/2003
-- -----------------------------------------------------------------------------------
SET VERIFY OFF

SELECT table_name, monitoring 
FROM   dba_tables
WHERE  owner = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'));

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/nls_params.sql
-- Author       : Tim Hall
-- Description  : Displays National Language Suppport (NLS) information.
-- Requirements : 
-- Call Syntax  : @nls_params
-- Last Modified: 21-FEB-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 100
COLUMN parameter FORMAT A45
COLUMN value FORMAT A45

PROMPT *** Database parameters ***
SELECT * FROM nls_database_parameters;

PROMPT *** Instance parameters ***
SELECT * FROM nls_instance_parameters;

PROMPT *** Session parameters ***
SELECT * FROM nls_session_parameters;
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/non_indexed_fks.sql
-- Author       : Tim Hall
-- Description  : Displays a list of non-indexes FKs.
-- Requirements : Access to the ALL views.
-- Call Syntax  : @non_indexed_fks
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 255
SET FEEDBACK OFF

  SELECT t.table_name,
         c.constraint_name,
         c.table_name table2,
         acc.column_name
    FROM all_constraints t, all_constraints c, all_cons_columns acc
   WHERE     c.r_constraint_name = t.constraint_name
         AND c.table_name = acc.table_name
         AND c.constraint_name = acc.constraint_name
         AND NOT EXISTS
                    (SELECT '1'
                       FROM all_ind_columns aid
                      WHERE     aid.table_name = acc.table_name
                            AND aid.column_name = acc.column_name)
ORDER BY c.table_name;

PROMPT
SET FEEDBACK ON
SET PAGESIZE 18

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/obj_lock.sql
-- Author       : Tim Hall
-- Description  : Displays a list of locked objects. !!! LONG RUNNING POSSIBLE !!!
-- Requirements : Access to the V$ views.
-- Call Syntax  : @obj_lock
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
  SELECT a.TYPE,
         SUBSTR (a.owner, 1, 30) owner,
         a.sid,
         SUBSTR (a.object, 1, 30) object
    FROM v$access a
   WHERE a.owner NOT IN ('SYS', 'PUBLIC')
ORDER BY 1,2,3,4;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/object_privs.sql
-- Author       : Tim Hall
-- Description  : Displays object privileges on a specified object.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @object_privs (owner) (object-name)
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200 VERIFY OFF

SELECT owner,
       table_name AS object_name,
       grantor,
       grantee,
       privilege,
       grantable,
       hierarchy
FROM   dba_tab_privs
WHERE  owner      = UPPER('&1')
AND    table_name = UPPER('&2')
ORDER BY 1,2,3,4;

SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/object_status.sql
-- Author       : Tim Hall
-- Description  : Displays a list of objects and their status for the specific schema.
-- Requirements : Access to the ALL views.
-- Call Syntax  : @object_status (schema-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET PAGESIZE 1000
SET LINESIZE 255
SET FEEDBACK OFF
SET VERIFY OFF

SELECT Substr(object_name,1,30) object_name,
       object_type,
       status
FROM   all_objects
WHERE  owner = Upper('&&1');

PROMPT
SET FEEDBACK ON
SET PAGESIZE 18

 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/objects.sql
-- Author       : Tim Hall
-- Description  : Displays information about all database objects.
-- Requirements : Access to the dba_objects view.
-- Call Syntax  : @objects [ object-name | % (for all)]
-- Last Modified: 21-FEB-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200 VERIFY OFF

COLUMN owner FORMAT A20
COLUMN object_name FORMAT A30
COLUMN edition_name FORMAT A15

SELECT owner,
       object_name,
       --subobject_name,
       object_id,
       data_object_id,
       object_type,
       TO_CHAR(created, 'DD-MON-YYYY HH24:MI:SS') AS created,
       TO_CHAR(last_ddl_time, 'DD-MON-YYYY HH24:MI:SS') AS last_ddl_time,
       timestamp,
       status,
       temporary,
       generated,
       secondary,
       --namespace,
       edition_name
FROM   dba_objects
WHERE  UPPER(object_name) LIKE UPPER('%&1%')
ORDER BY owner, object_name;

SET VERIFY ON
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/open_cursors.sql
-- Author       : Tim Hall
-- Description  : Displays a list of all cursors currently open.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @open_cursors
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SELECT a.user_name,
       a.sid,
       a.sql_text
FROM   v$open_cursor a
ORDER BY 1,2
/


 
 -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/open_cursors_by_sid.sql
-- Author       : Tim Hall
-- Description  : Displays the SQL statement held for a specific SID.
-- Comments     : The SID can be found by running session.sql or top_session.sql.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @open_cursors_by_sid (sid)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

SELECT oc.sql_text, cursor_type
FROM   v$open_cursor oc
WHERE  oc.sid = &1
ORDER BY cursor_type;

PROMPT
SET PAGESIZE 14
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/open_cursors_full_by_sid.sql
-- Author       : Tim Hall
-- Description  : Displays the SQL statement held for a specific SID.
-- Comments     : The SID can be found by running session.sql or top_session.sql.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @open_cursors_full_by_sid (sid)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

  SELECT st.sql_text
    FROM v$sqltext st, v$open_cursor oc
   WHERE     st.address = oc.address
         AND st.hash_value = oc.hash_value
         AND oc.sid = &1
ORDER BY st.address, st.piece;

PROMPT
SET PAGESIZE 14
  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/options.sql
-- Author       : Tim Hall
-- Description  : Displays information about all database options.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @options
-- Last Modified: 12/04/2013
-- -----------------------------------------------------------------------------------

COLUMN value FORMAT A20

SELECT *
FROM   v$option
ORDER BY parameter;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/param_valid_values.sql
-- Author       : Tim Hall
-- Description  : Lists all valid values for the specified parameter.
-- Call Syntax  : @param_valid_values (parameter-name)
-- Requirements : Access to the v$views.
-- Last Modified: 14/05/2013
-- -----------------------------------------------------------------------------------
SET VERIFY OFF

COLUMN value FORMAT A50
COLUMN isdefault FORMAT A10

SELECT value,
       isdefault
FROM   v$parameter_valid_values
WHERE  name = '&1';
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/parameter_diffs.sql
-- Author       : Tim Hall
-- Description  : Displays parameter values that differ between the current value and the spfile.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @parameter_diffs
-- Last Modified: 08-NOV-2004
-- -----------------------------------------------------------------------------------

SET LINESIZE 120
COLUMN name          FORMAT A30
COLUMN current_value FORMAT A30
COLUMN sid           FORMAT A8
COLUMN spfile_value  FORMAT A30

SELECT p.name,
       i.instance_name AS sid,
       p.VALUE AS current_value,
       sp.sid,
       sp.VALUE AS spfile_value
  FROM v$spparameter sp, v$parameter p, v$instance i
 WHERE sp.name = p.name AND sp.VALUE != p.VALUE;

COLUMN FORMAT DEFAULT
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/parameters.sql
-- Author       : Tim Hall
-- Description  : Displays a list of all the parameters.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @parameters
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500

COLUMN name  FORMAT A30
COLUMN value FORMAT A60

SELECT p.name,
       p.type,
       p.value,
       p.isses_modifiable,
       p.issys_modifiable,
       p.isinstance_modifiable
FROM   v$parameter p
ORDER BY p.name;

--list of given parameters in pfile or spfile

select * from v$spparameter where ISSPECIFIED <> 'FALSE';
select NAME,DISPLAY_VALUE,DEFAULT_VALUE from v$parameter where ISDEFAULT <> 'TRUE' order by 1;
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/part_tables.sql
-- Author       : Tim Hall
-- Description  : Displays information about all partitioned tables.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @part_tables
-- Last Modified: 21/12/2004
-- -----------------------------------------------------------------------------------

  SELECT owner,
         table_name,
         partitioning_type,
         partition_count
    FROM dba_part_tables
   WHERE owner NOT IN ('SYS', 'SYSTEM')
ORDER BY owner, table_name;
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/pga_target_advice.sql
-- Author       : Tim Hall
-- Description  : Predicts how changes to the PGA_AGGREGATE_TARGET will affect PGA usage.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @pga_target_advice
-- Last Modified: 12/02/2004
-- -----------------------------------------------------------------------------------

SELECT ROUND (pga_target_for_estimate / 1024 / 1024) target_mb,
       estd_pga_cache_hit_percentage cache_hit_perc,
       estd_overalloc_count
  FROM v$pga_target_advice;
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/pipes.sql
-- Author       : Tim Hall
-- Description  : Displays a list of all database pipes.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @pipes
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

  SELECT a.ownerid "Owner",
         SUBSTR (name, 1, 40) "Name",
         TYPE "Type",
         pipe_size "Size"
    FROM v$db_pipes a
ORDER BY 1, 2;

SET PAGESIZE 14
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/profiler_run_details.sql
-- Author       : Tim Hall
-- Description  : Displays details of a specified profiler run.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @profiler_run_details.sql (runid)
-- Last Modified: 25/02/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET VERIFY OFF

COLUMN runid FORMAT 99999
COLUMN unit_number FORMAT 99999
COLUMN unit_type FORMAT A20
COLUMN unit_owner FORMAT A20

  SELECT u.runid,
         u.unit_number,
         u.unit_type,
         u.unit_owner,
         u.unit_name,
         d.line#,
         d.total_occur,
         ROUND (d.total_time / d.total_occur) AS time_per_occur,
         d.total_time,
         d.min_time,
         d.max_time
    FROM plsql_profiler_units u
         JOIN plsql_profiler_data d
            ON u.runid = d.runid AND u.unit_number = d.unit_number
   WHERE u.runid = &1 AND d.total_time > 0 AND d.total_occur > 0
ORDER BY (d.total_time / d.total_occur) DESC, u.unit_number, d.line#;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/profiler_runs.sql
-- Author       : Tim Hall
-- Description  : Displays information on all profiler_runs.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @profiler_runs.sql
-- Last Modified: 25/02/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET TRIMOUT ON

COLUMN runid FORMAT 99999
COLUMN run_comment FORMAT A50

SELECT runid,
       run_date,
       run_comment,
       run_total_time
FROM   plsql_profiler_runs
ORDER BY runid;
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/profiles.sql
-- Author       : Tim Hall
-- Description  : Displays the specified profile(s).
-- Call Syntax  : @profiles (profile | part of profile | all)
-- Last Modified: 28/01/2006
-- -----------------------------------------------------------------------------------

SET LINESIZE 150 PAGESIZE 20 VERIFY OFF

BREAK ON profile SKIP 1

SELECT profile,
       resource_type,
       resource_name,
       limit
FROM   dba_profiles
WHERE  profile LIKE (DECODE(UPPER('&1'), 'ALL', '%', UPPER('%&1%')))
ORDER BY profile, resource_type, resource_name;

CLEAR BREAKS
SET LINESIZE 80 PAGESIZE 14 VERIFY ON

--profiles password policy for active DB users

SET LINESIZE 200 PAGESIZE 10000 heading on termout on serveroutput on
COL PROFILE FOR A35
COL RESOURCE_NAME FOR A35
COL LIMIT FOR A40
COL PROFILE HEADING PROFILE_NAME
COL RESOURCE_NAME HEADING PASSWORD_SETTING
COL LIMIT HEADING VALUE

  SELECT PROFILE, RESOURCE_NAME, LIMIT
    FROM DBA_PROFILES
   WHERE     RESOURCE_TYPE = 'PASSWORD'
         AND PROFILE IN
                 (SELECT DISTINCT PROFILE
                    FROM DBA_USERS
                   WHERE ACCOUNT_STATUS IN ('EXPIRED(GRACE)', 'OPEN','EXPIRED'))
ORDER BY PROFILE, RESOURCE_NAME;

 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/rbs_extents.sql
-- Author       : Tim Hall
-- Description  : Displays information about the rollback segment extents.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @rbs_extents
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

  SELECT SUBSTR (a.segment_name, 1, 30) "Segment Name",
         b.status "Status",
         COUNT (*) "Extents",
         b.max_extents "Max Extents",
         TRUNC (b.initial_extent / 1024) "Initial Extent (Kb)",
         TRUNC (b.next_extent / 1024) "Next Extent (Kb)",
         TRUNC (c.bytes / 1024) "Size (Kb)"
    FROM dba_extents a, dba_rollback_segs b, dba_segments c
   WHERE     a.segment_type = 'ROLLBACK'
         AND b.segment_name = a.segment_name
         AND b.segment_name = c.segment_name
GROUP BY a.segment_name,
         b.status,
         b.max_extents,
         b.initial_extent,
         b.next_extent,
         c.bytes
ORDER BY a.segment_name;

SET PAGESIZE 14
SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/rbs_stats.sql
-- Author       : Tim Hall
-- Description  : Displays rollback segment statistics.
-- Requirements : Access to the v$ & DBA views.
-- Call Syntax  : @rbs_stats
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

SELECT b.name "Segment Name",
       Trunc(c.bytes/1024/1024) "Size (Mb)",
       a.optsize "Optimal",
       a.shrinks "Shrinks",
       a.aveshrink "Avg Shrink",
       a.wraps "Wraps",
       a.extends "Extends"
FROM   v$rollstat a,
       v$rollname b,
       dba_segments c
WHERE  a.usn  = b.usn
AND    b.name = c.segment_name
ORDER BY b.name;

SET PAGESIZE 14
SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/recovery_status.sql
-- Author       : Tim Hall
-- Description  : Displays the recovery status of each datafile.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @recovery_status
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 500
SET FEEDBACK OFF

SELECT Substr(a.name,1,60) "Datafile",
       b.status "Status"
FROM   v$datafile a,
       v$backup b
WHERE  a.file# = b.file#;

SET PAGESIZE 14
SET FEEDBACK ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/redo_by_day.sql
-- Author       : Tim Hall
-- Description  : Lists the volume of archived redo by day for the specified number of days.
-- Call Syntax  : @redo_by_day (days)
-- Requirements : Access to the v$views.
-- Last Modified: 11/10/2013
-- -----------------------------------------------------------------------------------

SET VERIFY OFF

SELECT TRUNC(first_time) AS day,
       ROUND(SUM(blocks * block_size)/1024/1024/1024,2) size_gb
FROM   v$archived_log
WHERE  TRUNC(first_time) >= TRUNC(SYSDATE) - &1
GROUP BY TRUNC(first_time)
ORDER BY TRUNC(first_time);

SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/redo_by_hour.sql
-- Author       : Tim Hall
-- Description  : Lists the volume of archived redo by hour for the specified day.
-- Call Syntax  : @redo_by_hour (day 0=Today, 1=Yesterday etc.)
-- Requirements : Access to the v$views.
-- Last Modified: 11/10/2013
-- -----------------------------------------------------------------------------------

SET VERIFY OFF PAGESIZE 30

WITH hours
     AS (    SELECT TRUNC (SYSDATE) - &1 + ( (LEVEL - 1) / 24) AS hours
               FROM DUAL
         CONNECT BY LEVEL <= 24)
  SELECT h.hours AS date_hour,
         ROUND (SUM (blocks * block_size) / 1024 / 1024 / 1024, 2) size_gb
    FROM hours h
         LEFT OUTER JOIN v$archived_log al
            ON h.hours = TRUNC (al.first_time, 'HH24')
GROUP BY h.hours
ORDER BY h.hours;

SET VERIFY ON PAGESIZE 14
  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/redo_by_min.sql
-- Author       : Tim Hall
-- Description  : Lists the volume of archived redo by min for the specified number of hours.
-- Call Syntax  : @redo_by_min (N number of minutes from now)
-- Requirements : Access to the v$views.
-- Last Modified: 11/10/2013
-- -----------------------------------------------------------------------------------

SET VERIFY OFF PAGESIZE 100

WITH mins AS (
  SELECT TRUNC(SYSDATE, 'MI') - (60/(24*60)) + ((level-1)/(24*60)) AS mins
  FROM   dual
  CONNECT BY level <= 60
)
SELECT m.mins AS date_min,
       ROUND(SUM(blocks * block_size)/1024/1024,2) size_mb
FROM   mins m
       LEFT OUTER JOIN v$archived_log al ON m.mins = TRUNC(al.first_time, 'MI')
GROUP BY m.mins
ORDER BY m.mins;

SET VERIFY ON PAGESIZE 14
  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/registry_history.sql
-- Author       : Tim Hall
-- Description  : Displays contents of the registry history
-- Requirements : Access to the DBA role.
-- Call Syntax  : @registry_history
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN action_time FORMAT A20
COLUMN action FORMAT A20
COLUMN namespace FORMAT A20
COLUMN version FORMAT A10
COLUMN comments FORMAT A30
COLUMN bundle_series FORMAT A10

SELECT TO_CHAR(action_time, 'DD-MON-YYYY HH24:MI:SS') AS action_time,
       action,
       namespace,
       version,
       id,
       comments,
       bundle_series
FROM   sys.registry$history
ORDER by action_time;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/role_privs.sql
-- Author       : Tim Hall
-- Description  : Displays a list of all roles and privileges granted to the specified role.
-- Requirements : Access to the USER views.
-- Call Syntax  : @role_privs (role-name, ALL)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET VERIFY OFF

SELECT a.role,
       a.granted_role,
       a.admin_option
FROM   role_role_privs a
WHERE  a.role = DECODE(UPPER('&1'), 'ALL', a.role, UPPER('&1'))
ORDER BY a.role, a.granted_role;

SELECT a.grantee,
       a.granted_role,
       a.admin_option,
       a.default_role
FROM   dba_role_privs a
WHERE  a.grantee = DECODE(UPPER('&1'), 'ALL', a.grantee, UPPER('&1'))
ORDER BY a.grantee, a.granted_role;

SELECT a.role,
       a.privilege,
       a.admin_option
FROM   role_sys_privs a
WHERE  a.role = DECODE(UPPER('&1'), 'ALL', a.role, UPPER('&1'))
ORDER BY a.role, a.privilege;

SELECT a.role,
       a.owner,
       a.table_name, 
       a.column_name, 
       a.privilege,
       a.grantable
FROM   role_tab_privs a
WHERE  a.role = DECODE(UPPER('&1'), 'ALL', a.role, UPPER('&1'))
ORDER BY a.role, a.owner, a.table_name;
               
SET VERIFY ON
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/roles.sql
-- Author       : Tim Hall
-- Description  : Displays a list of all roles and privileges granted to the specified user.
-- Requirements : Access to the USER views.
-- Call Syntax  : @roles
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET VERIFY OFF

SELECT a.role,
       a.password_required,
       a.authentication_type
FROM   dba_roles a
ORDER BY a.role;
               
SET VERIFY ON
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/search_source.sql
-- Author       : Tim Hall
-- Description  : Displays a list of all code-objects that contain the specified word.
-- Requirements : Access to the ALL views.
-- Call Syntax  : @search_source (text) (schema-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
BREAK ON Name Skip 2
SET PAGESIZE 0
SET LINESIZE 500
SET VERIFY OFF

SPOOL Search_Source.txt

SELECT a.name "Name",
       a.line "Line",
       Substr(a.text,1,200) "Text"
FROM   all_source a
WHERE  Instr(Upper(a.text),Upper('&&1')) != 0
AND    a.owner = Upper('&&2')
ORDER BY 1,2;

SPOOL OFF
SET PAGESIZE 14
SET VERIFY ON
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/segment_stats.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays statistics for segments in th specified schema.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @segment_stats
-- Last Modified: 20/10/2006
-- -----------------------------------------------------------------------------------
SELECT statistic#,
       name
FROM   v$segstat_name
ORDER BY statistic#;

ACCEPT l_schema char PROMPT 'Enter Schema: '
ACCEPT l_stat  NUMBER PROMPT 'Enter Statistic#: '
SET VERIFY OFF

SELECT object_name,
       object_type,
       value
FROM   v$segment_statistics 
WHERE  owner = UPPER('&l_schema')
AND    statistic# = &l_stat
ORDER BY value;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/session_events.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database session events.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_events
-- Last Modified: 11/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN username FORMAT A20
COLUMN event FORMAT A40

  SELECT NVL (s.username, '(oracle)') AS username,
         s.sid,
         s.serial#,
         se.event,
         se.total_waits,
         se.total_timeouts,
         se.time_waited,
         se.average_wait,
         se.max_wait,
         se.time_waited_micro
    FROM v$session_event se, v$session s
   WHERE s.sid = se.sid
--AND    s.sid = &1
ORDER BY se.time_waited DESC;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/session_events_by_sid.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database session events for the specified sid.
--                This is a rename of session_events.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_events_by_sid (sid)
-- Last Modified: 06-APR-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN username FORMAT A20
COLUMN event FORMAT A40

  SELECT NVL (s.username, '(oracle)') AS username,
         s.sid,
         s.serial#,
         se.event,
         se.total_waits,
         se.total_timeouts,
         se.time_waited,
         se.average_wait,
         se.max_wait,
         se.time_waited_micro
    FROM v$session_event se, v$session s
   WHERE s.sid = se.sid AND s.sid = &1
ORDER BY se.time_waited DESC;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/session_events_by_spid.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database session events for the specified spid.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_events_by_spid (spid)
-- Last Modified: 06-APR-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN username FORMAT A20
COLUMN event FORMAT A40

  SELECT NVL (s.username, '(oracle)') AS username,
         s.sid,
         s.serial#,
         se.event,
         se.total_waits,
         se.total_timeouts,
         se.time_waited,
         se.average_wait,
         se.max_wait,
         se.time_waited_micro
    FROM v$session_event se, v$session s, v$process p
   WHERE s.sid = se.sid AND s.paddr = p.addr AND p.spid = &1
ORDER BY se.time_waited DESC;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/session_io.sql
-- Author       : Tim Hall
-- Description  : Displays I/O information on all database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_io
-- Last Modified: 21-FEB-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000

COLUMN username FORMAT A15

  SELECT NVL (s.username, '(oracle)') AS username,
         s.osuser,
         s.sid,
         s.serial#,
         si.block_gets,
         si.consistent_gets,
         si.physical_reads,
         si.block_changes,
         si.consistent_changes
    FROM v$session s, v$sess_io si
   WHERE s.sid = si.sid
ORDER BY s.username, s.osuser;

SET PAGESIZE 14

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/session_rollback.sql
-- Author       : Tim Hall
-- Description  : Displays rollback information on relevant database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_rollback
-- Last Modified: 29/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN username FORMAT A15

  SELECT s.username,
         s.sid,
         s.serial#,
         t.used_ublk,
         t.used_urec,
         rs.segment_name,
         r.rssize,
         r.status
    FROM v$transaction t,
         v$session s,
         v$rollstat r,
         dba_rollback_segs rs
   WHERE s.saddr = t.ses_addr AND t.xidusn = r.usn AND rs.segment_id = t.xidusn
ORDER BY t.used_ublk DESC;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/session_stats.sql
-- Author       : Tim Hall
-- Description  : Displays session-specific statistics.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_stats (statistic-name or all)
-- Last Modified: 03/11/2004
-- -----------------------------------------------------------------------------------
SET VERIFY OFF

  SELECT sn.name, ss.VALUE
    FROM v$sesstat ss, v$statname sn, v$session s
   WHERE     ss.statistic# = sn.statistic#
         AND s.sid = ss.sid
         AND s.audsid = SYS_CONTEXT ('USERENV', 'SESSIONID')
         AND sn.name LIKE
                '%' || DECODE (LOWER ('&1'), 'all', '', LOWER ('&1')) || '%'
ORDER BY 1, 2;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/session_stats_by_sid.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays session-specific statistics.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_stats_by_sid (sid) (statistic-name or all)
-- Last Modified: 19/09/2006
-- -----------------------------------------------------------------------------------
SET VERIFY OFF

SELECT sn.name, ss.value
FROM   v$sesstat ss,
       v$statname sn
WHERE  ss.statistic# = sn.statistic#
AND    ss.sid = &1
AND    sn.name LIKE '%' || DECODE(LOWER('&2'), 'all', '', LOWER('&2')) || '%';

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/session_undo.sql
-- Author       : Tim Hall
-- Description  : Displays undo information on relevant database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_undo
-- Last Modified: 29/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN username FORMAT A15

SELECT s.username,
       s.sid,
       s.serial#,
       t.used_ublk,
       t.used_urec,
       rs.segment_name,
       r.rssize,
       r.status
FROM   v$transaction t,
       v$session s,
       v$rollstat r,
       dba_rollback_segs rs
WHERE  s.saddr = t.ses_addr
AND    t.xidusn = r.usn
AND    rs.segment_id = t.xidusn
ORDER BY t.used_ublk DESC;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/session_waits.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database session waits.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_waits
-- Last Modified: 11/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000

COLUMN username FORMAT A20
COLUMN event FORMAT A30
COLUMN wait_class FORMAT A15

  SELECT NVL (s.username, '(oracle)') AS username,
         s.sid,
         s.serial#,
         sw.event,
         sw.wait_class,
         sw.wait_time,
         sw.seconds_in_wait,
         sw.state
    FROM v$session_wait sw, v$session s
   WHERE s.sid = sw.sid
ORDER BY sw.seconds_in_wait DESC;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/sessions.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @sessions
-- Last Modified: 21-FEB-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000

COLUMN username FORMAT A15
COLUMN osuser FORMAT A15
COLUMN spid FORMAT A10
COLUMN service_name FORMAT A15
COLUMN module FORMAT A35
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20

  SELECT NVL (s.username, '(oracle)') AS username,
         s.osuser,
         s.sid,
         s.serial#,
         p.spid,
         s.lockwait,
         s.status,
         s.service_name,
         s.module,
         s.machine,
         s.program,
         TO_CHAR (s.logon_Time, 'DD-MON-YYYY HH24:MI:SS') AS logon_time
    FROM v$session s, v$process p
   WHERE s.paddr = p.addr
ORDER BY s.username, s.osuser;

SET PAGESIZE 14

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/sessions_by_machine.sql
-- Author       : Tim Hall
-- Description  : Displays the number of sessions for each client machine.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @sessions_by_machine
-- Last Modified: 20-JUL-2014
-- -----------------------------------------------------------------------------------
SET PAGESIZE 1000

  SELECT machine,
         NVL (active_count, 0) AS active,
         NVL (inactive_count, 0) AS inactive,
         NVL (killed_count, 0) AS killed
    FROM (  SELECT machine, status, COUNT (*) AS quantity
              FROM v$session
          GROUP BY machine, status) PIVOT (SUM (quantity) AS COUNT
                                    FOR (status)
                                    IN  ('ACTIVE' AS active,
                                        'INACTIVE' AS inactive,
                                        'KILLED' AS killed))
ORDER BY machine;

SET PAGESIZE 14

-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/show_indexes.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays information about specified indexes.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @show_indexes (schema) (table-name or all)
-- Last Modified: 04/10/2006
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 200

COLUMN table_owner FORMAT A20
COLUMN index_owner FORMAT A20
COLUMN index_type FORMAT A12
COLUMN tablespace_name FORMAT A20

  SELECT table_owner,
         table_name,
         owner AS index_owner,
         index_name,
         tablespace_name,
         num_rows,
         status,
         index_type
    FROM dba_indexes
   WHERE     table_owner = UPPER ('&1')
         AND table_name =
                DECODE (UPPER ('&2'), 'ALL', table_name, UPPER ('&2'))
ORDER BY table_owner,
         table_name,
         index_owner,
         index_name;
		 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/show_space.sql
-- Author       : Tom Kyte
-- Description  : Displays free and unused space for the specified object.
-- Call Syntax  : EXEC Show_Space('Tablename');
-- Requirements : SET SERVEROUTPUT ON              
-- Last Modified: 10/09/2002
-- -----------------------------------------------------------------------------------
CREATE OR REPLACE
PROCEDURE show_space
( p_segname IN VARCHAR2,
  p_owner   IN VARCHAR2 DEFAULT user,
  p_type    IN VARCHAR2 DEFAULT 'TABLE' )
AS
  l_free_blks                 NUMBER;
  l_total_blocks              NUMBER;
  l_total_bytes               NUMBER;
  l_unused_blocks             NUMBER;
  l_unused_bytes              NUMBER;
  l_last_used_ext_file_id     NUMBER;
  l_last_used_ext_block_id        NUMBER;
  l_last_used_block           NUMBER;
  
  PROCEDURE p( p_label IN VARCHAR2, p_num IN NUMBER )
  IS
  BEGIN
     DBMS_OUTPUT.PUT_LINE( RPAD(p_label,40,'.') || p_num );
  END;
  
BEGIN
  DBMS_SPACE.FREE_BLOCKS (
    segment_owner     => p_owner,
    segment_name      => p_segname,
    segment_type      => p_type,
    freelist_group_id => 0,
    free_blks         => l_free_blks );

  DBMS_SPACE.UNUSED_SPACE ( 
    segment_owner             => p_owner,
    segment_name              => p_segname,
    segment_type              => p_type,
    total_blocks              => l_total_blocks,
    total_bytes               => l_total_bytes,
    unused_blocks             => l_unused_blocks,
    unused_bytes              => l_unused_bytes,
    last_used_extent_file_id  => l_last_used_ext_file_id,
    last_used_extent_block_id => l_last_used_ext_block_id,
    last_used_block           => l_last_used_block );
 
  p( 'Free Blocks', l_free_blks );
  p( 'Total Blocks', l_total_blocks );
  p( 'Total Bytes', l_total_bytes );
  p( 'Unused Blocks', l_unused_blocks );
  p( 'Unused Bytes', l_unused_bytes );
  p( 'Last Used Ext FileId', l_last_used_ext_file_id );
  p( 'Last Used Ext BlockId', l_last_used_ext_block_id );
  p( 'Last Used Block', l_LAST_USED_BLOCK );
END;
/

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/show_tables.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays information about specified tables.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @show_tables (schema)
-- Last Modified: 04/10/2006
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 200

COLUMN owner FORMAT A20
COLUMN table_name FORMAT A30

  SELECT t.table_name,
         t.tablespace_name,
         t.num_rows,
         t.avg_row_len,
         t.blocks,
         t.empty_blocks,
         ROUND (t.blocks * ts.block_size / 1024 / 1024, 2) AS size_mb
    FROM dba_tables t
         JOIN dba_tablespaces ts ON t.tablespace_name = ts.tablespace_name
   WHERE t.owner = UPPER ('&1')
ORDER BY t.table_name;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/source.sql
-- Author       : Tim Hall
-- Description  : Displays the section of code specified. Prompts user for parameters.
-- Requirements : Access to the ALL views.
-- Call Syntax  : @source
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
PROMPT
ACCEPT a_name   PROMPT 'Enter Name: '
ACCEPT a_type   PROMPT 'Enter Type (S,B,P,F): '
ACCEPT a_from   PROMPT 'Enter Line From: '
ACCEPT a_to     PROMPT 'Enter Line To: '
ACCEPT a_owner  PROMPT 'Enter Owner: '
VARIABLE v_name   VARCHAR2(100)
VARIABLE v_type   VARCHAR2(100)
VARIABLE v_from   NUMBER
VARIABLE v_to     NUMBER
VARIABLE v_owner  VARCHAR2(100)
SET VERIFY OFF
SET FEEDBACK OFF
SET LINESIZE 300
SET PAGESIZE 0

BEGIN
   :v_name := UPPER ('&a_name');
   :v_type := UPPER ('&a_type');
   :v_from := &a_from;
   :v_to := &a_to;
   :v_owner := UPPER ('&a_owner');

   IF :v_type = 'S'
   THEN
      :v_type := 'PACKAGE';
   ELSIF :v_type = 'B'
   THEN
      :v_type := 'PACKAGE BODY';
   ELSIF :v_type = 'P'
   THEN
      :v_type := 'PROCEDURE';
   ELSE
      :v_type := 'FUNCTION';
   END IF;
END;
/

SELECT a.line "Line", SUBSTR (a.text, 1, 200) "Text"
  FROM all_source a
 WHERE     a.name = :v_name
       AND a.TYPE = :v_type
       AND a.line BETWEEN :v_from AND :v_to
       AND a.owner = :v_owner;

SET VERIFY ON
SET FEEDBACK ON
SET PAGESIZE 22
PROMPT
     
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/spfile_parameters.sql
-- Author       : Tim Hall
-- Description  : Displays a list of all the spfile parameters.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @spfile_parameters
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500

COLUMN name  FORMAT A30
COLUMN value FORMAT A60
COLUMN displayvalue FORMAT A60

  SELECT sp.sid,
         sp.name,
         sp.VALUE,
         sp.display_value
    FROM v$spparameter sp
ORDER BY sp.name, sp.sid;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/sql_area.sql
-- Author       : Tim Hall
-- Description  : Displays the SQL statements for currently running processes.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @sql_area
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET FEEDBACK OFF

SELECT s.sid,
       s.status "Status",
       p.spid "Process",
       s.schemaname "Schema Name",
       s.osuser "OS User",
       SUBSTR (a.sql_text, 1, 120) "SQL Text",
       s.program "Program"
  FROM v$session s, v$sqlarea a, v$process p
 WHERE     s.sql_hash_value = a.hash_value(+)
       AND s.sql_address = a.address(+)
       AND s.paddr = p.addr;

SET PAGESIZE 14
SET FEEDBACK ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/sql_text.sql
-- Author       : Tim Hall
-- Description  : Displays the SQL statement held at the specified address.
-- Comments     : The address can be found using v$session or Top_SQL.sql.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @sql_text (address)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET FEEDBACK OFF
SET VERIFY OFF

SELECT a.sql_text
FROM   v$sqltext_with_newlines a
WHERE  a.address = UPPER('&&1')
ORDER BY a.piece;

PROMPT
SET PAGESIZE 14
SET FEEDBACK ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/sql_text_by_sid.sql
-- Author       : Tim Hall
-- Description  : Displays the SQL statement held for a specific SID.
-- Comments     : The SID can be found by running session.sql or top_session.sql.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @sql_text_by_sid (sid)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

  SELECT a.sql_text
    FROM v$sqltext a, v$session b
   WHERE     a.address = b.sql_address
         AND a.hash_value = b.sql_hash_value
         AND b.sid = &1
ORDER BY a.piece;

PROMPT
SET PAGESIZE 14

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/statistics_prefs.sql
-- Author       : Tim Hall
-- Description  : Displays current statistics preferences.
-- Requirements : Access to the DBMS_STATS package.
-- Call Syntax  : @statistics_prefs
-- Last Modified: 06-DEC-2013
-- -----------------------------------------------------------------------------------

SET LINESIZE 250

COLUMN autostats_target FORMAT A20
COLUMN cascade FORMAT A25
COLUMN degree FORMAT A10
COLUMN estimate_percent FORMAT A30
COLUMN method_opt FORMAT A25
COLUMN no_invalidate FORMAT A30
COLUMN granularity FORMAT A15
COLUMN publish FORMAT A10
COLUMN incremental FORMAT A15
COLUMN stale_percent FORMAT A15

SELECT DBMS_STATS.GET_PREFS('AUTOSTATS_TARGET') AS autostats_target,
       DBMS_STATS.GET_PREFS('CASCADE') AS cascade,
       DBMS_STATS.GET_PREFS('DEGREE') AS degree,
       DBMS_STATS.GET_PREFS('ESTIMATE_PERCENT') AS estimate_percent,
       DBMS_STATS.GET_PREFS('METHOD_OPT') AS method_opt,
       DBMS_STATS.GET_PREFS('NO_INVALIDATE') AS no_invalidate,
       DBMS_STATS.GET_PREFS('GRANULARITY') AS granularity,
       DBMS_STATS.GET_PREFS('PUBLISH') AS publish,
       DBMS_STATS.GET_PREFS('INCREMENTAL') AS incremental,
       DBMS_STATS.GET_PREFS('STALE_PERCENT') AS stale_percent
FROM   dual;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/synonyms_to_missing_objects.sql
-- Author       : Tim Hall
-- Description  : Lists all synonyms that point to missing objects.
-- Call Syntax  : @synonyms_to_missing_objects(object-schema-name or all)
-- Requirements : Access to the DBA views.
-- Last Modified: 07/10/2013
-- -----------------------------------------------------------------------------------
SET LINESIZE 1000 VERIFY OFF

  SELECT s.owner,
         s.synonym_name,
         s.table_owner,
         s.table_name
    FROM dba_synonyms s
   WHERE     s.db_link IS NULL
         AND s.table_owner NOT IN ('SYS', 'SYSTEM')
         AND NOT EXISTS
                    (SELECT 1
                       FROM dba_objects o
                      WHERE     o.owner = s.table_owner
                            AND o.object_name = s.table_name
                            AND o.object_type != 'SYNONYM')
         AND s.table_owner =
                DECODE (UPPER ('&1'), 'ALL', s.table_owner, UPPER ('&1'))
ORDER BY s.owner, s.synonym_name;

SET LINESIZE 80 VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/system_events.sql
-- Author       : Tim Hall
-- Description  : Displays information on all system events.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @system_events
-- Last Modified: 21-FEB-2005
-- -----------------------------------------------------------------------------------
  SELECT event,
         total_waits,
         total_timeouts,
         time_waited,
         average_wait,
         time_waited_micro
    FROM v$system_event
ORDER BY event;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/system_parameters.sql
-- Author       : Tim Hall
-- Description  : Displays a list of all the system parameters.
--                Comment out isinstance_modifiable for use prior to 10g.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @system_parameters
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500

COLUMN name  FORMAT A30
COLUMN value FORMAT A60

SELECT sp.name,
       sp.type,
       sp.value,
       sp.isses_modifiable,
       sp.issys_modifiable,
       sp.isinstance_modifiable
FROM   v$system_parameter sp
ORDER BY sp.name;


-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/system_privs.sql
-- Author       : Tim Hall
-- Description  : Displays users granted the specified system privilege.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @system_privs ("sys-priv")
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200 VERIFY OFF

SELECT privilege,
       grantee,
       admin_option
FROM   dba_sys_privs
WHERE  privilege LIKE UPPER('%&1%')
ORDER BY privilege, grantee;

SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/system_stats.sql
-- Author       : Tim Hall
-- Description  : Displays system statistics.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @system_stats (statistic-name or all)
-- Last Modified: 03-NOV-2004
-- -----------------------------------------------------------------------------------
SET VERIFY OFF

COLUMN name FORMAT A50
COLUMN value FORMAT 99999999999999999999

SELECT sn.name, ss.value
FROM   v$sysstat ss,
       v$statname sn
WHERE  ss.statistic# = sn.statistic#
AND    sn.name LIKE '%' || DECODE(LOWER('&1'), 'all', '', LOWER('&1')) || '%';

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/table_dep.sql
-- Author       : Tim Hall
-- Description  : Displays a list dependencies for the specified table.
-- Requirements : Access to the ALL views.
-- Call Syntax  : @table_dep (table-name) (schema-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
PROMPT
SET VERIFY OFF
SET FEEDBACK OFF
SET LINESIZE 255
SET PAGESIZE 1000


SELECT ad.referenced_name "Object",
       ad.name "Ref Object",
       ad.type "Type",
       Substr(ad.referenced_owner,1,10) "Ref Owner",
       Substr(ad.referenced_link_name,1,20) "Ref Link Name"
FROM   all_dependencies ad
WHERE  ad.referenced_name = Upper('&&1')
AND    ad.owner           = Upper('&&2')
ORDER BY 1,2,3;

SET VERIFY ON
SET FEEDBACK ON
SET PAGESIZE 14
PROMPT

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/table_extents.sql
-- Author       : Tim Hall
-- Description  : Displays a list of tables having more than 1 extent.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @table_extents (schema-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

  SELECT t.table_name,
         COUNT (e.segment_name) extents,
         t.max_extents,
         t.num_rows "ROWS",
         TRUNC (t.initial_extent / 1024) "INITIAL K",
         TRUNC (t.next_extent / 1024) "NEXT K"
    FROM all_tables t, dba_extents e
   WHERE     e.segment_name = t.table_name
         AND e.owner = t.owner
         AND t.owner = UPPER ('&&1')
GROUP BY t.table_name,
         t.max_extents,
         t.num_rows,
         t.initial_extent,
         t.next_extent
  HAVING COUNT (e.segment_name) > 1
ORDER BY COUNT (e.segment_name) DESC;

SET PAGESIZE 18
SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/table_indexes.sql
-- Author       : Tim Hall
-- Description  : Displays index-column information for the specified table.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @table_indexes (schema-name) (table-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500 PAGESIZE 1000 VERIFY OFF

COLUMN index_name      FORMAT A30
COLUMN column_name     FORMAT A30
COLUMN column_position FORMAT 99999

SELECT a.index_name,
       a.column_name,
       a.column_position
FROM   all_ind_columns a,
       all_indexes b
WHERE  b.owner      = UPPER('&1')
AND    b.table_name = UPPER('&2')
AND    b.index_name = a.index_name
AND    b.owner      = a.index_owner
ORDER BY 1,3;

SET PAGESIZE 18 VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/table_partitions.sql
-- Author       : Tim Hall
-- Description  : Displays partition information for the specified table, or all tables.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @table_partitions (table-name or all) (schema-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET FEEDBACK OFF
SET VERIFY OFF

  SELECT a.table_name,
         a.partition_name,
         a.tablespace_name,
         a.initial_extent,
         a.next_extent,
         a.pct_increase,
         a.num_rows,
         a.avg_row_len
    FROM dba_tab_partitions a
   WHERE     a.table_name =
                DECODE (UPPER ('&&1'), 'ALL', a.table_name, UPPER ('&&1'))
         AND a.table_owner = UPPER ('&&2')
ORDER BY a.table_name, a.partition_name
/


SET PAGESIZE 14
SET FEEDBACK ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/table_stats.sql
-- Author       : Tim Hall
-- Description  : Displays the table statistics belonging to the specified schema.
-- Requirements : Access to the DBA and v$ views.
-- Call Syntax  : @table_stats (schema-name) (table-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 300 VERIFY OFF

COLUMN owner FORMAT A20

SELECT owner,
       table_name,
       num_rows,
       blocks,
       empty_blocks,
       avg_space chain_cnt,
       avg_row_len,
       last_analyzed
  FROM dba_tables
 WHERE owner = UPPER ('&1') AND table_name = UPPER ('&2');

  SELECT index_name,
         blevel,
         leaf_blocks,
         distinct_keys,
         avg_leaf_blocks_per_key,
         avg_data_blocks_per_key,
         clustering_factor,
         num_rows,
         last_analyzed
    FROM dba_indexes
   WHERE table_owner = UPPER ('&1') AND table_name = UPPER ('&2')
ORDER BY index_name;

COLUMN column_name FORMAT A30
COLUMN endpoint_actual_value FORMAT A30

  SELECT column_id,
         column_name,
         num_distinct,
         avg_col_len,
         histogram,
         low_value,
         high_value
    FROM dba_tab_columns
   WHERE owner = UPPER ('&1') AND table_name = UPPER ('&2')
ORDER BY column_id;

SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/tables_with_locked_stats.sql
-- Author       : Tim Hall
-- Description  : Displays tables with locked stats.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tables_with_locked_stats.sql
-- Last Modified: 06-DEC-2013
-- -----------------------------------------------------------------------------------

  SELECT owner, table_name, stattype_locked
    FROM dba_tab_statistics
   WHERE stattype_locked IS NOT NULL
ORDER BY owner, table_name;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/tables_with_zero_rows.sql
-- Author       : Tim Hall
-- Description  : Displays tables with stats saying they have zero rows.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tables_with_zero_rows.sql
-- Last Modified: 06-DEC-2013
-- -----------------------------------------------------------------------------------

SELECT owner,
       table_name,
       last_analyzed,
       num_rows
FROM   dba_tables
WHERE  num_rows = 0
AND    owner NOT IN ('SYS','SYSTEM','SYSMAN','XDB','MDSYS',
                     'WMSYS','OUTLN','ORDDATA','ORDSYS',
                     'OLAPSYS','EXFSYS','DBNSMP','CTXSYS',
                     'APEX_030200','FLOWS_FILES','SCOTT',
                     'TSMSYS','DBSNMP','APPQOSSYS','OWBSYS',
                     'DMSYS','FLOWS_030100','WKSYS','WK_TEST')
ORDER BY owner, table_name;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/tablespaces.sql
-- Author       : Tim Hall
-- Description  : Displays information about tablespaces.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @tablespaces
-- Last Modified: 17-AUG-2005
-- -----------------------------------------------------------------------------------

SET LINESIZE 200

  SELECT tablespace_name,
         block_size,
         extent_management,
         allocation_type,
         segment_space_management,
         status
    FROM dba_tablespaces
ORDER BY tablespace_name;

-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/temp_extent_map.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays temp extents and their locations within the tablespace allowing identification of tablespace fragmentation.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @temp_extent_map (tablespace-name)
-- Last Modified: 25/01/2003
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON SIZE 1000000
SET FEEDBACK OFF
SET TRIMOUT ON
SET VERIFY OFF

DECLARE
   CURSOR c_extents
   IS
        SELECT d.name,
               t.block_id AS start_block,
               t.block_id + t.blocks - 1 AS end_block
          FROM v$temp_extent_map t, v$tempfile d
         WHERE t.file_id = d.file# AND t.tablespace_name = UPPER ('&1')
      ORDER BY d.name, t.block_id;

   l_last_block_id   NUMBER := 0;
   l_gaps_only       BOOLEAN := TRUE;
BEGIN
   FOR cur_rec IN c_extents
   LOOP
      IF cur_rec.start_block > l_last_block_id + 1
      THEN
         DBMS_OUTPUT.PUT_LINE (
               '*** GAP *** ('
            || l_last_block_id
            || ' -> '
            || cur_rec.start_block
            || ')');
      END IF;

      l_last_block_id := cur_rec.end_block;

      IF NOT l_gaps_only
      THEN
         DBMS_OUTPUT.PUT_LINE (
               RPAD (cur_rec.name, 50, ' ')
            || ' ('
            || cur_rec.start_block
            || ' -> '
            || cur_rec.end_block
            || ')');
      END IF;
   END LOOP;
END;
/

PROMPT
SET FEEDBACK ON
SET PAGESIZE 18

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/temp_free_space.sql
-- Author       : Tim Hall
-- Description  : Displays temp space usage for each datafile.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @temp_free_space
-- Last Modified: 15-JUL-2000 - Created.
--                13-OCT-2012 - Amended to include auto-extend and maxsize.
-- -----------------------------------------------------------------------------------
SET LINESIZE 255

COLUMN tablespace_name FORMAT A20
COLUMN file_name FORMAT A40

  SELECT tf.tablespace_name,
         tf.file_name,
         tf.size_mb,
         f.free_mb,
         tf.max_size_mb,
         f.free_mb + (tf.max_size_mb - tf.size_mb) AS max_free_mb,
         RPAD (
               ' '
            || RPAD (
                  'X',
                  ROUND (
                       (  tf.max_size_mb
                        - (f.free_mb + (tf.max_size_mb - tf.size_mb)))
                     / max_size_mb
                     * 10,
                     0),
                  'X'),
            11,
            '-')
            AS used_pct
    FROM (SELECT file_id,
                 file_name,
                 tablespace_name,
                 TRUNC (bytes / 1024 / 1024) AS size_mb,
                 TRUNC (GREATEST (bytes, maxbytes) / 1024 / 1024)
                    AS max_size_mb
            FROM dba_temp_files) tf,
         (  SELECT TRUNC (SUM (bytes) / 1024 / 1024) AS free_mb, file_id
              FROM dba_free_space
          GROUP BY file_id) f
   WHERE tf.file_id = f.file_id(+)
ORDER BY tf.tablespace_name, tf.file_name;

SET PAGESIZE 14

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/temp_io.sql
-- Author       : Tim Hall
-- Description  : Displays the amount of IO for each tempfile.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @temp_io
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET PAGESIZE 1000

  SELECT SUBSTR (t.name, 1, 50) AS file_name,
         f.phyblkrd AS blocks_read,
         f.phyblkwrt AS blocks_written,
         f.phyblkrd + f.phyblkwrt AS total_io
    FROM v$tempstat f, v$tempfile t
   WHERE t.file# = f.file#
ORDER BY f.phyblkrd + f.phyblkwrt DESC;

SET PAGESIZE 18

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/temp_segments.sql
-- Author       : Tim Hall
-- Description  : Displays a list of all temporary segments.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @temp_segments
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500

  SELECT owner, TRUNC (SUM (bytes) / 1024) Kb
    FROM dba_segments
   WHERE segment_type = 'TEMPORARY'
GROUP BY owner;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/temp_usage.sql
-- Author       : Tim Hall
-- Description  : Displays temp usage for all session currently using temp space.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @temp_usage
-- Last Modified: 12/02/2004
-- -----------------------------------------------------------------------------------


COLUMN temp_used FORMAT 9999999999

  SELECT NVL (s.username, '(background)') AS username,
         s.sid,
         s.serial#,
         ROUND (ss.VALUE / 1024 / 1024, 2) AS temp_used_mb
    FROM v$session s
         JOIN v$sesstat ss ON s.sid = ss.sid
         JOIN v$statname sn ON ss.statistic# = sn.statistic#
   WHERE sn.name = 'temp space allocated (bytes)' AND ss.VALUE > 0
ORDER BY 4 DESC, 1, 3;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/tempfiles.sql
-- Author       : Tim Hall
-- Description  : Displays information about tempfiles.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @tempfiles
-- Last Modified: 17-AUG-2005
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN file_name FORMAT A70

  SELECT file_id,
         file_name,
         ROUND (bytes / 1024 / 1024 / 1024) AS size_gb,
         ROUND (maxbytes / 1024 / 1024 / 1024) AS max_size_gb,
         autoextensible,
         increment_by,
         status
    FROM dba_temp_files
ORDER BY file_name;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/tempseg_usage.sql
-- Author       : Tim Hall
-- Description  : Displays temp segment usage for all session currently using temp space.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @tempseg_usage
-- Last Modified: 01/04/2006
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN username FORMAT A20

  SELECT username,
         session_addr,
         session_num,
         sqladdr,
         sqlhash,
         sql_id,
         contents,
         segtype,
         extents,
         blocks
    FROM v$tempseg_usage
ORDER BY 10 DESC, 1, 6;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/top_latches.sql
-- Author       : Tim Hall
-- Description  : Displays information about the top latches.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @top_latches
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

SELECT l.latch#,
       l.name,
       l.gets,
       l.misses,
       l.sleeps,
       l.immediate_gets,
       l.immediate_misses,
       l.spin_gets
FROM   v$latch l
WHERE  l.misses > 0
ORDER BY l.misses DESC;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/top_sessions.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database sessions ordered by executions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @top_sessions.sql (reads, execs or cpu)
-- Last Modified: 21/02/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN username FORMAT A15
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20

SELECT NVL(a.username, '(oracle)') AS username,
       a.osuser,
       a.sid,
       a.serial#,
       c.value AS &1,
       a.lockwait,
       a.status,
       a.module,
       a.machine,
       a.program,
       TO_CHAR(a.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
FROM   v$session a,
       v$sesstat c,
       v$statname d
WHERE  a.sid        = c.sid
AND    c.statistic# = d.statistic#
AND    d.name       = DECODE(UPPER('&1'), 'READS', 'session logical reads',
                                          'EXECS', 'execute count',
                                          'CPU',   'CPU used by this session',
                                                   'CPU used by this session')
ORDER BY c.value DESC;

SET PAGESIZE 14
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/top_sql.sql
-- Author       : Tim Hall
-- Description  : Displays a list of SQL statements that are using the most resources.
-- Comments     : The address column can be use as a parameter with SQL_Text.sql to display the full statement.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @top_sql (number)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

SELECT *
  FROM (  SELECT SUBSTR (a.sql_text, 1, 50) sql_text,
                 TRUNC (
                    a.disk_reads / DECODE (a.executions, 0, 1, a.executions))
                    reads_per_execution,
                 a.buffer_gets,
                 a.disk_reads,
                 a.executions,
                 a.sorts,
                 a.address
            FROM v$sqlarea a
        ORDER BY 2 DESC)
 WHERE ROWNUM <= &&1;

SET PAGESIZE 14

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/trace_run_details.sql
-- Author       : Tim Hall
-- Description  : Displays details of a specified trace run.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @trace_run_details.sql (runid)
-- Last Modified: 06/05/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET TRIMOUT ON

COLUMN runid FORMAT 99999
COLUMN event_seq FORMAT 99999
COLUMN event_unit_owner FORMAT A20
COLUMN event_unit FORMAT A20
COLUMN event_unit_kind FORMAT A20
COLUMN event_comment FORMAT A30

SELECT e.runid,
       e.event_seq,
       TO_CHAR(e.event_time, 'DD-MON-YYYY HH24:MI:SS') AS event_time,
       e.event_unit_owner,
       e.event_unit,
       e.event_unit_kind,
       e.proc_line,
       e.event_comment
FROM   plsql_trace_events e
WHERE  e.runid = &1
ORDER BY e.runid, e.event_seq;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/trace_runs.sql
-- Author       : Tim Hall
-- Description  : Displays information on all trace runs.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @trace_runs.sql
-- Last Modified: 06/05/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET TRIMOUT ON

COLUMN runid FORMAT 99999

SELECT runid,
       run_date,
       run_owner
FROM   plsql_trace_runs
ORDER BY runid;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/ts_datafiles.sql
-- Author       : Tim Hall
-- Description  : Displays information about datafiles for the specified tablespace.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @ts_datafiles (tablespace-name)
-- Last Modified: 17-AUG-2005
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN file_name FORMAT A70

SELECT file_id,
       file_name,
       ROUND(bytes/1024/1024/1024) AS size_gb,
       ROUND(maxbytes/1024/1024/1024) AS max_size_gb,
       autoextensible,
       increment_by,
       status
FROM   dba_data_files
WHERE  tablespace_name = UPPER('&1')
ORDER BY file_id;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/ts_extent_map.sql
-- Author       : Tim Hall
-- Description  : Displays gaps (empty space) in a tablespace or specific datafile.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @ts_extent_map (tablespace-name) [all | file_id]
-- Last Modified: 25/01/2003
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON SIZE 1000000
SET FEEDBACK OFF
SET TRIMOUT ON
SET VERIFY OFF

DECLARE
  l_tablespace_name VARCHAR2(30) := UPPER('&1');
  l_file_id         VARCHAR2(30) := UPPER('&2');

  CURSOR c_extents IS
    SELECT owner,
           segment_name,
           file_id,
           block_id AS start_block,
           block_id + blocks - 1 AS end_block
    FROM   dba_extents
    WHERE  tablespace_name = l_tablespace_name
    AND    file_id = DECODE(l_file_id, 'ALL', file_id, TO_NUMBER(l_file_id))
    ORDER BY file_id, block_id;

  l_block_size     NUMBER  := 0;
  l_last_file_id   NUMBER  := 0;
  l_last_block_id  NUMBER  := 0;
  l_gaps_only      BOOLEAN := TRUE;
  l_total_blocks   NUMBER  := 0;
BEGIN
  SELECT block_size
  INTO   l_block_size
  FROM   dba_tablespaces
  WHERE  tablespace_name = l_tablespace_name;

  DBMS_OUTPUT.PUT_LINE('Tablespace Block Size (bytes): ' || l_block_size);
  FOR cur_rec IN c_extents LOOP
    IF cur_rec.file_id != l_last_file_id THEN
      l_last_file_id  := cur_rec.file_id;
      l_last_block_id := cur_rec.start_block - 1;
    END IF;
    
    IF cur_rec.start_block > l_last_block_id + 1 THEN
      DBMS_OUTPUT.PUT_LINE('*** GAP *** (' || l_last_block_id || ' -> ' || cur_rec.start_block || ')' ||
        ' FileID=' || cur_rec.file_id ||
        ' Blocks=' || (cur_rec.start_block-l_last_block_id-1) || 
        ' Size(MB)=' || ROUND(((cur_rec.start_block-l_last_block_id-1) * l_block_size)/1024/1024,2)
      );
      l_total_blocks := l_total_blocks + cur_rec.start_block - l_last_block_id-1;
    END IF;
    l_last_block_id := cur_rec.end_block;
    IF NOT l_gaps_only THEN
      DBMS_OUTPUT.PUT_LINE(RPAD(cur_rec.owner || '.' || cur_rec.segment_name, 40, ' ') ||
                           ' (' || cur_rec.start_block || ' -> ' || cur_rec.end_block || ')');
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE('Total Gap Blocks: ' || l_total_blocks);
  DBMS_OUTPUT.PUT_LINE('Total Gap Space (MB): ' || ROUND((l_total_blocks * l_block_size)/1024/1024,2));
END;
/

PROMPT
SET FEEDBACK ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/ts_free_space.sql
-- Author       : Tim Hall
-- Description  : Displays a list of tablespaces and their used/full status.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @ts_free_space.sql
-- Last Modified: 13-OCT-2012 - Created. Based on ts_full.sql
-- -----------------------------------------------------------------------------------
SET PAGESIZE 140
COLUMN used_pct FORMAT A11

SELECT tablespace_name,
       size_mb,
       free_mb,
       max_size_mb,
       max_free_mb,
       TRUNC((max_free_mb/max_size_mb) * 100) AS free_pct,
       RPAD(' '|| RPAD('X',ROUND((max_size_mb-max_free_mb)/max_size_mb*10,0), 'X'),11,'-') AS used_pct
FROM   (
        SELECT a.tablespace_name,
               b.size_mb,
               a.free_mb,
               b.max_size_mb,
               a.free_mb + (b.max_size_mb - b.size_mb) AS max_free_mb
        FROM   (SELECT tablespace_name,
                       TRUNC(SUM(bytes)/1024/1024) AS free_mb
                FROM   dba_free_space
                GROUP BY tablespace_name) a,
               (SELECT tablespace_name,
                       TRUNC(SUM(bytes)/1024/1024) AS size_mb,
                       TRUNC(SUM(GREATEST(bytes,maxbytes))/1024/1024) AS max_size_mb
                FROM   dba_data_files
                GROUP BY tablespace_name) b
        WHERE  a.tablespace_name = b.tablespace_name
       )
ORDER BY tablespace_name;

-- used in percent

  SELECT TABLESPACE_NAME,
         SIZE_MB,
         FREE_MB,
         MAX_SIZE_MB,
         MAX_FREE_MB,
         TRUNC ((MAX_FREE_MB / MAX_SIZE_MB) * 100)                    AS FREE_PCT,
         ROUND (((MAX_SIZE_MB - MAX_FREE_MB) / MAX_SIZE_MB) * 100)    AS USED_PCT
    FROM (SELECT A.TABLESPACE_NAME,
                 B.SIZE_MB,
                 A.FREE_MB,
                 B.MAX_SIZE_MB,
                 A.FREE_MB + (B.MAX_SIZE_MB - B.SIZE_MB)     AS MAX_FREE_MB
            FROM (  SELECT TABLESPACE_NAME,
                           TRUNC (SUM (BYTES) / 1024 / 1024)     AS FREE_MB
                      FROM DBA_FREE_SPACE
                  GROUP BY TABLESPACE_NAME) A,
                 (  SELECT TABLESPACE_NAME,
                           TRUNC (SUM (BYTES) / 1024 / 1024)                         AS SIZE_MB,
                           TRUNC (SUM (GREATEST (BYTES, MAXBYTES)) / 1024 / 1024)    AS MAX_SIZE_MB
                      FROM DBA_DATA_FILES
                  GROUP BY TABLESPACE_NAME) B
           WHERE A.TABLESPACE_NAME = B.TABLESPACE_NAME)
ORDER BY TABLESPACE_NAME;

/* Formatted on 04/02/2015 12:05:45 (QP5 v5.227.12220.39754) */
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/ts_full.sql
-- Author       : Tim Hall
-- Description  : Displays a list of tablespaces that are nearly full.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @ts_full
-- Last Modified: 15-JUL-2000 - Created.
--                 13-OCT-2012 - Included support FOR AUTO-EXTEND AND maxsize.
-- -----------------------------------------------------------------------------------
SET PAGESIZE 100

PROMPT Tablespaces nearing 0% free
PROMPT ***************************

SELECT tablespace_name,
       size_mb,
       free_mb,
       max_size_mb,
       max_free_mb,
       TRUNC ( (max_free_mb / max_size_mb) * 100) AS free_pct
  FROM (SELECT a.tablespace_name,
               b.size_mb,
               a.free_mb,
               b.max_size_mb,
               a.free_mb + (b.max_size_mb - b.size_mb) AS max_free_mb
          FROM (  SELECT tablespace_name,
                         TRUNC (SUM (bytes) / 1024 / 1024) AS free_mb
                    FROM dba_free_space
                GROUP BY tablespace_name) a,
               (  SELECT tablespace_name,
                         TRUNC (SUM (bytes) / 1024 / 1024) AS size_mb,
                         TRUNC (SUM (GREATEST (bytes, maxbytes)) / 1024 / 1024)
                            AS max_size_mb
                    FROM dba_data_files
                GROUP BY tablespace_name) b
         WHERE a.tablespace_name = b.tablespace_name)
 WHERE ROUND ( (max_free_mb / max_size_mb) * 100, 2) < 5;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/ts_thresholds.sql
-- Author       : Tim Hall
-- Description  : Displays threshold information for tablespaces.
-- Call Syntax  : @ts_thresholds
-- Last Modified: 13/02/2014 - Created
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN metrics_name FORMAT A30
COLUMN warning_value FORMAT A30
COLUMN critical_value FORMAT A15

SELECT tablespace_name,
       contents,
       extent_management,
       threshold_type,
       metrics_name,
       warning_operator,
       warning_value,
       critical_operator,
       critical_value
FROM   dba_tablespace_thresholds
ORDER BY tablespace_name;

SET LINESIZE 80

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/ts_thresholds_reset.sql
-- Author       : Tim Hall
-- Description  : Displays threshold information for tablespaces.
-- Call Syntax  : @ts_thresholds_reset (warning) (critical)
--                @ts_thresholds_reset NULL NULL    -- To reset to defaults
-- Last Modified: 13/02/2014 - Created
-- -----------------------------------------------------------------------------------
SET VERIFY OFF

DECLARE
  g_warning_value      VARCHAR2(4) := '&1';
  g_warning_operator   VARCHAR2(4) := DBMS_SERVER_ALERT.OPERATOR_GE;
  g_critical_value     VARCHAR2(4) := '&2';
  g_critical_operator  VARCHAR2(4) := DBMS_SERVER_ALERT.OPERATOR_GE;

  PROCEDURE set_threshold(p_ts_name  IN VARCHAR2) AS
  BEGIN
    DBMS_SERVER_ALERT.SET_THRESHOLD(
      metrics_id              => DBMS_SERVER_ALERT.TABLESPACE_PCT_FULL,
      warning_operator        => g_warning_operator,
      warning_value           => g_warning_value,
      critical_operator       => g_critical_operator,
      critical_value          => g_critical_value,
      observation_period      => 1,
      consecutive_occurrences => 1,
      instance_name           => NULL,
      object_type             => DBMS_SERVER_ALERT.OBJECT_TYPE_TABLESPACE,
      object_name             => p_ts_name);
  END;
BEGIN
  IF g_warning_value  = 'NULL' THEN
    g_warning_value    := NULL;
    g_warning_operator := NULL;
  END IF;
  IF g_critical_value = 'NULL' THEN
    g_critical_value    := NULL;
    g_critical_operator := NULL;
  END IF;

  FOR cur_ts IN (SELECT tablespace_name
                 FROM   dba_tablespace_thresholds
                 WHERE  warning_operator != 'DO NOT CHECK'
                 AND    extent_management = 'LOCAL')
  LOOP
    set_threshold(cur_ts.tablespace_name);
  END LOOP;
END;
/

SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/ts_thresholds_set_default.sql
-- Author       : Tim Hall
-- Description  : Displays threshold information for tablespaces.
-- Call Syntax  : @ts_thresholds_set_default (warning) (critical)
-- Last Modified: 13/02/2014 - Created
-- -----------------------------------------------------------------------------------
SET VERIFY OFF

DECLARE
  l_warning  VARCHAR2(2) := '&1';
  l_critical VARCHAR2(2) := '&2';
BEGIN
    DBMS_SERVER_ALERT.SET_THRESHOLD(
      metrics_id              => DBMS_SERVER_ALERT.TABLESPACE_PCT_FULL,
      warning_operator        => DBMS_SERVER_ALERT.OPERATOR_GE,
      warning_value           => l_warning,
      critical_operator       => DBMS_SERVER_ALERT.OPERATOR_GE,
      critical_value          => l_critical,
      observation_period      => 1,
      consecutive_occurrences => 1,
      instance_name           => NULL,
      object_type             => DBMS_SERVER_ALERT.OBJECT_TYPE_TABLESPACE,
      object_name             => NULL);
END;
/

SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/tuning.sql
-- Author       : Tim Hall
-- Description  : Displays several performance indicators and comments on the value.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @tuning
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 1000
SET FEEDBACK OFF

SELECT *
FROM   v$database;
PROMPT

DECLARE
  v_value  NUMBER;

  FUNCTION Format(p_value  IN  NUMBER) 
    RETURN VARCHAR2 IS
  BEGIN
    RETURN LPad(To_Char(Round(p_value,2),'990.00') || '%',8,' ') || '  ';
  END;

BEGIN

  -- --------------------------
  -- Dictionary Cache Hit Ratio
  -- --------------------------
  SELECT (1 - (Sum(getmisses)/(Sum(gets) + Sum(getmisses)))) * 100
  INTO   v_value
  FROM   v$rowcache;

  DBMS_Output.Put('Dictionary Cache Hit Ratio       : ' || Format(v_value));
  IF v_value < 5 THEN
    DBMS_Output.Put_Line('Increase SORT_AREA_SIZE parameter to bring value below 5%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');  
  END IF;
  
  -- ----------------------
  -- Rollback Segment Waits
  -- ----------------------
  SELECT (Sum(waits) / Sum(gets)) * 100
  INTO   v_value
  FROM   v$rollstat;

  DBMS_Output.Put('Rollback Segment Waits           : ' || Format(v_value));
  IF v_value > 5 THEN
    DBMS_Output.Put_Line('Increase number of Rollback Segments to bring the value below 5%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;

  -- -------------------
  -- Dispatcher Workload
  -- -------------------
  SELECT NVL((Sum(busy) / (Sum(busy) + Sum(idle))) * 100,0)
  INTO   v_value
  FROM   v$dispatcher;

  DBMS_Output.Put('Dispatcher Workload              : ' || Format(v_value));
  IF v_value > 50 THEN
    DBMS_Output.Put_Line('Increase MTS_DISPATCHERS to bring the value below 50%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;
  
END;
/

PROMPT
SET FEEDBACK ON
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/unusable_indexes.sql
-- Author       : Tim Hall
-- Description  : Displays unusable indexes for the specified schema or all schemas.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @unusable_indexes (schema-name or all)
-- Last Modified: 05/11/2004
-- -----------------------------------------------------------------------------------
SET VERIFY OFF

SELECT owner,
       index_name
FROM   dba_indexes
WHERE  owner = DECODE(UPPER('&1'), 'ALL', owner, UPPER('&1'))
AND    status NOT IN ('VALID', 'N/A')
ORDER BY owner, index_name;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/unused_space.sql
-- Author       : Tim Hall
-- Description  : Displays unused space for each segment.
-- Requirements : Access to the DBMS_SPACE package.
-- Call Syntax  : @unused_space (segment_owner) (segment_name) (segment_type) (partition_name OR NA)
-- Last Modified: 16/05/2001
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET VERIFY OFF
DECLARE
  v_partition_name            VARCHAR2(30) := UPPER('&4');
  v_total_blocks              NUMBER;
  v_total_bytes               NUMBER;
  v_unused_blocks             NUMBER;
  v_unused_bytes              NUMBER;
  v_last_used_extent_file_id  NUMBER;
  v_last_used_extent_block_id NUMBER;
  v_last_used_block           NUMBER;
BEGIN
  IF v_partition_name != 'NA' THEN
    DBMS_SPACE.UNUSED_SPACE (segment_owner              => UPPER('&1'), 
                             segment_name               => UPPER('&2'),
                             segment_type               => UPPER('&3'),
                             total_blocks               => v_total_blocks,
                             total_bytes                => v_total_bytes,
                             unused_blocks              => v_unused_blocks,
                             unused_bytes               => v_unused_bytes,
                             last_used_extent_file_id   => v_last_used_extent_file_id,
                             last_used_extent_block_id  => v_last_used_extent_block_id,
                             last_used_block            => v_last_used_block,
                             partition_name             => v_partition_name);
  ELSE
    DBMS_SPACE.UNUSED_SPACE (segment_owner              => UPPER('&1'), 
                             segment_name               => UPPER('&2'),
                             segment_type               => UPPER('&3'),
                             total_blocks               => v_total_blocks,
                             total_bytes                => v_total_bytes,
                             unused_blocks              => v_unused_blocks,
                             unused_bytes               => v_unused_bytes,
                             last_used_extent_file_id   => v_last_used_extent_file_id,
                             last_used_extent_block_id  => v_last_used_extent_block_id,
                             last_used_block            => v_last_used_block);
  END IF;

  DBMS_OUTPUT.PUT_LINE('v_total_blocks              :' || v_total_blocks);
  DBMS_OUTPUT.PUT_LINE('v_total_bytes               :' || v_total_bytes);
  DBMS_OUTPUT.PUT_LINE('v_unused_blocks             :' || v_unused_blocks);
  DBMS_OUTPUT.PUT_LINE('v_unused_bytes              :' || v_unused_bytes);
  DBMS_OUTPUT.PUT_LINE('v_last_used_extent_file_id  :' || v_last_used_extent_file_id);
  DBMS_OUTPUT.PUT_LINE('v_last_used_extent_block_id :' || v_last_used_extent_block_id);
  DBMS_OUTPUT.PUT_LINE('v_last_used_block           :' || v_last_used_block);
END;
/

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/user_hit_ratio.sql
-- Author       : Tim Hall
-- Description  : Displays the Cache Hit Ratio per user.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @user_hit_ratio
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
COLUMN "Hit Ratio %" FORMAT 999.99

SELECT a.username "Username",
       b.consistent_gets "Consistent Gets",
       b.block_gets "DB Block Gets",
       b.physical_reads "Physical Reads",
       Round(100* (b.consistent_gets + b.block_gets - b.physical_reads) /
       (b.consistent_gets + b.block_gets),2) "Hit Ratio %"
FROM   v$session a,
       v$sess_io b
WHERE  a.sid = b.sid
AND    (b.consistent_gets + b.block_gets) > 0
AND    a.username IS NOT NULL;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/user_roles.sql
-- Author       : Tim Hall
-- Description  : Displays a list of all roles and privileges granted to the specified user.
-- Requirements : Access to the USER views.
-- Call Syntax  : @user_roles
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET VERIFY OFF

SELECT a.granted_role,
       a.admin_option
FROM   user_role_privs a
ORDER BY a.granted_role;

SELECT a.privilege,
       a.admin_option
FROM   user_sys_privs a
ORDER BY a.privilege;
               
SET VERIFY ON
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/user_system_privs.sql
-- Author       : Tim Hall
-- Description  : Displays system privileges granted to a specified user.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_system_privs (user-name)
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200 VERIFY OFF

SELECT grantee,
       privilege,
       admin_option
FROM   dba_sys_privs
WHERE  grantee = UPPER('&1')
ORDER BY grantee, privilege;

SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/user_temp_space.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays the temp space currently in use by users.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @user_temp_space
-- Last Modified: 12/02/2004
-- -----------------------------------------------------------------------------------

COLUMN tablespace FORMAT A20
COLUMN temp_size FORMAT A20
COLUMN sid_serial FORMAT A20
COLUMN username FORMAT A20
COLUMN program FORMAT A40
SET LINESIZE 200

SELECT b.tablespace,
       ROUND(((b.blocks*p.value)/1024/1024),2)||'M' AS temp_size,
       a.sid||','||a.serial# AS sid_serial,
       NVL(a.username, '(oracle)') AS username,
       a.program
FROM   v$session a,
       v$sort_usage b,
       v$parameter p
WHERE  p.name  = 'db_block_size'
AND    a.saddr = b.session_addr
ORDER BY b.tablespace, b.blocks;
  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/user_undo_space.sql
-- Author       : Tim Hall
-- Description  : Displays the undo space currently in use by users.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @user_undo_space
-- Last Modified: 12/02/2004
-- -----------------------------------------------------------------------------------

COLUMN sid_serial FORMAT A20
COLUMN username FORMAT A20
COLUMN program FORMAT A30
COLUMN undoseg FORMAT A25
COLUMN undo FORMAT A20
SET LINESIZE 120

SELECT TO_CHAR(s.sid)||','||TO_CHAR(s.serial#) AS sid_serial,
       NVL(s.username, '(oracle)') AS username,
       s.program,
       r.name undoseg,
       t.used_ublk * TO_NUMBER(x.value)/1024||'K' AS undo
FROM   v$rollname    r,
       v$session     s,
       v$transaction t,
       v$parameter   x
WHERE  s.taddr = t.addr
AND    r.usn   = t.xidusn(+)
AND    x.name  = 'db_block_size';


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/users.sql
-- Author       : Tim Hall
-- Description  : Displays information about all database users.
-- Requirements : Access to the dba_users view.
-- Call Syntax  : @users [ username | % (for all)]
-- Last Modified: 21-FEB-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200 VERIFY OFF

COLUMN username FORMAT A20
COLUMN account_status FORMAT A16
COLUMN default_tablespace FORMAT A15
COLUMN temporary_tablespace FORMAT A15
COLUMN profile FORMAT A15

SELECT username,
       account_status,
       TO_CHAR(lock_date, 'DD-MON-YYYY') AS lock_date,
       TO_CHAR(expiry_date, 'DD-MON-YYYY') AS expiry_date,
       default_tablespace,
       temporary_tablespace,
       TO_CHAR(created, 'DD-MON-YYYY') AS created,
       profile,
       initial_rsrc_consumer_group,
       editions_enabled,
       authentication_type
FROM   dba_users
WHERE  username LIKE UPPER('%&1%')
ORDER BY username;

SET VERIFY ON
  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/users_with_role.sql
-- Author       : Tim Hall
-- Description  : Displays a list of users granted the specified role.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @user_with_role DBA
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------

SET VERIFY OFF

SELECT username,
       lock_date,
       expiry_date
FROM   dba_users
WHERE  username IN (SELECT grantee
                    FROM   dba_role_privs
                    WHERE  granted_role = UPPER('&1'))
ORDER BY username;

SET VERIFY ON
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/users_with_sys_priv.sql
-- Author       : Tim Hall
-- Description  : Displays a list of users granted the specified role.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @users_with_sys_priv "UNLIMITED TABLESPACE"
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------

SET VERIFY OFF

SELECT username,
       lock_date,
       expiry_date
FROM   dba_users
WHERE  username IN (SELECT grantee
                    FROM   dba_sys_privs
                    WHERE  privilege = UPPER('&1'))
ORDER BY username;

    
10g

  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/active_session_waits.sql
-- Author       : Tim Hall
-- Description  : Displays information on the current wait states for all active database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @active_session_waits
-- Last Modified: 21/12/2004
-- -----------------------------------------------------------------------------------
SET LINESIZE 250
SET PAGESIZE 1000

COLUMN username FORMAT A15
COLUMN osuser FORMAT A15
COLUMN sid FORMAT 99999
COLUMN serial# FORMAT 9999999
COLUMN wait_class FORMAT A15
COLUMN state FORMAT A19
COLUMN logon_time FORMAT A20

SELECT NVL(a.username, 'oracle') AS username,
       a.osuser,
       a.sid,
       a.serial#,
       d.spid AS process_id,
       a.wait_class,
       a.seconds_in_wait,
       a.state,
       a.blocking_session,
       a.blocking_session_status,
       a.module,
       TO_CHAR(a.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
FROM   v$session a,
       v$process d
WHERE  a.paddr  = d.addr
AND    a.status = 'ACTIVE'
ORDER BY 1,2;

SET PAGESIZE 14
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/ash.sql
-- Author       : Tim Hall
-- Description  : Displays the minutes spent on each event for the specified time.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @active_session_waits (mins)
-- Last Modified: 21/12/2004
-- -----------------------------------------------------------------------------------

SET VERIFY OFF

  SELECT NVL (a.event, 'ON CPU') AS event, COUNT (*) AS total_wait_time
    FROM v$active_session_history a
   WHERE a.sample_time > SYSDATE - &1 / (24 * 60)
GROUP BY a.event
ORDER BY total_wait_time DESC;

SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/db_usage_hwm.sql
-- Author       : Tim Hall
-- Description  : Displays high water mark statistics.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @db_usage_hwm
-- Last Modified: 26-NOV-2004
-- -----------------------------------------------------------------------------------

COLUMN name  FORMAT A40
COLUMN highwater FORMAT 999999999999
COLUMN last_value FORMAT 999999999999
SET PAGESIZE 24

SELECT hwm1.name,
       hwm1.highwater,
       hwm1.last_value
FROM   dba_high_water_mark_statistics hwm1
WHERE  hwm1.version = (SELECT MAX(hwm2.version)
                       FROM   dba_high_water_mark_statistics hwm2
                       WHERE  hwm2.name = hwm1.name)
ORDER BY hwm1.name;

COLUMN FORMAT DEFAULT

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/event_histogram.sql
-- Author       : Tim Hall
-- Description  : Displays histogram of the event waits times.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @event_histogram "(event-name)"
-- Last Modified: 08-NOV-2005
-- -----------------------------------------------------------------------------------

SET VERIFY OFF
COLUMN event FORMAT A30

SELECT event#,
       event,
       wait_time_milli,
       wait_count
FROM   v$event_histogram
WHERE  event LIKE '%&1%'
ORDER BY event, wait_time_milli;

COLUMN FORMAT DEFAULT
SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/feature_usage.sql
-- Author       : Tim Hall
-- Description  : Displays feature usage statistics.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @feature_usage
-- Last Modified: 26-NOV-2004
-- -----------------------------------------------------------------------------------

COLUMN name  FORMAT A60
COLUMN detected_usages FORMAT 999999999999

  SELECT u1.name,
         u1.detected_usages,
         u1.currently_used,
         u1.version
    FROM dba_feature_usage_statistics u1
   WHERE     u1.version = (SELECT MAX (u2.version)
                             FROM dba_feature_usage_statistics u2
                            WHERE u2.name = u1.name)
         AND u1.detected_usages > 0
         AND u1.dbid = (SELECT dbid FROM v$database)
ORDER BY u1.name;

COLUMN FORMAT DEFAULT

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/flashback_db_info.sql
-- Author       : Tim Hall
-- Description  : Displays information relevant to flashback database.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @flashback_db_info
-- Last Modified: 21/12/2004
-- -----------------------------------------------------------------------------------
PROMPT Flashback Status
PROMPT ================
select flashback_on from v$database;

PROMPT Flashback Parameters
PROMPT ====================

column name format A30
column value format A50
select name, value
from   v$parameter
where  name in ('db_flashback_retention_target', 'db_recovery_file_dest','db_recovery_file_dest_size')
order by name;

PROMPT Flashback Restore Points
PROMPT ========================

select * from v$restore_point;

PROMPT Flashback Logs
PROMPT ==============

select * from v$flashback_database_log;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/job_chain_rules.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information about job chain rules.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_chain_rules
-- Last Modified: 26/10/2011
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
COLUMN owner FORMAT A10
COLUMN chain_name FORMAT A15
COLUMN rule_owner FORMAT A10
COLUMN rule_name FORMAT A15
COLUMN condition FORMAT A25
COLUMN action FORMAT A20
COLUMN comments FORMAT A25

SELECT owner,
       chain_name,
       rule_owner,
       rule_name,
       condition,
       action,
       comments
FROM   dba_scheduler_chain_rules
ORDER BY owner, chain_name, rule_owner, rule_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/job_chain_steps.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information about job chain steps.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_chain_steps
-- Last Modified: 26/10/2011
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
COLUMN owner FORMAT A10
COLUMN chain_name FORMAT A15
COLUMN step_name FORMAT A15
COLUMN program_owner FORMAT A10
COLUMN program_name FORMAT A15

SELECT owner,
       chain_name,
       step_name,
       program_owner,
       program_name,
       step_type
FROM   dba_scheduler_chain_steps
ORDER BY owner, chain_name, step_name;
     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/job_chains.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information about job chains.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_chains
-- Last Modified: 26/10/2011
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
COLUMN owner FORMAT A10
COLUMN chain_name FORMAT A15
COLUMN rule_set_owner FORMAT A10
COLUMN rule_set_name FORMAT A15
COLUMN comments FORMAT A15

SELECT owner,
       chain_name,
       rule_set_owner,
       rule_set_name,
       number_of_rules,
       number_of_steps,
       enabled,
       comments
  FROM dba_scheduler_chains;
  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/job_classes.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information about job classes.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_classes
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN service FORMAT A20
COLUMN comments FORMAT A40

  SELECT job_class_name,
         resource_consumer_group,
         service,
         logging_level,
         log_history,
         comments
    FROM dba_scheduler_job_classes
ORDER BY job_class_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/job_programs.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information about job programs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_programs
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 250

COLUMN owner FORMAT A20
COLUMN program_name FORMAT A30
COLUMN program_action FORMAT A50
COLUMN comments FORMAT A40

  SELECT owner,
         program_name,
         program_type,
         program_action,
         number_of_arguments,
         enabled,
         comments
    FROM dba_scheduler_programs
ORDER BY owner, program_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/job_running_chains.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information about job running chains.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_running_chains.sql
-- Last Modified: 26/10/2011
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
COLUMN owner FORMAT A10
COLUMN job_name FORMAT A20
COLUMN chain_owner FORMAT A10
COLUMN chain_name FORMAT A15
COLUMN step_name FORMAT A25

SELECT owner,
       job_name,
       chain_owner,
       chain_name,
       step_name,
       state
FROM   dba_scheduler_running_chains
ORDER BY owner, job_name, chain_name, step_name;



  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/job_schedules.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information about job schedules.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_schedules
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 250

COLUMN owner FORMAT A20
COLUMN schedule_name FORMAT A30
COLUMN start_date FORMAT A35
COLUMN repeat_interval FORMAT A50
COLUMN end_date FORMAT A35
COLUMN comments FORMAT A40

SELECT owner,
       schedule_name,
       start_date,
       repeat_interval,
       end_date,
       comments
FROM   dba_scheduler_schedules
ORDER BY owner, schedule_name;

  
    -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/jobs.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler job information.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @jobs
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN owner FORMAT A20
COLUMN next_run_date FORMAT A35

  SELECT owner,
         job_name,
         enabled,
         job_class,
         next_run_date
    FROM dba_scheduler_jobs
ORDER BY owner, job_name;
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/jobs_running.sql
-- Author       : Tim Hall
-- Description  : Displays information about all jobs currently running.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @jobs_running
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

SELECT a.job "Job",
       a.sid,
       a.failures "Failures",       
       Substr(To_Char(a.last_date,'DD-Mon-YYYY HH24:MI:SS'),1,20) "Last Date",      
       Substr(To_Char(a.this_date,'DD-Mon-YYYY HH24:MI:SS'),1,20) "This Date"             
FROM   dba_jobs_running a;

SET PAGESIZE 14
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/lock_tree.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays information on all database sessions with the username
--                column displayed as a heirarchy if locks are present.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @lock_tree
-- Last Modified: 18-MAY-2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000

COLUMN username FORMAT A30
COLUMN osuser FORMAT A10
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20

SELECT level,
       LPAD(' ', (level-1)*2, ' ') || NVL(s.username, '(oracle)') AS username,
       s.osuser,
       s.sid,
       s.serial#,
       s.lockwait,
       s.status,
       s.module,
       s.machine,
       s.program,
       TO_CHAR(s.logon_Time,'DD-MON-YYYY HH24:MI:SS') AS logon_time
FROM   v$session s
WHERE  level > 1
OR     EXISTS (SELECT 1
               FROM   v$session
               WHERE  blocking_session = s.sid)
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL;

SET PAGESIZE 14

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/segment_advisor.sql
-- Author       : Tim Hall
-- Description  : Displays segment advice for the specified segment.
-- Requirements : Access to the DBMS_ADVISOR package.
-- Call Syntax  : Object-type = "tablespace":
--                  @segment_advisor.sql tablespace (tablespace-name) null
--                Object-type = "table" or "index":
--                  @segment_advisor.sql (object-type) (object-owner) (object-name)
-- Last Modified: 08-APR-2005
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON SIZE 1000000
SET LINESIZE 200
SET VERIFY OFF

DECLARE
  l_object_id     NUMBER;
  l_task_name     VARCHAR2(32767) := 'SEGMENT_ADVISOR_TASK';
  l_object_type   VARCHAR2(32767) := UPPER('&1');
  l_attr1         VARCHAR2(32767) := UPPER('&2');
  l_attr2         VARCHAR2(32767) := UPPER('&3');
BEGIN
  IF l_attr2 = 'NULL' THEN
    l_attr2 := NULL;
  END IF;

  DBMS_ADVISOR.create_task (
    advisor_name      => 'Segment Advisor',
    task_name         => l_task_name);

  DBMS_ADVISOR.create_object (
    task_name   => l_task_name,
    object_type => l_object_type,
    attr1       => l_attr1,
    attr2       => l_attr2,
    attr3       => NULL,
    attr4       => 'null',
    attr5       => NULL,
    object_id   => l_object_id);

  DBMS_ADVISOR.set_task_parameter (
    task_name => l_task_name,
    parameter => 'RECOMMEND_ALL',
    value     => 'TRUE');

  DBMS_ADVISOR.execute_task(task_name => l_task_name);


  FOR cur_rec IN (SELECT f.impact,
                         o.type,
                         o.attr1,
                         o.attr2,
                         f.message,
                         f.more_info
                  FROM   dba_advisor_findings f
                         JOIN dba_advisor_objects o ON f.object_id = o.object_id AND f.task_name = o.task_name
                  WHERE  f.task_name = l_task_name
                  ORDER BY f.impact DESC)
  LOOP
    DBMS_OUTPUT.put_line('..');
    DBMS_OUTPUT.put_line('Type             : ' || cur_rec.type);
    DBMS_OUTPUT.put_line('Attr1            : ' || cur_rec.attr1);
    DBMS_OUTPUT.put_line('Attr2            : ' || cur_rec.attr2);
    DBMS_OUTPUT.put_line('Message          : ' || cur_rec.message);
    DBMS_OUTPUT.put_line('More info        : ' || cur_rec.more_info);
  END LOOP;

  DBMS_ADVISOR.delete_task(task_name => l_task_name);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('Error            : ' || DBMS_UTILITY.format_error_backtrace);
    DBMS_ADVISOR.delete_task(task_name => l_task_name);
END;
/
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/services.sql
-- Author       : Tim Hall
-- Description  : Displays information about database services.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @services
-- Last Modified: 05/11/2004
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
COLUMN name FORMAT A30
COLUMN network_name FORMAT A50

SELECT name,
       network_name
FROM   dba_services
ORDER BY name;
     
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/session_waits.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database session waits.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_waits
-- Last Modified: 11/03/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000

COLUMN username FORMAT A20
COLUMN event FORMAT A30

  SELECT NVL (s.username, '(oracle)') AS username,
         s.sid,
         s.serial#,
         sw.event,
         sw.wait_time,
         sw.seconds_in_wait,
         sw.state
    FROM v$session_wait sw, v$session s
   WHERE s.sid = sw.sid
ORDER BY sw.seconds_in_wait DESC;

-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/10g/sga_buffers.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays the status of buffers in the SGA.
-- Requirements : Access to the v$ and DBA views.
-- Call Syntax  : @sga_buffers
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
COLUMN object_name FORMAT A30

SELECT t.name AS tablespace_name,
       o.object_name,
       SUM(DECODE(bh.status, 'free', 1, 0)) AS free,
       SUM(DECODE(bh.status, 'xcur', 1, 0)) AS xcur,
       SUM(DECODE(bh.status, 'scur', 1, 0)) AS scur,
       SUM(DECODE(bh.status, 'cr', 1, 0)) AS cr,
       SUM(DECODE(bh.status, 'read', 1, 0)) AS read,
       SUM(DECODE(bh.status, 'mrec', 1, 0)) AS mrec,
       SUM(DECODE(bh.status, 'irec', 1, 0)) AS irec
FROM   v$bh bh
       JOIN dba_objects o ON o.object_id = bh.objd
       JOIN v$tablespace t ON t.ts# = bh.ts#
GROUP BY t.name, o.object_name;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/sga_dynamic_components.sql
-- Author       : Tim Hall
-- Description  : Provides information about dynamic SGA components.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @sga_dynamic_components
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------
COLUMN component FORMAT A30

  SELECT component,
         ROUND (current_size / 1024 / 1204) AS current_size_mb,
         ROUND (min_size / 1024 / 1204) AS min_size_mb,
         ROUND (max_size / 1024 / 1204) AS max_size_mb
    FROM v$sga_dynamic_components
   WHERE current_size != 0
ORDER BY component;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/sga_dynamic_free_memory.sql
-- Author       : Tim Hall
-- Description  : Provides information about free memory in the SGA.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @sga_dynamic_free_memory
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------

SELECT *
FROM   v$sga_dynamic_free_memory;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/sga_resize_ops.sql
-- Author       : Tim Hall
-- Description  : Provides information about memory resize operations.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @sga_resize_ops
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------

SET LINESIZE 200

COLUMN parameter FORMAT A25

SELECT start_time,
       end_time,
       component,
       oper_type,
       oper_mode,
       parameter,
       ROUND(initial_size/1024/1204) AS initial_size_mb,
       ROUND(target_size/1024/1204) AS target_size_mb,
       ROUND(final_size/1024/1204) AS final_size_mb,
       status
FROM   v$sga_resize_ops
ORDER BY start_time;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/sysaux_occupants.sql
-- Author       : Tim Hall
-- Description  : Displays information about the contents of the SYSAUX tablespace.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @sysaux_occupants
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------
COLUMN occupant_name FORMAT A30
COLUMN schema_name FORMAT A20

  SELECT occupant_name, schema_name, space_usage_kbytes
    FROM v$sysaux_occupants
ORDER BY 3 DESC, occupant_name;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/test_calendar_string.sql
-- Author       : Tim Hall
-- Description  : Displays the schedule associated with a calendar string.
-- Requirements : Access to the DBMS_SCHEDULER package.
-- Call Syntax  : @test_calendar_string (frequency) (interations)
--                @test_calendar_string 'freq=hourly; byminute=0,30; bysecond=0;' 5
-- Last Modified: 27/07/2005
-- -----------------------------------------------------------------------------------

SET SERVEROUTPUT ON;
SET VERIFY OFF
ALTER SESSION SET nls_timestamp_format = 'DD-MON-YYYY HH24:MI:SS';

DECLARE
  l_calendar_string  VARCHAR2(100) := '&1';
  l_iterations       NUMBER        := &2;

  l_start_date         TIMESTAMP := TO_TIMESTAMP('01-JAN-2004 03:04:32',
                                                 'DD-MON-YYYY HH24:MI:SS');
  l_return_date_after  TIMESTAMP := l_start_date;
  l_next_run_date      TIMESTAMP;
BEGIN
  FOR i IN 1 .. l_iterations LOOP
    DBMS_SCHEDULER.evaluate_calendar_string(  
      calendar_string   => l_calendar_string,
      start_date        => l_start_date,
      return_date_after => l_return_date_after,
      next_run_date     => l_next_run_date);
    
    DBMS_OUTPUT.put_line('Next Run Date: ' || l_next_run_date);
    l_return_date_after := l_next_run_date;
  END LOOP;
END;
/

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/window_groups.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information about window groups.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @window_groups
-- Last Modified: 05/11/2004
-- -----------------------------------------------------------------------------------
SET LINESIZE 250

COLUMN comments FORMAT A40

SELECT window_group_name,
       enabled,
       number_of_windows,
       comments
FROM   dba_scheduler_window_groups
ORDER BY window_group_name;

SELECT window_group_name,
       window_name
FROM   dba_scheduler_wingroup_members
ORDER BY window_group_name, window_name;  
  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/windows.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information about windows.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @windows
-- Last Modified: 05/11/2004
-- -----------------------------------------------------------------------------------
SET LINESIZE 250

COLUMN comments FORMAT A40

SELECT window_name,
       resource_plan,
       enabled,
       active,
       comments
FROM   dba_scheduler_windows
ORDER BY window_name;

    
11g

 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/diag_info.sql
-- Author       : Tim Hall
-- Description  : Displays the contents of the v$diag_info view.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @diag_info
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
COLUMN name FORMAT A30
COLUMN value FORMAT A110

SELECT * FROM v$diag_info;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/extended_stats.sql
-- Author       : Tim Hall
-- Description  : Provides information about extended statistics.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @extended_stats
-- Last Modified: 30/11/2011
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
COLUMN owner FORMAT A20
COLUMN extension_name FORMAT A15
COLUMN extension FORMAT A50

  SELECT owner,
         table_name,
         extension_name,
         extension
    FROM dba_stat_extensions
ORDER BY owner, table_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/fda.sql
-- Author       : Tim Hall
-- Description  : Displays information about flashback data archives.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @fda
-- Last Modified: 06-JAN-2015
-- -----------------------------------------------------------------------------------

SET LINESIZE 150

COLUMN owner_name FORMAT A20
COLUMN flashback_archive_name FORMAT A22
COLUMN create_time FORMAT A20
COLUMN last_purge_time FORMAT A20

SELECT owner_name,
       flashback_archive_name,
       flashback_archive#,
       retention_in_days,
       TO_CHAR(create_time, 'DD-MON-YYYY HH24:MI:SS') AS create_time,
       TO_CHAR(last_purge_time, 'DD-MON-YYYY HH24:MI:SS') AS last_purge_time,
       status
FROM   dba_flashback_archive
ORDER BY owner_name, flashback_archive_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/fda_tables.sql
-- Author       : Tim Hall
-- Description  : Displays information about flashback data archives.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @fda_tables
-- Last Modified: 06-JAN-2015
-- -----------------------------------------------------------------------------------

SET LINESIZE 150

COLUMN owner_name FORMAT A20
COLUMN table_name FORMAT A20
COLUMN flashback_archive_name FORMAT A22
COLUMN archive_table_name FORMAT A20

SELECT owner_name,
       table_name,
       flashback_archive_name,
       archive_table_name,
       status
FROM   dba_flashback_archive_tables
ORDER BY owner_name, table_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/fda_ts.sql
-- Author       : Tim Hall
-- Description  : Displays information about flashback data archives.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @fda_ts
-- Last Modified: 06-JAN-2015
-- -----------------------------------------------------------------------------------

SET LINESIZE 150

COLUMN flashback_archive_name FORMAT A22
COLUMN tablespace_name FORMAT A20
COLUMN quota_in_mb FORMAT A11

SELECT flashback_archive_name,
       flashback_archive#,
       tablespace_name,
       quota_in_mb
FROM   dba_flashback_archive_ts
ORDER BY flashback_archive_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/identify_trace_file.sql
-- Author       : Tim Hall
-- Description  : Displays the name of the trace file associated with the current session.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @identify_trace_file
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------
SET LINESIZE 100
COLUMN value FORMAT A60

SELECT value
FROM   v$diag_info
WHERE  name = 'Default Trace File';

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/job_credentials.sql
-- Author       : Tim Hall
-- Description  : Displays scheduler information about job credentials.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_credentials
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------
COLUMN credential_name FORMAT A25
COLUMN username FORMAT A20
COLUMN windows_domain FORMAT A20

  SELECT credential_name, username, windows_domain
    FROM dba_scheduler_credentials
ORDER BY credential_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/job_output_file.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays scheduler job information for previous runs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_output_file (job-name) (credential-name)
-- Last Modified: 06/06/2014
-- -----------------------------------------------------------------------------------

SET VERIFY OFF

SET SERVEROUTPUT ON
DECLARE
  l_clob             CLOB;
  l_additional_info  VARCHAR2(4000);
  l_external_log_id  VARCHAR2(50);
BEGIN
  SELECT additional_info, external_log_id
  INTO   l_additional_info, l_external_log_id
  FROM   (SELECT log_id, 
                 additional_info,
                 REGEXP_SUBSTR(additional_info,'job[_0-9]*') AS external_log_id
          FROM   dba_scheduler_job_run_details
          WHERE  job_name = UPPER('&1')
          ORDER BY log_id DESC)
  WHERE  ROWNUM = 1;

  DBMS_OUTPUT.put_line('ADDITIONAL_INFO: ' || l_additional_info);
  DBMS_OUTPUT.put_line('EXTERNAL_LOG_ID: ' || l_external_log_id);

  DBMS_LOB.createtemporary(l_clob, FALSE);

  DBMS_SCHEDULER.get_file(
    source_file     => l_external_log_id ||'_stdout',
    credential_name => UPPER('&2'),
    file_contents   => l_clob,
    source_host     => NULL);

  DBMS_OUTPUT.put_line('stdout:');
  DBMS_OUTPUT.put_line(l_clob);
END;
/
     
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/job_run_details.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays scheduler job information for previous runs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @job_run_details (job-name | all)
-- Last Modified: 06/06/2014
-- -----------------------------------------------------------------------------------
SET LINESIZE 300 VERIFY OFF

COLUMN log_date FORMAT A35
COLUMN owner FORMAT A20
COLUMN job_name FORMAT A30
COLUMN error FORMAT A20
COLUMN req_start_date FORMAT A35
COLUMN actual_start_date FORMAT A35
COLUMN run_duration FORMAT A20
COLUMN credential_owner FORMAT A20
COLUMN credential_name FORMAT A20
COLUMN additional_info FORMAT A30

  SELECT log_date,
         owner,
         job_name,
         status error,
         req_start_date,
         actual_start_date,
         run_duration,
         credential_owner,
         credential_name,
         additional_info
    FROM dba_scheduler_job_run_details
   WHERE job_name = DECODE (UPPER ('&1'), 'ALL', job_name, UPPER ('&1'))
ORDER BY log_date;


-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/memory_dynamic_components.sql
-- Author       : Tim Hall
-- Description  : Provides information about dynamic memory components.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @memory_dynamic_components
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------
COLUMN component FORMAT A30

  SELECT component,
         ROUND (current_size / 1024 / 1204) AS current_size_mb,
         ROUND (min_size / 1024 / 1204) AS min_size_mb,
         ROUND (max_size / 1024 / 1204) AS max_size_mb
    FROM v$memory_dynamic_components
   WHERE current_size != 0
ORDER BY component;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/memory_resize_ops.sql
-- Author       : Tim Hall
-- Description  : Provides information about memory resize operations.
-- Requirements : Access to the v$ views.
-- Call Syntax  : @memory_resize_ops
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------

SET LINESIZE 200

COLUMN parameter FORMAT A25

SELECT start_time,
       end_time,
       component,
       oper_type,
       oper_mode,
       parameter,
       ROUND(initial_size/1024/1204) AS initial_size_mb,
       ROUND(target_size/1024/1204) AS target_size_mb,
       ROUND(final_size/1024/1204) AS final_size_mb,
       status
FROM   v$memory_resize_ops
ORDER BY start_time;


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/memory_target_advice.sql
-- Author       : Tim Hall
-- Description  : Provides information to help tune the MEMORY_TARGET parameter.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @memory_target_advice
-- Last Modified: 23/08/2008
-- -----------------------------------------------------------------------------------
SELECT *
FROM   v$memory_target_advice
ORDER BY memory_size;
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/network_acl_privileges.sql
-- Author       : Tim Hall
-- Description  : Displays privileges for the network ACLs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @network_acl_privileges
-- Last Modified: 30/11/2011
-- -----------------------------------------------------------------------------------
SET LINESIZE 150

COLUMN acl FORMAT A50
COLUMN principal FORMAT A20
COLUMN privilege FORMAT A10

  SELECT acl,
         principal,
         privilege,
         is_grant,
         TO_CHAR (start_date, 'DD-MON-YYYY') AS start_date,
         TO_CHAR (end_date, 'DD-MON-YYYY') AS end_date
    FROM dba_network_acl_privileges
ORDER BY acl, principal, privilege;

SET LINESIZE 80

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/network_acls.sql
-- Author       : Tim Hall
-- Description  : Displays information about network ACLs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @network_acls
-- Last Modified: 30/11/2011
-- -----------------------------------------------------------------------------------
SET LINESIZE 150

COLUMN host FORMAT A40
COLUMN acl FORMAT A50

SELECT host, lower_port, upper_port, acl
FROM   dba_network_acls
ORDER BY host;

SET LINESIZE 80
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/result_cache_objects.sql
-- Author       : Tim Hall
-- Description  : Displays information about the objects in the result cache.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @result_cache_objects
-- Last Modified: 07/11/2012
-- -----------------------------------------------------------------------------------
SET LINESIZE 1000

SELECT *
FROM v$result_cache_objects;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/result_cache_report.sql
-- Author       : Tim Hall
-- Description  : Displays the result cache report.
-- Requirements : Access to the DBMS_RESULT_CACHE package.
-- Call Syntax  : @result_cache_report
-- Last Modified: 07/11/2012
-- -----------------------------------------------------------------------------------

SET SERVEROUTPUT ON
EXEC DBMS_RESULT_CACHE.memory_report(detailed => true);

     
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/result_cache_statistics.sql
-- Author       : Tim Hall
-- Description  : Displays result cache statistics.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @result_cache_statistics
-- Last Modified: 07/11/2012
-- -----------------------------------------------------------------------------------

COLUMN name FORMAT A30
COLUMN value FORMAT A30

SELECT id,
       name,
       value
FROM   v$result_cache_statistics
ORDER BY id;

CLEAR COLUMNS

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/result_cache_status.sql
-- Author       : Tim Hall
-- Description  : Displays the status of the result cache.
-- Requirements : Access to the DBMS_RESULT_CACHE package.
-- Call Syntax  : @result_cache_status
-- Last Modified: 07/11/2012
-- -----------------------------------------------------------------------------------

SELECT DBMS_RESULT_CACHE.status FROM dual;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/session_fix.sql
-- Author       : Tim Hall
-- Description  : Provides information about session fixes for the specified phrase and version.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_fix (session_id | all) (phrase | all) (version | all)
-- Last Modified: 30/11/2011
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 300

COLUMN sql_feature FORMAT A35
COLUMN optimizer_feature_enable FORMAT A9

SELECT *
FROM   v$session_fix_control
WHERE  session_id = DECODE('&1', 'all', session_id, '&1')
AND    LOWER(description) LIKE DECODE('&2', 'all', '%', '%&2%')
AND    optimizer_feature_enable = DECODE('&3', 'all', optimizer_feature_enable, '&3');

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/system_fix.sql
-- Author       : Tim Hall
-- Description  : Provides information about system fixes for the specified phrase and version.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @system_fix (phrase | all) (version | all)
-- Last Modified: 30/11/2011
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET LINESIZE 300

COLUMN sql_feature FORMAT A35
COLUMN optimizer_feature_enable FORMAT A9

SELECT *
  FROM v$system_fix_control
 WHERE     LOWER (description) LIKE DECODE ('&1', 'all', '%', '%&1%')
       AND optimizer_feature_enable =
              DECODE ('&2', 'all', optimizer_feature_enable, '&2');
			  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/system_fix_count.sql
-- Author       : Tim Hall
-- Description  : Provides information about system fixes per version.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @system_fix_count
-- Last Modified: 30/11/2011
-- -----------------------------------------------------------------------------------
SELECT optimizer_feature_enable,
       COUNT(*)
FROM   v$system_fix_control
GROUP BY optimizer_feature_enable
ORDER BY optimizer_feature_enable;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/11g/temp_free_space.sql
-- Author       : Tim Hall
-- Description  : Displays information about temporary tablespace usage.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @temp_free_space
-- Last Modified: 23-AUG-2008
-- -----------------------------------------------------------------------------------
SELECT *
FROM   dba_temp_free_space;
    
12c

 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/cdb_resource_plan_directives.sql
-- Author       : Tim Hall
-- Description  : Displays CDB resource plan directives.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @cdb_resource_plan_directives.sql (plan-name or all)
-- Last Modified: 22-MAR-2014
-- -----------------------------------------------------------------------------------

COLUMN plan FORMAT A30
COLUMN pluggable_database FORMAT A25
SET LINESIZE 100 VERIFY OFF

SELECT plan, 
       pluggable_database, 
       shares, 
       utilization_limit AS util,
       parallel_server_limit AS parallel
FROM   dba_cdb_rsrc_plan_directives
WHERE  plan = DECODE(UPPER('&1'), 'ALL', plan, UPPER('&1'))
ORDER BY plan, pluggable_database;

SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/cdb_resource_plans.sql
-- Author       : Tim Hall
-- Description  : Displays CDB resource plans.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @cdb_resource_plans.sql
-- Last Modified: 22-MAR-2014
-- -----------------------------------------------------------------------------------

COLUMN plan FORMAT A30
COLUMN comments FORMAT A30
COLUMN status FORMAT A10
SET LINESIZE 100

SELECT plan_id,
       plan,
       comments,
       status,
       mandatory
FROM   dba_cdb_rsrc_plans
ORDER BY plan;


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/credentials.sql
-- Author       : Tim Hall
-- Description  : Displays information about credentials.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @credentials
-- Last Modified: 18/12/2013
-- -----------------------------------------------------------------------------------
COLUMN credential_name FORMAT A25
COLUMN username FORMAT A20
COLUMN windows_domain FORMAT A20

SELECT credential_name,
       username,
       windows_domain
FROM   dba_credentials
ORDER BY credential_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/host_aces.sql
-- Author       : Tim Hall
-- Description  : Displays information about host ACEs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @host_aces
-- Last Modified: 10/09/2014
-- -----------------------------------------------------------------------------------
SET LINESIZE 150

COLUMN host FORMAT A20
COLUMN start_date FORMAT A11
COLUMN end_date FORMAT A11

SELECT host,
       lower_port,
       upper_port,
       ace_order,
       TO_CHAR(start_date, 'DD-MON-YYYY') AS start_date,
       TO_CHAR(end_date, 'DD-MON-YYYY') AS end_date,
       grant_type,
       inverted_principal,
       principal,
       principal_type,
       privilege
FROM   dba_host_aces
ORDER BY host, ace_order;

SET LINESIZE 80

     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/host_acls.sql
-- Author       : Tim Hall
-- Description  : Displays information about host ACLs.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @host_acls
-- Last Modified: 10/09/2014
-- -----------------------------------------------------------------------------------
SET LINESIZE 150

COLUMN host FORMAT A20
COLUMN acl_owner FORMAT A10

SELECT HOST,
       LOWER_PORT,
       UPPER_PORT,
       ACL,
       ACLID,
       ACL_OWNER
FROM   dba_host_acls
ORDER BY host;

SET LINESIZE 80

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/login.sql
-- Author       : Tim Hall
-- Description  : Resets the SQL*Plus prompt when a new connection is made.
--                Includes PDB:CDB.
-- Call Syntax  : @login
-- Last Modified: 21/04/2014
-- -----------------------------------------------------------------------------------
SET FEEDBACK OFF
SET TERMOUT OFF

COLUMN X NEW_VALUE Y
SELECT LOWER(USER || '@' || 
             SYS_CONTEXT('userenv', 'con_name') || ':' || 
             SYS_CONTEXT('userenv', 'instance_name')) X
FROM dual;
SET SQLPROMPT '&Y> '

ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'; 
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD-MON-YYYY HH24:MI:SS.FF'; 

SET TERMOUT ON
SET FEEDBACK ON
SET LINESIZE 100
SET TAB OFF
SET TRIM ON
SET TRIMSPOOL ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/pdbs.sql
-- Author       : Tim Hall
-- Description  : Displays information about all PDBs in the current CDB.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @pdbs
-- Last Modified: 18/12/2013
-- -----------------------------------------------------------------------------------

COLUMN pdb_name FORMAT A20

SELECT pdb_name, status
FROM   dba_pdbs
ORDER BY pdb_name;

SELECT name, open_mode
FROM   v$pdbs
ORDER BY name;
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/priv_captures.sql
-- Author       : Tim Hall
-- Description  : Displays privilege capture policies.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @priv_captures.sql
-- Last Modified: 22-APR-2014
-- -----------------------------------------------------------------------------------

COLUMN name FORMAT A15
COLUMN description FORMAT A30
COLUMN roles FORMAT A20
COLUMN context FORMAT A30
SET LINESIZE 200

  SELECT name,
         description,
         TYPE,
         enabled,
         roles,
         context
    FROM dba_priv_captures
ORDER BY name;
     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/redaction_columns.sql
-- Author       : Tim Hall
-- Description  : Displays information about columns related to redaction policies.
-- Requirements : Access to the REDACTION_COLUMNS view.
-- Call Syntax  : @redaction_columns (schema | all) (object | all)
-- Last Modified: 27-NOV-2014
-- -----------------------------------------------------------------------------------

SET LINESIZE 300 VERIFY OFF

COLUMN object_owner FORMAT A20
COLUMN object_name FORMAT A30
COLUMN column_name FORMAT A30
COLUMN function_parameters FORMAT A30
COLUMN regexp_pattern FORMAT A30
COLUMN regexp_replace_string FORMAT A30
COLUMN column_description FORMAT A20

  SELECT object_owner,
         object_name,
         column_name,
         function_type,
         function_parameters,
         regexp_pattern,
         regexp_replace_string,
         regexp_position,
         regexp_occurrence,
         regexp_match_parameter,
         column_description
    FROM redaction_columns
   WHERE     object_owner =
                DECODE (UPPER ('&1'), 'ALL', object_owner, UPPER ('&1'))
         AND object_name =
                DECODE (UPPER ('&2'), 'ALL', object_name, UPPER ('&2'))
ORDER BY 1, 2, 3;

SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/redaction_policies.sql
-- Author       : Tim Hall
-- Description  : Displays redaction policy information.
-- Requirements : Access to the REDACTION_POLICIES view.
-- Call Syntax  : @redaction_policies
-- Last Modified: 27-NOV-2014
-- -----------------------------------------------------------------------------------

SET LINESIZE 200

COLUMN object_owner FORMAT A20
COLUMN object_name FORMAT A30
COLUMN policy_name FORMAT A30
COLUMN expression FORMAT A30
COLUMN policy_description FORMAT A20

SELECT object_owner,
       object_name,
       policy_name,
       expression,
       enable,
       policy_description
FROM   redaction_policies
ORDER BY 1, 2, 3;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/12c/redaction_value_defaults.sql
-- Author       : Tim Hall
-- Description  : Displays information about redaction defaults.
-- Requirements : Access to the REDACTION_VALUES_FOR_TYPE_FULL view.
-- Call Syntax  : @redaction_value_defaults
-- Last Modified: 27-NOV-2014
-- -----------------------------------------------------------------------------------

SET LINESIZE 250
COLUMN char_value FORMAT A10
COLUMN varchar_value FORMAT A10
COLUMN nchar_value FORMAT A10
COLUMN nvarchar_value FORMAT A10
COLUMN timestamp_value FORMAT A27
COLUMN timestamp_with_time_zone_value FORMAT A32
COLUMN blob_value FORMAT A20
COLUMN clob_value FORMAT A10
COLUMN nclob_value FORMAT A10

SELECT *
FROM   redaction_values_for_type_full;
 

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/services.sql
-- Author       : Tim Hall
-- Description  : Displays information about database services.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @services
-- Last Modified: 05/11/2004
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
COLUMN name FORMAT A30
COLUMN network_name FORMAT A50
COLUMN pdb FORMAT A20

SELECT name,
       network_name,
       pdb
FROM   dba_services
ORDER BY name;
    


Constraints

  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/constraints/disable_chk.sql
-- Author       : Tim Hall
-- Description  : Disables all check constraints for a specified table, or all tables.
-- Call Syntax  : @disable_chk (table-name or all) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" DISABLE CONSTRAINT "' || a.constraint_name || '";'
FROM   all_constraints a
WHERE  a.constraint_type = 'C'
AND    a.owner           = UPPER('&2');
AND    a.table_name      = DECODE(UPPER('&1'),'ALL',a.table_name,UPPER('&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/constraints/disable_fk.sql
-- Author       : Tim Hall
-- Description  : Disables all Foreign Keys belonging to the specified table, or all tables.
-- Call Syntax  : @disable_fk (table-name or all) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" DISABLE CONSTRAINT "' || a.constraint_name || '";'
FROM   all_constraints a
WHERE  a.constraint_type = 'R'
AND    a.table_name      = DECODE(Upper('&1'),'ALL',a.table_name,Upper('&1'))
AND    a.owner           = Upper('&2');

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/constraints/disable_pk.sql
-- Author       : Tim Hall
-- Description  : Disables the Primary Key for the specified table, or all tables.
-- Call Syntax  : @disable_pk (table-name or all) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" DISABLE PRIMARY KEY;'
FROM   all_constraints a
WHERE  a.constraint_type = 'P'
AND    a.owner           = Upper('&2')
AND    a.table_name      = DECODE(Upper('&1'),'ALL',a.table_name,Upper('&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/constraints/disable_ref_fk.sql
-- Author       : Tim Hall
-- Description  : Disables all Foreign Keys referencing a specified table, or all tables.
-- Call Syntax  : @disable_ref_fk (table-name) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" DISABLE CONSTRAINT "' || a.constraint_name || '";' enable_constraints
FROM   all_constraints a
WHERE  a.owner      = Upper('&2')
AND    a.constraint_type = 'R'
AND    a.r_constraint_name IN (SELECT a1.constraint_name
                               FROM   all_constraints a1
                               WHERE  a1.table_name = DECODE(Upper('&1'),'ALL',a.table_name,Upper('&1'))
                               AND    a1.owner      = Upper('&2'));

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/constraints/enable_chk.sql
-- Author       : Tim Hall
-- Description  : Enables all check constraints for a specified table, or all tables.
-- Call Syntax  : @enable_chk (table-name or all) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" ENABLE CONSTRAINT "' || a.constraint_name || '";'
FROM   all_constraints a
WHERE  a.constraint_type = 'C'
AND    a.owner           = Upper('&2');
AND    a.table_name      = DECODE(Upper('&1'),'ALL',a.table_name,UPPER('&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/constraints/enable_fk.sql
-- Author       : Tim Hall
-- Description  : Enables all Foreign Keys belonging to the specified table, or all tables.
-- Call Syntax  : @enable_fk (table-name or all) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" ENABLE CONSTRAINT "' || a.constraint_name || '";'
FROM   all_constraints a
WHERE  a.constraint_type = 'R'
AND    a.table_name      = DECODE(Upper('&1'),'ALL',a.table_name,Upper('&1'))
AND    a.owner           = Upper('&2');

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON
     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/constraints/enable_pk.sql
-- Author       : Tim Hall
-- Description  : Enables the Primary Key for the specified table, or all tables.
-- Call Syntax  : @disable_pk (table-name or all) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" ENABLE PRIMARY KEY;'
FROM   all_constraints a
WHERE  a.constraint_type = 'P'
AND    a.owner           = Upper('&2')
AND    a.table_name      = DECODE(Upper('&1'),'ALL',a.table_name,Upper('&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/constraints/enable_ref_fk.sql
-- Author       : Tim Hall
-- Description  : Enables all Foreign Keys referencing a specified table, or all tables.
-- Call Syntax  : @enable_ref_fk (table-name) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TABLE "' || a.table_name || '" ENABLE CONSTRAINT "' || a.constraint_name || '";'
FROM   all_constraints a
WHERE  a.owner           = Upper('&2')
AND    a.constraint_type = 'R'
AND    a.r_constraint_name IN (SELECT a1.constraint_name
                               FROM   all_constraints a1
                               WHERE  a1.table_name = DECODE(Upper('&1'),'ALL',a.table_name,Upper('&1'))
                               AND    a1.owner      = Upper('&2'));

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

    
Miscellaneous

  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/analyze_all.sql
-- Author       : Tim Hall
-- Description  : Outdated script to analyze all tables for the specified schema.
-- Comment      : Use DBMS_UTILITY.ANALYZE_SCHEMA or DBMS_STATS.GATHER_SCHEMA_STATS if your server allows it.
-- Call Syntax  : @ananlyze_all (schema-name)
-- Last Modified: 26/02/2002
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ANALYZE TABLE "' || table_name || '" COMPUTE STATISTICS;'
FROM   all_tables
WHERE  owner = Upper('&1')
ORDER BY 1;

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/column_comments.sql
-- Author       : Tim Hall
-- Description  : Displays comments associate with specific tables.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @column_comments (schema) (table-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
SET PAGESIZE 100
COLUMN column_name FORMAT A20
COLUMN comments    FORMAT A50

SELECT column_name,
       comments
FROM   dba_col_comments
WHERE  owner      = UPPER('&1')
AND    table_name = UPPER('&2')
ORDER BY column_name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/comments.sql
-- Author       : Tim Hall
-- Description  : Displays all comments for the specified table and its columns.
-- Call Syntax  : @comments (table-name) (schema-name)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
PROMPT
SET VERIFY OFF
SET FEEDBACK OFF
SET LINESIZE 255
SET PAGESIZE 1000

SELECT a.table_name "Table",
       a.table_type "Type",
       Substr(a.comments,1,200) "Comments"
FROM   all_tab_comments a
WHERE  a.table_name = Upper('&1')
AND    a.owner      = Upper('&2');

SELECT a.column_name "Column",
       Substr(a.comments,1,200) "Comments"
FROM   all_col_comments a
WHERE  a.table_name = Upper('&1')
AND    a.owner      = Upper('&2');

SET VERIFY ON
SET FEEDBACK ON
SET PAGESIZE 14
PROMPT
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/compile_all.sql
-- Author       : Tim Hall
-- Description  : Compiles all invalid objects for specified schema, or all schema.
-- Requirements : Requires all other "Compile_All" scripts.
-- Call Syntax  : @compile_all (schema-name or all)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
@Compile_All_Specs &&1
@Compile_All_Bodies &&1
@Compile_All_Procs &&1
@Compile_All_Funcs &&1
@Compile_All_Views &&1

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/compile_all_bodies.sql
-- Author       : Tim Hall
-- Description  : Compiles all invalid package bodies for specified schema, or all schema.
-- Call Syntax  : @compile_all_bodies (schema-name or all)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER PACKAGE ' || a.owner || '.' || a.object_name || ' COMPILE BODY;'
FROM    all_objects a
WHERE   a.object_type = 'PACKAGE BODY'
AND     a.status      = 'INVALID'
AND     a.owner       = Decode(Upper('&&1'), 'ALL',a.owner, Upper('&&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/compile_all_funcs.sql
-- Author       : Tim Hall
-- Description  : Compiles all invalid functions for specified schema, or all schema.
-- Call Syntax  : @compile_all_funcs (schema-name or all)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER FUNCTION ' || a.owner || '.' || a.object_name || ' COMPILE;'
FROM    all_objects a
WHERE   a.object_type = 'FUNCTION'
AND     a.status      = 'INVALID'
AND     a.owner       = Decode(Upper('&&1'), 'ALL',a.owner, Upper('&&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/compile_all_procs.sql
-- Author       : Tim Hall
-- Description  : Compiles all invalid procedures for specified schema, or all schema.
-- Call Syntax  : @compile_all_procs (schema-name or all)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER PROCEDURE ' || a.owner || '.' || a.object_name || ' COMPILE;'
FROM    all_objects a
WHERE   a.object_type = 'PROCEDURE'
AND     a.status      = 'INVALID'
AND     a.owner       = Decode(Upper('&&1'), 'ALL',a.owner, Upper('&&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/compile_all_specs.sql
-- Author       : Tim Hall
-- Description  : Compiles all invalid package specifications for specified schema, or all schema.
-- Call Syntax  : @compile_all_specs (schema-name or all)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER PACKAGE ' || a.owner || '.' || a.object_name || ' COMPILE;'
FROM    all_objects a
WHERE   a.object_type = 'PACKAGE'
AND     a.status      = 'INVALID'
AND     a.owner       = Decode(Upper('&&1'), 'ALL',a.owner, Upper('&&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/compile_all_trigs.sql
-- Author       : Tim Hall
-- Description  : Compiles all invalid triggers for specified schema, or all schema.
-- Call Syntax  : @compile_all_trigs (schema-name or all)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER TRIGGER ' || a.owner || '.' || a.object_name || ' COMPILE;'
FROM    all_objects a
WHERE   a.object_type = 'TRIGGER'
AND     a.status      = 'INVALID'
AND     a.owner       = Decode(Upper('&&1'), 'ALL',a.owner, Upper('&&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/compile_all_views.sql
-- Author       : Tim Hall
-- Description  : Compiles all invalid views for specified schema, or all schema.
-- Call Syntax  : @compile_all_views (schema-name or all)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER VIEW ' || a.owner || '.' || a.object_name || ' COMPILE;'
FROM    all_objects a
WHERE   a.object_type = 'VIEW'
AND     a.status      = 'INVALID'
AND     a.owner       = Decode(Upper('&&1'), 'ALL',a.owner, Upper('&&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/dict_comments.sql
-- Author       : Tim Hall
-- Description  : Displays comments associate with specific tables.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @dict_comments (table-name or partial match)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
PROMPT
SET VERIFY OFF
SET FEEDBACK OFF
SET LINESIZE 255
SET PAGESIZE 1000

SELECT a.table_name "Table", SUBSTR (a.comments, 1, 200) "Comments"
  FROM dictionary a
 WHERE a.table_name LIKE UPPER ('%&1%');

SET VERIFY ON
SET FEEDBACK ON
SET PAGESIZE 14
PROMPT

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/drop_all.sql
-- Author       : Tim Hall
-- Description  : Drops all objects within the current schema.
-- Call Syntax  : @drop_all
-- Last Modified: 20/01/2006
-- Notes        : Loops a maximum of 5 times, allowing for failed drops due to dependencies.
--                Quits outer loop if no drops were atempted.
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
DECLARE
  l_count    NUMBER;
  l_cascade  VARCHAR2(20);
BEGIN
  >
  FOR i IN 1 .. 5 LOOP
    EXIT dependency_failure_loop WHEN l_count = 0;
    l_count := 0;
    
    FOR cur_rec IN (SELECT object_name, object_type 
                    FROM   user_objects) LOOP
      BEGIN
        l_count := l_count + 1;
        l_cascade := NULL;
        IF cur_rec.object_type = 'TABLE' THEN
          l_cascade := ' CASCADE CONSTRAINTS';
        END IF;
        EXECUTE IMMEDIATE 'DROP ' || cur_rec.object_type || ' "' || cur_rec.object_name || '"' || l_cascade;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END LOOP;
    -- Comment out the following line if you are pre-10g, or want to preserve the recyclebin contents. 
    EXECUTE IMMEDIATE 'PURGE RECYCLEBIN';
    DBMS_OUTPUT.put_line('Pass: ' || i || '  Drops: ' || l_count);
  END LOOP;
END;
/

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/gen_health.sql
-- Author       : Tim Hall
-- Description  : Miscellaneous queries to check the general health of the system.
-- Call Syntax  : @gen_health
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SELECT file_id, 
       tablespace_name, 
       file_name, 
       status 
FROM   sys.dba_data_files; 

SELECT file#, 
       name, 
       status, 
       enabled 
FROM   v$datafile;

SELECT * 
FROM   v$backup;

SELECT * 
FROM   v$recovery_status;

SELECT * 
FROM   v$recover_file;

SELECT * 
FROM   v$recovery_file_status;

SELECT * 
FROM   v$recovery_log;

SELECT username, 
       command, 
       status, 
       module 
FROM   v$session;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/get_pivot.sql
-- Author       : Tim Hall
-- Description  : Creates a function to produce a virtual pivot table with the specific values.
-- Requirements : CREATE TYPE, CREATE PROCEDURE
-- Call Syntax  : @get_pivot.sql
-- Last Modified: 13/08/2003
-- -----------------------------------------------------------------------------------

CREATE OR REPLACE TYPE t_pivot AS TABLE OF NUMBER;
/

CREATE OR REPLACE FUNCTION get_pivot(p_max   IN  NUMBER,
                                     p_step  IN  NUMBER DEFAULT 1) 
  RETURN t_pivot AS
  l_pivot t_pivot := t_pivot();
BEGIN
  FOR i IN 0 .. TRUNC(p_max/p_step) LOOP
    l_pivot.extend;
    l_pivot(l_pivot.last) := 1 + (i * p_step);
  END LOOP;
  RETURN l_pivot;
END;
/
SHOW ERRORS

SELECT column_value
FROM   TABLE(get_pivot(17,2));

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/login.sql
-- Author       : Tim Hall
-- Description  : Resets the SQL*Plus prompt when a new connection is made.
-- Call Syntax  : @login
-- Last Modified: 04/03/2004
-- -----------------------------------------------------------------------------------
SET FEEDBACK OFF
SET TERMOUT OFF

COLUMN X NEW_VALUE Y
SELECT LOWER(USER || '@' || SYS_CONTEXT('userenv', 'instance_name')) X FROM dual;
SET SQLPROMPT '&Y> '

ALTER SESSION SET NLS_DATE_FORMAT='DD-MON-YYYY HH24:MI:SS'; 
ALTER SESSION SET NLS_TIMESTAMP_FORMAT='DD-MON-YYYY HH24:MI:SS.FF'; 

SET TERMOUT ON
SET FEEDBACK ON
SET LINESIZE 100
SET TAB OFF
SET TRIM ON
SET TRIMSPOOL ON

  
  CREATE OR REPLACE FUNCTION part_hv_to_date (p_table_owner    IN  VARCHAR2,
                                            p_table_name     IN VARCHAR2,
                                            p_partition_name IN VARCHAR2)
  RETURN DATE
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/part_hv_to_date.sql
-- Author       : Tim Hall
-- Description  : Create a function to turn partition HIGH_VALUE column to a date.
-- Call Syntax  : @part_hv_to_date
-- Last Modified: 19/01/2012
-- Notes        : Has to re-select the value from the view as LONG cannot be passed as a parameter.
--                Example call:
--
-- SELECT a.partition_name, 
--        part_hv_to_date(a.table_owner, a.table_name, a.partition_name) as high_value
-- FROM   all_tab_partitions a;
--
-- Does no error handling. 
-- -----------------------------------------------------------------------------------
AS
  l_high_value VARCHAR2(32767);
  l_date DATE;
BEGIN
  SELECT high_value
  INTO   l_high_value
  FROM   all_tab_partitions
  WHERE  table_owner    = p_table_owner
  AND    table_name     = p_table_name
  AND    partition_name = p_partition_name;
  
  EXECUTE IMMEDIATE 'SELECT ' || l_high_value || ' FROM dual' INTO l_date;
  RETURN l_date;
END;
/

     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/proc_defs.sql
-- Author       : Tim Hall
-- Description  : Lists the parameters for the specified package and procedure.
-- Call Syntax  : @proc_defs (package-name) (procedure-name or all)
-- Last Modified: 24/09/2003
-- -----------------------------------------------------------------------------------
COLUMN "Object Name" FORMAT A30
COLUMN ol FORMAT A2
COLUMN sq FORMAT 99
COLUMN "Argument Name" FORMAT A32
COLUMN "Type" FORMAT A15
COLUMN "Size" FORMAT A6
BREAK ON ol SKIP 2
SET PAGESIZE 0
SET LINESIZE 200
SET TRIMOUT ON
SET TRIMSPOOL ON
SET VERIFY OFF

  SELECT object_name AS "Object Name",
         overload AS ol,
         sequence AS sq,
         RPAD (' ', data_level * 2, ' ') || argument_name AS "Argument Name",
         data_type AS "Type",
         (CASE
             WHEN data_type IN ('VARCHAR2', 'CHAR')
             THEN
                TO_CHAR (data_length)
             WHEN data_scale IS NULL OR data_scale = 0
             THEN
                TO_CHAR (data_precision)
             ELSE
                TO_CHAR (data_precision) || ',' || TO_CHAR (data_scale)
          END)
            "Size",
         in_out AS "In/Out",
         DEFAULT_VALUE
    FROM user_arguments
   WHERE     package_name = UPPER ('&1')
         AND object_name =
                DECODE (UPPER ('&2'), 'ALL', object_name, UPPER ('&2'))
ORDER BY object_name, overload, sequence;

SET PAGESIZE 14
SET LINESIZE 80

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/rebuild_index.sql
-- Author       : Tim Hall
-- Description  : Rebuilds the specified index, or all indexes.
-- Call Syntax  : @rebuild_index (index-name or all) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'ALTER INDEX ' || a.index_name || ' REBUILD;'
FROM   all_indexes a
WHERE  index_name  = DECODE(Upper('&1'),'ALL',a.index_name,Upper('&1'))
AND    table_owner = Upper('&2')
ORDER BY 1
/

SPOOL OFF

-- Comment out following line to prevent immediate run
@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON


-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/string_agg.sql
-- Author       : Tim Hall (based on an a method suggested by Tom Kyte).
--                http://asktom.oracle.com/pls/ask/f?p=4950:8:::::F4950_P8_DISPLAYID:229614022562
-- Description  : Aggregate function to concatenate strings.
-- Call Syntax  : Incorporate into queries as follows:
--                  COLUMN employees FORMAT A50
--                  
--                  SELECT deptno, string_agg(ename) AS employees
--                  FROM   emp
--                  GROUP BY deptno;
--                  
--                      DEPTNO EMPLOYEES
--                  ---------- --------------------------------------------------
--                          10 CLARK,KING,MILLER
--                          20 SMITH,FORD,ADAMS,SCOTT,JONES
--                          30 ALLEN,BLAKE,MARTIN,TURNER,JAMES,WARD
--                  
-- Last Modified: 20-APR-2005
-- -----------------------------------------------------------------------------------
CREATE OR REPLACE TYPE t_string_agg AS OBJECT
(
  g_string  VARCHAR2(32767),

  STATIC FUNCTION ODCIAggregateInitialize(sctx  IN OUT  t_string_agg)
    RETURN NUMBER,

  MEMBER FUNCTION ODCIAggregateIterate(self   IN OUT  t_string_agg,
                                       value  IN      VARCHAR2 )
     RETURN NUMBER,

  MEMBER FUNCTION ODCIAggregateTerminate(self         IN   t_string_agg,
                                         returnValue  OUT  VARCHAR2,
                                         flags        IN   NUMBER)
    RETURN NUMBER,

  MEMBER FUNCTION ODCIAggregateMerge(self  IN OUT  t_string_agg,
                                     ctx2  IN      t_string_agg)
    RETURN NUMBER
);
/
SHOW ERRORS


CREATE OR REPLACE TYPE BODY t_string_agg IS
  STATIC FUNCTION ODCIAggregateInitialize(sctx  IN OUT  t_string_agg)
    RETURN NUMBER IS
  BEGIN
    sctx := t_string_agg(NULL);
    RETURN ODCIConst.Success;
  END;

  MEMBER FUNCTION ODCIAggregateIterate(self   IN OUT  t_string_agg,
                                       value  IN      VARCHAR2 )
    RETURN NUMBER IS
  BEGIN
    SELF.g_string := self.g_string || ',' || value;
    RETURN ODCIConst.Success;
  END;

  MEMBER FUNCTION ODCIAggregateTerminate(self         IN   t_string_agg,
                                         returnValue  OUT  VARCHAR2,
                                         flags        IN   NUMBER)
    RETURN NUMBER IS
  BEGIN
    returnValue := RTRIM(LTRIM(SELF.g_string, ','), ',');
    RETURN ODCIConst.Success;
  END;

  MEMBER FUNCTION ODCIAggregateMerge(self  IN OUT  t_string_agg,
                                     ctx2  IN      t_string_agg)
    RETURN NUMBER IS
  BEGIN
    SELF.g_string := SELF.g_string || ',' || ctx2.g_string;
    RETURN ODCIConst.Success;
  END;
END;
/
SHOW ERRORS


CREATE OR REPLACE FUNCTION string_agg (p_input VARCHAR2)
RETURN VARCHAR2
PARALLEL_ENABLE AGGREGATE USING t_string_agg;
/
SHOW ERRORS

  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/switch_schema.sql
-- Author       : Tim Hall
-- Description  : Allows developers to switch synonyms between schemas where a single instance
--              : contains multiple discrete schemas.
-- Requirements : Must be loaded into privileged user such as SYS.
-- Usage        : Create the package in a user that has the appropriate privileges to perform the actions (SYS)
--              : Amend the list of schemas in the "reset_grants" FOR LOOP as necessary.
--              : Call SWITCH_SCHEMA.RESET_GRANTS once to grant privileges to the developer role.
--              : Assign the developer role to all developers.
--              : Tell developers to use EXEC SWITCH_SCHEMA.RESET_SCHEMA_SYNONYMS ('SCHEMA-NAME'); to switch
--              : there synonyms between schemas.
-- Call Syntax  : EXEC SWITCH_SCHEMA.RESET_SCHEMA_SYNONYMS ('SCHEMA-NAME');
-- Last Modified: 02/06/2003
-- -----------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE switch_schema AS

PROCEDURE reset_grants;
PROCEDURE reset_schema_synonyms (p_schema  IN  VARCHAR2);

END;
/

SHOW ERRORS


CREATE OR REPLACE PACKAGE BODY switch_schema AS

PROCEDURE reset_grants IS
BEGIN
  FOR cur_obj IN (SELECT owner, object_name, object_type
                  FROM   all_objects
                  WHERE  owner IN ('SCHEMA1','SCHEMA2','SCHEMA3','SCHEMA4')
                  AND    object_type IN ('TABLE','VIEW','SEQUENCE', 'PACKAGE', 'PROCEDURE', 'FUNCTION', 'TYPE'))
  LOOP
    CASE 
      WHEN cur_obj.object_type IN ('TABLE','VIEW') THEN
        EXECUTE IMMEDIATE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ' || cur_obj.owner || '."' || cur_obj.object_name || '" TO developer';
      WHEN cur_obj.object_type IN ('SEQUENCE') THEN
        EXECUTE IMMEDIATE 'GRANT SELECT ON ' || cur_obj.owner || '."' || cur_obj.object_name || '" TO developer';
      WHEN cur_obj.object_type IN ('PACKAGE', 'PROCEDURE', 'FUNCTION', 'TYPE') THEN
        EXECUTE IMMEDIATE 'GRANT EXECUTE ON ' || cur_obj.owner || '."' || cur_obj.object_name || '" TO developer';
    END CASE;
  END LOOP;
END;

PROCEDURE reset_schema_synonyms (p_schema  IN  VARCHAR2) IS
  v_user  VARCHAR2(30) := USER;
BEGIN
  -- Drop all existing synonyms
  FOR cur_obj IN (SELECT synonym_name
                  FROM   all_synonyms
                  WHERE  owner = v_user)
  LOOP
    EXECUTE IMMEDIATE 'DROP SYNONYM ' || v_user || '."' || cur_obj.synonym_name || '"';
  END LOOP;

  -- Create new synonyms
  FOR cur_obj IN (SELECT object_name, object_type
                  FROM   all_objects
                  WHERE  owner = p_schema
                  AND    object_type IN ('TABLE','VIEW','SEQUENCE'))
  LOOP
    EXECUTE IMMEDIATE 'CREATE SYNONYM ' || v_user || '."' || cur_obj.object_name || '" FOR ' || p_schema || '."' || cur_obj.object_name || '"';
  END LOOP;
END;

END;
/

SHOW ERRORS

CREATE PUBLIC SYNONYM switch_schema FOR switch_schema;
GRANT EXECUTE ON switch_schema TO PUBLIC;

CREATE ROLE developer;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/table_comments.sql
-- Author       : Tim Hall
-- Description  : Displays comments associate with specific tables.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @table_comments (schema or all) (table-name or partial match)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET VERIFY OFF
COLUMN table_name FORMAT A30
COLUMN comments   FORMAT A40

SELECT table_name,
       comments
FROM   dba_tab_comments
WHERE  owner = DECODE(UPPER('&1'), 'ALL', owner, UPPER('&1'))
AND    table_name LIKE UPPER('%&2%')
ORDER BY table_name;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/table_defs.sql
-- Author       : Tim Hall
-- Description  : Lists the column definitions for the specified table.
-- Call Syntax  : @table_defs (tablee-name or all)
-- Last Modified: 24/09/2003
-- -----------------------------------------------------------------------------------
COLUMN column_id FORMAT 99
COLUMN data_type FORMAT A10
COLUMN nullable FORMAT A8
COLUMN size FORMAT A6
BREAK ON table_name SKIP 2
SET PAGESIZE 0
SET LINESIZE 200
SET TRIMOUT ON
SET TRIMSPOOL ON
SET VERIFY OFF

SELECT table_name,
       column_id,
       column_name,
       data_type,
       (CASE
         WHEN data_type IN ('VARCHAR2','CHAR') THEN TO_CHAR(data_length)
         WHEN data_scale IS NULL OR data_scale = 0 THEN TO_CHAR(data_precision)
         ELSE TO_CHAR(data_precision) || ',' || TO_CHAR(data_scale)
       END) "SIZE",
       DECODE(nullable, 'Y', '', 'NOT NULL') nullable
FROM   user_tab_columns
WHERE  table_name = DECODE(UPPER('&1'), 'ALL', table_name, UPPER('&1'))
ORDER BY table_name, column_id;

SET PAGESIZE 14
SET LINESIZE 80

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/miscellaneous/table_differences.sql
-- Author       : Tim Hall
-- Description  : Checks column differences between a specified table or ALL tables.
--              : The comparison is done both ways so datatype/size mismatches will
--              : be listed twice per column.
--              : Log into the first schema-owner. Make sure a DB Link is set up to
--              : the second schema owner. Use this DB Link in the definition of 
--              : the c_table2 cursor and amend v_owner1 and v_owner2 accordingly
--              : to make output messages sensible.
--              : The result is spooled to the Tab_Diffs.txt file in the working directory.
-- Call Syntax  : @table_differences (table-name or all)
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 500
SET VERIFY OFF
SET FEEDBACK OFF
PROMPT

SPOOL Tab_Diffs.txt

DECLARE

  CURSOR c_tables IS
    SELECT a.table_name
    FROM   user_tables a
    WHERE  a.table_name = Decode(Upper('&&1'),'ALL',a.table_name,Upper('&&1'));
    
  CURSOR c_table1 (p_table_name   IN  VARCHAR2,
                   p_column_name  IN  VARCHAR2) IS
    SELECT a.column_name,
           a.data_type,
           a.data_length,
           a.data_precision,
           a.data_scale,
           a.nullable
    FROM   user_tab_columns a
    WHERE  a.table_name  = p_table_name
    AND    a.column_name = NVL(p_column_name,a.column_name);

  CURSOR c_table2 (p_table_name   IN  VARCHAR2,
                   p_column_name  IN  VARCHAR2) IS
    SELECT a.column_name,
           a.data_type,
           a.data_length,
           a.data_precision,
           a.data_scale,
           a.nullable
    FROM   user_tab_columns@pdds a
    WHERE  a.table_name  = p_table_name
    AND    a.column_name = NVL(p_column_name,a.column_name);

  v_owner1  VARCHAR2(10) := 'DDDS2';
  v_owner2  VARCHAR2(10) := 'PDDS';
  v_data    c_table1%ROWTYPE;
  v_work    BOOLEAN := FALSE;
  
BEGIN

  Dbms_Output.Disable;
  Dbms_Output.Enable(1000000);
  
  FOR cur_tab IN c_tables LOOP
    v_work := FALSE;
    FOR cur_rec IN c_table1 (cur_tab.table_name, NULL) LOOP
      v_work := TRUE;
      
      OPEN  c_table2 (cur_tab.table_name, cur_rec.column_name);
      FETCH c_table2
      INTO  v_data;
      IF c_table2%NOTFOUND THEN
        Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : Present in ' || v_owner1 || ' but not in ' || v_owner2);
      ELSE
        IF cur_rec.data_type != v_data.data_type THEN
          Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : DATA_TYPE differs between ' || v_owner1 || ' and ' || v_owner2);
        END IF;
        IF cur_rec.data_length != v_data.data_length THEN
          Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : DATA_LENGTH differs between ' || v_owner1 || ' and ' || v_owner2);
        END IF;
        IF cur_rec.data_precision != v_data.data_precision THEN
          Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : DATA_PRECISION differs between ' || v_owner1 || ' and ' || v_owner2);
        END IF;
        IF cur_rec.data_scale != v_data.data_scale THEN
          Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : DATA_SCALE differs between ' || v_owner1 || ' and ' || v_owner2);
        END IF;
        IF cur_rec.nullable != v_data.nullable THEN
          Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : NULLABLE differs between ' || v_owner1 || ' and ' || v_owner2);
        END IF;
      END IF;
      CLOSE c_table2; 
    END LOOP;
    
    FOR cur_rec IN c_table2 (cur_tab.table_name, NULL) LOOP
      v_work := TRUE;
      
      OPEN  c_table1 (cur_tab.table_name, cur_rec.column_name);
      FETCH c_table1
      INTO  v_data;
      IF c_table1%NOTFOUND THEN
        Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : Present in ' || v_owner2 || ' but not in ' || v_owner1);
      ELSE
        IF cur_rec.data_type != v_data.data_type THEN
          Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : DATA_TYPE differs between ' || v_owner2 || ' and ' || v_owner1);
        END IF;
        IF cur_rec.data_length != v_data.data_length THEN
          Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : DATA_LENGTH differs between ' || v_owner2 || ' and ' || v_owner1);
        END IF;
        IF cur_rec.data_precision != v_data.data_precision THEN
          Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : DATA_PRECISION differs between ' || v_owner2 || ' and ' || v_owner1);
        END IF;
        IF cur_rec.data_scale != v_data.data_scale THEN
          Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : DATA_SCALE differs between ' || v_owner2 || ' and ' || v_owner1);
        END IF;
        IF cur_rec.nullable != v_data.nullable THEN
          Dbms_Output.Put_Line(cur_tab.table_name || '.' || cur_rec.column_name || ' : NULLABLE differs between ' || v_owner2 || ' and ' || v_owner1);
        END IF;
      END IF;
      CLOSE c_table1; 
    END LOOP;
    
    IF v_work = FALSE THEN
      Dbms_Output.Put_Line(cur_tab.table_name || ' does not exist!');
    END IF;  
  END LOOP;
END;
/

SPOOL OFF

PROMPT
SET FEEDBACK ON

     

Real Application Clusters (RAC)

  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/locked_objects.sql
-- Author       : Tim Hall
-- Description  : Lists all locked objects for whole RAC. - work quickly
-- Requirements : Access to the V$ views.
-- Call Syntax  : @locked_objects
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

COLUMN owner FORMAT A20
COLUMN username FORMAT A20
COLUMN object_owner FORMAT A20
COLUMN object_name FORMAT A30
COLUMN locked_mode FORMAT A15

  SELECT b.inst_id,
         b.session_id AS sid,
         NVL (b.oracle_username, '(oracle)') AS username,
         a.owner AS object_owner,
         a.object_name,
         DECODE (b.locked_mode,
                 0, 'None',
                 1, 'Null (NULL)',
                 2, 'Row-S (SS)',
                 3, 'Row-X (SX)',
                 4, 'Share (S)',
                 5, 'S/Row-X (SSX)',
                 6, 'Exclusive (X)',
                 b.locked_mode)
            locked_mode,
         b.os_user_name
    FROM dba_objects a, gv$locked_object b
   WHERE a.object_id = b.object_id
ORDER BY 1,2,3,4;

SET PAGESIZE 14
SET VERIFY ON
  
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/longops_rac.sql
-- Author       : Tim Hall
-- Description  : Displays information on all long operations for whole RAC.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @longops_rac
-- Last Modified: 03/07/2003
-- -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN sid FORMAT 9999
COLUMN serial# FORMAT 9999999
COLUMN machine FORMAT A30
COLUMN progress_pct FORMAT 99999999.00
COLUMN elapsed FORMAT A10
COLUMN remaining FORMAT A10

SELECT s.inst_id,
       s.sid,
       s.serial#,
       s.username,
       s.module,
       ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
       ROUND(sl.time_remaining/60) || ':' || MOD(sl.time_remaining,60) remaining,
       ROUND(sl.sofar/sl.totalwork*100, 2) progress_pct
FROM   gv$session s,
       gv$session_longops sl
WHERE  s.sid     = sl.sid
AND    s.inst_id = sl.inst_id
AND    s.serial# = sl.serial#;

     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/monitor_memory_rac.sql
-- Author       : Tim Hall
-- Description  : Displays memory allocations for the current database sessions for the whole RAC.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @monitor_memory_rac
-- Last Modified: 15-JUL-2000
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN username FORMAT A20
COLUMN module FORMAT A20

  SELECT a.inst_id,
         NVL (a.username, '(oracle)') AS username,
         a.module,
         a.program,
         TRUNC (b.VALUE / 1024) AS memory_kb
    FROM gv$session a, gv$sesstat b, gv$statname c
   WHERE     a.sid = b.sid
         AND a.inst_id = b.inst_id
         AND b.statistic# = c.statistic#
         AND b.inst_id = c.inst_id
         AND c.name = 'session pga memory'
         AND a.program IS NOT NULL
ORDER BY b.VALUE DESC;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/session_undo_rac.sql
-- Author       : Tim Hall
-- Description  : Displays undo information on relevant database sessions.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_undo_rac
-- Last Modified: 20/12/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200

COLUMN username FORMAT A15

  SELECT s.inst_id,
         s.username,
         s.sid,
         s.serial#,
         t.used_ublk,
         t.used_urec,
         rs.segment_name,
         r.rssize,
         r.status
    FROM gv$transaction t,
         gv$session s,
         gv$rollstat r,
         dba_rollback_segs rs
   WHERE     s.saddr = t.ses_addr
         AND s.inst_id = t.inst_id
         AND t.xidusn = r.usn
         AND t.inst_id = r.inst_id
         AND rs.segment_id = t.xidusn
ORDER BY t.used_ublk DESC;
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/10g/session_waits_rac.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database session waits for the whole RAC.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @session_waits_rac
-- Last Modified: 02/07/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET PAGESIZE 1000

COLUMN username FORMAT A20
COLUMN event FORMAT A30
COLUMN wait_class FORMAT A15

  SELECT s.inst_id,
         NVL (s.username, '(oracle)') AS username,
         s.sid,
         s.serial#,
         sw.event,
         sw.wait_class,
         sw.wait_time,
         sw.seconds_in_wait,
         sw.state
    FROM gv$session_wait sw, gv$session s
   WHERE s.sid = sw.sid AND s.inst_id = sw.inst_id
ORDER BY sw.seconds_in_wait DESC;

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/monitoring/sessions_rac.sql
-- Author       : Tim Hall
-- Description  : Displays information on all database sessions for whole RAC.
-- Requirements : Access to the V$ views.
-- Call Syntax  : @sessions_rac
-- Last Modified: 21/02/2005
-- -----------------------------------------------------------------------------------
SET LINESIZE 500
SET PAGESIZE 1000

COLUMN username FORMAT A15
COLUMN machine FORMAT A25
COLUMN logon_time FORMAT A20

  SELECT NVL (s.username, '(oracle)') AS username,
         s.inst_id,
         s.osuser,
         s.sid,
         s.serial#,
         p.spid,
         s.lockwait,
         s.status,
         s.module,
         s.machine,
         s.program,
         TO_CHAR (s.logon_Time, 'DD-MON-YYYY HH24:MI:SS') AS logon_time
    FROM gv$session s, gv$process p
   WHERE s.paddr = p.addr AND s.inst_id = p.inst_id
ORDER BY s.username, s.osuser;

SET PAGESIZE 14 
    
Resource Manager

  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/resource_manager/active_plan.sql
-- Author       : Tim Hall
-- Description  : Lists the currently active resource plan if one is set.
-- Call Syntax  : @active_plan
-- Requirements : Access to the v$ views.
-- Last Modified: 12/11/2004
-- -----------------------------------------------------------------------------------
SELECT name,
       is_top_plan
FROM   v$rsrc_plan
ORDER BY name;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/resource_manager/consumer_group_usage.sql
-- Author       : Tim Hall
-- Description  : Lists usage information of consumer groups.
-- Call Syntax  : @consumer_group_usage
-- Requirements : Access to the v$ views.
-- Last Modified: 12/11/2004
-- -----------------------------------------------------------------------------------
  SELECT name, consumed_cpu_time
    FROM v$rsrc_consumer_group
ORDER BY name;
     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/resource_manager/consumer_groups.sql
-- Author       : Tim Hall
-- Description  : Lists all consumer groups.
-- Call Syntax  : @consumer_groups
-- Requirements : Access to the DBA views.
-- Last Modified: 12/11/2004
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET VERIFY OFF

COLUMN status FORMAT A10
COLUMN comments FORMAT A50

  SELECT consumer_group, status, comments
    FROM dba_rsrc_consumer_groups
ORDER BY consumer_group;

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/resource_manager/plan_directives.sql
-- Author       : Tim Hall
-- Description  : Lists all plan directives.
-- Call Syntax  : @plan_directives (plan-name or all)
-- Requirements : Access to the DBA views.
-- Last Modified: 12/11/2004
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET VERIFY OFF

  SELECT plan,
         group_or_subplan,
         cpu_p1,
         cpu_p2,
         cpu_p3,
         cpu_p4
    FROM dba_rsrc_plan_directives
   WHERE plan = DECODE (UPPER ('&1'), 'ALL', plan, UPPER ('&1'))
ORDER BY plan,
         cpu_p1 DESC,
         cpu_p2 DESC,
         cpu_p3 DESC;
     
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/resource_manager/resource_plans.sql
-- Author       : Tim Hall
-- Description  : Lists all resource plans.
-- Call Syntax  : @resource_plans
-- Requirements : Access to the DBA views.
-- Last Modified: 12/11/2004
-- -----------------------------------------------------------------------------------
SET LINESIZE 200
SET VERIFY OFF

COLUMN status FORMAT A10
COLUMN comments FORMAT A50

SELECT plan,
       status,
       comments
FROM   dba_rsrc_plans
ORDER BY plan;
    
Script Creation

  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/backup.sql
-- Author       : Tim Hall
-- Description  : Creates a very basic hot-backup script. A useful starting point.
-- Call Syntax  : @backup
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 1000
SET TRIMOUT ON
SET FEEDBACK OFF
SPOOL Backup.txt

DECLARE
   CURSOR c_tablespace
   IS
        SELECT a.tablespace_name
          FROM dba_tablespaces a
      ORDER BY 1;

   CURSOR c_datafiles (in_ts_name IN VARCHAR2)
   IS
        SELECT a.file_name
          FROM dba_data_files a
         WHERE a.tablespace_name = in_ts_name
      ORDER BY 1;

   CURSOR c_archive_redo
   IS
      SELECT a.VALUE
        FROM v$parameter a
       WHERE a.name = 'log_archive_dest';

   v_sid          VARCHAR2 (100) := 'ORCL';
   v_backup_com   VARCHAR2 (100) := '!ocopy ';
   v_remove_com   VARCHAR2 (100) := '!rm';
   v_dest_loc     VARCHAR2 (100) := '/opt/oracleddds/dbs1/oradata/ddds/';
BEGIN
   DBMS_OUTPUT.Disable;
   DBMS_OUTPUT.Enable (1000000);

   DBMS_OUTPUT.Put_Line ('svrmgrl');
   DBMS_OUTPUT.Put_Line ('connect internal');

   DBMS_OUTPUT.Put_Line ('    ');
   DBMS_OUTPUT.Put_Line ('-- ----------------------');
   DBMS_OUTPUT.Put_Line ('-- Backup all tablespaces');
   DBMS_OUTPUT.Put_Line ('-- ----------------------');

   FOR cur_ts IN c_tablespace
   LOOP
      DBMS_OUTPUT.Put_Line ('    ');
      DBMS_OUTPUT.Put_Line (
         'ALTER TABLESPACE ' || cur_ts.tablespace_name || ' BEGIN BACKUP;');

      FOR cur_df IN c_datafiles (in_ts_name => cur_ts.tablespace_name)
      LOOP
         DBMS_OUTPUT.Put_Line (
               v_backup_com
            || ' '
            || cur_df.file_name
            || ' '
            || v_dest_loc
            || SUBSTR (cur_df.file_name,
                       INSTR (cur_df.file_name, '/', -1) + 1));
      END LOOP;

      DBMS_OUTPUT.Put_Line (
         'ALTER TABLESPACE ' || cur_ts.tablespace_name || ' END BACKUP;');
   END LOOP;

   DBMS_OUTPUT.Put_Line ('    ');
   DBMS_OUTPUT.Put_Line ('-- -----------------------------');
   DBMS_OUTPUT.Put_Line ('-- Backup the archived redo logs');
   DBMS_OUTPUT.Put_Line ('-- -----------------------------');

   FOR cur_ar IN c_archive_redo
   LOOP
      DBMS_OUTPUT.Put_Line (
         v_backup_com || ' ' || cur_ar.VALUE || '/* ' || v_dest_loc);
   END LOOP;


   DBMS_OUTPUT.Put_Line ('    ');
   DBMS_OUTPUT.Put_Line ('-- ----------------------');
   DBMS_OUTPUT.Put_Line ('-- Backup the controlfile');
   DBMS_OUTPUT.Put_Line ('-- ----------------------');
   DBMS_OUTPUT.Put_Line (
         'ALTER DATABASE BACKUP CONTROLFILE TO '''
      || v_dest_loc
      || v_sid
      || 'Controlfile.backup'';');
   DBMS_OUTPUT.Put_Line (
      v_backup_com || ' ' || v_dest_loc || v_sid || 'Controlfile.backup');
   DBMS_OUTPUT.Put_Line (
      v_remove_com || ' ' || v_dest_loc || v_sid || 'Controlfile.backup');

   DBMS_OUTPUT.Put_Line ('    ');
   DBMS_OUTPUT.Put_Line ('EXIT');
END;
/

PROMPT
SPOOL OFF
SET LINESIZE 80
SET FEEDBACK ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/db_link_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for DB links for the specific schema, or all schemas.
-- Call Syntax  : @db_link_ddl (schema or all)
-- Last Modified: 16/03/2013
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('DB_LINK', db_link, owner)
FROM   dba_db_links
WHERE  owner = DECODE(UPPER('&1'), 'ALL', owner, UPPER('&1'));

SET PAGESIZE 14 LINESIZE 1000 FEEDBACK ON VERIFY ON


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/directory_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for specified directory, or all directories.
-- Call Syntax  : @directory_ddl (directory or all)
-- Last Modified: 16/03/2013
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('DIRECTORY', directory_name)
FROM   dba_directories
WHERE  directory_name = DECODE(UPPER('&1'), 'ALL', directory_name, UPPER('&1'));

SET PAGESIZE 14 LINESIZE 1000 FEEDBACK ON VERIFY ON
    
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/drop_cons_on_table.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL to drop the UK & PK constraints on the specified table, or all tables.
-- Call Syntax  : @drop_cons_on_table (table-name or all) (schema)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 100
SET VERIFY OFF
SET FEEDBACK OFF
PROMPT

DECLARE

    CURSOR cu_cons IS
        SELECT *
        FROM   all_constraints a
        WHERE  a.table_name = Decode(Upper('&&1'),'ALL',a.table_name,Upper('&&1'))
        AND    a.owner      = Upper('&&2')
        AND    a.constraint_type IN ('P','U');

    -- ----------------------------------------------------------------------------------------
    FUNCTION Con_Columns(p_tab  IN  VARCHAR2,
                         p_con  IN  VARCHAR2)
        RETURN VARCHAR2 IS
    -- ----------------------------------------------------------------------------------------    
        CURSOR cu_col_cursor IS
            SELECT  a.column_name
            FROM    all_cons_columns a
            WHERE   a.table_name      = p_tab
            AND     a.constraint_name = p_con
            AND     a.owner           = Upper('&&2')
            ORDER BY a.position;
     
        l_result    VARCHAR2(1000);        
    BEGIN    
        FOR cur_rec IN cu_col_cursor LOOP
            IF cu_col_cursor%ROWCOUNT = 1 THEN
                l_result   := cur_rec.column_name;
            ELSE
                l_result   := l_result || ',' || cur_rec.column_name;
            END IF;
        END LOOP;
        RETURN Lower(l_result);        
    END;
    -- ----------------------------------------------------------------------------------------

BEGIN

    DBMS_Output.Disable;
    DBMS_Output.Enable(1000000);
    DBMS_Output.Put_Line('PROMPT');
    DBMS_Output.Put_Line('PROMPT Droping Constraints on ' || Upper('&&1'));
    FOR cur_rec IN cu_cons LOOP
        IF    cur_rec.constraint_type = 'P' THEN
            DBMS_Output.Put_Line('ALTER TABLE ' || Lower(cur_rec.table_name) || ' DROP PRIMARY KEY;');
        ELSIF cur_rec.constraint_type = 'R' THEN
            DBMS_Output.Put_Line('ALTER TABLE ' || Lower(cur_rec.table_name) || ' DROP CONSTRAINT ' || Lower(cur_rec.constraint_name) || ';');
        ELSIF cur_rec.constraint_type = 'U' THEN
            DBMS_Output.Put_Line('ALTER TABLE ' || Lower(cur_rec.table_name) || ' DROP UNIQUE (' || Con_Columns(cur_rec.table_name, cur_rec.constraint_name) || ');');
        END IF;
    END LOOP; 
 
END;
/

PROMPT
SET VERIFY ON
SET FEEDBACK ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/drop_fks_on_table.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL to drop the foreign keys on the specified table.
-- Call Syntax  : @drop_fks_on_table (table-name) (schema)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 100
SET VERIFY OFF
SET FEEDBACK OFF
PROMPT

DECLARE

    CURSOR cu_fks IS
        SELECT *
        FROM   all_constraints a
        WHERE  a.constraint_type = 'R'
        AND    a.table_name = Decode(Upper('&&1'),'ALL',a.table_name,Upper('&&1'))
        AND    a.owner      = Upper('&&2');

BEGIN

    DBMS_Output.Disable;
    DBMS_Output.Enable(1000000);
    DBMS_Output.Put_Line('PROMPT');
    DBMS_Output.Put_Line('PROMPT Droping Foreign Keys on ' || Upper('&&1'));
    FOR cur_rec IN cu_fks LOOP
        DBMS_Output.Put_Line('ALTER TABLE ' || Lower(cur_rec.table_name) || ' DROP CONSTRAINT ' || Lower(cur_rec.constraint_name) || ';');
    END LOOP; 

END;
/

PROMPT
SET VERIFY ON
SET FEEDBACK ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/drop_fks_ref_table.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL to drop the foreign keys that referenece the specified table.
-- Call Syntax  : @drop_fks_ref_table (table-name) (schema)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 100
SET VERIFY OFF
SET FEEDBACK OFF
PROMPT

DECLARE

    CURSOR cu_fks IS
        SELECT *
        FROM   all_constraints a
        WHERE  a.owner      = Upper('&&2')
        AND    a.constraint_type = 'R'
        AND    a.r_constraint_name IN (SELECT a1.constraint_name
                                       FROM   all_constraints a1
                                       WHERE  a1.table_name = Upper('&&1')
                                       AND    a1.owner      = Upper('&&2'));

BEGIN

    DBMS_Output.Put_Line('PROMPT');
    DBMS_Output.Put_Line('PROMPT Droping Foreign Keys to ' || Upper('&&1'));
    FOR cur_rec IN cu_fks LOOP
        DBMS_Output.Put_Line('ALTER TABLE ' || Lower(cur_rec.table_name) || ' DROP CONSTRAINT ' || Lower(cur_rec.constraint_name) || ';');
    END LOOP; 

END;
/

PROMPT
SET VERIFY ON
SET FEEDBACK ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/drop_indexes.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL to drop the indexes on the specified table, or all tables.
-- Call Syntax  : @drop_indexes (table-name or all) (schema)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 100
SET VERIFY OFF
SET FEEDBACK OFF
PROMPT

DECLARE

    CURSOR cu_idx IS
        SELECT *
        FROM   all_indexes a
        WHERE  a.table_name = Decode(Upper('&&1'),'ALL',a.table_name,Upper('&&1'))
        AND    a.owner      = Upper('&&2');

BEGIN

    DBMS_Output.Disable;
    DBMS_Output.Enable(1000000);
    DBMS_Output.Put_Line('PROMPT');
    DBMS_Output.Put_Line('PROMPT Droping Indexes on ' || Upper('&&1'));
    FOR cur_rec IN cu_idx LOOP
        DBMS_Output.Put_Line('DROP INDEX ' || Lower(cur_rec.index_name) || ';');
    END LOOP; 

END;
/

PROMPT
SET VERIFY ON
SET FEEDBACK ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/fks_on_table_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for the foreign keys on the specified table, or all tables.
-- Call Syntax  : @fks_on_table_ddl (schema) (table-name or all)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('REF_CONSTRAINT', constraint_name, owner)
FROM   all_constraints
WHERE  owner      = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'))
AND    constraint_type = 'R';

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/fks_ref_table_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for the foreign keys that reference the specified table.
-- Call Syntax  : @fks_ref_table_ddl (schema) (table-name)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('REF_CONSTRAINT', ac1.constraint_name, ac1.owner)
FROM   all_constraints ac1
       JOIN all_constraints ac2 ON ac1.r_owner = ac2.owner AND ac1.r_constraint_name = ac2.constraint_name
WHERE  ac2.owner      = UPPER('&1')
AND    ac2.table_name = UPPER('&2')
AND    ac2.constraint_type IN ('P','U')
AND    ac1.constraint_type = 'R';

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/index_monitoring_on.sql
-- Author       : Tim Hall
-- Description  : Sets monitoring off for the specified table indexes.
-- Call Syntax  : @index_monitoring_on (schema) (table-name or all)
-- Last Modified: 04/02/2005
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF
SPOOL temp.sql

SELECT 'ALTER INDEX "' || i.owner || '"."' || i.index_name || '" NOMONITORING USAGE;'
FROM   dba_indexes i
WHERE  owner      = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'));

SPOOL OFF

SET PAGESIZE 18
SET FEEDBACK ON

--@temp.sql

     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/index_monitoring_on.sql
-- Author       : Tim Hall
-- Description  : Sets monitoring on for the specified table indexes.
-- Call Syntax  : @index_monitoring_on (schema) (table-name or all)
-- Last Modified: 04/02/2005
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF
SPOOL temp.sql

SELECT 'ALTER INDEX "' || i.owner || '"."' || i.index_name || '" MONITORING USAGE;'
FROM   dba_indexes i
WHERE  owner      = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'));

SPOOL OFF

SET PAGESIZE 18
SET FEEDBACK ON

--@temp.sql

-- DDL for table and its dependencies:
-- Igor Chistov v1.1

SPO C:\TEMP\DDL_OBJECT.SQL
SET LONG 200000 PAGES 0 LINES 200 FEEDBACK OFF SERVEROUTPUT ON TERMOUT ON

DECLARE
    V_OBJECT_TYPE    VARCHAR2 (20) DEFAULT 'TABLE';      --object type - TABLE
    V_APP_USER       VARCHAR2 (20) DEFAULT 'OWS';                 --app schema
    V_OBJECT         VARCHAR2 (20) DEFAULT 'ACCOUNT';         --app table name
    V_DLL            CLOB;
    V_OBJECT_COUNT   NUMBER;
BEGIN
    SELECT DBMS_METADATA.GET_DDL (V_OBJECT_TYPE, V_OBJECT, V_APP_USER)
      INTO V_DLL
      FROM DUAL;

    DBMS_OUTPUT.PUT_LINE (V_DLL);
    DBMS_OUTPUT.PUT_LINE (';');

    SELECT COUNT (1)
      INTO V_OBJECT_COUNT
      FROM DBA_INDEXES
     WHERE TABLE_NAME = V_OBJECT AND TABLE_OWNER = V_APP_USER;

    DBMS_OUTPUT.PUT_LINE ('-- dependent indexes: ' || V_OBJECT_COUNT);

    IF V_OBJECT_COUNT > 0
    THEN
        SELECT DBMS_METADATA.GET_DEPENDENT_DDL ('INDEX',
                                                V_OBJECT,
                                                V_APP_USER)
          INTO V_DLL
          FROM DUAL;

        DBMS_OUTPUT.PUT_LINE (V_DLL);
        DBMS_OUTPUT.PUT_LINE (';');
    END IF;

    V_OBJECT_COUNT := 0;

    SELECT COUNT (1)
      INTO V_OBJECT_COUNT
      FROM DBA_TRIGGERS
     WHERE TABLE_NAME = V_OBJECT AND TABLE_OWNER = V_APP_USER;

    DBMS_OUTPUT.PUT_LINE ('-- dependent triggers: ' || V_OBJECT_COUNT);

    IF V_OBJECT_COUNT > 0
    THEN
        SELECT DBMS_METADATA.GET_DEPENDENT_DDL ('TRIGGER',
                                                V_OBJECT,
                                                V_APP_USER)
          INTO V_DLL
          FROM DUAL;

        DBMS_OUTPUT.PUT_LINE (V_DLL);
        DBMS_OUTPUT.PUT_LINE (';');
    END IF;

    V_OBJECT_COUNT := 0;
    DBMS_OUTPUT.PUT_LINE ('--' || V_OBJECT_TYPE || ' grants:');

    FOR REC
        IN (SELECT    'grant '
                   || PRIVILEGE
                   || ' on '
                   || OWNER
                   || '.'
                   || TABLE_NAME
                   || ' TO '
                   || GRANTEE
                   || ' ;'    GRANT_SQL
              FROM DBA_TAB_PRIVS
             WHERE TABLE_NAME = V_OBJECT AND OWNER = V_APP_USER)
    LOOP
        DBMS_OUTPUT.PUT_LINE (REC.GRANT_SQL);
    END LOOP;
END;
/

SPO OFF
EXIT

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/logon_as_user.sql
-- Author       : Tim Hall
-- Description  : Displays the DDL for a specific user.
-- Call Syntax  : @logon_as_user (username)
-- Last Modified: 28/01/2006
-- -----------------------------------------------------------------------------------

DECLARE
   l_username   VARCHAR2 (30) := UPPER ('&1');
   l_orig_pwd   VARCHAR2 (32767);
BEGIN
   SELECT password
     INTO l_orig_pwd
     FROM sys.user$
    WHERE name = l_username;

   DBMS_OUTPUT.put_line ('--');
   DBMS_OUTPUT.put_line (
      'alter user ' || l_username || ' identified by DummyPassword1;');
   DBMS_OUTPUT.put_line ('conn ' || l_username || '/DummyPassword1');

   DBMS_OUTPUT.put_line ('--');
   DBMS_OUTPUT.put_line ('-- Do something here.');
   DBMS_OUTPUT.put_line ('--');

   DBMS_OUTPUT.put_line ('conn / as sysdba');
   DBMS_OUTPUT.put_line (
         'alter user '
      || l_username
      || ' identified by values '''
      || l_orig_pwd
      || ''';');
END;
/

 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/monitoring_on.sql
-- Author       : Tim Hall
-- Description  : Sets monitoring off for the specified tables.
-- Call Syntax  : @monitoring_on (schema) (table-name or all)
-- Last Modified: 21/03/2003
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF
SPOOL temp.sql

SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" NOMONITORING;'
FROM   dba_tables
WHERE  owner      = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'))
AND    monitoring = 'YES';

SPOOL OFF

SET PAGESIZE 18
SET FEEDBACK ON

@temp.sql
 
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/monitoring_on.sql
-- Author       : Tim Hall
-- Description  : Sets monitoring on for the specified tables.
-- Call Syntax  : @monitoring_on (schema) (table-name or all)
-- Last Modified: 21/03/2003
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF
SPOOL temp.sql

SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" MONITORING;'
FROM   dba_tables
WHERE  owner       = UPPER('&1')
AND    table_name  = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'))
AND    monitoring != 'YES';

SPOOL OFF

SET PAGESIZE 18
SET FEEDBACK ON

@temp.sql

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/object_grants.sql
-- Author       : Tim Hall
-- Description  : Displays the DDL for all grants on a specific object.
-- Call Syntax  : @object_grants (owner) (object_name)
-- Last Modified: 28/01/2006
-- -----------------------------------------------------------------------------------

set long 1000000 linesize 1000 pagesize 0 feedback off trimspool on verify off
column ddl format a1000

begin
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SQLTERMINATOR', true);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'PRETTY', true);
end;
/
 
select dbms_metadata.get_dependent_ddl('OBJECT_GRANT', UPPER('&2'), UPPER('&1')) AS ddl
from   dual;

set linesize 80 pagesize 14 feedback on trimspool on verify on


  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/profile_ddl.sql
-- Author       : Tim Hall
-- Description  : Displays the DDL for the specified profile(s).
-- Call Syntax  : @profile_ddl (profile | part of profile)
-- Last Modified: 28/01/2006
-- -----------------------------------------------------------------------------------

set long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on
column ddl format a1000

begin
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SQLTERMINATOR', true);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'PRETTY', true);
end;
/

select dbms_metadata.get_ddl('PROFILE', profile) as profile_ddl
from   (select distinct profile
        from   dba_profiles)
where  profile like upper('%&1%');

set linesize 80 pagesize 14 feedback on verify on

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/rbs_structure.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for specified segment, or all segments.
-- Call Syntax  : @rbs_structure (segment-name or all)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 100
SET VERIFY OFF
SET FEEDBACK OFF
PROMPT

DECLARE

    CURSOR cu_rs IS
        SELECT a.segment_name,
               a.tablespace_name,
               a.initial_extent,
               a.next_extent,
               a.min_extents,
               a.max_extents,
               a.pct_increase,
               b.bytes
        FROM   dba_rollback_segs a,
               dba_segments      b
        WHERE  a.segment_name = b.segment_name
        AND    a.segment_name  = Decode(Upper('&&1'), 'ALL',a.segment_name, Upper('&&1'))
        ORDER BY a.segment_name;
 
BEGIN

    DBMS_Output.Disable;
    DBMS_Output.Enable(1000000);

    FOR cur_rs IN cu_rs LOOP
        DBMS_Output.Put_Line('PROMPT');
        DBMS_Output.Put_Line('PROMPT Creating Rollback Segment ' || cur_rs.segment_name);
        DBMS_Output.Put_Line('CREATE ROLLBACK SEGMENT ' || Lower(cur_rs.segment_name));
        DBMS_Output.Put_Line('TABLESPACE ' || Lower(cur_rs.tablespace_name));        
        DBMS_Output.Put_Line('STORAGE	(');
        DBMS_Output.Put_Line('		INITIAL     ' || Trunc(cur_rs.initial_extent/1024) || 'K');
        DBMS_Output.Put_Line('		NEXT        ' || Trunc(cur_rs.next_extent/1024) || 'K');
        DBMS_Output.Put_Line('		MINEXTENTS  ' || cur_rs.min_extents);
        DBMS_Output.Put_Line('		MAXEXTENTS  ' || cur_rs.max_extents);
        DBMS_Output.Put_Line('		PCTINCREASE ' || cur_rs.pct_increase);
        DBMS_Output.Put_Line('	)');
        DBMS_Output.Put_Line('/');        
        DBMS_Output.Put_Line('	');        
    END LOOP;

    DBMS_Output.Put_Line('	');

END;
/

SET VERIFY ON
SET FEEDBACK ON


-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/recreate_table.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL to recreate the specified table.
-- Comments     : Mostly used when dropping columns prior to Oracle 8i. Not updated since Oracle 7.3.4.
-- Requirements : Requires a number of the other creation scripts.
-- Call Syntax  : @recreate_table (table-name) (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET SERVEROUTPUT ON
SET LINESIZE 100
SET VERIFY OFF
SET FEEDBACK OFF
SET TERMOUT OFF
SPOOL ReCreate_&&1
PROMPT

-- ----------------------------------------------
-- Reset the buffer size and display script title
-- ----------------------------------------------
BEGIN
    DBMS_Output.Disable;
    DBMS_Output.Enable(1000000);
    DBMS_Output.Put_Line('-------------------------------------------------------------');
    DBMS_Output.Put_Line('-- Author        : Tim Hall');
    DBMS_Output.Put_Line('-- Creation Date : ' || To_Char(SYSDATE,'DD/MM/YYYY HH24:MI:SS'));
    DBMS_Output.Put_Line('-- Description   : Re-creation script for ' ||  Upper('&&1'));
    DBMS_Output.Put_Line('-------------------------------------------------------------');
END;
/
       
-- ------------------------------------
-- Drop existing FKs to specified table
-- ------------------------------------
@Drop_FKs_Ref_Table &&1 &&2    

-- -----------------
-- Drop FKs on table
-- -----------------
@Drop_FKs_On_Table &&1 &&2  
    
-- -------------------------
-- Drop constraints on table
-- -------------------------
@Drop_Cons_On_Table &&1 &&2  
    
-- ---------------------
-- Drop indexes on table
-- ---------------------
@Drop_Indexes &&1 &&2 
    
-- -----------------------------------------
-- Rename existing table - prefix with 'tmp'
-- -----------------------------------------
SET VERIFY OFF
SET FEEDBACK OFF
BEGIN
    DBMS_Output.Put_Line('	');
    DBMS_Output.Put_Line('PROMPT');
    DBMS_Output.Put_Line('PROMPT Renaming ' || Upper('&&1') || ' to TMP_' || Upper('&&1'));
    DBMS_Output.Put_Line('RENAME ' || Lower('&&1') || ' TO tmp_' || Lower('&&1'));
    DBMS_Output.Put_Line('/');
END;
/
    
-- ---------------
-- Re-Create table
-- ---------------
@Table_Structure &&1 &&2

-- ---------------------
-- Re-Create constraints
-- ---------------------
@Table_Constraints &&1 &&2

-- ---------------------
-- Recreate FKs on table
-- ---------------------
@FKs_On_Table &&1 &&2

-- -----------------
-- Re-Create indexes
-- -----------------
@Table_Indexes &&1 &&2
    
-- --------------------------
-- Build up population insert
-- --------------------------
SET VERIFY OFF
SET FEEDBACK OFF
DECLARE

    CURSOR cu_columns IS
        SELECT Lower(column_name) column_name
        FROM   all_tab_columns atc
        WHERE  atc.table_name = Upper('&&1')
        AND    atc.owner      = Upper('&&2');

BEGIN

    DBMS_Output.Put_Line('	');
    DBMS_Output.Put_Line('PROMPT');
    DBMS_Output.Put_Line('PROMPT Populating ' || Upper('&&1') || ' from TPM_' || Upper('&&1'));
    DBMS_Output.Put_Line('INSERT INTO ' || Lower('&&1'));
    DBMS_Output.Put('SELECT ');
    FOR cur_rec IN cu_columns LOOP
        IF cu_columns%ROWCOUNT != 1 THEN
            DBMS_Output.Put_Line(',');
        END IF;
        DBMS_Output.Put('	a.' || cur_rec.column_name);
    END LOOP; 
    DBMS_Output.New_Line;
    DBMS_Output.Put_Line('FROM	tmp_' || Lower('&&1') || ' a');
    DBMS_Output.Put_Line('/');
      
    -- --------------
    -- Drop tmp table
    -- --------------
    DBMS_Output.Put_Line('	');
    DBMS_Output.Put_Line('PROMPT');
    DBMS_Output.Put_Line('PROMPT Droping TMP_' || Upper('&&1'));
    DBMS_Output.Put_Line('DROP TABLE tmp_' || Lower('&&1'));
    DBMS_Output.Put_Line('/');

END;
/

-- ---------------------
-- Recreate FKs to table
-- ---------------------
@FKs_Ref_Table &&1 &&2

SET VERIFY OFF
SET FEEDBACK OFF
BEGIN    
    DBMS_Output.Put_Line('	');
    DBMS_Output.Put_Line('-------------------------------------------------------------');
    DBMS_Output.Put_Line('-- END Re-creation script for ' || Upper('&&1'));
    DBMS_Output.Put_Line('-------------------------------------------------------------');
END;
/

SPOOL OFF
PROMPT
SET VERIFY ON
SET FEEDBACK ON
SET TERMOUT ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/role_ddl.sql
-- Author       : Tim Hall
-- Description  : Displays the DDL for a specific role.
-- Call Syntax  : @role_ddl (role)
-- Last Modified: 28/01/2006
-- -----------------------------------------------------------------------------------

set long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on
column ddl format a1000

begin
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'SQLTERMINATOR', true);
   dbms_metadata.set_transform_param (dbms_metadata.session_transform, 'PRETTY', true);
end;
/
 
variable v_role VARCHAR2(30);

exec :v_role := upper('&1');

select dbms_metadata.get_ddl('ROLE', r.role) AS ddl
from   dba_roles r
where  r.role = :v_role
union all
select dbms_metadata.get_granted_ddl('ROLE_GRANT', rp.grantee) AS ddl
from   dba_role_privs rp
where  rp.grantee = :v_role
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('SYSTEM_GRANT', sp.grantee) AS ddl
from   dba_sys_privs sp
where  sp.grantee = :v_role
and    rownum = 1
union all
select dbms_metadata.get_granted_ddl('OBJECT_GRANT', tp.grantee) AS ddl
from   dba_tab_privs tp
where  tp.grantee = :v_role
and    rownum = 1
/

set linesize 80 pagesize 14 feedback on verify on

 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/sequence_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for the specified sequence, or all sequences.
-- Call Syntax  : @sequence_ddl (schema-name) (sequence-name or all)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('SEQUENCE', sequence_name, sequence_owner)
FROM   all_sequences
WHERE  sequence_owner = UPPER('&1')
AND    sequence_name  = DECODE(UPPER('&2'), 'ALL', sequence_name, UPPER('&2'));

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON


-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/synonym_by_object_owner_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for the specified synonym, or all synonyms.
--                Search based on owner of the object, not the synonym.
-- Call Syntax  : @synonym_by_object_owner_ddl (schema-name) (synonym-name or all)
-- Last Modified: 08/07/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('SYNONYM', synonym_name, owner)
FROM   all_synonyms
WHERE  table_owner = UPPER('&1')
AND    synonym_name  = DECODE(UPPER('&2'), 'ALL', synonym_name, UPPER('&2'));

SET PAGESIZE 14 FEEDBACK ON VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/synonym_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for the specified synonym, or all synonyms.
--                Search based on owner of the synonym.
-- Call Syntax  : @synonym_ddl (schema-name) (synonym-name or all)
-- Last Modified: 08/07/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('SYNONYM', synonym_name, owner)
FROM   all_synonyms
WHERE  owner = UPPER('&1')
AND    synonym_name  = DECODE(UPPER('&2'), 'ALL', synonym_name, UPPER('&2'));

SET PAGESIZE 14 FEEDBACK ON VERIFY ON
     
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/synonym_public_remote_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for public synonyms to remote objects.
-- Call Syntax  : @synonym_remote_ddl
-- Last Modified: 08/07/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('SYNONYM', synonym_name, owner)
FROM   dba_synonyms
WHERE  owner = 'PUBLIC'
AND    db_link IS NOT NULL;

SET PAGESIZE 14 FEEDBACK ON VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/table_constraints_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the UK & PK constraint DDL for specified table, or all tables.
-- Call Syntax  : @table_constraints_ddl (schema-name) (table-name or all)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('CONSTRAINT', constraint_name, owner)
FROM   all_constraints
WHERE  owner      = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'))
AND    constraint_type IN ('U', 'P');

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/table_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for specified table, or all tables.
-- Call Syntax  : @table_ddl (schema) (table-name or all)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
   -- Uncomment the following lines if you need them.
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SEGMENT_ATTRIBUTES', false);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'STORAGE', false);
END;
/

SELECT DBMS_METADATA.get_ddl ('TABLE', table_name, owner)
FROM   all_tables
WHERE  owner      = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'));

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/table_grants_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for all grants on the specified table.
-- Call Syntax  : @table_grants_ddl (schema) (table_name)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT dbms_metadata.get_dependent_ddl('OBJECT_GRANT', UPPER('&2'), UPPER('&1')) from dual;

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/table_indexes_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the index DDL for specified table, or all tables.
-- Call Syntax  : @table_indexes_ddl (schema-name) (table-name or all)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
   -- Uncomment the following lines if you need them.
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SEGMENT_ATTRIBUTES', false);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'STORAGE', false);
END;
/

SELECT DBMS_METADATA.get_ddl ('INDEX', index_name, owner)
FROM   all_indexes
WHERE  owner      = UPPER('&1')
AND    table_name = DECODE(UPPER('&2'), 'ALL', table_name, UPPER('&2'));

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/table_triggers_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for all triggers on the specified table.
-- Call Syntax  : @table_triggers_ddl (schema) (table_name)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner)
FROM   all_triggers
WHERE  table_owner = UPPER('&1')
AND    table_name  = UPPER('&2');

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/tablespace_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for the specified tablespace, or all tablespaces.
-- Call Syntax  : @tablespace_ddl (tablespace-name or all)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('TABLESPACE', tablespace_name)
FROM   dba_tablespaces
WHERE  tablespace_name = DECODE(UPPER('&1'), 'ALL', tablespace_name, UPPER('&1'));

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON

  tablespace_structure.sql 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/trigger_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for specified trigger, or all trigger.
-- Call Syntax  : @trigger_ddl (schema) (trigger-name or all)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('TRIGGER', trigger_name, owner)
FROM   all_triggers
WHERE  owner        = UPPER('&1')
AND    trigger_name = DECODE(UPPER('&2'), 'ALL', trigger_name, UPPER('&2'));

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON

-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/user_ddl.sql
-- Author       : Tim Hall
-- Description  : Displays the DDL for a specific user.
-- Call Syntax  : @user_ddl (username)
-- Last Modified: 28/01/2006
-- -----------------------------------------------------------------------------------

set long 20000 longchunksize 20000 pagesize 0 linesize 1000 feedback off verify off trimspool on
column ddl format a1000

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform,
                                      'SQLTERMINATOR',
                                      TRUE);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform,
                                      'PRETTY',
                                      TRUE);
END;
/

VARIABLE v_username VARCHAR2(30);

EXEC :v_username := upper('&1');

SELECT DBMS_METADATA.get_ddl ('USER', u.username) AS ddl
  FROM dba_users u
 WHERE u.username = :v_username
UNION ALL
SELECT DBMS_METADATA.get_granted_ddl ('TABLESPACE_QUOTA', tq.username) AS ddl
  FROM dba_ts_quotas tq
 WHERE tq.username = :v_username AND ROWNUM = 1
UNION ALL
SELECT DBMS_METADATA.get_granted_ddl ('ROLE_GRANT', rp.grantee) AS ddl
  FROM dba_role_privs rp
 WHERE rp.grantee = :v_username AND ROWNUM = 1
UNION ALL
SELECT DBMS_METADATA.get_granted_ddl ('SYSTEM_GRANT', sp.grantee) AS ddl
  FROM dba_sys_privs sp
 WHERE sp.grantee = :v_username AND ROWNUM = 1
UNION ALL
SELECT DBMS_METADATA.get_granted_ddl ('OBJECT_GRANT', tp.grantee) AS ddl
  FROM dba_tab_privs tp
 WHERE tp.grantee = :v_username AND ROWNUM = 1
UNION ALL
SELECT DBMS_METADATA.get_granted_ddl ('DEFAULT_ROLE', rp.grantee) AS ddl
  FROM dba_role_privs rp
 WHERE rp.grantee = :v_username AND rp.default_role = 'YES' AND ROWNUM = 1
UNION ALL
SELECT TO_CLOB ('/* Start profile creation script in case they are missing')
          AS ddl
  FROM dba_users u
 WHERE u.username = :v_username AND u.profile = 'DEFAULT' AND ROWNUM = 1
UNION ALL
SELECT DBMS_METADATA.get_ddl ('PROFILE', u.profile) AS ddl
  FROM dba_users u
 WHERE u.username = :v_username AND u.profile = 'DEFAULT'
UNION ALL
SELECT TO_CLOB ('End profile creation script */') AS ddl
  FROM dba_users u
 WHERE u.username = :v_username AND u.profile = 'DEFAULT' AND ROWNUM = 1
/

set linesize 80 pagesize 14 feedback on trimspool on verify on

  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/script_creation/view_ddl.sql
-- Author       : Tim Hall
-- Description  : Creates the DDL for the specified view.
-- Call Syntax  : @view_ddl (schema-name) (view-name)
-- Last Modified: 16/03/2013 - Rewritten to use DBMS_METADATA
-- -----------------------------------------------------------------------------------
SET LONG 20000 LONGCHUNKSIZE 20000 PAGESIZE 0 LINESIZE 1000 FEEDBACK OFF VERIFY OFF TRIMSPOOL ON

BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.get_ddl ('VIEW', view_name, owner)
FROM   all_views
WHERE  owner      = UPPER('&1')
AND    view_name = DECODE(UPPER('&2'), 'ALL', view_name, UPPER('&2'));

SET PAGESIZE 14 LINESIZE 100 FEEDBACK ON VERIFY ON
 
    
Security



  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/security/grant_delete.sql
-- Author       : Tim Hall
-- Description  : Grants delete on current schemas tables to the specified user/role.
-- Call Syntax  : @grant_delete (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'GRANT DELETE ON "' || u.table_name || '" TO &1;'
FROM   user_tables u
WHERE  NOT EXISTS (SELECT '1'
                   FROM   all_tab_privs a
                   WHERE  a.grantee    = UPPER('&1')
                   AND    a.privilege  = 'DELETE'
                   AND    a.table_name = u.table_name);

SPOOL OFF

@temp.sql

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/security/grant_execute.sql
-- Author       : Tim Hall
-- Description  : Grants execute on current schemas code objects to the specified user/role.
-- Call Syntax  : @grant_execute (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'GRANT EXECUTE ON "' || u.object_name || '" TO &1;'
FROM   user_objects u
WHERE  u.object_type IN ('PACKAGE','PROCEDURE','FUNCTION')
AND    NOT EXISTS (SELECT '1'
                   FROM   all_tab_privs a
                   WHERE  a.grantee    = UPPER('&1')
                   AND    a.privilege  = 'EXECUTE'
                   AND    a.table_name = u.object_name);

SPOOL OFF

-- Comment out following line to prevent immediate run
--temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/security/grant_insert.sql
-- Author       : Tim Hall
-- Description  : Grants insert on current schemas tables to the specified user/role.
-- Call Syntax  : @grant_insert (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'GRANT INSERT ON "' || u.table_name || '" TO &1;'
FROM   user_tables u
WHERE  NOT EXISTS (SELECT '1'
                   FROM   all_tab_privs a
                   WHERE  a.grantee    = UPPER('&1')
                   AND    a.privilege  = 'INSERT'
                   AND    a.table_name = u.table_name);

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/security/grant_select.sql
-- Author       : Tim Hall
-- Description  : Grants select on current schemas tables, views & sequences to the specified user/role.
-- Call Syntax  : @grant_select (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'GRANT SELECT ON "' || u.object_name || '" TO &1;'
FROM   user_objects u
WHERE  u.object_type IN ('TABLE','VIEW','SEQUENCE')
AND    NOT EXISTS (SELECT '1'
                   FROM   all_tab_privs a
                   WHERE  a.grantee    = UPPER('&1')
                   AND    a.privilege  = 'SELECT'
                   AND    a.table_name = u.object_name);

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

     
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/security/grant_update.sql
-- Author       : Tim Hall
-- Description  : Grants update on current schemas tables to the specified user/role.
-- Call Syntax  : @grant_update (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'GRANT UPDATE ON "' || u.table_name || '" TO &1;'
FROM   user_tables u
WHERE  NOT EXISTS (SELECT '1'
                   FROM   all_tab_privs a
                   WHERE  a.grantee    = UPPER('&1')
                   AND    a.privilege  = 'UPDATE'
                   AND    a.table_name = u.table_name);

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/security/package_synonyms.sql
-- Author       : Tim Hall
-- Description  : Creates synonyms in the current schema for all code objects in the specified schema.
-- Call Syntax  : @package_synonyms (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'CREATE SYNONYM "' || a.object_name || '" FOR "' || a.owner || '"."' || a.object_name || '";'
FROM   all_objects a
WHERE  a.object_type IN ('PACKAGE','PROCEDURE','FUNCTION')
AND    a.owner = UPPER('&1')
AND    NOT EXISTS (SELECT '1'
                   FROM   user_synonyms u
                   WHERE  u.synonym_name = a.object_name
                   AND    u.table_owner  = UPPER('&1'));


SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/security/schema_write_access.sql
-- Author       : Tim Hall
-- Description  : Displays the users with write access to a specified schema.
-- Requirements : Access to the DBA views.
-- Call Syntax  : @schema_write_access.sql (schema-name)
-- Last Modified: 05-MAY-2012
-- -----------------------------------------------------------------------------------

set verify off

-- Direct grants
SELECT DISTINCT grantee
  FROM dba_tab_privs
 WHERE privilege IN ('INSERT', 'UPDATE', 'DELETE') AND owner = UPPER ('&1')
UNION
-- Grants via a role
SELECT DISTINCT grantee
  FROM dba_role_privs JOIN dba_users ON grantee = username
 WHERE granted_role IN
          (SELECT DISTINCT role
             FROM role_tab_privs
            WHERE     privilege IN ('INSERT', 'UPDATE', 'DELETE')
                  AND owner = UPPER ('&1')
           UNION
           SELECT DISTINCT role
             FROM role_sys_privs
            WHERE privilege IN
                     ('INSERT ANY TABLE',
                      'UPDATE ANY TABLE',
                      'DELETE ANY TABLE'))
UNION
-- Access via ANY sys privileges
SELECT DISTINCT grantee
  FROM dba_sys_privs JOIN dba_users ON grantee = username
 WHERE privilege IN
          ('INSERT ANY TABLE', 'UPDATE ANY TABLE', 'DELETE ANY TABLE');
 
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/security/sequence_synonyms.sql
-- Author       : Tim Hall
-- Description  : Creates synonyms in the current schema for all sequences in the specified schema.
-- Call Syntax  : @sequence_synonyms (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'CREATE SYNONYM "' || a.object_name || '" FOR "' || a.owner || '"."' || a.object_name || '";'
FROM   all_objects a
WHERE  a.object_type = 'SEQUENCE'
AND    a.owner       = UPPER('&1')
AND    NOT EXISTS (SELECT '1'
                   FROM   user_synonyms a1
                   WHERE  a1.synonym_name = a.object_name
                   AND    a1.table_owner  = UPPER('&1'));


SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

     
-- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/security/table_synonyms.sql
-- Author       : Tim Hall
-- Description  : Creates synonyms in the current schema for all tables in the specified schema.
-- Call Syntax  : @table_synonyms (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'CREATE SYNONYM "' || a.table_name || '" FOR "' || a.owner || '"."' || a.table_name || '";'
FROM   all_tables a
WHERE  NOT EXISTS (SELECT '1'
                   FROM   user_synonyms u
                   WHERE  u.synonym_name = a.table_name
                   AND    u.table_owner  = UPPER('&1'))
AND    a.owner = UPPER('&1');

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON 
  
  -- -----------------------------------------------------------------------------------
-- File Name    : http://oracle-base.com/dba/security/view_synonyms.sql
-- Author       : Tim Hall
-- Description  : Creates synonyms in the current schema for all views in the specified schema.
-- Call Syntax  : @view_synonyms (schema-name)
-- Last Modified: 28/01/2001
-- -----------------------------------------------------------------------------------
SET PAGESIZE 0
SET FEEDBACK OFF
SET VERIFY OFF

SPOOL temp.sql

SELECT 'CREATE SYNONYM "' || a.view_name || '" FOR "' || a.owner || '"."' || a.view_name || '";'
FROM   all_views a
WHERE  a.owner = UPPER('&1')
AND    NOT EXISTS (SELECT '1'
                   FROM   user_synonyms u
                   WHERE  u.synonym_name = a.view_name
                   AND    u.table_owner  = UPPER('&1'));

SPOOL OFF

-- Comment out following line to prevent immediate run
--@temp.sql

SET PAGESIZE 14
SET FEEDBACK ON
SET VERIFY ON

-- -----------------------------------------------------------------------------------
-- Block corruption / lologged block queries 
-- -----------------------------------------------------------------------------------

set lines 1000
set pages 101
alter session set nls_date_format='DD-MM-YYYY HH24:MI:SS';

--fast
select FILE#, BLOCK#, BLOCKS, to_char(NONLOGGED_START_CHANGE#, '999999999999999') NONLOGGED_START_CHANGE#,NONLOGGED_START_TIME,OBJECT# from V$NONLOGGED_BLOCK;

--slow
SELECT e.owner, e.segment_type, e.segment_name, e.partition_name, c.file#
, greatest(e.block_id, c.block#) corr_start_block#
, least(e.block_id+e.blocks-1, c.block#+c.blocks-1) corr_end_block#
, least(e.block_id+e.blocks-1, c.block#+c.blocks-1)
- greatest(e.block_id, c.block#) + 1 blocks_corrupted
, null description
FROM dba_extents e, v$nonlogged_block c
WHERE e.file_id = c.file#
AND e.block_id <= c.block# + c.blocks - 1
AND e.block_id + e.blocks - 1 >= c.block#
UNION
SELECT null owner, null segment_type, null segment_name, null partition_name, c.file#
, greatest(f.block_id, c.block#) corr_start_block#
, least(f.block_id+f.blocks-1, c.block#+c.blocks-1) corr_end_block#
, least(f.block_id+f.blocks-1, c.block#+c.blocks-1)
- greatest(f.block_id, c.block#) + 1 blocks_corrupted
, 'Free Block' description
FROM dba_free_space f, v$nonlogged_block c
WHERE f.file_id = c.file#
AND f.block_id <= c.block# + c.blocks - 1
AND f.block_id + f.blocks - 1 >= c.block#
order by file#, corr_start_block#;

-- -----------------------------------------------------------------------------------
-- Get the estimated memory footprint of an existing database. 
-- -----------------------------------------------------------------------------------

---- Get the SGA footprint of a database instance:
SELECT round(sum(value)/1024/1024) "current TOTAL SGA (MB)" FROM v$sga;

---- Get the current PGA consumption of a database instance:
select round(sum(PGA_MAX_MEM)/1024/1024) "current TOTAL MAX PGA (MB)" from v$process;

-- TABLESPACE free space percent % (with AUTOEXTEND)

 select tablespace_name,round(used_space*8192/1024/1024) used_MB,round(tablespace_size*8192/1024/1024) size_MB,round(USED_PERCENT,1) PERCENT_USED from DBA_TABLESPACE_USAGE_METRICS --where

SELECT A.TABLESPACE_NAME,
       ROUND (
             (((A.TABLESPACE_SIZE * 8192)) - ((A.USED_SPACE * 8192)))
           / 1024
           / 1024,
           0)                                                 MB_FREE,
       ROUND ((A.TABLESPACE_SIZE * 8192) / 1024 / 1024, 1)    MB_TOTAL,
         (ROUND (((A.TABLESPACE_SIZE - A.USED_SPACE) / A.TABLESPACE_SIZE), 3))
       * 100                                                  PERCENT_FREE,
         100
       -   (ROUND (((A.TABLESPACE_SIZE - A.USED_SPACE) / A.TABLESPACE_SIZE),
                   3))
         * 100                                                PERCENT_USED
  FROM DBA_TABLESPACE_USAGE_METRICS A, DBA_TABLESPACES B
 WHERE A.TABLESPACE_NAME = B.TABLESPACE_NAME AND B.CONTENTS != 'TEMPORARY';
 
 -- Checkpoint and change for all datafile headers (freezed after begin backup)
 
 select file#,tablespace_name,CHECKPOINT_CHANGE#,CHECKPOINT_TIME from V$DATAFILE_HEADER order by 4 desc, 3 desc;

    
