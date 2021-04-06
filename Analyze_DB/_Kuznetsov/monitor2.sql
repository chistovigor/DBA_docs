

col PREV_SQL_TEXT format a30
col HOST_NAME format a20
column program format a28
column service format a18
column event format a20
column LONGOPS_MESSAGE format a30
column REQ_OBJECT format a25
column LATCHNAME  format a25
column P1TEXT  format a15
column P2TEXT  format a15
column P3TEXT  format a15
column KILL_SESSION  format a40
column SQL_PROFILE  format a15
    



select/*+ RULE*/ distinct gv$session.INST_ID
, gv$session.SID
, gv$session.SERIAL#
, gv$session.LOGON_TIME
, gv$session.LAST_CALL_ET as LAST_CALL_ET
, gv$session.STATUS
, gv$session.USERNAME
, gv$session.PROGRAM
, gv$session.SERVICE_NAME as service
, decode(gv$session_wait.state, 'WAITING', gv$session_wait.EVENT,'On CPU / runqueue') as EVENT
, v$latchname.NAME as LATCHNAME
, gv$latchholder.sid
, gv$session_wait.SECONDS_IN_WAIT
, dba_objects.owner||'.'||dba_objects.object_name req_object
, decode(nvl(gv$session.ROW_WAIT_OBJ#,-1),-1,'NONE'
, DBMS_ROWID.ROWID_CREATE( 1, gv$session.ROW_WAIT_OBJ#
, gv$session.ROW_WAIT_FILE#, gv$session.ROW_WAIT_BLOCK#
, gv$session.ROW_WAIT_ROW# )) req_rowid
, lockhold.inst_id as BLOCKING_INSTANCE
, lockhold.sid as BLOCKING_SESSION
, gv$session.COMMAND
, gv$session_longops.TIME_REMAINING as LONGOPS_CALL_RT
, gv$session_longops.MESSAGE as LONGOPS_MESSAGE
, gv$session_wait.P1
, gv$session_wait.P1TEXT
, gv$session_wait.P1RAW /* X$BH.HLADDR for LATCH: CACHE BUFFERS CHAINS */
, gv$session_wait.P2 P2
, gv$session_wait.P2TEXT
, gv$session_wait.P3
, gv$session_wait.P3TEXT
, ses_optimizer_env38.VALUE as ses_optimizer_mode
, ses_optimizer_env48.VALUE as ses_cursor_sharing
, gv$sql.SQL_ID as SQL_ID
, gv$sql.PLAN_HASH_VALUE as PLAN_HASH_VALUE
, gv$sql.OPTIMIZER_MODE as SQL_OPTIMIZER_MODE
,trim(substr(gv$sql.sql_text,1,30)) as sql_text
, gv$sql.SQL_PROFILE
, gv$session.SQL_CHILD_NUMBER SQL_CHILD_NUMBER
, sql1.SQL_ID as PREV_SQL_ID
, sql1.PLAN_HASH_VALUE as PREV_PLAN_HASH_VALUE
, sql1.OPTIMIZER_MODE as PREV_SQL_OPTIMIZER_MODE
,trim(substr(sql1.sql_text,1,30)) as PREV_sql_text
, gv$session.PREV_CHILD_NUMBER
--Network connection properties
, gv$session.SERVER
, gv$session.FAILOVER_TYPE
, gv$session.FAILOVER_METHOD
, gv$session.FAILED_OVER
, gv$session.FIXED_TABLE_SEQUENCE
--OS properties
, gv$session.MACHINE
, gv$session.MODULE
, gv$session.OSUSER
, gv$session.OWNERID
, gv$session.TERMINAL
, 'Alter system kill session '''||gv$session.SID||','||gv$session.SERIAL#
||''';' as KILL_SESSION
--, gv$session.PROCESS
, gv$instance.HOST_NAME
, 'kill -9 '||gv$process.SPID as KILL_SPID
-- from 10g and above - SQL Trace info
, gv$session.SQL_TRACE, gv$session.SQL_TRACE_WAITS, gv$session.SQL_TRACE_BINDS
, 'begin sys.dbms_support.start_trace_in_session('||gv$session.SID||','||
gv$session.SERIAL#||', waits=>TRUE, binds=>TRUE );end;'
, 'begin sys.dbms_support.stop_trace_in_session('||gv$session.SID||','||
gv$session.SERIAL#||' );end;'
from gv$session
, gv$instance
, gv$process
, gv$session_wait
, gv$sql
, gv$sql sql1
, gv$transaction
, v$latchname
, dba_objects
, gv$session_longops
, gv$ses_optimizer_env ses_optimizer_env38
, gv$ses_optimizer_env ses_optimizer_env48
, gv$lock lockwait
, gv$lock lockhold
, gv$latchholder
where gv$session.status='ACTIVE'
and gv$session.INST_ID = gv$instance.INST_ID
and gv$session.PADDR=gv$process.ADDR(+)
and gv$session.INST_ID = gv$process.INST_ID(+)
and gv$session.sql_address=gv$sql.address(+)
and gv$session.sql_hash_value=gv$sql.hash_value(+)
and gv$session.SQL_CHILD_NUMBER = gv$sql.CHILD_NUMBER(+)
and gv$session.INST_ID = gv$sql.INST_ID(+)
and gv$session.PREV_SQL_ADDR = sql1.address(+)
and gv$session.PREV_HASH_VALUE = sql1.hash_value(+)
and gv$session.PREV_CHILD_NUMBER = sql1.CHILD_NUMBER(+)
and gv$session.SID=gv$session_wait.SID(+)
and gv$session.INST_ID = gv$session_wait.INST_ID(+)
and gv$session.SADDR=gv$transaction.SES_ADDR(+)
and gv$session.INST_ID = gv$transaction.INST_ID(+)
and gv$session.SERVICE_NAME not in ('SYS$BACKGROUND')
and gv$session.PROGRAM not like '%QMNC%' --Queue Monitor Coordinator excluded
and gv$session.PROGRAM not like '%q00%' --Queue monitor processes excluded
--and v$session.PROGRAM not like '%J00%' --DBMS_JOB processes excluded
and gv$session_wait.P2=v$latchname.LATCH#(+)
and gv$session_wait.p1raw = gv$latchholder.laddr(+)
and gv$session.ROW_WAIT_OBJ# = dba_objects.object_id(+)
and gv$session.SID = gv$session_longops.sid(+)
and gv$session.INST_ID = gv$session_longops.INST_ID(+)
and gv$session.SERIAL# = gv$session_longops.SERIAL#(+)
and gv$session.sql_address = gv$session_longops.SQL_ADDRESS(+)
and gv$session.sql_hash_value = gv$session_longops.SQL_HASH_VALUE(+)
and (nvl(gv$session_longops.TIME_REMAINING, 1) > 0
     or
     nvl(gv$session_longops.START_TIME, sysdate) = (select max(START_TIME) from gv$session_longops gsl where gv$session.SID = gsl.sid and  gv$session.INST_ID = gsl.INST_ID and gv$session.SERIAL# = gsl.SERIAL# and gv$session.sql_address = gsl.SQL_ADDRESS and gv$session.sql_hash_value = gsl.SQL_HASH_VALUE))
and gv$session.sid = ses_optimizer_env38.sid(+)
and gv$session.INST_ID = ses_optimizer_env38.INST_ID(+)
and nvl(ses_optimizer_env38.id,38) = 38 --optimizer_mode
and gv$session.sid = ses_optimizer_env48.sid(+)
and gv$session.INST_ID = ses_optimizer_env48.INST_ID(+)
and nvl(ses_optimizer_env48.id, 48) = 48--cursor_sharing
and gv$session.LOCKWAIT = lockwait.KADDR(+)
and lockwait.id1 = lockhold.id1(+)
and lockwait.id2 = lockhold.id2(+)
and nvl(lockwait.REQUEST,1) > 0
and nvl(lockwait.LMODE,0) = 0
and nvl(lockhold.REQUEST,0) = 0
and nvl(lockhold.LMODE,1) > 0
and nvl(lockwait.SID,0) <> nvl(lockhold.SID,1)
order by status, LOGON_TIME, username, gv$session.sid;
