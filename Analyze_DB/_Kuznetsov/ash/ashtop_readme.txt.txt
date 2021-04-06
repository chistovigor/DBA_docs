@ash/ashtop username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate

@ash/ashtop session_state,event,sql_id session_type='FOREGROUND'  sysdate-1/24 sysdate

@ash/ashtop session_state,event   session_type='FOREGROUND'  sysdate-1/24 sysdate

@ash/ashtop session_state,event   sql_id='6unz1crums4p9'     sysdate-1/24 sysdate


col event format a25
col client_id format a20
col FIRST_SEEN format a20
col LAST_SEEN format a20
col USERNAME format a12
col SESSION_STATE format a10

@ash/ashtop inst_id,username,SESSION_ID,session_state,event,sql_id SESSION_ID=2914  sysdate-1/24 sysdate 

@ash/ashtop inst_id,username,SESSION_ID,session_state,event,sql_id session_type='FOREGROUND'  sysdate-1/24 sysdate 


-- Example:
-- @ash/dash_wait_chains username||':'||program2||event2 session_type='FOREGROUND' sysdate-1/24 sysdate