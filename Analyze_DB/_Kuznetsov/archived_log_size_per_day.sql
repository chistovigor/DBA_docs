--
-- Total size of archived log per days
--

select nvl(to_char(trunc(completion_time),'YYYY-MM-DD'),'TOTAL_SIZE_GB') completion_time, 
       round(sum(blocks*block_size)/(1024*1024*1024),0) size_gb 
from v$archived_log 
where (THREAD#, SEQUENCE#) in (select THREAD#, SEQUENCE# from v$log_history)
group by cube(to_char(trunc(completion_time),'YYYY-MM-DD')) 
order by 1 asc
/

