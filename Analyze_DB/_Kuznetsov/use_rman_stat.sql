col OUTPUT_DEVICE_TYPE format a10
col STATUS format a25
col INPUT_BYTES_PER_SEC_DISPLAY format a12
col OUTPUT_BYTES_PER_SEC_DISPLAY format a12
col TIME_TAKEN_DISPLAY format a12

select SESSION_KEY,
       START_TIME, 
       OUTPUT_DEVICE_TYPE, 
       INPUT_TYPE,
       STATUS, 
       ELAPSED_SECONDS, 
       COMPRESSION_RATIO, 
       INPUT_BYTES_PER_SEC_DISPLAY, 
       OUTPUT_BYTES_PER_SEC_DISPLAY, 
       TIME_TAKEN_DISPLAY 
from v$rman_backup_job_details
where INPUT_TYPE='DB FULL'
order by START_TIME;

select SESSION_KEY,
       START_TIME, 
       OUTPUT_DEVICE_TYPE, 
       INPUT_TYPE,
       STATUS, 
       ELAPSED_SECONDS, 
       COMPRESSION_RATIO, 
       INPUT_BYTES_PER_SEC_DISPLAY, 
       OUTPUT_BYTES_PER_SEC_DISPLAY, 
       TIME_TAKEN_DISPLAY 
from v$rman_backup_job_details
where INPUT_TYPE='DB INCR'
order by START_TIME;

