
select /*+ RULE */ operation, status, mbytes_processed, start_time, end_time from v$rman_status where status='RUNNING';
