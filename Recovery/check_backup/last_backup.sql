set heading off
set feedback off
set termout off
set trimspool on

select to_char(max(END_TIME),'dd/mm/yy hh24:mi') LAST_BACKUP from V$RMAN_BACKUP_JOB_DETAILS
 where INPUT_TYPE = 'DB FULL' and STATUS = 'COMPLETED';
