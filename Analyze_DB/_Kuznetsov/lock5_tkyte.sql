select username,
       v$lock.sid,
       trunc(id1/power(2,16)) rbs,
       bitand(id1,power(2,16)-1)+0 slot,
       id2 seq,
       lmode,
       request,
       v$lock.type
from v$lock, v$session
where  v$lock.sid = v$session.sid and v$lock.type = 'TX'
/


select username,
       v$lock.sid,
       (select object_name from dba_objects where object_id=id1) object_name, 
       id2,
       lmode,
       request, 
       block, 
       v$lock.type
from v$lock, v$session
where v$lock.sid = v$session.sid and v$lock.type = 'TM'
/


