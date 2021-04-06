Prompt ===============================================
Prompt What Archived log need for recover at XXXX time
Prompt Must be enter exactly date and time
Prompt ===============================================




select dest_id, thread#, sequence#, first_time, next_time, name
from (
select dest_id, thread#, sequence#, first_time, next_time, name, row_number() over (order by sequence# desc ) rn
from v$archived_log 
where first_time<=to_date('2007-09-04:06:00:00','YYYY-MM-DD:HH24:MI:SS') 
  and dest_id=1
) where rn<11
/



