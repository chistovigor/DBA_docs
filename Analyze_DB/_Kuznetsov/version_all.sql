column comp_name format a35
select comp_name, status, substr(version,1,10) as version, schema from dba_registry;


col action format a18
col action_time format a28
col version_id format a18
col comments format a30
select action, version||'.'||id as version_id, comments, ACTION_TIME from DBA_REGISTRY_HISTORY where ID!=0;
select action, version||'.'||id as version_id, comments, ACTION_TIME from DBA_REGISTRY_HISTORY where ID=0;
select action, version||'.'||id as version_id, comments, ACTION_TIME from DBA_REGISTRY_HISTORY;



prompt ************************
prompt ***** Database 12c *****
prompt ************************

col action format a14
col action_time format a28
col version_id format a18
col description format a58

select action, status, version||'.'||bundle_id as version_id, description, ACTION_TIME, patch_id, patch_uid from DBA_REGISTRY_SQLPATCH order by action_time;
