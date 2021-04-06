col reason format a80
col object_type format a30

select instance_name, sequence_id, object_type, reason from dba_outstanding_alerts order by 1,2;

