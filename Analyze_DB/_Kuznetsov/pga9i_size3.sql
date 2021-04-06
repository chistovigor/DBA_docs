select
    s.sid,
    s.serial#,
    p.program,
    round(p.pga_used_mem/1024/1024,1) pga_used_mb,
    round(p.pga_alloc_mem/1024/1024,1) pga_alloc_mb,
    round(p.pga_max_mem/1024/1024,1) pga_max_mb,
    s.sql_id,
    q.sql_id,
    substr(q.sql_text,1,30)
from
   v$process p,
   v$session s,
   v$sql q
where
  p.addr = s.paddr and
  s.sql_address = q.address(+) and
  s.sql_hash_value = q.hash_value(+) and
  p.pga_used_mem > 1024*1024*50;



