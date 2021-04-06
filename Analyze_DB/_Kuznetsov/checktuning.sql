-- CheckTuning.sql
-- D. Sisk 1998/12/10
-- Script to give a quick overview of instance tuning needs

SET ECHO OFF
SET SERVEROUTPUT ON
SET FEEDBACK OFF
COLUMN v_bchp FORMAT 999999999.99

DECLARE
 v_datetime VARCHAR2(19);  --MM/DD/YYYY HH:MI:SS format
 v_dbname v$parameter.value%TYPE;
 v_lchp NUMBER(3,2); --Library cache hit percent
 v_dchp NUMBER(3,2); --Dictionary cache hit percent
 v_consistentgets v$sysstat.value%TYPE; 
 v_dbblockgets v$sysstat.value%TYPE;
 v_physicalreads v$sysstat.value%TYPE;
 v_bchp NUMBER(3,2); --Buffer cache hit percent
 v_sortsdisk v$sysstat.value%TYPE;
 v_sortsmem v$sysstat.value%TYPE;
 v_sahp NUMBER(3,2); --Sort area hit percent
 v_rlsr v$sysstat.value%TYPE; --Redo log space requests
 v_rlswt v$sysstat.value%TYPE; --Redo log space wait time
 v_enqw v$sysstat.value%TYPE; --Enqueue waits
 v_checkpointsstarted v$sysstat.value%TYPE;
 v_checkpointscompleted v$sysstat.value%TYPE;
 v_cpnc v$sysstat.value%TYPE; -- Checkpoints not completed
 v_rollbackwaits v$waitstat.count%TYPE;
 v_rbcr NUMBER(3,2); --Rollback contention ratio (rollback waits/buffer reads)
 v_rawl NUMBER(3,2); --Redo allocation latch willing-to-wait miss ratio
 v_rail NUMBER(3,2); --Redo allocation latch immediate miss ratio
 v_rcwl NUMBER(3,2); --Redo copy latch willing-to-wait miss ratio
 v_rcil NUMBER(3,2); --Redo copy latch immediate miss ratio
 v_freelistwaits v$waitstat.count%TYPE;
 v_flbr NUMBER(3,2); --Freelist waits to blocks requested ratio
 v_iparm v$parameter.name%TYPE;
 v_ivalue v$parameter.value%TYPE;
 v_logbytes v$log.bytes%TYPE;
 v_loggroups NUMBER(2,0);
BEGIN
    dbms_output.enable(20000);
 -- Get current date and time
    SELECT to_char(sysdate, 'MM/DD/YYYY HH24:MI:SS') INTO v_datetime FROM dual;
    dbms_output.put_line ('Current Date and Time: '||v_datetime);
 -- Get database name
    SELECT value INTO v_dbname FROM v$parameter WHERE name = 'db_name';
    dbms_output.put_line ('Database name: '||v_dbname);
 --
 dbms_output.put_line ('Measurement                       Goal      Value Action');
 dbms_output.put_line ('------------------------------ ------ ----------- -------------------------------------------------');
 -- Get library cache hit percentage
    SELECT (1 - SUM(reloads)/SUM(pins)) INTO v_lchp FROM v$librarycache;
    IF v_lchp < 0.99 THEN
       dbms_output.put_line ('Library cache hit percent      >=0.99 '||to_char(v_lchp,'9999990.99')||' Increase the SHARED_POOL_SIZE in INIT.ORA');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='shared_pool_size';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
    ELSE
       dbms_output.put_line ('Library cache hit percent      >=0.99 '||to_char(v_lchp,'9999990.99')||' OK');
    END IF;
 --
 -- Get dictionary cache hit percentage
    SELECT  (1 - SUM(getmisses)/SUM(gets)) INTO v_dchp FROM v$rowcache;
    IF v_dchp < 0.90 THEN
       dbms_output.put_line ('Dictionary cache hit percent   >=0.90 '||to_char(v_dchp,'9999990.99')||' Increase the SHARED_POOL_SIZE in INIT.ORA');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='shared_pool_size';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
    ELSE
       dbms_output.put_line ('Dictionary cache hit percent   >=0.90 '||to_char(v_dchp,'9999990.99')||' OK');
    END IF;
 --
 -- Get buffer cache hit percentage
    SELECT value INTO v_consistentgets FROM v$sysstat WHERE name = 'consistent gets';
    SELECT value INTO v_dbblockgets FROM v$sysstat WHERE name = 'db block gets';
    SELECT value INTO v_physicalreads FROM v$sysstat WHERE name = 'physical reads';
    v_bchp := 1 - (v_physicalreads/(v_consistentgets + v_dbblockgets));
    IF v_bchp < 0.90 THEN
       dbms_output.put_line ('Buffer cache hit percent       >=0.90 '||to_char(v_bchp,'9999990.99')||' Increase the DB_BLOCK_BUFFERS in INIT.ORA');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='db_block_buffers';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
    ELSE
       dbms_output.put_line ('Buffer cache hit percent       >=0.90 '||to_char(v_bchp,'9999990.99')||' OK');
    END IF;
 --
 -- Get sort hit percentage
    SELECT value INTO v_sortsmem FROM v$sysstat WHERE name = 'sorts (memory)';
    SELECT value INTO v_sortsdisk FROM v$sysstat WHERE name = 'sorts (disk)';
    v_sahp := 1 - (v_sortsdisk)/(v_sortsmem + v_sortsdisk);
    IF v_sahp < 0.90 THEN
       dbms_output.put_line ('Sort area hit percent          >=0.90 '||to_char(v_sahp,'9999990.99')||' Increase the SORT_AREA_SIZE in INIT.ORA');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='sort_area_size';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
    ELSE
       dbms_output.put_line ('Sort area hit percent          >=0.90 '||to_char(v_sahp,'9999990.99')||' OK');
    END IF;
 -- Get redo log space request count and time
    SELECT value INTO v_rlsr FROM v$sysstat 
     WHERE name = 'redo log space requests';
    SELECT value INTO v_rlswt FROM v$sysstat 
     WHERE name = 'redo log space wait time';
    IF v_rlsr > 0 THEN
       dbms_output.put_line ('Redo Log space requests        =0      '||to_char(v_rlsr,'999999999')||' Increase the LOG_BUFFER in INIT.ORA');
       dbms_output.put_line ('"                                                 Examine Redo Log size');
       dbms_output.put_line ('"                                                 Examine number of Redo Log groups');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='log_buffer';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
       SELECT max(bytes) INTO v_logbytes FROM v$log;
       dbms_output.put_line ('-- Current value: redo log size = '||v_logbytes);
       SELECT count(*) INTO v_loggroups FROM v$log;
       dbms_output.put_line ('-- Current value: # of redo log groups = '||v_loggroups);
    ELSE
       dbms_output.put_line ('Redo Log space requests        =0      '||to_char(v_rlsr,'999999999')||' OK');
    END IF;
 -- Get enqueue waits
    SELECT value INTO v_enqw FROM v$sysstat WHERE name = 'enqueue waits';
    IF v_enqw > 0 THEN
       dbms_output.put_line ('Enqueue waits                  =0      '||to_char(v_enqw,'999999999')||' Increase the ENQUEUE_RESOURCES in INIT.ORA');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='enqueue_resources';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
    ELSE
       dbms_output.put_line ('Enqueue waits                  =0      '||to_char(v_enqw,'999999999')||' OK');
    END IF;
 -- Get checkpoint completion statistics
    SELECT value INTO v_checkpointsstarted FROM v$sysstat WHERE name = 'background checkpoints started';
    SELECT value INTO v_checkpointscompleted FROM v$sysstat WHERE name = 'background checkpoints completed';
    v_cpnc := v_checkpointsstarted - v_checkpointscompleted;  
    IF v_cpnc > 1 THEN
       dbms_output.put_line ('Checkpoints not completed      <=1     '||to_char(v_cpnc,'999999999')||' Increase LOG_CHECKPOINT_INTERVAL in INIT.ORA');
       dbms_output.put_line ('"                                                 Examine LOG_CHECKPOINT_TIMEOUT in INIT.ORA');
       dbms_output.put_line ('"                                                 Examine Redo Log size');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='log_checkpoint_interval';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='log_checkpoint_timeout';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
       SELECT max(bytes) INTO v_logbytes FROM v$log;
       dbms_output.put_line ('-- Current value: redo log size = '||v_logbytes);
    ELSE
       dbms_output.put_line ('Checkpoints not completed      <=1     '||to_char(v_cpnc,'999999999')||' OK');
    END IF;
 -- Get rollback segment contention statistics
    SELECT max(count) INTO v_rollbackwaits FROM v$waitstat 
     WHERE class IN ('system undo header', 'system undo block','undo header', 'undo block')
     GROUP BY class;
    v_rbcr := v_rollbackwaits/(v_consistentgets + v_dbblockgets);
    IF v_rbcr > 0.01 THEN
       dbms_output.put_line ('Rollback contention ratio      <=0.01 '||to_char(v_rbcr,'9999990.99')||' Create more ROLLBACK SEGMENTS');
    ELSE
       dbms_output.put_line ('Rollback contention ratio      <=0.01 '||to_char(v_rbcr,'9999990.99')||' OK');
    END IF;
 -- Get redo allocation willing-to-wait latch statistics
    SELECT l.misses/(l.gets + 0.000001) INTO v_rawl
      FROM v$latch l, v$latchname ln
      WHERE ln.name = 'redo allocation' AND ln.latch# = l.latch#;
    IF v_rawl > 0.01 THEN
       dbms_output.put_line ('Redo allocation latch miss (W) <=0.01 '||to_char(v_rawl,'9999990.99')||' Decrease LOG_SMALL_ENTRY_MAX_SIZE in INIT.ORA');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='log_small_entry_size';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
    ELSE
       dbms_output.put_line ('Redo allocation latch miss (W) <=0.01 '||to_char(v_rawl,'9999990.99')||' OK');
    END IF;
 -- Get redo allocation immediate latch statistics
    SELECT l.immediate_misses/(l.immediate_gets + l.immediate_misses + 0.000001) INTO v_rail
      FROM v$latch l, v$latchname ln
      WHERE ln.name = 'redo allocation' AND ln.latch# = l.latch#;
    IF v_rail > 0.01 THEN
       dbms_output.put_line ('Redo allocation latch miss (I) <=0.01 '||to_char(v_rail,'9999990.99')||' Decrease LOG_SMALL_ENTRY_MAX_SIZE in INIT.ORA');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='log_small_entry_max_size';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
    ELSE
       dbms_output.put_line ('Redo allocation latch miss (I) <=0.01 '||to_char(v_rail,'9999990.99')||' OK');
    END IF;
 -- Get redo copy willing-to-wait latch statistics
    SELECT l.misses/(l.gets + 0.000001) INTO v_rcwl
      FROM v$latch l, v$latchname ln
      WHERE ln.name = 'redo copy' AND ln.latch# = l.latch#;
    IF v_rcwl > 0.01 THEN
       dbms_output.put_line ('Redo copy latch miss (WTW)     <=0.01 '||to_char(v_rcwl,'9999990.99')||' Increase LOG_SIMULTANEOUS_COPIES 2xCPU in INIT.ORA');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='log_simultaneous_copies';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='log_small_entry_max_size';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
    ELSE
       dbms_output.put_line ('Redo copy latch miss (WTW)     <=0.01 '||to_char(v_rcwl,'9999990.99')||' OK');
    END IF;
 -- Get redo copy immediate latch statistics
    SELECT l.immediate_misses/(l.immediate_gets + l.immediate_misses + 0.000001) INTO v_rcil
      FROM v$latch l, v$latchname ln
      WHERE ln.name = 'redo copy' AND ln.latch# = l.latch#;
    IF v_rcil > 0.01 THEN
       dbms_output.put_line ('Redo copy latch miss (Immed)   <=0.01 '||to_char(v_rcil,'9999990.99')||' Increase LOG_SIMULATEOUS_COPIES 2xCPU in INIT.ORA');
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='log_simultaneous_copies';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
       SELECT name,value INTO v_iparm,v_ivalue FROM v$parameter WHERE name='log_small_entry_max_size';
       dbms_output.put_line ('-- Current value: '||v_iparm||' = '||v_ivalue);
    ELSE
       dbms_output.put_line ('Redo copy latch miss (Immed)   <=0.01 '||to_char(v_rcil,'9999990.99')||' OK');
    END IF;
-- Get freelist contention statistics
   SELECT count INTO v_freelistwaits FROM v$waitstat WHERE class = 'free list';
   v_flbr := v_freelistwaits/(v_consistentgets + v_dbblockgets);
   IF v_flbr > 0.01 THEN
      dbms_output.put_line ('Freelist contention ratio      <=0.01 '||to_char(v_flbr,'9999990.99')||' Identify tables with contention and add freelists');
   ELSE
      dbms_output.put_line ('Freelist contention ratio      <=0.01 '||to_char(v_flbr,'9999990.99')||' OK');
   END IF;
END;
/

SET SERVEROUTPUT OFF
SET FEEDBACK ON
