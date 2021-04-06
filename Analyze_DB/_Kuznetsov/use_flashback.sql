set doc on

DOC
######################################################################
##
## Monitoring retention target and flashback size
##
######################################################################
#

set doc off

select name,
       round( space_limit/(1024*1024),3) limit_mb,
       round( space_used/(1024*1024),3) used_mb,
       round( space_reclaimable/(1024*1024),3) reclaimable_mb,
       number_of_files 
from v$recovery_file_dest
/
  
select retention_target retention_target_min, 
       round(flashback_size/(1024*1024),3) flashback_size_mb, 
       round(estimated_flashback_size /(1024*1024),3) estimated_flashback_size_mb
from v$flashback_database_log
/
      

set doc on

DOC
######################################################################
##
## For monitoring flashback logs
## It contains at 24 rows with one row for each of the last 24 hours
##
######################################################################
#

set doc off
                        
select to_char(begin_time, 'YYYY-MON-DD HH24:MI') begin_time,
       to_char(end_time, 'YYYY-MON-DD HH24:MI') end_time,
       round(flashback_data/(1024*1024),3) flashback_data_mb,
       round(db_data/(1024*1024),3) db_data_mb,
       round(redo_data/(1024*1024),3) redo_data_mb
from v$flashback_database_stat
order by begin_time
/

