alter session set optimizer_mode=RULE;

column module format a15
column action format a15
column object_name format a25
col sql_text format a100 heading 'sql query' 

select lpad(' ',decode(l.xidusn,0,3,0)) || l.oracle_username USER_NAME,
       case l.xidusn when 0 then 'WAITING' else 'BLOCKING' end STATUS,
       --s.blocking_session,
       s.module,
       s.action,
       l.session_id,
       s.serial#,
       o.owner,
       o.object_name,
       o.object_type,
       a.sql_text
from v$locked_object l,
     dba_objects o,
     v$session s,
     v$sqlarea a
where l.object_id = o.object_id
  and l.session_id = s.sid
  and s.sql_hash_value = a.hash_value
  and s.sql_address = a.address
order by o.object_id, 1 desc
/
