set feedback off
--
--Script to show Active Distributed Transactions (Doc ID 104420.1)
--Oracle Server, 7.3.x to 12.1
--
column origin format a20
column GTXID format a35
column LSESSION format a10
column s format a8
column waiting format a60

/* --original
Select --+ ORDERED
    substr(s.ksusemnm,1,10)||'-'|| substr(s.ksusepid,1,10) "ORIGIN",
    substr(g.K2GTITID_ORA,1,35) "GTXID",
    substr(s.indx,1,4)||'.'|| substr(s.ksuseser,1,5) "LSESSION" ,
    substr(decode(bitand(ksuseidl,11),
               1,'ACTIVE',
               0, decode(bitand(ksuseflg,4096),0,'INACTIVE','CACHED'),
               2,'SNIPED',
               3,'SNIPED', 'KILLED'),1,1) "S",
    event "WAITING"
from  x$k2gte g, x$ktcxb t, x$ksuse s, v$session_wait w
-- where  g.K2GTeXCB =t.ktcxbxba <= use this if running in Oracle7
where  g.K2GTDXCB =t.ktcxbxba -- comment out if running in Oracle8 or later
   and g.K2GTDSES=t.ktcxbses
   and s.addr=g.K2GTDSES
   and w.sid=s.indx;
*/

Select --+ ORDERED
    substr(s.ksusemnm,1,10)||'-'|| substr(s.ksusepid,1,10) "ORIGIN",
    substr(g.K2GTITID_ORA,1,35) "GTXID",
    substr(s.indx,1,4)||'.'|| substr(s.ksuseser,1,5) "LSESSION" ,
    substr(decode(bitand(ksuseidl,11),
               1,'ACTIVE',
               0, decode(bitand(ksuseflg,4096),0,'INACTIVE','CACHED'),
               2,'SNIPED',
               3,'SNIPED', 'KILLED'),1,1) "S",
    decode(state, 'WAITING', EVENT, 'On CPU / runqueue') "WAITING"
    ,se.osuser
    ,se.machine
    ,se.program
    ,se.module
    ,se.client_identifier
from  x$k2gte g, x$ktcxb t, x$ksuse s, v$session se
-- where  g.K2GTeXCB =t.ktcxbxba <= use this if running in Oracle7
where  g.K2GTDXCB =t.ktcxbxba -- comment out if running in Oracle8 or later
   and g.K2GTDSES=t.ktcxbses
   and s.addr=g.K2GTDSES
   and se.sid=s.indx;

REM distri_details.sql
set headin off
select /*+ ORDERED */
'--------------------------------------------------------------------------------'||'
Curent Time : '|| substr(to_char(sysdate,'dd-Mon-YYYY HH24.MI.SS'),1,22) ||'
'||'GTXID='||substr(g.K2GTITID_EXT,1,10) ||'
'||'Ascii GTXID='||g.K2GTITID_ORA ||'
'||'Branch= '||g.K2GTIBID ||'
Client Process ID is '|| substr(s.ksusepid,1,10)||'
running in machine : '||substr(s.ksusemnm,1,80)||'
  Local TX Id  ='||substr(t.KXIDUSN||'.'||t.kXIDSLT||'.'||t.kXIDSQN,1,10) ||'
  Local Session SID.SERIAL ='||substr(s.indx,1,4)||'.'|| s.ksuseser ||'
  is : '||decode(bitand(ksuseidl,11),1,'ACTIVE',0,
          decode(bitand(ksuseflg,4096),0,'INACTIVE','CACHED'),
          2,'SNIPED',3,'SNIPED', 'KILLED') ||
  ' and '|| substr(STATE,1,9)||
  ' since '|| to_char(SECONDS_IN_WAIT,'9999')||' seconds' ||'
  Wait Event is :'||'
  '||  substr(event,1,30)||' '||p1text||'='||p1
        ||','||p2text||'='||p2
        ||','||p3text||'='||p3    ||'
  Waited '||to_char(SEQ#,'99999')||' times '||'
  Server for this session:' ||decode(s.ksspatyp,1,'Dedicated Server',
                                                2,'Shared Server',
                                                3,'PSE',
                                                  'None') "Server"
from  x$k2gte g, x$ktcxb t, x$ksuse s, v$session_wait w
-- where  g.K2GTeXCB =t.ktcxbxba <= use this if running Oracle7
where  g.K2GTDXCB =t.ktcxbxba -- comment out if running Oracle8 or later
   and  g.K2GTDSES=t.ktcxbses
   and  s.addr=g.K2GTDSES
   and  w.sid=s.indx;

set headin on
set feedback on

--http://jkstill.blogspot.ru/2010/03/whos-using-database-link.html
