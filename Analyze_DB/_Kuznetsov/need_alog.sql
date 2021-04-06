--
-- What last archived log need for recover db
--
select * from (
select thread#, sequence#, first_time, next_time, row_number() over (order by sequence# desc) as rn
from v$archived_log 
where dest_id=1 
  and first_time<=to_date('2007-11-06:18:00:00','YYYY-MM-DD:HH24:MI:SS') 
) where rn<11

