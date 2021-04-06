set serveroutput on size 200000 format wrapped
set trimspool on

spool hitratio2.log

declare
 v_xInstanceName varchar2(30);
 v_xPortString   varchar2(30);
 v_xLibNameSpace varchar2(30);
 v_xLibGetHitRatio numeric(5,2);
 v_xLibPinHitRatio numeric(5,2);
 v_xLibReloadRatio char(10);
 v_xDictHitRatio char(10);
 v_xBuffHitRatio char(10);
 v_xSharedPoolReservedSize varchar(15); 
 v_xLogBufferRatio char(10);
 v_xSortRatio char(10);
begin
 -- Instance Name
 dbms_output.put_line(' ');
 select upper(host_name) ||' - ' || upper(instance_name) || ' - ' || version as instance_name into v_xInstanceName from v$instance;
 select dbms_utility.port_string into v_xPortString from dual;
 dbms_output.put_line('Instance : ' || v_xInstanceName || ' - PortString = ' || v_xPortString);
 dbms_output.put_line(' ');
 
 --
 -- Shared Pool
 --
 
 -- Library Cache hit ratio
 dbms_output.put_line('1. Library cache hit ratio');
 dbms_output.put_line('--------------------------');
 dbms_output.put_line(lpad('Name Space',15) || ' GetHit%' || ' PinHit%');
 for l_lib in (select namespace, 
                      round(gethitratio*100,2) gethitratio, 
                      round(pinhitratio*100,2) pinhitratio 
               from v$librarycache 
               order by 2 desc, 3 desc)
 loop
  dbms_output.put_line(lpad(l_lib.namespace,15) || ' ' || rpad(trim(to_char(l_lib.gethitratio,'900D00')),8) || rpad(trim(to_char(l_lib.pinhitratio,'900D00')),7));
 end loop;
 
 -- Library Cache Reloads Ratio
 dbms_output.put_line(' ');
 dbms_output.put_line('2. Library cache reloads ratio');
 dbms_output.put_line('------------------------------');
 select trim(to_char(round((sum(reloads)/sum(pins))*100,2),'00D0000'))||'%' reloads_ratio into v_xLibReloadRatio 
 from v$librarycache;
 dbms_output.put_line(lpad(v_xLibReloadRatio,25)); 
 
 -- Library Cache Reserved size (Pinned object)
 dbms_output.put_line(' ');
 dbms_output.put_line('3. Shared Pool Reserved size (Pinned object)');
 dbms_output.put_line('----------------------------------------------');
 select trim(to_char(value/(1024*1024),'999G999G999D00'))||' MB' shared_pool_reserved_size into v_xSharedPoolReservedSize from v$parameter where name='shared_pool_reserved_size';
 dbms_output.put_line('shared_pool_reserved_size = ' || v_xSharedPoolReservedSize);
 dbms_output.put_line(' ');
 dbms_output.put_line('statistics in v$shared_pool_reserved');
 for l_res in (select free_space, request_misses, request_failures from v$shared_pool_reserved)
 loop
  dbms_output.put_line('   free_space       = ' || to_char(l_res.free_space,'999G999G999D00'));
  dbms_output.put_line('   request_misses   = ' || to_char(l_res.request_misses));
  dbms_output.put_line('   request_failures = ' || to_char(l_res.request_failures));
 end loop;
 dbms_output.put_line(' ');
 dbms_output.put_line('Pinned object size ');
 dbms_output.put_line(lpad('Owner',15)||' '||'Size');
 for l_pin in (select * from (select owner, round(sum(sharable_mem)/(1024*1024),2) SIZE_MB from v$db_object_cache where kept='YES' group by owner) where size_mb>0)
 loop
  dbms_output.put_line(lpad(l_pin.owner,15) || ' ' || trim(to_char(l_pin.size_mb,'999G999G999D00'))||'MB');
 end loop;


 
 -- Data dictionary hit ratio
 dbms_output.put_line(' ');
 dbms_output.put_line('4. Data dictionary hit ratio');
 dbms_output.put_line('------------------------------');
 select trim(to_char((1 - (sum(getmisses)/sum(gets)))*100,'900D0000'))||'%' dicthitratio into v_xDictHitRatio
 from v$rowcache;
 dbms_output.put_line(lpad(v_xDictHitRatio,25)); 

 -- Buffer Cache hit ratio
 dbms_output.put_line(' ');
 dbms_output.put_line('5. Buffer cache hit ratio');
 dbms_output.put_line('------------------------------');
 select trim(to_char((1 - ((physical.value - direct.value - lobs.value) / logical.value))*100,'900D0000'))||'%' buffercachehitratio into v_xBuffHitRatio
 from v$sysstat physical,
      v$sysstat direct,
      v$sysstat lobs,
      v$sysstat logical
 where physical.name = 'physical reads' and
       direct.name   = 'physical reads direct' and
       lobs.name     = 'physical reads direct (lob)' and      
       logical.name  = 'session logical reads';
 dbms_output.put_line(lpad(v_xBuffHitRatio,25)); 

 -- Buffer Cache non-hit ratio
 dbms_output.put_line(' ');
 dbms_output.put_line('6. Buffer cache non-hit ratio');
 dbms_output.put_line('------------------------------');
 dbms_output.put_line(lpad('Name',20) || '   Value');
 for l_buff in (select name, value
                from v$sysstat
                where name in ('free buffer inspected')
                union all
                select event, total_waits
                from v$system_event
                where event in ('free buffer waits','buffer busy waits'))
 loop
  dbms_output.put_line(lpad(l_buff.name,20) || ' ' || lpad(to_char(l_buff.value),7));
 end loop;

 -- Buffer Cache Advisory Statistics
 dbms_output.put_line(' ');
 dbms_output.put_line('7. Buffer Cache Advisory Statistics');
 dbms_output.put_line('-----------------------------------');
 dbms_output.put_line('NAME - SIZE_ESTIMATE - PHYSICAL_READS - READ_FACTOR');
 for l_adv in (select name, size_for_estimate, estd_physical_reads, estd_physical_read_factor
               from v$db_cache_advice
               where advice_status='ON' and
                     block_size = (select value 
                                   from v$parameter 
                                   where name='db_block_size'))
 loop
  dbms_output.put_line(lpad(l_adv.name,10) || ' ' || lpad(l_adv.size_for_estimate,7)||'MB' || ' ' || lpad(l_adv.estd_physical_reads,7) || ' ' || lpad(l_adv.estd_physical_read_factor,7));
 end loop;
 
 -- Buffer Pool
 dbms_output.put_line(' ');
 dbms_output.put_line('8. Buffer Pool');
 dbms_output.put_line('-----------------------------------');
 --dbms_output.put_line('Pool name     block_size     current_size');
 for l_pool in (select name, block_size, current_size from v$buffer_pool)
 loop
  dbms_output.put_line(lpad(l_pool.name,10) || ' ' || lpad(to_char(l_pool.block_size),10) || ' ' || lpad(to_char(l_pool.current_size),10)||'MB');
 end loop; 
 
 -- Buffer Pool Statistics
 dbms_output.put_line(' ');
 dbms_output.put_line('9. Buffer Pool Statistics');
 dbms_output.put_line('-----------------------------------');
 for l_pools in (select name poolname,
                trim(to_char((1 - (physical_reads/(db_block_gets + consistent_gets)))*100,'900D0000'))||'%' poolhitratio
                from v$buffer_pool_statistics)
 loop
  dbms_output.put_line(lpad(l_pools.poolname,10) || ' ' || lpad(to_char(l_pools.poolhitratio),10));
 end loop; 
 
 -- LOG_BUFFER
 dbms_output.put_line(' ');
 dbms_output.put_line('10. Log Buffer Ratio (tuning chechpoint or log switch)');
 dbms_output.put_line('-----------------------------------');
 select trim(to_char((retries.value/entries.value)*100,'900D0000'))||'%' Log_B_Ratio into v_xLogBufferRatio
 from v$sysstat retries,
      v$sysstat entries
 where retries.name = 'redo buffer allocation retries' and
       entries.name = 'redo entries'; 
 dbms_output.put_line(lpad(v_xLogBufferRatio,14)); 

 dbms_output.put_line(' ');
 dbms_output.put_line('11. Log Buffer Session wait for each user session');
 dbms_output.put_line('--------------------------------------------------');
 for l_logm in (select username, wait_time, seconds_in_wait, v$session_wait.state
                from v$session_wait, v$session
                where v$session_wait.sid = v$session.sid and event like '%log buffer%')
 loop
  dbms_output.put_line(lpad(l_logm.username,20) || ' ' || to_char(l_logm.wait_time) || ' ' || to_char(l_logm.seconds_in_wait) || ' ' || l_logm.state);
 end loop;

 dbms_output.put_line(' ');
 dbms_output.put_line('12. Log Buffer I/O concurents (LGWR waits while log switch complete)');
 dbms_output.put_line('-----------------------------------');
 for l_logc in (select name, value
                from v$sysstat
                where name = 'redo log space requests')
 loop
  dbms_output.put_line(lpad(l_logc.name,27) || ' - ' || to_char(l_logc.value)); 
 end loop;

 dbms_output.put_line(' ');
 dbms_output.put_line('13. Online Redo Log Files');
 dbms_output.put_line('--------------------------');
 dbms_output.put_line(lpad('Event',27) ||'   ' || lpad('total_waits',10) ||'   '|| lpad('average_wait',12));
 for l_oredo in (select event, total_waits, average_wait
                 from v$system_event
                 where event in ('log file switch completion','log file parallel write'))
 loop
  dbms_output.put_line(lpad(l_oredo.event,27) ||' - ' || lpad(to_char(l_oredo.total_waits),10) ||' - '|| lpad(to_char(l_oredo.average_wait),7));
 end loop;
 
 dbms_output.put_line(' ');
 dbms_output.put_line('14. Checkpoint (v$sysstat)');
 dbms_output.put_line('--------------------------');
 dbms_output.put_line(lpad('Name',35) || '  Value');
 for l_ckpt1 in ( select name, value
                  from v$sysstat
                  where name in ('background checkpoints started','background checkpoints completed'))
 loop
  dbms_output.put_line(lpad(l_ckpt1.name,35) || ' - ' || to_char(l_ckpt1.value)); 
 end loop;

 dbms_output.put_line(' ');
 dbms_output.put_line('15. Checkpoint (v$system_event)');
 dbms_output.put_line('--------------------------');
 dbms_output.put_line(lpad('Event',27) ||'   ' || lpad('total_waits',10) ||'   '|| lpad('average_wait',12));
 for l_ckpt2 in (select event, total_waits, average_wait
                 from v$system_event
                 where event in ('checkpoint completed','log file switch (checkpoint incomplete)'))
 loop
  dbms_output.put_line(lpad(l_ckpt2.event,27) ||' - ' || lpad(to_char(l_ckpt2.total_waits),10) ||' - '|| lpad(to_char(l_ckpt2.average_wait),7));
 end loop;

 dbms_output.put_line(' ');
 dbms_output.put_line('16. Sort ratio (sort activity)');
 dbms_output.put_line('------------------------------');
 select trim(to_char((mem.value/(disk.value+mem.value))*100,'900D00'))||'%' SortRatio into v_xSortRatio
 from v$sysstat mem, v$sysstat disk
 where mem.name = 'sorts (memory)' and disk.name = 'sorts (disk)';
 dbms_output.put_line(lpad(v_xSortRatio,25)); 

 dbms_output.put_line(' ');
 dbms_output.put_line('17. Latch contention (v$system_event)');
 dbms_output.put_line('------------------------------');
 dbms_output.put_line(lpad('Event',15) ||'   ' || lpad('total_waits',10) ||'   '|| lpad('average_wait',12));
 for l_latch1 in (select event, total_waits, time_waited
                  from v$system_event
                  where event='latch free')
 loop
  dbms_output.put_line(lpad(l_latch1.event,15) || ' - ' || lpad(to_char(l_latch1.total_waits),10) || ' - ' || lpad(to_char(l_latch1.time_waited),12));
 end loop;

 dbms_output.put_line(' ');
 dbms_output.put_line('18. Latch contention (v$latch)');
 dbms_output.put_line('------------------------------');
 dbms_output.put_line(lpad('Name',30) || ' - ' || lpad(to_char('Gets'),10) || ' - ' || lpad(to_char('Misses'),8) || ' - ' || lpad(to_char('Wait_time'),8) || ' - ' || lpad(to_char('Imm_Gets'),10) || ' - ' || lpad(to_char('Imm_Misses'),10));
 for l_latch2 in (select name, gets, misses, wait_time, immediate_gets, immediate_misses
                  from v$latch
                  where name in ('shared pool',
                                 'library cache',
                                 'cache buffers lru chain',
                                 'cache buffers chains',
                                 'redo allocation',
                                 'redo copy')
                 order by 1)
 loop
  dbms_output.put_line(lpad(l_latch2.name,30) || ' - ' || lpad(to_char(l_latch2.gets),10) || ' - ' || lpad(to_char(l_latch2.misses),8) || ' - ' || lpad(to_char(l_latch2.wait_time),8) || ' - ' || lpad(to_char(l_latch2.immediate_gets),10) || ' - ' || lpad(to_char(l_latch2.immediate_misses),10));
 end loop;
 
 dbms_output.put_line(' ');
 dbms_output.put_line('19. Table scans');
 dbms_output.put_line('------------------------------');
 dbms_output.put_line(lpad('Name',30) || ' - ' || lpad(to_char('Value'),10));
 
 for l_tscan in (select name, value from v$sysstat where name like '%table scans%')
 loop
   dbms_output.put_line(lpad(l_tscan.name,30) || ' - ' || lpad(to_char(l_tscan.value),10));
 end loop;
 
end;
/

spool off
