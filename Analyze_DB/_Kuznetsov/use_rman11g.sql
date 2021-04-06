REM -------------------------------
REM Script to monitor rman backup/restore operations
REM -------------------------------


col CLI_INFO format a10
col spid format a5
col ch format a30
col seconds format 999999.99
col bfc  format 9
col "% Complete" format 999.99
col event format a40
col status format a12
set numwidth 10

select sysdate from dual;

REM v$session_longops (channel level)

select o.sid, CLIENT_INFO ch, context, sofar, totalwork, round(sofar/totalwork*100,2) "% Complete"
     FROM v$session_longops o, v$session s
     WHERE opname LIKE 'RMAN%'
     AND opname NOT LIKE '%aggregate%'
     AND o.sid=s.sid
     AND totalwork != 0
     AND sofar <> totalwork;

select operation, status, round(mbytes_processed,2) as mbytes_processed, start_time, end_time from v$rman_status where status='RUNNING';

/*
select sid, CLIENT_INFO ch, seq#, event, state, wait_time_micro/1000000 seconds
from v$session where program like '%rman%' and
wait_time = 0 and
not action is null;

REM use the following for 10G
select  sid, CLIENT_INFO ch, seq#, event, state, seconds_in_wait secs
from v$session where program like '%rman%' and
wait_time = 0 and
not action is null;
*/


col filename format a30

select a.sid, CLIENT_INFO Ch, filename, a.type, a.status, buffer_size bsz, buffer_count bfc,
open_time open, io_count
from v$backup_sync_io a, v$session s
where
a.sid=s.sid and
open_time > (sysdate-2/24) ;


col filename format a95

select a.sid, CLIENT_INFO Ch, a.STATUS,
open_time, round(BYTES/1024/1024,2) "SOFAR Mb" , round(total_bytes/1024/1024,2)
TotMb, io_count,
round(BYTES/TOTAL_BYTES*100,2) "% Complete" , a.type, filename
from v$backup_async_io a,  v$session s
where not a.STATUS in ('UNKNOWN')
and a.sid=s.sid and open_time > (sysdate-2/24) order by 2,7;






