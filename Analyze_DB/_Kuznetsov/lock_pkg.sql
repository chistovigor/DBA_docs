set doc on

DOC
######################################################################
######################################################################
##
## Package locks
##
######################################################################
######################################################################
#

set doc off


define SCHEMA_NAME='LOT3CONSPRM'
define PACKAGE_NAME='CEPKS_AMLSEARCHENGINE'

select s.process uspid,
       s.sid, 
       s.serial#,
       s.status, 
       s.osuser,
       s.machine,
       --utl_inaddr.get_host_address(substr(s.machine,instr(s.machine,'\')+1)) ip_address,
       s.username, 
       s.program sprogram, 
       s.service_name,
       s.module,
       s.action,
   	   s.sql_id,
	    (select substr(sql_text,1,35) from v$sqltext where sql_id=s.sql_id and piece=0) sql_text,
       s.client_info,
       s.resource_consumer_group,
       s.blocking_session,
       s.state,
       s.event,
       s.p1, 
       s.p2, 
       s.p3
from v$session s
where status = 'ACTIVE'
    and audsid <> userenv('SESSIONID') 
    and sid in
    ( select sid from v$access 
        where owner  = 'FCCHS'
          and object = 'V_IFCCHS_ACCOUNT_INFO_A'
    )
/



