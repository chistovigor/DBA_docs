select distinct c.sid,
       sess.username,
       sess.osuser,
       sess.schemaname,
       rawtohex(s.address) address,
       s.hash_value,
       s.sql_text
from v$open_cursor c,
     v$sql s,
     v$session sess
where c.hash_value= s.hash_value and 
      c.address=s.address and 
      c.sid = sess.sid 
order by 1
/
