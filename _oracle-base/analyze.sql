spool analyze.log

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/active_sessions.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all active database sessions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @active_sessions
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/cache_hit_ratio.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays cache hit ratio for the database.
PROMPT Comments     : The minimum figure of 89% is often quoted, but depending on the type of system this may not be possible.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @cache_hit_ratio
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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
  
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/db_cache_advice.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Predicts how changes to the buffer cache will affect physical reads.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @db_cache_advice
PROMPT Last Modified: 12/02/2004
PROMPT -----------------------------------------------------------------------------------

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
	   
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/db_info.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays general information about the database.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @db_info
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/db_links.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all database links.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @db_links
PROMPT Last Modified: 11/05/2007
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 150

COLUMN db_link FORMAT A30
COLUMN host FORMAT A30

SELECT owner,
       db_link,
       username,
       host
FROM   dba_db_links
ORDER BY owner, db_link;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/db_links_open.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all open database links.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @db_links_open
PROMPT Last Modified: 11/05/2007
PROMPT -----------------------------------------------------------------------------------

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


PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/db_properties.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays all database property values.
PROMPT Call Syntax  : @db_properties
PROMPT Last Modified: 15/09/2006
PROMPT -----------------------------------------------------------------------------------

COLUMN property_value FORMAT A50

SELECT property_name,
       property_value
FROM   database_properties
ORDER BY property_name;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/df_free_space.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays free space information about datafiles.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @df_free_space.sql
PROMPT Last Modified: 17-AUG-2005
PROMPT -----------------------------------------------------------------------------------

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


PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/directories.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about all directories.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @directories
PROMPT Last Modified: 04/10/2006
PROMPT -----------------------------------------------------------------------------------

COLUMN owner FORMAT A20
COLUMN directory_name FORMAT A25
COLUMN directory_path FORMAT A50

SELECT *
FROM   dba_directories
ORDER BY owner, directory_name;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/dispatchers.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays dispatcher statistics.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @dispatchers
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/file_io.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the amount of IO for each datafile.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @file_io
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

SET PAGESIZE 1000

  SELECT SUBSTR (d.name, 1, 50) "File Name",
         f.phyblkrd "Blocks Read",
         f.phyblkwrt "Blocks Writen",
         f.phyblkrd + f.phyblkwrt "Total I/O"
    FROM v$filestat f, v$datafile d
   WHERE d.file# = f.file#
ORDER BY f.phyblkrd + f.phyblkwrt DESC;

SET PAGESIZE 18

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/free_space.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays space usage for each datafile.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @free_space
PROMPT Last Modified: 15-JUL-2000 - Created.
PROMPT                12-OCT-2012 - Amended to include auto-extend and maxsize.
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://www.oracle-base.com/dba/monitoring/hidden_parameters.sql
PROMPT Author       : DR Timothy S Hall
PROMPT Description  : Displays a list of one or all the hidden parameters.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @hidden_parameters (parameter-name or all)
PROMPT Last Modified: 28-NOV-2006
PROMPT -----------------------------------------------------------------------------------

SET VERIFY OFF
COLUMN parameter      FORMAT a37
COLUMN description    FORMAT a30 WORD_WRAPPED
COLUMN session_value  FORMAT a10
COLUMN instance_value FORMAT a10
 
  SELECT a.ksppinm AS parameter,
         a.ksppdesc AS description,
         b.ksppstvl AS session_value,
         c.ksppstvl AS instance_value
    FROM x$ksppi a, x$ksppcv b, x$ksppsv c
   WHERE     a.indx = b.indx
         AND a.indx = c.indx
         AND a.ksppinm LIKE '/_%' ESCAPE '/'
         AND a.ksppinm = DECODE (LOWER ('ALL'), 'all', a.ksppinm, LOWER ('ALL'))
ORDER BY a.ksppinm;

/*
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/hot_blocks.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Detects hot blocks. !!! long running possible !!!
PROMPT Call Syntax  : @hot_blocks
PROMPT Last Modified: 17/02/2005
PROMPT -----------------------------------------------------------------------------------

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
 */
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/identify_trace_file.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the name of the trace file associated with the current session.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @identify_trace_file
PROMPT Last Modified: 17-AUG-2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/invalid_objects.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Lists all invalid objects in the database.
PROMPT Call Syntax  : @invalid_objects
PROMPT Requirements : Access to the DBA views.
PROMPT Last Modified: 18/12/2005
PROMPT -----------------------------------------------------------------------------------

COLUMN object_name FORMAT A30
SELECT owner,
       object_type,
       object_name,
       status
FROM   dba_objects
WHERE  status = 'INVALID'
ORDER BY owner, object_type, object_name;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/jobs.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about all scheduled jobs.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @jobs
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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
       PROMPTTO_CHAR (a.this_date, 'DD-MON-YYYY HH24:MI:SS') AS this_date,
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


PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/jobs_running.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information for running jobs.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @jobs_running
PROMPT Last Modified: 27/07/2005
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 200

COLUMN owner FORMAT A20

SELECT owner,
       job_name,
       running_instance,
       elapsed_time
FROM   dba_scheduler_running_jobs
ORDER BY owner, job_name;


PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/latch_hit_ratios.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays current latch hit ratios.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @latch_hit_ratios
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

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

  
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/latch_holders.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about all current latch holders.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @latch_holders
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/latches.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about all current latches.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @latches
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/library_cache.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays library cache statistics.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @library_cache
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/license.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays session usage for licensing purposes.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @license
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

SELECT *
FROM   v$license;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/locked_objects.sql
PROMPT Author       : DR Timothy S Hall
PROMPT Description  : Lists all locked objects.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @locked_objects
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/logfiles.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about redo log files.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @logfiles
PROMPT Last Modified: 21/12/2004
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/longops.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all long operations.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @longops
PROMPT Last Modified: 03/07/2003
PROMPT -----------------------------------------------------------------------------------

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
       ROUND (sl.sofar / sl.totalwork * 100, 2) progress_pct
  FROM v$session s, v$session_longops sl
 WHERE s.sid = sl.sid AND s.serial# = sl.serial#;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/lru_latch_ratio.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays current LRU latch ratios.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @lru_latch_hit_ratio
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/max_extents.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays all tables and indexes nearing their MAX_EXTENTS setting.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @max_extents
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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
     
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://www.oracle-base.com/dba/monitoring/min_datafile_size.sql
PROMPT Author       : DR Timothy S Hall
PROMPT Description  : Displays smallest size the datafiles can shrink to without a reorg.
PROMPT Requirements : Access to the V$ and DBA views.
PROMPT Call Syntax  : @min_datafile_size
PROMPT Last Modified: 07/09/2007
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/monitor.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays SQL statements for the current database sessions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @monitor
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/monitor_memory.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays memory allocations for the current database sessions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @monitor_memory
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/nls_params.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays National Language Suppport (NLS) information.
PROMPT Requirements : 
PROMPT Call Syntax  : @nls_params
PROMPT Last Modified: 21-FEB-2005
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 100
COLUMN parameter FORMAT A45
COLUMN value FORMAT A45

PROMPT *** Database parameters ***
SELECT * FROM nls_database_parameters;

PROMPT *** Instance parameters ***
SELECT * FROM nls_instance_parameters;

PROMPT *** Session parameters ***
SELECT * FROM nls_session_parameters;
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/non_indexed_fks.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of non-indexes FKs.
PROMPT Requirements : Access to the ALL views.
PROMPT Call Syntax  : @non_indexed_fks
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

/*
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/obj_lock.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of locked objects. !!! LONG RUNNING POSSIBLE !!!
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @obj_lock
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

  SELECT a.TYPE,
         SUBSTR (a.owner, 1, 30) owner,
         a.sid,
         SUBSTR (a.object, 1, 30) object
    FROM v$access a
   WHERE a.owner NOT IN ('SYS', 'PUBLIC')
ORDER BY 1,2,3,4;
*/

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/open_cursors.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of all cursors currently open.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @open_cursors
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

SELECT a.user_name,
       a.sid,
       a.sql_text
FROM   v$open_cursor a
ORDER BY 1,2;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/options.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about all database options.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @options
PROMPT Last Modified: 12/04/2013
PROMPT -----------------------------------------------------------------------------------

COLUMN value FORMAT A20

SELECT *
FROM   v$option
ORDER BY parameter;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/parameter_diffs.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays parameter values that differ between the current value and the spfile.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @parameter_diffs
PROMPT Last Modified: 08-NOV-2004
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/parameters.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of all the parameters.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @parameters
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/part_tables.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about all partitioned tables.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @part_tables
PROMPT Last Modified: 21/12/2004
PROMPT -----------------------------------------------------------------------------------

  SELECT owner,
         table_name,
         partitioning_type,
         partition_count
    FROM dba_part_tables
   WHERE owner NOT IN ('SYS', 'SYSTEM')
ORDER BY owner, table_name;
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/pga_target_advice.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Predicts how changes to the PGA_AGGREGATE_TARGET will affect PGA usage.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @pga_target_advice
PROMPT Last Modified: 12/02/2004
PROMPT -----------------------------------------------------------------------------------

SELECT ROUND (pga_target_for_estimate / 1024 / 1024) target_mb,
       estd_pga_cache_hit_percentage cache_hit_perc,
       estd_overalloc_count
  FROM v$pga_target_advice;
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/pipes.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of all database pipes.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @pipes
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/profiler_runs.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all profiler_runs.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @profiler_runs.sql
PROMPT Last Modified: 25/02/2005
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/profiles.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the specified profile(s).
PROMPT Call Syntax  : @profiles (profile | part of profile | all)
PROMPT Last Modified: 28/01/2006
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 150 PAGESIZE 20 VERIFY OFF

BREAK ON profile SKIP 1

SELECT profile,
       resource_type,
       resource_name,
       limit
FROM   dba_profiles
WHERE  profile LIKE (DECODE(UPPER('ALL'), 'ALL', '%', UPPER('%ALL%')))
ORDER BY profile, resource_type, resource_name;

CLEAR BREAKS
SET LINESIZE 80 PAGESIZE 14 VERIFY ON

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/rbs_extents.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about the rollback segment extents.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @rbs_extents
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/rbs_stats.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays rollback segment statistics.
PROMPT Requirements : Access to the v$ DBA views.
PROMPT Call Syntax  : @rbs_stats
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 500
SET PAGESIZE 1000
SET VERIFY OFF

SELECT b.name "Segment Name",
       Trunc(c.bytes/1024) "Size (Kb)",
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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/recovery_status.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the recovery status of each datafile.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @recovery_status
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/redo_by_day.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Lists the volume of archived redo by day for the specified number of days.
PROMPT Call Syntax  : @redo_by_day (days)
PROMPT Requirements : Access to the v$views.
PROMPT Last Modified: 11/10/2013
PROMPT -----------------------------------------------------------------------------------

SET VERIFY OFF

SELECT TRUNC(first_time) AS day,
       ROUND(SUM(blocks * block_size)/1024/1024/1024,2) size_gb
FROM   v$archived_log
WHERE  TRUNC(first_time) >= TRUNC(SYSDATE) - 7
GROUP BY TRUNC(first_time)
ORDER BY TRUNC(first_time);

SET VERIFY ON

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/redo_by_hour.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Lists the volume of archived redo by hour for the specified day.
PROMPT Call Syntax  : @redo_by_hour (day 0=Today, 1=Yesterday etc.)
PROMPT Requirements : Access to the v$views.
PROMPT Last Modified: 11/10/2013
PROMPT -----------------------------------------------------------------------------------

SET VERIFY OFF PAGESIZE 30

WITH hours
     AS (    SELECT TRUNC (SYSDATE) - 0 + ( (LEVEL - 1) / 24) AS hours
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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/redo_by_min.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Lists the volume of archived redo by min for the specified number of hours.
PROMPT Call Syntax  : @redo_by_min (N number of minutes from now)
PROMPT Requirements : Access to the v$views.
PROMPT Last Modified: 11/10/2013
PROMPT -----------------------------------------------------------------------------------

SET VERIFY OFF PAGESIZE 100

WITH mins
     AS (    SELECT   TRUNC (SYSDATE, 'MI')
                    - (60 / (24 * 60))
                    + ( (LEVEL - 1) / (24 * 60))
                       AS mins
               FROM DUAL
         CONNECT BY LEVEL <= 60)
  SELECT m.mins AS date_min,
         ROUND (SUM (blocks * block_size) / 1024 / 1024, 2) size_mb
    FROM mins m
         LEFT OUTER JOIN v$archived_log al
            ON m.mins = TRUNC (al.first_time, 'MI')
GROUP BY m.mins
ORDER BY m.mins;

SET VERIFY ON PAGESIZE 14
  
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/registry_history.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays contents of the registry history
PROMPT Requirements : Access to the DBA role.
PROMPT Call Syntax  : @registry_history
PROMPT Last Modified: 23/08/2008
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/roles.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of all roles and privileges granted to the specified user.
PROMPT Requirements : Access to the USER views.
PROMPT Call Syntax  : @roles
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

SET SERVEROUTPUT ON
SET VERIFY OFF

SELECT a.role,
       a.password_required,
       a.authentication_type
FROM   dba_roles a
ORDER BY a.role;
               
SET VERIFY ON

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/session_events.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all database session events.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @session_events
PROMPT Last Modified: 11/03/2005
PROMPT -----------------------------------------------------------------------------------

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
ORDER BY se.time_waited DESC;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/session_io.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays I/O information on all database sessions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @session_io
PROMPT Last Modified: 21-FEB-2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/session_rollback.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays rollback information on relevant database sessions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @session_rollback
PROMPT Last Modified: 29/03/2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/session_undo.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays undo information on relevant database sessions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @session_undo
PROMPT Last Modified: 29/03/2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/session_waits.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all database session waits.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @session_waits
PROMPT Last Modified: 11/03/2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/sessions.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all database sessions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @sessions
PROMPT Last Modified: 21-FEB-2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/sessions_by_machine.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the number of sessions for each client machine.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @sessions_by_machine
PROMPT Last Modified: 20-JUL-2014
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/spfile_parameters.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of all the spfile parameters.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @spfile_parameters
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/sql_area.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the SQL statements for currently running processes.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @sql_area
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/statistics_prefs.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays current statistics preferences.
PROMPT Requirements : Access to the DBMS_STATS package.
PROMPT Call Syntax  : @statistics_prefs
PROMPT Last Modified: 06-DEC-2013
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/synonyms_to_missing_objects.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Lists all synonyms that point to missing objects.
PROMPT Call Syntax  : @synonyms_to_missing_objects(object-schema-name or all)
PROMPT Requirements : Access to the DBA views.
PROMPT Last Modified: 07/10/2013
PROMPT -----------------------------------------------------------------------------------

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
                DECODE (UPPER ('ALL'), 'ALL', s.table_owner, UPPER ('ALL'))
ORDER BY s.owner, s.synonym_name;

SET LINESIZE 80 VERIFY ON

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/system_events.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all system events.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @system_events
PROMPT Last Modified: 21-FEB-2005
PROMPT -----------------------------------------------------------------------------------

  SELECT event,
         total_waits,
         total_timeouts,
         time_waited,
         average_wait,
         time_waited_micro
    FROM v$system_event
ORDER BY event;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/system_parameters.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of all the system parameters.
PROMPT                Comment out isinstance_modifiable for use prior to 10g.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @system_parameters
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

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


PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/tables_with_locked_stats.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays tables with locked stats.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @tables_with_locked_stats.sql
PROMPT Last Modified: 06-DEC-2013
PROMPT -----------------------------------------------------------------------------------

  SELECT owner, table_name, stattype_locked
    FROM dba_tab_statistics
   WHERE stattype_locked IS NOT NULL
ORDER BY owner, table_name;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/tables_with_zero_rows.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays tables with stats saying they have zero rows.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @tables_with_zero_rows.sql
PROMPT Last Modified: 06-DEC-2013
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/tablespaces.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about tablespaces.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @tablespaces
PROMPT Last Modified: 17-AUG-2005
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 200

  SELECT tablespace_name,
         block_size,
         extent_management,
         allocation_type,
         segment_space_management,
         status
    FROM dba_tablespaces
ORDER BY tablespace_name;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/temp_free_space.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays temp space usage for each datafile.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @temp_free_space
PROMPT Last Modified: 15-JUL-2000 - Created.
PROMPT                13-OCT-2012 - Amended to include auto-extend and maxsize.
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/temp_io.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the amount of IO for each tempfile.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @temp_io
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

SET PAGESIZE 1000

  SELECT SUBSTR (t.name, 1, 50) AS file_name,
         f.phyblkrd AS blocks_read,
         f.phyblkwrt AS blocks_written,
         f.phyblkrd + f.phyblkwrt AS total_io
    FROM v$tempstat f, v$tempfile t
   WHERE t.file# = f.file#
ORDER BY f.phyblkrd + f.phyblkwrt DESC;

SET PAGESIZE 18

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/temp_segments.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of all temporary segments.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @temp_segments
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 500

  SELECT owner, TRUNC (SUM (bytes) / 1024) Kb
    FROM dba_segments
   WHERE segment_type = 'TEMPORARY'
GROUP BY owner;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/temp_usage.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays temp usage for all session currently using temp space.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @temp_usage
PROMPT Last Modified: 12/02/2004
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/tempfiles.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about tempfiles.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @tempfiles
PROMPT Last Modified: 17-AUG-2005
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/tempseg_usage.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays temp segment usage for all session currently using temp space.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @tempseg_usage
PROMPT Last Modified: 01/04/2006
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/top_latches.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about the top latches.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @top_latches
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/top_sessions.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all database sessions ordered by executions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @top_sessions.sql (reads, execs or cpu)
PROMPT Last Modified: 21/02/2005
PROMPT -----------------------------------------------------------------------------------

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
       c.value AS "READS",
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
AND    d.name       = DECODE(UPPER('READS'), 'READS', 'session logical reads',
                                          'EXECS', 'execute count',
                                          'CPU',   'CPU used by this session',
                                                   'CPU used by this session')
ORDER BY c.value DESC;

SET PAGESIZE 14

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/top_sessions.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all database sessions ordered by executions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @top_sessions.sql (reads, execs or cpu)
PROMPT Last Modified: 21/02/2005
PROMPT -----------------------------------------------------------------------------------

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
       c.value AS "EXECS",
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
AND    d.name       = DECODE(UPPER('EXECS'), 'READS', 'session logical reads',
                                          'EXECS', 'execute count',
                                          'CPU',   'CPU used by this session',
                                                   'CPU used by this session')
ORDER BY c.value DESC;

SET PAGESIZE 14

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/top_sessions.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all database sessions ordered by executions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @top_sessions.sql (reads, execs or cpu)
PROMPT Last Modified: 21/02/2005
PROMPT -----------------------------------------------------------------------------------

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
       c.value AS "CPU",
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
AND    d.name       = DECODE(UPPER('CPU'), 'READS', 'session logical reads',
                                          'EXECS', 'execute count',
                                          'CPU',   'CPU used by this session',
                                                   'CPU used by this session')
ORDER BY c.value DESC;

SET PAGESIZE 14

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/top_sql.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of SQL statements that are using the most resources.
PROMPT Comments     : The address column can be use as a parameter with SQL_Text.sql to display the full statement.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @top_sql (number)
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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
 WHERE ROWNUM <= 10;

SET PAGESIZE 14

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/trace_runs.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all trace runs.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @trace_runs.sql
PROMPT Last Modified: 06/05/2005
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 200
SET TRIMOUT ON

COLUMN runid FORMAT 99999

SELECT runid,
       run_date,
       run_owner
FROM   plsql_trace_runs
ORDER BY runid;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/ts_free_space.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of tablespaces and their used/full status.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @ts_free_space.sql
PROMPT Last Modified: 13-OCT-2012 - Created. Based on ts_full.sql
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/tuning.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays several performance indicators and comments on the value.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @tuning
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

  PROMPT --------------------------
  PROMPT Dictionary Cache Hit Ratio
  PROMPT --------------------------
  SELECT (1 - (Sum(getmisses)/(Sum(gets) + Sum(getmisses)))) * 100
  INTO   v_value
  FROM   v$rowcache;

  DBMS_Output.Put('Dictionary Cache Hit Ratio       : ' || Format(v_value));
  IF v_value < 5 THEN
    DBMS_Output.Put_Line('Increase SORT_AREA_SIZE parameter to bring value below 5%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');  
  END IF;
  
  PROMPT ----------------------
  PROMPT Rollback Segment Waits
  PROMPT ----------------------
  SELECT (Sum(waits) / Sum(gets)) * 100
  INTO   v_value
  FROM   v$rollstat;

  DBMS_Output.Put('Rollback Segment Waits           : ' || Format(v_value));
  IF v_value > 5 THEN
    DBMS_Output.Put_Line('Increase number of Rollback Segments to bring the value below 5%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;

  PROMPT -------------------
  PROMPT Dispatcher Workload
  PROMPT -------------------
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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/user_hit_ratio.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the Cache Hit Ratio per user.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @user_hit_ratio
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/user_roles.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of all roles and privileges granted to the specified user.
PROMPT Requirements : Access to the USER views.
PROMPT Call Syntax  : @user_roles
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://www.oracle-base.com/dba/monitoring/user_temp_space.sql
PROMPT Author       : DR Timothy S Hall
PROMPT Description  : Displays the temp space currently in use by users.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @user_temp_space
PROMPT Last Modified: 12/02/2004
PROMPT -----------------------------------------------------------------------------------

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
  
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/user_undo_space.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the undo space currently in use by users.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @user_undo_space
PROMPT Last Modified: 12/02/2004
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/ts_full.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of tablespaces that are nearly full.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @ts_full
PROMPT Last Modified: 15-JUL-2000 - Created.
PROMPT                 13-OCT-2012 - Included support FOR AUTO-EXTEND AND maxsize.
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/ts_thresholds.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays threshold information for tablespaces.
PROMPT Call Syntax  : @ts_thresholds
PROMPT Last Modified: 13/02/2014 - Created
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/users_with_role.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of users granted the specified role.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @user_with_role DBA
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

SET VERIFY OFF

SELECT username,
       lock_date,
       expiry_date
FROM   dba_users
WHERE  username IN (SELECT grantee
                    FROM   dba_role_privs
                    WHERE  granted_role = UPPER('DBA'))
ORDER BY username;

SET VERIFY ON
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/users_with_sys_priv.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays a list of users granted the specified role.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @users_with_sys_priv "UNLIMITED TABLESPACE"
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

SET VERIFY OFF

SELECT username,
       lock_date,
       expiry_date
FROM   dba_users
WHERE  username IN (SELECT grantee
                    FROM   dba_sys_privs
                    WHERE  privilege = UPPER('UNLIMITED TABLESPACE'))
ORDER BY username;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/active_session_waits.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on the current wait states for all active database sessions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @active_session_waits
PROMPT Last Modified: 21/12/2004
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/db_usage_hwm.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays high water mark statistics.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @db_usage_hwm
PROMPT Last Modified: 26-NOV-2004
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/feature_usage.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays feature usage statistics.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @feature_usage
PROMPT Last Modified: 26-NOV-2004
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/flashback_db_info.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information relevant to flashback database.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @flashback_db_info
PROMPT Last Modified: 21/12/2004
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/job_chain_rules.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information about job chain rules.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @job_chain_rules
PROMPT Last Modified: 26/10/2011
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/job_chain_steps.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information about job chain steps.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @job_chain_steps
PROMPT Last Modified: 26/10/2011
PROMPT -----------------------------------------------------------------------------------

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
     
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/job_chains.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information about job chains.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @job_chains
PROMPT Last Modified: 26/10/2011
PROMPT -----------------------------------------------------------------------------------

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
  
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/job_classes.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information about job classes.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @job_classes
PROMPT Last Modified: 27/07/2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/job_programs.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information about job programs.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @job_programs
PROMPT Last Modified: 27/07/2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/job_running_chains.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information about job running chains.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @job_running_chains.sql
PROMPT Last Modified: 26/10/2011
PROMPT -----------------------------------------------------------------------------------

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



PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/job_schedules.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information about job schedules.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @job_schedules
PROMPT Last Modified: 27/07/2005
PROMPT -----------------------------------------------------------------------------------

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

  
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/jobs.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler job information.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @jobs
PROMPT Last Modified: 27/07/2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/jobs_running.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about all jobs currently running.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @jobs_running
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/lock_tree.sql
PROMPT Author       : DR Timothy S Hall
PROMPT Description  : Displays information on all database sessions with the username
PROMPT                column displayed as a heirarchy if locks are present.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @lock_tree
PROMPT Last Modified: 18-MAY-2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/services.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about database services.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @services
PROMPT Last Modified: 05/11/2004
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN name FORMAT A30
COLUMN network_name FORMAT A50

SELECT name,
       network_name
FROM   dba_services
ORDER BY name;
     
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/session_waits.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all database session waits.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @session_waits
PROMPT Last Modified: 11/03/2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://www.oracle-base.com/dba/10g/sga_buffers.sql
PROMPT Author       : DR Timothy S Hall
PROMPT Description  : Displays the status of buffers in the SGA.
PROMPT Requirements : Access to the v$ and DBA views.
PROMPT Call Syntax  : @sga_buffers
PROMPT Last Modified: 27/07/2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/sga_dynamic_components.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Provides information about dynamic SGA components.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @sga_dynamic_components
PROMPT Last Modified: 23/08/2008
PROMPT -----------------------------------------------------------------------------------

COLUMN component FORMAT A30

  SELECT component,
         ROUND (current_size / 1024 / 1204) AS current_size_mb,
         ROUND (min_size / 1024 / 1204) AS min_size_mb,
         ROUND (max_size / 1024 / 1204) AS max_size_mb
    FROM v$sga_dynamic_components
   WHERE current_size != 0
ORDER BY component;
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/sga_dynamic_free_memory.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Provides information about free memory in the SGA.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @sga_dynamic_free_memory
PROMPT Last Modified: 23/08/2008
PROMPT -----------------------------------------------------------------------------------

SELECT *
FROM   v$sga_dynamic_free_memory;
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/sga_resize_ops.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Provides information about memory resize operations.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @sga_resize_ops
PROMPT Last Modified: 23/08/2008
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/sysaux_occupants.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about the contents of the SYSAUX tablespace.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @sysaux_occupants
PROMPT Last Modified: 27/07/2005
PROMPT -----------------------------------------------------------------------------------

COLUMN occupant_name FORMAT A30
COLUMN schema_name FORMAT A20

  SELECT occupant_name, schema_name, space_usage_kbytes
    FROM v$sysaux_occupants
ORDER BY 3 DESC, occupant_name;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/window_groups.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information about window groups.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @window_groups
PROMPT Last Modified: 05/11/2004
PROMPT -----------------------------------------------------------------------------------

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
  
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/windows.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information about windows.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @windows
PROMPT Last Modified: 05/11/2004
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 250

COLUMN comments FORMAT A40

SELECT window_name,
       resource_plan,
       enabled,
       active,
       comments
FROM   dba_scheduler_windows
ORDER BY window_name;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/diag_info.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the contents of the v$diag_info view.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @diag_info
PROMPT Last Modified: 23/08/2008
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 200
COLUMN name FORMAT A30
COLUMN value FORMAT A110

SELECT * FROM v$diag_info;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/extended_stats.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Provides information about extended statistics.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @extended_stats
PROMPT Last Modified: 30/11/2011
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/fda.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about flashback data archives.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @fda
PROMPT Last Modified: 06-JAN-2015
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/fda_tables.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about flashback data archives.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @fda_tables
PROMPT Last Modified: 06-JAN-2015
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/fda_ts.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about flashback data archives.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @fda_ts
PROMPT Last Modified: 06-JAN-2015
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/identify_trace_file.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the name of the trace file associated with the current session.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @identify_trace_file
PROMPT Last Modified: 23/08/2008
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 100
COLUMN value FORMAT A60

SELECT value
FROM   v$diag_info
WHERE  name = 'Default Trace File';

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/job_credentials.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays scheduler information about job credentials.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @job_credentials
PROMPT Last Modified: 23/08/2008
PROMPT -----------------------------------------------------------------------------------

COLUMN credential_name FORMAT A25
COLUMN username FORMAT A20
COLUMN windows_domain FORMAT A20

  SELECT credential_name, username, windows_domain
    FROM dba_scheduler_credentials
ORDER BY credential_name;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/job_run_details.sql
PROMPT Author       : DR Timothy S Hall
PROMPT Description  : Displays scheduler job information for previous runs.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @job_run_details (job-name | all)
PROMPT Last Modified: 06/06/2014
PROMPT -----------------------------------------------------------------------------------

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
   WHERE job_name = DECODE (UPPER ('ALL'), 'ALL', job_name, UPPER ('ALL'))
ORDER BY log_date;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/memory_dynamic_components.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Provides information about dynamic memory components.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @memory_dynamic_components
PROMPT Last Modified: 23/08/2008
PROMPT -----------------------------------------------------------------------------------

COLUMN component FORMAT A30

  SELECT component,
         ROUND (current_size / 1024 / 1204) AS current_size_mb,
         ROUND (min_size / 1024 / 1204) AS min_size_mb,
         ROUND (max_size / 1024 / 1204) AS max_size_mb
    FROM v$memory_dynamic_components
   WHERE current_size != 0
ORDER BY component;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/memory_resize_ops.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Provides information about memory resize operations.
PROMPT Requirements : Access to the v$ views.
PROMPT Call Syntax  : @memory_resize_ops
PROMPT Last Modified: 23/08/2008
PROMPT -----------------------------------------------------------------------------------

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


PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/memory_target_advice.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Provides information to help tune the MEMORY_TARGET parameter.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @memory_target_advice
PROMPT Last Modified: 23/08/2008
PROMPT -----------------------------------------------------------------------------------

SELECT *
FROM   v$memory_target_advice
ORDER BY memory_size;
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/network_acl_privileges.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays privileges for the network ACLs.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @network_acl_privileges
PROMPT Last Modified: 30/11/2011
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/network_acls.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about network ACLs.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @network_acls
PROMPT Last Modified: 30/11/2011
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 150

COLUMN host FORMAT A40
COLUMN acl FORMAT A50

SELECT host, lower_port, upper_port, acl
FROM   dba_network_acls
ORDER BY host;

SET LINESIZE 80
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/result_cache_objects.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about the objects in the result cache.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @result_cache_objects
PROMPT Last Modified: 07/11/2012
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 1000

SELECT *
FROM v$result_cache_objects;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/result_cache_report.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the result cache report.
PROMPT Requirements : Access to the DBMS_RESULT_CACHE package.
PROMPT Call Syntax  : @result_cache_report
PROMPT Last Modified: 07/11/2012
PROMPT -----------------------------------------------------------------------------------

SET SERVEROUTPUT ON
EXEC DBMS_RESULT_CACHE.memory_report(detailed => true);

     
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/result_cache_statistics.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays result cache statistics.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @result_cache_statistics
PROMPT Last Modified: 07/11/2012
PROMPT -----------------------------------------------------------------------------------

COLUMN name FORMAT A30
COLUMN value FORMAT A30

SELECT id,
       name,
       value
FROM   v$result_cache_statistics
ORDER BY id;

CLEAR COLUMNS

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/result_cache_status.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays the status of the result cache.
PROMPT Requirements : Access to the DBMS_RESULT_CACHE package.
PROMPT Call Syntax  : @result_cache_status
PROMPT Last Modified: 07/11/2012
PROMPT -----------------------------------------------------------------------------------

SELECT DBMS_RESULT_CACHE.status FROM dual;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/system_fix_count.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Provides information about system fixes per version.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @system_fix_count
PROMPT Last Modified: 30/11/2011
PROMPT -----------------------------------------------------------------------------------

SELECT optimizer_feature_enable,
       COUNT(*)
FROM   v$system_fix_control
GROUP BY optimizer_feature_enable
ORDER BY optimizer_feature_enable;
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/11g/temp_free_space.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information about temporary tablespace usage.
PROMPT Requirements : Access to the DBA views.
PROMPT Call Syntax  : @temp_free_space
PROMPT Last Modified: 23-AUG-2008
PROMPT -----------------------------------------------------------------------------------

SELECT *
FROM   dba_temp_free_space;


PROMPT Real Application Clusters (RAC)

  
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/locked_objects.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Lists all locked objects for whole RAC. - work quickly
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @locked_objects
PROMPT Last Modified: 15/07/2000
PROMPT -----------------------------------------------------------------------------------

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
  
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/longops_rac.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all long operations for whole RAC.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @longops_rac
PROMPT Last Modified: 03/07/2003
PROMPT -----------------------------------------------------------------------------------

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

     
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/monitor_memory_rac.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays memory allocations for the current database sessions for the whole RAC.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @monitor_memory_rac
PROMPT Last Modified: 15-JUL-2000
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/session_undo_rac.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays undo information on relevant database sessions.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @session_undo_rac
PROMPT Last Modified: 20/12/2005
PROMPT -----------------------------------------------------------------------------------

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
 
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/10g/session_waits_rac.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all database session waits for the whole RAC.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @session_waits_rac
PROMPT Last Modified: 02/07/2005
PROMPT -----------------------------------------------------------------------------------

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

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/monitoring/sessions_rac.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Displays information on all database sessions for whole RAC.
PROMPT Requirements : Access to the V$ views.
PROMPT Call Syntax  : @sessions_rac
PROMPT Last Modified: 21/02/2005
PROMPT -----------------------------------------------------------------------------------

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


PROMPT Resource Manager

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/resource_manager/active_plan.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Lists the currently active resource plan if one is set.
PROMPT Call Syntax  : @active_plan
PROMPT Requirements : Access to the v$ views.
PROMPT Last Modified: 12/11/2004
PROMPT -----------------------------------------------------------------------------------

SELECT name,
       is_top_plan
FROM   v$rsrc_plan
ORDER BY name;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/resource_manager/consumer_group_usage.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Lists usage information of consumer groups.
PROMPT Call Syntax  : @consumer_group_usage
PROMPT Requirements : Access to the v$ views.
PROMPT Last Modified: 12/11/2004
PROMPT -----------------------------------------------------------------------------------

  SELECT name, consumed_cpu_time
    FROM v$rsrc_consumer_group
ORDER BY name;
     
PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/resource_manager/consumer_groups.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Lists all consumer groups.
PROMPT Call Syntax  : @consumer_groups
PROMPT Requirements : Access to the DBA views.
PROMPT Last Modified: 12/11/2004
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 200
SET VERIFY OFF

COLUMN status FORMAT A10
COLUMN comments FORMAT A50

  SELECT consumer_group, status, comments
    FROM dba_rsrc_consumer_groups
ORDER BY consumer_group;

PROMPT -----------------------------------------------------------------------------------
PROMPT File Name    : http://oracle-base.com/dba/resource_manager/resource_plans.sql
PROMPT Author       : Tim Hall
PROMPT Description  : Lists all resource plans.
PROMPT Call Syntax  : @resource_plans
PROMPT Requirements : Access to the DBA views.
PROMPT Last Modified: 12/11/2004
PROMPT -----------------------------------------------------------------------------------

SET LINESIZE 200
SET VERIFY OFF

COLUMN status FORMAT A10
COLUMN comments FORMAT A50

SELECT plan,
       status,
       comments
FROM   dba_rsrc_plans
ORDER BY plan;

spool off
