-- TOAD DB monitor collect

SELECT SYSDATE,
         SUM (DECODE (name, 'table scans (long tables)', VALUE, 0))
       / (  SUM (DECODE (name, 'table scans (long tables)', VALUE, 0))
          + SUM (DECODE (name, 'table scans (short tables)', VALUE, 0)))
       * 100
          non_indexed_sql,
         100
       -   SUM (DECODE (name, 'table scans (long tables)', VALUE, 0))
         / (  SUM (DECODE (name, 'table scans (long tables)', VALUE, 0))
            + SUM (DECODE (name, 'table scans (short tables)', VALUE, 0)))
         * 100
          indexed_sql,
       SUM (DECODE (name, 'db block changes', VALUE, 0)) block_changes,
       SUM (DECODE (name, 'db block gets', VALUE, 0)) current_reads,
       SUM (DECODE (name, 'consistent gets', VALUE, 0)) consistent_reads,
       SUM (DECODE (name, 'physical reads', VALUE, 0)) datafile_reads,
       SUM (DECODE (name, 'physical writes', VALUE, 0)) datafile_writes,
       SUM (DECODE (name, 'redo writes', VALUE, 0)) redo_writes,
       SUM (DECODE (name, 'parse count (total)', VALUE, 0)) parse,
       SUM (DECODE (name, 'execute count', VALUE, 0)) execute,
       SUM (DECODE (name, 'user commits', VALUE, 0)) commit,
       SUM (DECODE (name, 'user rollbacks', VALUE, 0)) rollback
  FROM V$SYSSTAT
 WHERE NAME IN
          ('table scans (long tables)',
           'table scans (short tables)',
           'db block changes',
           'db block gets',
           'consistent gets',
           'physical reads',
           'physical writes',
           'redo writes',
           'redo writes',
           'parse count (total)',
           'execute count',
           'user commits',
           'user rollbacks');
		   
		   
SELECT SYSDATE,
       SUM (
          DECODE (event,
                  'control file sequential read', total_waits,
                  'control file single write', total_waits,
                  'control file parallel write', total_waits,
                  0))
          ControlFileIO,
       SUM (DECODE (event, 'db file sequential read', total_waits, 0))
          SingleBlockRead,
       SUM (DECODE (event, 'db file scattered read', total_waits, 0))
          MultiBlockRead,
       SUM (DECODE (event, 'direct path read', total_waits, 0))
          DirectPathRead,
       SUM (
          DECODE (event,
                  'SQL*Net message to client', total_waits,
                  'SQL*Net message to dblink', total_waits,
                  'SQL*Net more data to client', total_waits,
                  'SQL*Net more data to dblink', total_waits,
                  'SQL*Net break/reset to client', total_waits,
                  'SQL*Net break/reset to dblink', total_waits,
                  0))
          SQLNET,
       SUM (
          DECODE (event,
                  'file identify', total_waits,
                  'file open', total_waits,
                  0))
          FileIO,
       SUM (
          DECODE (event,
                  'log file single write', total_waits,
                  'log file parallel write', total_waits,
                  0))
          LogWrite,
       SUM (
          DECODE (event,
                  'control file sequential read', 0,
                  'control file single write', 0,
                  'control file parallel write', 0,
                  'db file sequential read', 0,
                  'db file scattered read', 0,
                  'direct path read', 0,
                  'file identify', 0,
                  'file open', 0,
                  'SQL*Net message to client', 0,
                  'SQL*Net message to dblink', 0,
                  'SQL*Net more data to client', 0,
                  'SQL*Net more data to dblink', 0,
                  'SQL*Net break/reset to client', 0,
                  'SQL*Net break/reset to dblink', 0,
                  'log file single write', 0,
                  'log file parallel write', 0,
                  total_waits))
          Other
  FROM V$SYSTEM_EVENT;
  
  
SELECT SYSDATE,
       ROUND (SUM (DECODE (pool, 'large pool', (bytes) / (1024 * 1024), 0)),
              2)
          sga_lpool,
       ROUND (
          SUM (
             DECODE (
                pool,
                NULL, DECODE (name,
                              'db_block_buffers', (bytes) / (1024 * 1024),
                              0),
                0)),
          2)
          sga_bufcache,
       ROUND (
          SUM (
             DECODE (
                pool,
                NULL, DECODE (name, 'log_buffer', (bytes) / (1024 * 1024), 0),
                0)),
          2)
          sga_lbuffer,
       ROUND (
          SUM (
             DECODE (
                pool,
                NULL, DECODE (name, 'fixed_sga', (bytes) / (1024 * 1024), 0),
                0)),
          2)
          sga_fixed,
       ROUND (SUM (DECODE (pool, 'java pool', (bytes) / (1024 * 1024), 0)),
              2)
          sga_jpool,
       ROUND (
          SUM (
             DECODE (
                pool,
                'shared pool', DECODE (name,
                                       'sql area', (bytes) / (1024 * 1024),
                                       0),
                0)),
          2)
          pool_sql_area,
       ROUND (
          SUM (
             DECODE (
                pool,
                'shared pool', DECODE (
                                  name,
                                  'free memory', (bytes) / (1024 * 1024),
                                  0),
                0)),
          2)
          pool_free_mem,
       ROUND (
          SUM (
             DECODE (
                pool,
                'shared pool', DECODE (
                                  name,
                                  'library cache', (bytes) / (1024 * 1024),
                                  0),
                0)),
          2)
          pool_lib_cache,
       ROUND (
          SUM (
             DECODE (
                pool,
                'shared pool', DECODE (
                                  name,
                                  'dictionary cache', (bytes) / (1024 * 1024),
                                  0),
                0)),
          2)
          pool_dict_cache,
       ROUND (
          SUM (
             DECODE (
                pool,
                'shared pool', DECODE (name,
                                       'library cache', 0,
                                       'dictionary cache', 0,
                                       'free memory', 0,
                                       'sql area', 0,
                                       (bytes) / (1024 * 1024)),
                0)),
          2)
          pool_misc,
       ROUND (SUM (DECODE (pool, 'shared pool', (bytes) / (1024 * 1024), 0)),
              2)
          sga_pool
  FROM V$SGASTAT;