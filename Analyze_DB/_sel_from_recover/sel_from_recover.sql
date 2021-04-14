SET TERMOUT ON
SET ECHO OFF
SET VERIFY OFF
SET LINESIZE 300
SET PAGESIZE 75

SPOOL sel_from_recover.log

ACCEPT Server PROMPT 'Enter DATABASE name (default - DATABASE): ' DEFAULT DATABASE
ACCEPT SYSpsw PROMPT 'Enter SYS password: ' DEFAULT sys HIDE
CONNECT SYS/&SYSpsw@&Server AS SYSDBA

PROMPT ********************
PROMPT sel_from_recover 4.9
PROMPT ********************


PROMPT
PROMPT *********** CONNECTION STRING *************
PROMPT "SYS/&SYSpsw@&Server"

PROMPT
PROMPT *********** SCRIPT START TIME *************
SET HEADING OFF
select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') from dual;
SET HEADING ON

PROMPT
PROMPT
PROMPT ######
PROMPT ##############
PROMPT ### CONTENTS ###
PROMPT ##############
PROMPT ######
PROMPT
PROMPT ### 1 OVERALL INFO ###
PROMPT ************** ORACLE DBMS VERSION *************
PROMPT ************** SERVER PROPERTIES *************
PROMPT ************** DATABASE TOTAL SIZE *************
PROMPT ************** INSTANCE MAX MEMORY SIZE *************
PROMPT ************** INITITIALIZATION PROPERTIES *************
PROMPT ************** DATABASE PROPERTIES *************
PROMPT ************** DATABASE COMPONENTS *************
PROMPT ************** FLASH RECOVERY AREA  *************
PROMPT ************** NLS PARAMETERS *************
PROMPT ************** SESSIONS *************
PROMPT ************** PROCESSES *************
PROMPT ************** RUNNING SQL QUERIES *************
PROMPT
PROMPT ### 2 FILE INFO ###
PROMPT ************** REDOFILES *****************
PROMPT ************** CONTROLFILES *****************
PROMPT ************** DATAFILES *****************
PROMPT ************** TEMPFILES *****************
PROMPT ************** TABLESPACES *****************
PROMPT ************** TS 10G PROPERTIES *****************
PROMPT
PROMPT ### 3 USERS AND OBJECTS INFO ###
PROMPT ************** USERS WITH OBJECTS *****************
PROMPT ************** EMPTY USERS *****************
PROMPT ************** DBA ROLES *****************
PROMPT ************** NCT INFO *****************
PROMPT ************** TOP 25 BIG OBJECTS *****************
PROMPT ************** JO EXCHANGE TABLES *****************
PROMPT ************** JO EXCHANGE INDEXES *****************
PROMPT ************** OBJECT ERRORS *****************
PROMPT ************** LOCKED OBJECTS *****************
PROMPT ************** UNUSABLE INDEXES *****************
PROMPT ************** INVALID OBJECTS *****************
PROMPT ************** COMPRESSED TABLES *****************
PROMPT
PROMPT ### 4 RECOVERY INFO ###
PROMPT ************** INIT PARAMETERS *****************
PROMPT ************** FILES FOR RECOVER *************
PROMPT ************** RECOVERY FILE STATUS *************
PROMPT ************** RECOVER LOG *************
PROMPT ************** RECOVERY STATUS *************
PROMPT ************** BACKUP CORRUPTION *************
PROMPT ************** DB BLOCK CORRUPTION *************
PROMPT
PROMPT ### 5 MEMORY INFO AND ADVICES ###
PROMPT ************** MEMORY PARAMETERS **************
PROMPT ************** CURRENT SGA TOTAL SIZE *************
PROMPT ************** BUFFER CACHE ADVICE **************
PROMPT ************** SHARED POOL ADVICE *************
PROMPT ************** PGA TARGET ADVICE *************
PROMPT ************** PGA CHANGING *************
PROMPT ************** PGA STATS *************
PROMPT ************** SGA BUFFERS *************
PROMPT ************** RESOURCE USAGE *************
PROMPT ************** DISK SORTS *************
PROMPT ************** INSTANCE RATIOS *************
PROMPT ************** BUFFER CACHE GETS *************
PROMPT ************** SHARED POOL SIZES *************
PROMPT ************** SHARED POOL LIBRARY CACHE HIT RATIO *************
PROMPT ************** SHARED POOL DICTIONARY CACHE HIT RATIO  *************
PROMPT ************** WAIT STATS *************
PROMPT ************** TOTAL WAITS *************
PROMPT ************** SESSION WAITS *************
PROMPT ************** SYSTEM EVENTS *************
PROMPT
PROMPT ### 6 UNDO AND RBS INFO ###
PROMPT ************** UNDO STATUSES *************
PROMPT ************** UNDO SEGMENTS LOGICAL *************
PROMPT ************** UNDO SEGMENTS PHYSICAL *************
PROMPT ************** UNDO SEGMENTS GETS AND WAITS *************
PROMPT ************** ADDITIONAL UNDO STATS *************
PROMPT
PROMPT ### 7 REDO AND WAITS INFO ###
PROMPT ************** REDO DYNAMICS DURING LAST DAYS *****************
PROMPT ************** REDOLOG CONFLICTS *****************
PROMPT ************** REDO CONTENTION *****************
PROMPT ************** LATCH CONTENTION *****************
PROMPT ************** GETHIT RATIO *****************
PROMPT ************** I/O FOR DBFILES *****************
PROMPT ************** I/O CONFLICTS *****************
PROMPT ************** WAITS STATS *****************
PROMPT ************** SORTWORK STATS *****************
PROMPT
PROMPT ### 8 STATS AND TRANSACTIONS INFO ###
PROMPT ************** NOT ANALYZED TABLES *****************
PROMPT ************** RECYCLE BIN OBJECTS *****************
PROMPT ************** ACTIVE TRANSACTIONS *****************
PROMPT ************** UNFINISHED TRANSACTIONS *****************
PROMPT ************** SCHEDULER *****************
PROMPT ************** RUNNNING JOBS *****************
PROMPT ************** SCHEDULER DETAILS *****************
PROMPT
PROMPT ### 9 ALERTS AND REPORTS ###
PROMPT ************** DBA ALERTS HISTORY *************
PROMPT ************** ADDM REPORT *************
PROMPT ************** ADVISOR FINDINGS *************
PROMPT ************** ALERT LOG *****************
PROMPT
PROMPT ### 10 LOCAL INFO ###
PROMPT ************** SCRIPT END TIME *************
PROMPT ************** LOCAL ORACLE REGISTRY *************
PROMPT ************** LOCAL LISTENER *************
PROMPT ************** LOCAL ENVIRONMENT VARIABLE (PATH) *************
PROMPT ************** LOCAL OS INFO *************

Begin
 DBMS_STATS.GATHER_TABLE_STATS('sys', 'fet$');
 DBMS_STATS.GATHER_TABLE_STATS('sys', 'uet$');
 DBMS_STATS.GATHER_TABLE_STATS('sys', 'ts$');
 commit;

 DBMS_STATS.GATHER_TABLE_STATS('sys', 'fet$');
 DBMS_STATS.GATHER_TABLE_STATS('sys', 'uet$');
 DBMS_STATS.GATHER_TABLE_STATS('sys', 'ts$');
 commit;
end;
/


PROMPT
PROMPT
PROMPT
PROMPT #########
PROMPT ####################
PROMPT ### 1 OVERALL INFO ###
PROMPT ####################
PROMPT #########
PROMPT

PROMPT ************** ORACLE DBMS VERSION *************
SET HEADING OFF
SELECT banner
  FROM v$version;
SET HEADING ON


PROMPT 
PROMPT ************** SERVER PROPERTIES *************
SET HEADING OFF
SELECT 'Number of CPU cores - ' || value from V_$OSSTAT where stat_name='NUM_CPU_CORES'
UNION
SELECT 'Available physical memory - ' || round(value/1024/1024,1) || ' Mb' from V_$OSSTAT where stat_name='PHYSICAL_MEMORY_BYTES'
;
SET HEADING ON


PROMPT
PROMPT ************** DATABASE TOTAL SIZE *************
SET HEADING OFF
select 'Total DB Size - ' || to_char(round(sum(t.bytes)/1024/1024/1024,1)) || 'Gb' 
from v$datafile t;
SET HEADING ON


PROMPT
PROMPT ************** INSTANCE MAX MEMORY SIZE *************
PROMPT This is the maximum memory that instance can use. It counts current settings even with auto-SGA and auto-MEMORY management turned on.
SET SERVEROUTPUT ON

DECLARE
var_auto_pga number;
var_auto_sga number;
var_auto_mem number;
var_auto_buf number;
var_mem_counter number;
var_mem_pga number;
var_mem_sga number;
var_mem_buf number;
var_blksize number;

BEGIN

BEGIN
	SELECT p.value INTO var_auto_pga FROM v$parameter p WHERE p.name IN ('pga_aggregate_target') ;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	var_auto_pga := 0;
END;

BEGIN
	SELECT p.value INTO var_auto_sga FROM v$parameter p WHERE p.name IN ('sga_target') ;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	var_auto_sga := 0;
	BEGIN
		SELECT p.value INTO var_auto_buf FROM v$parameter p WHERE p.name IN ('db_cache_size') ;
	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		var_auto_buf := 0;
	END;
END;

BEGIN
	SELECT p.value INTO var_auto_mem FROM v$parameter p WHERE p.name IN ('memory_target') ;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
	var_auto_mem := 0;
END;

var_mem_counter := 0;

IF var_auto_mem > 0 THEN
	SELECT p.value INTO var_mem_counter FROM v$parameter p WHERE p.name IN ('memory_max_target') ;
ELSE 
	IF var_auto_pga > 0 THEN
		SELECT p.value INTO var_mem_pga FROM v$parameter p WHERE p.name IN ('pga_aggregate_target'); 
	ELSE 
		SELECT SUM(p.value) INTO var_mem_pga FROM v$parameter p WHERE p.name IN ('sort_area_size','hash_area_size'); 
	END IF;
	IF var_auto_sga > 0 THEN
		SELECT p.value INTO var_mem_sga FROM v$parameter p WHERE p.name IN ('sga_target'); 
	ELSE 
		IF var_auto_buf > 0 THEN
			SELECT SUM(p.value) INTO var_mem_sga FROM v$parameter p WHERE p.name IN ('db_cache_size','large_pool_size','java_pool_size','log_buffer','shared_pool_size');
		ELSE
			SELECT p2.VALUE INTO var_blksize FROM v$parameter p2 WHERE p2.NAME IN ('db_block_size');
			SELECT SUM(p.value) INTO var_mem_sga FROM v$parameter p WHERE p.name IN ('large_pool_size','java_pool_size','log_buffer','shared_pool_size');
			SELECT SUM(p.value) INTO var_mem_buf FROM v$parameter p WHERE p.name IN ('db_block_buffers');
			var_mem_buf := var_mem_buf * var_blksize;
			var_mem_sga := var_mem_sga + var_mem_buf;
		END IF;
	END IF;
	var_mem_counter := var_mem_pga + var_mem_sga;
END IF;

DBMS_OUTPUT.PUT_LINE('Max memory on Instance - ' || round(var_mem_counter/1024/1024,2) || ' Mb');

END;
/


PROMPT
PROMPT ************** INITITIALIZATION PROPERTIES *************
SET HEADING OFF
SELECT 'Initialization Type - ' || DECODE(value, NULL, 'PFILE', 'SPFILE')
FROM sys.v_$parameter WHERE name = 'spfile';
SET HEADING ON


PROMPT
PROMPT ************** DATABASE PROPERTIES *************
COLUMN NAME FORMAT A20 HEADING "Database name"
COLUMN LOG_MODE FORMAT A15 HEADING "Log mode"
COLUMN checkpoint_change# FORMAT 999,999,999,999 HEADING "Checkpoint chng #"
COLUMN archive_change# FORMAT 999,999,999,999 HEADING "Archived chng #"
COLUMN controlfile_change# FORMAT 999,999,999,999 HEADING "Controlfile chng #"
COLUMN controlfile_sequence# FORMAT 999,999,999,999 HEADING "Controlfile seq #"
COLUMN open_mode FORMAT A20 HEADING "Database mode"
SELECT NAME, log_mode, checkpoint_change#, archive_change#,
       controlfile_sequence#, controlfile_change#, open_mode
  FROM v$database;

COLUMN INSTANCE_NAME FORMAT A20 HEADING "Instance name"
COLUMN HOST_NAME FORMAT A25 HEADING "Host name"
COLUMN VERSION FORMAT A20 HEADING "Instance version"
COLUMN STARTED FORMAT A25 HEADING "Instance started"
COLUMN STATUS FORMAT A15 HEADING "Status"
SELECT INSTANCE_NAME, HOST_NAME, VERSION, TO_CHAR(STARTUP_TIME,'DD-MON-YYYY HH24:Mi:SS') STARTED, STATUS
  FROM v$instance;

PROMPT
PROMPT ************** DATABASE COMPONENTS *************
COLUMN comp_name FORMAT A40 HEADING "Component name"
SELECT comp_name, VERSION, status, modified
  FROM dba_registry
	ORDER BY comp_name;


PROMPT
PROMPT ************** FLASH RECOVERY AREA  *************
column name format A100	HEADING "Path"
column SPACE_MAX format A15	HEADING "Space Limit"
column SPACE_USED format A15	HEADING "Space Used"
column Free_space format A15	HEADING "% Free"
column NUMBER_OF_FILES format 999,999	HEADING "# of Files"
select 			name, 
				round(SPACE_LIMIT/1024/1024/1024,1)  || ' Gb'  "SPACE_MAX", 
				round(SPACE_USED/1024/1024/1024,1)|| ' Gb' "SPACE_USED", 
				round((SPACE_LIMIT-SPACE_USED)/SPACE_LIMIT*100,1)||'%' "Free_space", 
				NUMBER_OF_FILES   
from V$RECOVERY_FILE_DEST
ORDER BY 1;	
	
	
PROMPT
PROMPT ************** NLS PARAMETERS *************
SELECT * FROM v$nls_parameters;


PROMPT  
PROMPT ************** SESSIONS *************
PROMPT For killing session, you need to specify in SQL - "ALTER SYSTEM DISCONNECT SESSION '<SID>,<SERIAL>' IMMEDIATE;"
COLUMN User        	format A25  trunc
COLUMN Client      	format A25  trunc
COLUMN Address      format A35  trunc
COLUMN Login     	format A20  trunc
COLUMN Started    	format A22  trunc
COLUMN TO_KILL    	format A25  heading "Sid-n-Serial to KILL it!"	trunc
SELECT 		t.USERNAME "User", 
			t.PROGRAM "Client", 
			t.MACHINE "Address", 
			t.OSUSER "Login", 
			to_char(t.LOGON_TIME,'dd/mm/yyyy hh24:mi:ss') "Started",
			'''' || t.SID || ',' || t.SERIAL# || '''' "TO_KILL" 
FROM v$session t
ORDER BY 1,2,3;  


PROMPT
PROMPT ************** PROCESSES *************
PROMPT For killing process, you need to specify in CMD - "orakill &Server <SPID>"
COLUMN O_USER      format A15  HEADING "Oracle User" trunc
COLUMN U_USER      format A15  HEADING "OS User" trunc
COLUMN TERMINAL    format A20  HEADING "Workstation" trunc
COLUMN PROGRAM     format A60  HEADING "Program" trunc
COLUMN BACKGROUND  format A10  HEADING "Background?" 
COLUMN SID#        format A25  HEADING "SPID to KILL it!" trunc justify LEFT
SELECT   	s.program program,
			UPPER (DECODE (NVL (s.command, 0),
                        0, '---------------',
                        1, 'Create Table',
                        2, 'Insert ...',
                        3, 'Select ...',
                        4, 'Create Cluster',
                        5, 'Alter Cluster',
                        6, 'Update ...',
                        7, 'Delete ...',
                        8, 'Drop ...',
                        9, 'Create Index',
                        10, 'Drop Index',
                        11, 'Alter Index',
                        12, 'Drop Table',
                        13, '--',
                        14, '--',
                        15, 'Alter Table',
                        16, '--',
                        17, 'Grant',
                        18, 'Revoke',
                        19, 'Create Synonym',
                        20, 'Drop Synonym',
                        21, 'Create View',
                        22, 'Drop View',
                        23, '--',
                        24, '--',
                        25, '--',
                        26, 'Lock Table',
                        27, 'No Operation',
                        28, 'Rename',
                        29, 'Comment',
                        30, 'Audit',
                        31, 'NoAudit',
                        32, 'Create Ext DB',
                        33, 'Drop Ext. DB',
                        34, 'Create Database',
                        35, 'Alter Database',
                        36, 'Create RBS',
                        37, 'Alter RBS',
                        38, 'Drop RBS',
                        39, 'Create Tablespace',
                        40, 'Alter Tablespace',
                        41, 'Drop tablespace',
                        42, 'Alter Session',
                        43, 'Alter User',
                        44, 'Commit',
                        45, 'Rollback',
                        46, 'Savepoint'
                       )
               ) job,
			   'U:' || p.username u_user,
			   p.terminal,
			   'O:' || LOWER (s.username) o_user,
			   DECODE (NVL (p.background, 0), 0, ' ', 'B') background,
			   trim(to_char(p.spid)) SID#			   
    FROM v$process p, v$session s
   WHERE p.addr = s.paddr(+) AND p.spid IS NOT NULL
ORDER BY 1, program, p.username, s.username, p.spid;



PROMPT  
PROMPT ************** RUNNING SQL QUERIES *************
SET LINESIZE 1000
PROMPT For checking QUERY PLAN use the following string in SQL - "select * from table(dbms_xplan.display_awr('<SQL_ID>',<PLAN_HASH>));"
COLUMN parsing_user      format A15  HEADING "User"
COLUMN SID      format 9999  HEADING "SID"
COLUMN MODULE    format A25  HEADING "Program"
COLUMN STEXT     format A400  HEADING "Query text"
COLUMN sql_id  format A15  HEADING "SQL_ID" 
COLUMN plan_hash_value        format 999999999999  HEADING "PLAN_HASH"
COLUMN disk_reads        format 999999999999  HEADING "Disk reads"
COLUMN buffer_gets        format 999999999999  HEADING "Buffer gets"
COLUMN executions        format 999999999999  HEADING "Executions"
COLUMN sorts        format 999999999999  HEADING "Sorts"
COLUMN parse_calls        format 999999999999  HEADING "Parse calls"
COLUMN rows_processed        format 999999999999999  HEADING "Rows processes"
SELECT /*+ use_nl (e s) ordered */
 u.name parsing_user,
 e.sid,
 s.module,
 s.sql_id,
 s.plan_hash_value,
 s.disk_reads,
 s.buffer_gets,
 s.executions,
 s.sorts,
 s.parse_calls,
 s.rows_processed,
 rpad(s.sql_text, 400) stext
  FROM v$session e, v$sql s, sys.user$ u
 WHERE s.address = e.sql_address
   AND s.hash_value = e.sql_hash_value
   AND s.child_number = e.sql_child_number
   AND u.type# != 2
   AND s.parsing_user_id = u.user#
   AND u.name NOT IN ('ANONYMOUS','SYS','SYSTEM','SYSMAN','DBSNMP','OUTLN','SCOTT','XDB','RMAN','MGMT_VIEW','ORDPLUGINS',
					'CTXSYS','LBACSYS','WMSYS','WKSYS','TSMSYS','DMSYS','EXFSYS','MDSYS','OLAPSYS','ORDSYS','OWBSYS',
					'BI','HR','OE','PM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','IX','ODM','ODM_MTR',
					'SI_INFORMTN_SCHEMA','WK_TEST','WKPROXY','APEX_PUBLIC_USER','DIP','FLOWS_30000','FLOWS_FILES',
					'MDDATA','ORACLE_OCM','PUBLIC','SPATIAL_CSW_ADMIN_USER','SPATIAL_WFS_ADMIN_USR','XS$NULL')
UNION ALL
SELECT /*+ use_nl (e s) ordered */
 u.name parsing_user,
 e.sid,
 s.module,
 s.sql_id,
 s.plan_hash_value,
 s.disk_reads,
 s.buffer_gets,
 s.executions,
 s.sorts,
 s.parse_calls,
 s.rows_processed,
 rpad(s.sql_text, 400) stext
  FROM v$session e, v$sql s, sys.user$ u
 WHERE s.address = e.prev_sql_addr
   AND s.hash_value = e.prev_hash_value
   AND s.child_number = e.prev_child_number
   AND e.sql_hash_value = 0
   AND u.type# != 2
   AND s.parsing_user_id = u.user#
   AND u.name NOT IN ('ANONYMOUS','SYS','SYSTEM','SYSMAN','DBSNMP','OUTLN','SCOTT','XDB','RMAN','MGMT_VIEW','ORDPLUGINS',
					'CTXSYS','LBACSYS','WMSYS','WKSYS','TSMSYS','DMSYS','EXFSYS','MDSYS','OLAPSYS','ORDSYS','OWBSYS',
					'BI','HR','OE','PM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','IX','ODM','ODM_MTR',
					'SI_INFORMTN_SCHEMA','WK_TEST','WKPROXY','APEX_PUBLIC_USER','DIP','FLOWS_30000','FLOWS_FILES',
					'MDDATA','ORACLE_OCM','PUBLIC','SPATIAL_CSW_ADMIN_USER','SPATIAL_WFS_ADMIN_USR','XS$NULL');
SET LINESIZE 300
					
					
PROMPT
PROMPT  
PROMPT
PROMPT #########
PROMPT ###################
PROMPT ### 2 FILE INFO ###
PROMPT ###################
PROMPT #########
PROMPT



PROMPT ************** REDOFILES *****************
COLUMN group# FORMAT 99 HEADING "Group#"     trunc
COLUMN member FORMAT A70 HEADING "File"     trunc
COLUMN rtype FORMAT A15 HEADING "Log Type"     trunc
COLUMN status FORMAT A16 HEADING "Status"     trunc
COLUMN rsize FORMAT A10 HEADING "Size"     trunc
COLUMN archived FORMAT A9 HEADING "Archived"     trunc
COLUMN sequence# FORMAT 999999999 HEADING "Sequence #"     trunc
COLUMN members FORMAT 999 HEADING "# of Members"     trunc
select t1.group#,
       'Online log' as rtype,
       t1.member,
       t2.status,
       (TO_CHAR(ROUND(t2.bytes / 1024 / 1024, 1)) || 'Mb') rsize,
       t2.archived,
       t2.sequence#,
       t2.members
  from v$logfile t1, v$log t2
 where t1.group# = t2.group#
union
select t1.group#,
       'Standby log',
       t1.member,
       t2.status,
       (TO_CHAR(ROUND(t2.bytes / 1024 / 1024, 1)) || 'Mb') rsize,
       t2.archived,
       t2.sequence#,
       1
  from v$logfile t1, v$standby_log t2
 where t1.group# = t2.group#
 order by 1;

PROMPT
PROMPT ************** CONTROLFILES *****************
COLUMN name 	FORMAT A70 		HEADING "Name"     trunc
select name from v$controlfile
order by name;

PROMPT
PROMPT ************** DATAFILES *****************
COLUMN file# 				FORMAT 99 				HEADING "File"     trunc
COLUMN tsname 				FORMAT A22 				HEADING "TS Name"     trunc
COLUMN fname 				FORMAT A90 				HEADING "Datafile Name"     trunc
COLUMN fsize 				FORMAT A14 				HEADING "Size"     trunc
COLUMN flimit      			FORMAT A14          	HEADING "Limit"	trunc
COLUMN AUTOEXTENSIBLE		FORMAT A11          	HEADING "Autoextend?"	trunc
COLUMN status 				FORMAT A10 				HEADING "Status"     trunc
COLUMN checkpoint_change# 	FORMAT 999,999,999,999 	HEADING "Checkpoint Chng#"     trunc
select 		a.file#, 
			d.name tsname, 
			a.name fname, 
			(TO_CHAR(ROUND(b.bytes/1024/1024,1)) || ' Mb') fsize, 
			round( (CASE WHEN f.autoextensible = 'YES'THEN f.maxbytes ELSE f.bytes END) / 1048576 , 0) || ' Mb' flimit,
			f.AUTOEXTENSIBLE,
			b.status, 
			b.checkpoint_change# 
from v$dbfile a, v$datafile b, v$datafile_header c, v$tablespace d, dba_data_files f
WHERE b.file# = a.file#
AND c.file# = a.file#
AND d.ts# = b.ts#
AND f.file_id = a.file#
order by 2,1;

--SELECT a.file#, a.ts#, a.status, a.checkpoint_change#,
--       a.unrecoverable_change#, a.last_change#, a.BYTES, a.blocks,
--       a.block_size, b.error, b.RECOVER, b.fuzzy, b.resetlogs_change#,
--       b.checkpoint_change#, b.checkpoint_count
--  FROM v$datafile a, v$datafile_header b
-- WHERE a.file# = b.file#;

PROMPT
PROMPT ************** TEMPFILES *****************
COLUMN file# FORMAT 99 HEADING "File#"     trunc
COLUMN ts# FORMAT 99 HEADING "TS#"     trunc
COLUMN name FORMAT A70 HEADING "Tempfile Name"     trunc
COLUMN status FORMAT A7 HEADING "Status"     trunc
COLUMN fsize FORMAT A10 HEADING "Size"     trunc
COLUMN enabled FORMAT A15 HEADING "Enabled?"     trunc
select file#, ts#, name, status, (TO_CHAR(ROUND(bytes/1024/1024,1)) || 'Mb') fsize, enabled from v$tempfile
order by file#;

--PROMPT *** SELECT REDOLOGHIST ***********

--SELECT   thread#, TO_CHAR (first_time, 'DD-MON-YYYY') create_date,
--         TO_CHAR (first_time, 'HH24:MI') TIME, sequence#,
--         first_change# lowest_scn_in_log, next_change# highest_scn_in_log,
--         recid controlfile_record_id, stamp controlfile_record_stamp
--   FROM v$log_history
--   WHERE first_time = SYSDATE
--ORDER BY first_time;


--PROMPT *** SELECT v$datafile_copy ***
--SELECT *
--  FROM v$datafile_copy;

PROMPT
PROMPT ************** TABLESPACES *****************
COLUMN TS#        		FORMAT 99           HEADING "TS#"	trunc
COLUMN NAME       		FORMAT A25          HEADING "Name"	trunc
COLUMN FILES     		FORMAT 99          	HEADING "Files"	trunc
COLUMN CONTYPE      	FORMAT A20          HEADING "Type"	trunc
COLUMN FILESIZE      	FORMAT A16          HEADING "Current Size"	trunc
COLUMN FILELIMIT      	FORMAT A16          HEADING "Max Limit"	trunc
COLUMN FILEAVAIL      	FORMAT A16          HEADING "(Limit - Size)"	trunc
COLUMN FTOTALB      	FORMAT A12          HEADING "Empty Space"	trunc
COLUMN STATUS      		FORMAT A10          HEADING "Status"	trunc
COLUMN SGMTS      		FORMAT A15         	HEADING "Objects"	trunc
SELECT  v.ts#, 
		v.name, 
		f.files, 
		DECODE(b.contents,'TEMPORARY','TEMP',b.contents) CONTYPE,
		TO_CHAR(round(f.fsize,0))  || ' Mb' filesize,
		TO_CHAR(round(f.flimit,0)) || ' Mb' filelimit, 
		TO_CHAR(round(f.flimit,0) - round(f.fsize,0)) || ' Mb' fileavail, 
		TO_CHAR(round ( round (NVL(s.FRBYTES,0) / 1048576, 0) / round(f.fsize,0) , 2 ) * 100) || '%' ftotalb,
		b.STATUS,
		(CASE WHEN b.contents='TEMPORARY' THEN '{temp}' WHEN b.contents='UNDO' THEN '{undo}' ELSE NVL(to_char(z.SEGMENTS),'EMPTY!!!') END) SGMTS
    FROM 	dba_tablespaces b,
			v$tablespace v,
			(SELECT tablespace_name, SUM(BYTES) "FRBYTES"  FROM dba_free_space GROUP BY tablespace_name) s,  
			(SELECT tablespace_name, 
									SUM( CASE WHEN autoextensible = 'YES' THEN 
											maxbytes
										ELSE 
											BYTES
										END
										) / 1048576 "FLIMIT",
									SUM(BYTES) / 1048576 "FSIZE",
									COUNT (file_name) "FILES"
							FROM dba_data_files
							GROUP BY tablespace_name
							UNION
							SELECT tablespace_name, 
									SUM( CASE WHEN autoextensible = 'YES' THEN 
											maxbytes
										ELSE 
											BYTES
										END
										) / 1048576 "FLIMIT",
									SUM(BYTES) / 1048576 "FSIZE",
									COUNT (file_name) "FILES"
							FROM dba_temp_files
							GROUP BY tablespace_name) f,
			(select count(1) SEGMENTS, tablespace_name from dba_segments group by tablespace_name) z
WHERE s.tablespace_name (+) = v.name	
AND f.tablespace_name (+) = v.name	
AND z.tablespace_name (+) = v.name	
AND b.tablespace_name = v.name
ORDER BY v.ts#;


PROMPT
PROMPT ************** TS 10G PROPERTIES *****************
COLUMN TS#        						FORMAT 99           HEADING "TS#"	trunc
COLUMN NAME       						FORMAT A25          HEADING "Name"	trunc
COLUMN BIGFILE       					FORMAT A15          HEADING "Bigfile?"	trunc
COLUMN FLASHBACK_ON       				FORMAT A15          HEADING "Flashback?"	trunc
COLUMN SEGMENT_SPACE_MANAGEMENT       	FORMAT A16          HEADING "Segment Mng Type"	trunc
COLUMN EXTENT_MANAGEMENT       			FORMAT A15          HEADING "Extent Mng Type"	trunc
select v.ts#, v.name, v.bigfile, v.flashback_on, b.SEGMENT_SPACE_MANAGEMENT, b.EXTENT_MANAGEMENT
from v$tablespace v, dba_tablespaces b
where v.name = b.tablespace_name;





PROMPT
PROMPT
PROMPT
PROMPT #########
PROMPT ####################
PROMPT ### 3 USERS AND OBJECTS INFO ###
PROMPT ####################
PROMPT #########
PROMPT  
 
PROMPT
PROMPT ************** USERS WITH OBJECTS *****************
COLUMN USERNAME                     FORMAT A30
COLUMN USER_SIZE                    FORMAT A14
COLUMN STATUS               		FORMAT A18
COLUMN SECURITY_PROFILE             FORMAT A15
COLUMN CREATED                      FORMAT A12
COLUMN LOCK_DATE                    FORMAT A12
COLUMN EXPIRY_DATE                  FORMAT A12
COLUMN DEFAULT_TABLESPACE           FORMAT A20
COLUMN TEMPORARY_TABLESPACE         FORMAT A20
SELECT 		t.USERNAME, 
			objsize.sch_size USER_SIZE, 
			RPAD(ACCOUNT_STATUS,18) STATUS, 
			RPAD(PROFILE,15) SECURITY_PROFILE, 
			CREATED, 
			EXPIRY_DATE, 
			LOCK_DATE, 
			DEFAULT_TABLESPACE, 
			TEMPORARY_TABLESPACE 
	FROM 		DBA_USERS t ,
				(SELECT owner, TO_CHAR (ROUND(SUM (BYTES)/1024/1024,1)) || ' Mb' sch_size FROM dba_segments t1 GROUP BY owner ) objsize
	WHERE objsize.owner=t.username
	ORDER BY 3 DESC, 1 ASC;


PROMPT
PROMPT ************** EMPTY USERS *****************
COLUMN USERNAME                     FORMAT A30
COLUMN USER_SIZE                    FORMAT A14
COLUMN STATUS               		FORMAT A18
COLUMN SECURITY_PROFILE             FORMAT A15
COLUMN CREATED                      FORMAT A12
COLUMN LOCK_DATE                    FORMAT A12
COLUMN EXPIRY_DATE                  FORMAT A12
COLUMN DEFAULT_TABLESPACE           FORMAT A20
COLUMN TEMPORARY_TABLESPACE         FORMAT A20
SELECT USERNAME, objsize.sch_size USER_SIZE, RPAD(ACCOUNT_STATUS,18) STATUS, RPAD(PROFILE,15) SECURITY_PROFILE, CREATED, EXPIRY_DATE, LOCK_DATE, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE 
FROM DBA_USERS t , (SELECT owner, TO_CHAR (ROUND(SUM (BYTES)/1024/1024,1)) || ' Mb' sch_size FROM dba_segments t1 GROUP BY owner ) objsize 
WHERE objsize.owner (+) = t.username  
MINUS
SELECT USERNAME, objsize.sch_size USER_SIZE, RPAD(ACCOUNT_STATUS,18) STATUS, RPAD(PROFILE,15) SECURITY_PROFILE, CREATED, EXPIRY_DATE, LOCK_DATE, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE 
FROM DBA_USERS t , (SELECT owner, TO_CHAR (ROUND(SUM (BYTES)/1024/1024,1)) || ' Mb' sch_size FROM dba_segments t1 GROUP BY owner ) objsize 
WHERE objsize.owner = t.username
ORDER BY 3 DESC, 1 ASC;



PROMPT
PROMPT ************** DBA ROLES *****************
COLUMN granted_role                  	FORMAT A30         HEADING "Role"		trunc
COLUMN grantee			               FORMAT A30         HEADING "User"		trunc
COLUMN admin_option               	FORMAT A10         HEADING "Admin?"		trunc
COLUMN default_role             	FORMAT A10         HEADING "Default?"	trunc
SELECT granted_role, grantee, admin_option, default_role
FROM dba_role_privs
WHERE granted_role IN ('DBA')
UNION
SELECT privilege, grantee, admin_option, 'YES' default_role
FROM dba_sys_privs
WHERE privilege IN ('UNLIMITED TABLESPACE')
ORDER BY 1,2;


PROMPT
PROMPT ************** NCT INFO *****************

PROMPT *******************
PROMPT nct_info 2.6
PROMPT *******************

SET SERVEROUTPUT ON 
EXEC DBMS_OUTPUT.ENABLE(20000000);

PROMPT
PROMPT

DECLARE

CURSOR cur_tables -- Общий курсор выбирающий имя и схему таблицы из dba_tables
IS
	SELECT   table_name, owner
	FROM   dba_tables
	WHERE owner NOT LIKE '%SYS%'
	ORDER BY owner; 


var_table varchar2(45); -- Общая переменная (имя_таблицы)
var_owner varchar2(45); -- Общая переменная (схема_таблицы)
var_version varchar2(18); -- Общая переменная (версия_модуля)
var_emitent varchar2(12); -- Общая переменная (эмитент_модуля)
var_bltype number; -- Общая переменная (Тип ЖО)
var_bltype_res varchar2(3); -- Общая переменная (Тип ЖО)
var_type varchar2(12); -- Общая переменная (тип_модуля)
var_type_str varchar2(12); -- Общая переменная (тип_модуля)

var_lnr_ver varchar2(18); -- Переменная для ЛНР (версия_ЛНР)
var_rep_ver varchar2(18); -- Переменная для d-reports (версия_отчетов)
var_rlnr_ver varchar2(18); -- Переменная для d-reports (версия_отчетов)
var_mcs_ver varchar2(18); -- Переменная для d-reports (версия_отчетов)
var_pcrep_ver varchar2(18); -- Переменная для d-reports (версия_отчетов)
var_coup_ver varchar2(18); -- Переменная для Coupons

var_onl_prod varchar2(18); -- Переменная для ONLINE
var_onl_ver varchar2(18); -- Переменная для ONLINE
var_onl_date date; -- Переменная для ONLINE

var_plh1 varchar2(45); -- placeholder
var_plh2 varchar2(45); -- placeholder

var_tms_ver varchar2(18); -- Переменная для TMS
var_pws_oc_ver varchar2(18); -- Переменная для PWS OC
var_pws_web_ver varchar2(18); -- Переменная для PWS WEB
var_aqua_ver varchar2(18); -- Переменная для AQUA
var_phoenix_ver varchar2(18); -- Переменная для Phoenix
var_iemoc_ver varchar2(18); -- Переменная для IEM-OC
var_online_prod varchar2(18); -- Переменная для ONLINE
var_online_loop number := 1; -- Переменная для ONLINE

BEGIN

DBMS_OUTPUT.PUT_LINE('*');
DBMS_OUTPUT.PUT_LINE('*');
DBMS_OUTPUT.PUT_LINE('**********************************************');
DBMS_OUTPUT.PUT_LINE('***** Users/Schemas with OC and LNR(LFC) *****');
DBMS_OUTPUT.PUT_LINE('**********************************************');

OPEN cur_tables; -- Открываем курсор для ОЦ
LOOP
	FETCH cur_tables INTO var_table,var_owner;
	EXIT WHEN cur_tables%NOTFOUND;

	IF var_table = 'P5CONFIG' THEN
		BEGIN
			
			EXECUTE IMMEDIATE ('select count(1) from SYS.DBA_TAB_COLUMNS t where owner = ''' || var_owner || ''' and table_name = ''P5CONFIG'' and column_name = ''NEW_RECEIVE_BL''') INTO var_bltype;
			
			IF var_bltype > 0 THEN
				EXECUTE IMMEDIATE ('SELECT version,id_emitent,id_filial,nvl(NEW_RECEIVE_BL,0) FROM ' || var_owner || '.P5CONFIG WHERE date_version = (SELECT MAX(date_version) FROM ' || var_owner || '.P5CONFIG) and rownum=1') INTO var_version,var_emitent,var_type,var_bltype;
			ELSE
				EXECUTE IMMEDIATE ('SELECT version,id_emitent,id_filial FROM ' || var_owner || '.P5CONFIG WHERE date_version = (SELECT MAX(date_version) FROM ' || var_owner || '.P5CONFIG) and rownum=1') INTO var_version,var_emitent,var_type;
			END IF;
			
			IF var_bltype = 0 THEN
				var_bltype_res := 'No';
			ELSE
				var_bltype_res := 'Yes';
			END IF;
			
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_emitent := '0000';
			var_type_str := '00';
        		var_version := 'NO_DATA';
		END;
		BEGIN
			EXECUTE IMMEDIATE ('SELECT table_name,owner FROM dba_tables WHERE owner=''' || var_owner || ''' AND table_name=''LNR_CONFIG'' ') INTO 				var_plh1, var_plh2; -- Необходимо на случай отсутствия самой таблицы
			EXECUTE IMMEDIATE ('SELECT SUBSTR(C_3,1,1) || ''.'' || SUBSTR(C_3,2,1) || ''.'' || SUBSTR(C_3,3,1) || ''.'' || SUBSTR(C_3,4,1) 
						FROM ' || var_owner || '.LNR_CONFIG WHERE c_1 = (SELECT MAX(c_1) FROM ' || var_owner || '.LNR_CONFIG) and ROWNUM=1') INTO var_lnr_ver;
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_lnr_ver := 'NO_DATA';
		END;
		BEGIN
			EXECUTE IMMEDIATE ('SELECT table_name,owner FROM dba_tables WHERE owner=''' || var_owner || ''' AND table_name=''CONFIGS'' ') INTO 				var_plh1, var_plh2; -- Необходимо на случай отсутствия самой таблицы
			EXECUTE IMMEDIATE ('SELECT param_val FROM ' || var_owner || '.CONFIGS WHERE param_type=''DB_VERSION'' and ROWNUM=1') INTO var_rep_ver;
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_rep_ver := 'NO_REPORTS';
		END;

		BEGIN	
			EXECUTE IMMEDIATE ('SELECT table_name,owner FROM dba_tables WHERE owner=''' || var_owner || ''' AND table_name=''INSTALL_LOG'' ') INTO 				var_plh1, var_plh2; -- Необходимо на случай отсутствия самой таблицы
			EXECUTE IMMEDIATE ('SELECT TRIM(SUBSTR(DESCRIPTION,INSTR(DESCRIPTION,''.'')-2)) FROM ' || var_owner || '.' || 'INSTALL_LOG t where t.DATEOF=(SELECT MAX(DATEOF) FROM ' || var_owner || '.' || 'INSTALL_LOG WHERE DESCRIPTION LIKE ''%LNR%'' OR DESCRIPTION LIKE ''%ЛНР%'') and ROWNUM=1') INTO var_rlnr_ver; 
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_rlnr_ver := 'NO_REPORTS';
		END;

		BEGIN	
			EXECUTE IMMEDIATE ('SELECT table_name,owner FROM dba_tables WHERE owner=''' || var_owner || ''' AND table_name=''INSTALL_LOG'' ') INTO 				var_plh1, var_plh2; -- Необходимо на случай отсутствия самой таблицы
			EXECUTE IMMEDIATE ('SELECT TRIM(SUBSTR(DESCRIPTION,INSTR(DESCRIPTION,''.'')-2)) FROM ' || var_owner || '.' || 'INSTALL_LOG t where t.DATEOF=(SELECT MAX(DATEOF) FROM ' || var_owner || '.' || 'INSTALL_LOG WHERE DESCRIPTION LIKE ''%Monitor%'' OR DESCRIPTION LIKE ''%Монитор%'') and ROWNUM=1') INTO var_mcs_ver; 
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_mcs_ver := 'NO_REPORTS';
		END;

		BEGIN	
			EXECUTE IMMEDIATE ('SELECT table_name,owner FROM dba_tables WHERE owner=''' || var_owner || ''' AND table_name=''PCPN_SETTINGS'' ') INTO 				var_plh1, var_plh2; -- Необходимо на случай отсутствия самой таблицы
			BEGIN
				EXECUTE IMMEDIATE ('SELECT t.PARAMETER_VALUE FROM ' || var_owner || '.' || 'PCPN_SETTINGS t WHERE t.PARAMETER_NAME=''PCPN_DB_VERSION'' and ROWNUM=1') INTO var_coup_ver; 
			EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    				WHEN NO_DATA_FOUND THEN
				var_coup_ver := 'NO_DATA';
			END;
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_coup_ver := 'NO_REPORTS';
		END;


		DBMS_OUTPUT.PUT_LINE( var_owner || ' - OC ' || var_emitent || ',' || var_type || ' version: ' || var_version || ';  LNR version: ' || var_lnr_ver || ' New Exchange: ' || var_bltype_res);

		IF var_rep_ver != 'NO_REPORTS' THEN
			DBMS_OUTPUT.PUT_LINE('--- D-Reports OC version: ' || var_rep_ver);
		END IF;

		IF var_rlnr_ver != 'NO_REPORTS' THEN
			DBMS_OUTPUT.PUT_LINE('--- D-Reports LNR version: ' || var_rlnr_ver);
		END IF;

		IF var_mcs_ver != 'NO_REPORTS' THEN
			DBMS_OUTPUT.PUT_LINE('--- D-Reports MCS version: ' || var_mcs_ver);
		END IF;

		IF var_coup_ver != 'NO_REPORTS' THEN
			DBMS_OUTPUT.PUT_LINE('--- OC Coupons version: ' || var_coup_ver);
		END IF;

		DBMS_OUTPUT.PUT_LINE('----------------------------------------');


	END IF;

END LOOP;

CLOSE cur_tables; -- Закрываем курсор для ОЦ


DBMS_OUTPUT.PUT_LINE('*');
DBMS_OUTPUT.PUT_LINE('*');
DBMS_OUTPUT.PUT_LINE('**************************************************');
DBMS_OUTPUT.PUT_LINE('******* Users/Schemas with ROC and PC(DPC) *******');
DBMS_OUTPUT.PUT_LINE('**************************************************');

OPEN cur_tables; -- Открываем курсор для ПЦ\РОЦ

LOOP
	FETCH cur_tables INTO var_table,var_owner;
	EXIT WHEN cur_tables%NOTFOUND;

	IF var_table = 'PC_CONFIGURATION' THEN
		BEGIN
			
			EXECUTE IMMEDIATE ('select count(1) from SYS.DBA_TAB_COLUMNS t where owner = ''' || var_owner || ''' and table_name = ''PC_CONFIGURATION'' and column_name = ''SL_TABLE''') INTO var_bltype;
			
			IF var_bltype > 0 THEN
				EXECUTE IMMEDIATE ('SELECT db_version,pc_number,pc_type,nvl(sl_table,0) FROM ' || var_owner || '.' || var_table) INTO var_version,var_emitent,var_type,var_bltype;
			ELSE
				EXECUTE IMMEDIATE ('SELECT db_version,pc_number,pc_type FROM ' || var_owner || '.' || var_table) INTO var_version,var_emitent,var_type;
			END IF;
			
			IF var_bltype = 0 THEN
				var_bltype_res := 'No';
			ELSE
				var_bltype_res := 'Yes';
			END IF;
			
			
			IF var_type = 1 THEN
				var_type_str := 'ROC';
			ELSE
				var_type_str := 'PC';
			END IF;
			
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_emitent := '0000';
			var_type_str := '???';
        		var_version := 'NO_DATA';
		END;
		BEGIN
			EXECUTE IMMEDIATE ('SELECT table_name,owner FROM dba_tables WHERE owner=''' || var_owner || ''' AND table_name=''PC_CONFIGS'' ') INTO var_plh1, var_plh2; -- Необходимо на случай отсутствия самой таблицы
			EXECUTE IMMEDIATE ('SELECT param_val FROM ' || var_owner || '.PC_CONFIGS WHERE param_type=''DB_VERSION''  and ROWNUM=1') INTO var_pcrep_ver;		
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_pcrep_ver := 'NO_REPORTS';
		END;

		DBMS_OUTPUT.PUT_LINE( var_owner || ' - ' || var_type_str || ' ' || var_emitent || ' version: ' || var_version || ' New Exchange: ' || var_bltype_res);

		IF var_pcrep_ver != 'NO_REPORTS' THEN
			DBMS_OUTPUT.PUT_LINE('--- D-Reports PC/ROC version: ' || var_pcrep_ver);
		END IF;

		DBMS_OUTPUT.PUT_LINE('--------------------------------');


	END IF;

END LOOP;
CLOSE cur_tables; -- Закрываем курсор для ПЦ\РОЦ

DBMS_OUTPUT.PUT_LINE('*');
DBMS_OUTPUT.PUT_LINE('*');
DBMS_OUTPUT.PUT_LINE('***************************************************');
DBMS_OUTPUT.PUT_LINE('******* Users/Schemas with AS and P+ Online *******');
DBMS_OUTPUT.PUT_LINE('***************************************************');

OPEN cur_tables; -- Открываем курсор для ONLINE

LOOP
	FETCH cur_tables INTO var_table,var_owner;

	EXIT WHEN cur_tables%NOTFOUND;

	IF var_table = 'INSTALL_ONL' THEN
		DBMS_OUTPUT.PUT_LINE( var_owner || ' - P+ Online components installed:');
		var_online_loop := 1;
		LOOP
		EXIT WHEN var_online_loop = 4;
			BEGIN

					IF var_online_loop = 1 THEN
						var_online_prod := 'FASTPREPARE';
					END IF;
					IF var_online_loop = 2 THEN
						var_online_prod := 'IEM';
					END IF;
					IF var_online_loop = 3 THEN
						var_online_prod := 'AS';
					END IF;

					var_online_loop := var_online_loop + 1;
					EXECUTE IMMEDIATE ('SELECT t1.product, t1.version FROM ' || var_owner || '.INSTALL_ONL t1, (SELECT t3.product as r_prod, MAX(t3.INSTALL_DATE) as r_date FROM ' || var_owner || '.INSTALL_ONL t3  WHERE t3.product=''' || var_online_prod || ''' GROUP BY t3.product) t2 WHERE t1.INSTALL_DATE=t2.r_date AND t1.product=t2.r_prod AND rownum=1') INTO var_onl_prod, var_onl_ver;
					DBMS_OUTPUT.PUT_LINE('--- ' || var_onl_prod || ' version: ' || var_onl_ver);

			EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    				WHEN NO_DATA_FOUND THEN
				var_onl_prod := 'NO_DATA';
        			var_onl_ver := 'NO_DATA';
			END;
		END LOOP;
		DBMS_OUTPUT.PUT_LINE('--------------------------------');

	END IF;

END LOOP;
CLOSE cur_tables; -- Закрываем курсор для ONLINE

DBMS_OUTPUT.PUT_LINE('*');
DBMS_OUTPUT.PUT_LINE('*');
DBMS_OUTPUT.PUT_LINE('*************************************************');
DBMS_OUTPUT.PUT_LINE('*** Users/Schemas with other P+ Plus Software ***');
DBMS_OUTPUT.PUT_LINE('*************************************************');

OPEN cur_tables; -- Открываем курсор для остальных приложений
LOOP
	FETCH cur_tables INTO var_table,var_owner;
	EXIT WHEN cur_tables%NOTFOUND;

	IF var_table = 'TERMINALCONFIG' THEN
		BEGIN	
			EXECUTE IMMEDIATE ('SELECT TRIM(SUBSTR(DESCRIPTION,INSTR(DESCRIPTION,''.'')-2)) FROM ' || var_owner || '.' || 'INSTALL_LOG t where t.DATEOF=(SELECT MAX(DATEOF) FROM ' || var_owner || '.' || 'INSTALL_LOG WHERE DESCRIPTION LIKE ''%TMS%'') and ROWNUM=1') INTO var_tms_ver; 
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_tms_ver := 'NO_DATA';
		END;
		DBMS_OUTPUT.PUT_LINE( var_owner || ' - TMS version: ' || var_tms_ver);
	END IF;

	IF var_table = 'X$PWS_EMT_LIST' THEN
		BEGIN	
			EXECUTE IMMEDIATE ('SELECT TRIM(SUBSTR(DESCRIPTION,INSTR(DESCRIPTION,''.'')-2)) FROM ' || var_owner || '.' || 'INSTALL_LOG t where t.DATEOF=(SELECT MAX(DATEOF) FROM ' || var_owner || '.' || 'INSTALL_LOG WHERE DESCRIPTION LIKE ''%PWS OC%'') and ROWNUM=1') INTO var_pws_oc_ver; 
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_pws_oc_ver := 'NO_DATA';
		END;
		DBMS_OUTPUT.PUT_LINE( var_owner || ' - PWS-OC version: ' || var_pws_oc_ver);
	END IF;

	IF var_table = 'PWS_CARD_HOLDER' THEN
		BEGIN	
			EXECUTE IMMEDIATE ('SELECT TRIM(SUBSTR(DESCRIPTION,INSTR(DESCRIPTION,''.'')-2)) FROM ' || var_owner || '.' || 'INSTALL_LOG t where t.DATEOF=(SELECT MAX(DATEOF) FROM ' || var_owner || '.' || 'INSTALL_LOG WHERE DESCRIPTION LIKE ''%PWS WEB%'') and ROWNUM=1') INTO var_pws_web_ver; 
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_pws_web_ver := 'NO_DATA';
		END;
		DBMS_OUTPUT.PUT_LINE( var_owner || ' - PWS-WEB version: ' || var_pws_web_ver);
	END IF;

	IF var_table = 'AQUA_PHONE' THEN
		BEGIN	
			EXECUTE IMMEDIATE ('SELECT TRIM(SUBSTR(DESCRIPTION,INSTR(DESCRIPTION,''.'')-2)) FROM ' || var_owner || '.' || 'INSTALL_LOG t where t.DATEOF=(SELECT MAX(DATEOF) FROM ' || var_owner || '.' || 'INSTALL_LOG WHERE DESCRIPTION LIKE ''%AQUA%'') and ROWNUM=1') INTO var_aqua_ver; 
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_aqua_ver := 'NO_DATA';
		END;
		DBMS_OUTPUT.PUT_LINE( var_owner || ' - AQUA-Center version: ' || var_aqua_ver);
	END IF;

	IF var_table = 'CS_ACTIONS' THEN
		BEGIN	
			EXECUTE IMMEDIATE ('SELECT TRIM(SUBSTR(DESCRIPTION,INSTR(DESCRIPTION,''.'')-2)) FROM ' || var_owner || '.' || 'INSTALL_LOG t where t.DATEOF=(SELECT MAX(DATEOF) FROM ' || var_owner || '.' || 'INSTALL_LOG WHERE DESCRIPTION LIKE ''%Phoenix%'') and ROWNUM=1') INTO var_phoenix_ver; 
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_phoenix_ver := 'NO_DATA';
		END;
		DBMS_OUTPUT.PUT_LINE( var_owner || ' - IS-Phoenix version: ' || var_phoenix_ver);
	END IF;

	IF var_table = 'IEM_CONFIG' THEN
		BEGIN	
			EXECUTE IMMEDIATE ('SELECT MAX(VERSION) FROM ' || var_owner || '.IEM_CONFIG') INTO var_iemoc_ver; 
		EXCEPTION -- Необходимо на случай отсутствия данных в таблице
    			WHEN NO_DATA_FOUND THEN
			var_iemoc_ver := 'NO_DATA';
		END;
		DBMS_OUTPUT.PUT_LINE( var_owner || ' - IEM-OC version: ' || var_iemoc_ver);
	END IF;

END LOOP;

CLOSE cur_tables; -- Закрываем курсор для остальных приложений

END;
/


PROMPT 
PROMPT ************** TOP 25 BIG OBJECTS *****************
COLUMN 1      	FORMAT A30          HEADING "Name"
COLUMN 2      	FORMAT A13          HEADING "User"
COLUMN 3       	FORMAT A20          HEADING "Obj Type"
COLUMN 4       	FORMAT 999,999,999  HEADING "Size in MBs"
select * from
(select 'Table' "Object type", table_name "Name", owner "Owner", ROUND(blocks * (SELECT VALUE FROM v$parameter WHERE NAME = 'db_block_size')/1024/1024,0) "Size in MBs" from all_tables
UNION
select 'Index' "Object type", index_name "Name", owner "Owner", ROUND(leaf_blocks * (SELECT VALUE FROM v$parameter WHERE NAME = 'db_block_size')/1024/1024,0) "Size in MBs"  from all_indexes 
order by 4 desc nulls last) top
where rownum <=25;




PROMPT
PROMPT ************** JO EXCHANGE TABLES *****************
SELECT owner, table_name, tablespace_name
  FROM dba_tables
 WHERE table_name IN ('TR3',
					'OC_BL1',
					'OC_BL2',
					'PC_EX_JOURNAL',
					'PC_EX_JOURNAL_SL1',
					'PC_EX_JOURNAL_SL2')
ORDER BY 1,2,3;




PROMPT
PROMPT ************** JO EXCHANGE INDEXES *****************
SELECT owner, table_name, index_name, status, tablespace_name
  FROM dba_indexes
 WHERE table_name IN ('TR3',
					'OC_BL1',
					'OC_BL2',
					'PC_EX_JOURNAL',
					'PC_EX_JOURNAL_SL1',
					'PC_EX_JOURNAL_SL2')
ORDER BY 1,2,3;




PROMPT
PROMPT ************** OBJECT ERRORS *****************

COLUMN OWNER      FORMAT A13          HEADING OWNER
COLUMN NAME       FORMAT A30          HEADING OBJECT
COLUMN TYPE       FORMAT A20          HEADING OBJTYPE
COLUMN LINE       FORMAT 999,999      HEADING LINE
COLUMN TEXT       FORMAT A80          HEADING ERROR
select owner,name,type,line,text from all_errors;



PROMPT
PROMPT ************** LOCKED OBJECTS *****************
COLUMN Owner      FORMAT A20
COLUMN Object       FORMAT A40 
COLUMN Type       FORMAT A15   
COLUMN Session       FORMAT A20  
COLUMN Machine       FORMAT A40      
COLUMN Status       FORMAT A30       
SELECT 		trim(owner) "Owner",
			trim(object_name) "Object", 
			trim(object_type) "Type", 
			trim(username) "Session", 
			trim(s.osuser) "Machine",
			DECODE(l.block,
			0, 'Not Blocking',
			1, 'Blocking',
			2, 'Global') "Status" FROM gv$locked_object v, dba_objects d,
gv$lock l, gv$session s
WHERE v.object_id = d.object_id
AND (v.object_id = l.id1)
AND v.session_id = s.sid
ORDER BY 1, 2;
--  DECODE(v.locked_mode,
--    0, 'None',
--    1, 'Null',
--    2, 'Row-S (SS)',
--    3, 'Row-X (SX)',
--    4, 'Share',
--    5, 'S/Row-X (SSX)',
--    6, 'Exclusive', TO_CHAR(lmode)
--  ) MODE_HELD

PROMPT
PROMPT ************** UNUSABLE INDEXES *****************
  SELECT   OWNER,
           TABLE_NAME,
		   INDEX_NAME,
           STATUS
    FROM   DBA_INDEXES
   WHERE   STATUS IN ('UNUSABLE')
ORDER BY   owner, table_name DESC;


PROMPT
PROMPT ************** INVALID OBJECTS *****************
  SELECT   OWNER,
           OBJECT_NAME,
           OBJECT_TYPE,
           CREATED,
           TEMPORARY,
           STATUS
    FROM   ALL_OBJECTS
   WHERE   OBJECT_TYPE NOT IN ('JAVA CLASS')
   AND STATUS NOT IN ('VALID')
ORDER BY   STATUS, owner DESC;

PROMPT
PROMPT ************** COMPRESSED TABLES *****************
SELECT owner, table_name, tablespace_name 
  FROM dba_tables
 WHERE compression = 'ENABLED'
 AND OWNER NOT IN ('ANONYMOUS','SYS','SYSTEM','SYSMAN','DBSNMP','OUTLN','SCOTT','XDB','RMAN','MGMT_VIEW','ORDPLUGINS',
					'CTXSYS','LBACSYS','WMSYS','WKSYS','TSMSYS','DMSYS','EXFSYS','MDSYS','OLAPSYS','ORDSYS','OWBSYS',
					'BI','HR','OE','PM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','IX','ODM','ODM_MTR',
					'SI_INFORMTN_SCHEMA','WK_TEST','WKPROXY','APEX_PUBLIC_USER','DIP','FLOWS_30000','FLOWS_FILES',
					'MDDATA','ORACLE_OCM','PUBLIC','SPATIAL_CSW_ADMIN_USER','SPATIAL_WFS_ADMIN_USR','XS$NULL')
 ORDER BY owner, table_name;




PROMPT
PROMPT
PROMPT
PROMPT #########
PROMPT ####################
PROMPT ### 4 RECOVERY INFO ###
PROMPT ####################
PROMPT #########
PROMPT  



PROMPT ************** INIT PARAMETERS *****************
show parameters;


PROMPT
PROMPT ************** FILES FOR RECOVER *************
SELECT *
  FROM v$recover_file;

PROMPT
PROMPT ************** RECOVERY FILE STATUS *************
SELECT *
  FROM v$recovery_file_status;

PROMPT
PROMPT ************** RECOVER LOG *************
SELECT *
  FROM v$recovery_log;

PROMPT
PROMPT ************** RECOVERY STATUS *************
SELECT *
  FROM v$recovery_status;

PROMPT
PROMPT ************** BACKUP CORRUPTION *************
SELECT *
  FROM v$backup_corruption;
  
  
PROMPT
PROMPT ************** DB BLOCK CORRUPTION *************
SELECT *
  FROM V$DATABASE_BLOCK_CORRUPTION; 
  




  
PROMPT
PROMPT
PROMPT
PROMPT #########
PROMPT ####################
PROMPT ### 5 MEMORY INFO AND ADVICES ###
PROMPT ####################
PROMPT #########
PROMPT  



PROMPT ************** MEMORY PARAMETERS **************
COLUMN NAME        	FORMAT A30              HEADING "Parameter" 	TRUNC
COLUMN PARVAL       FORMAT A30              HEADING "Value" 		TRUNC
COLUMN DESCRIPTION 	FORMAT A80              HEADING "Description" 	TRUNC
SELECT NAME, RPAD(TO_CHAR(VALUE),30) "PARVAL", description
  FROM v$parameter
 WHERE NAME IN
          ('db_cache_size',
           'db_block_buffers',
		   'shared_pool_size',
           'large_pool_size',
		   'java_pool_size',
           'log_buffer',
		   'memory_target',
		   'memory_max_target',
		   'hash_area_size',
           'sort_area_size',
           'pga_aggregate_target',
		   'sga_target',
		   'sga_max_size'
          )
ORDER BY 1 ASC;


PROMPT ************** CURRENT SGA TOTAL SIZE *************
SET HEADING OFF
SELECT 'Total size of SGA - ' || round(SUM (BYTES) / (1024*1024),1) || ' MB' FROM v$sgastat;
SET HEADING ON
		  

PROMPT ************** BUFFER CACHE ADVICE **************
PROMPT !!!Optimal size is where the value of ESTD_PHYSICAL_READS starts decreasing much slowly or stops decreasing at all
PROMPT BUFC_SIZE_IN_MB shows the size of BUFFER CACHE in MB.
PROMPT SIZE_FACTOR shows the ratio of BUFC_SIZE_IN_MB to the current size of BUFFER CACHE
PROMPT ESTD_PHYSICAL_READS - the number of disk physical reads.

COLUMN Size_for_estimate      FORMAT 999,999,999,999  HEADING BUFC_SIZE_IN_MB

SELECT Size_for_estimate, size_factor, Buffers_for_estimate, estd_physical_read_factor, estd_physical_reads
  FROM v$db_cache_advice
 WHERE NAME = 'DEFAULT'
   AND block_size = (SELECT VALUE
                       FROM v$parameter
                      WHERE NAME = 'db_block_size')
   AND advice_status = 'ON';
   
PROMPT
PROMPT ************** SHARED POOL ADVICE *************
PROMPT !!!Optimal size is where ESTD_LC_TIME_SAVED AND OBJECT_HITS = MAX!!!
PROMPT SHARED_POOL_SIZE_IN_MB shows the size of SHARED POOL in MB.
PROMPT SHARED_POOL_SIZE_FACTOR shows the ratio of SHARED_POOL_SIZE to the current size of SHARED POOL

COLUMN SHARED_POOL_SIZE_FOR_ESTIMATE                         HEADING SHARED_POOL_SIZE_IN_MB

SELECT *
  FROM V_$SHARED_POOL_ADVICE;

PROMPT
PROMPT ************** PGA TARGET ADVICE *************
PROMPT !!!Optimal size is where ESTD_OVERALLOC_COUNT = 0 and ESTD_PGA_CACHE_HIT_PERCENTAGE = 100%!!!
PROMPT !!!Use for PGA_AGGREGATE_TARGET.
PROMPT PGA_SIZE_IN_B shows the size of PGA.
PROMPT PGA_TARGET_FACTOR shows the ratio of PGA_SIZE_IN_B to the current size of PGA

COLUMN PGA_TARGET_FOR_ESTIMATE       FORMAT 999,999,999,999  HEADING PGA_SIZE_IN_B
COLUMN BYTES_PROCESSED               FORMAT 999,999,999,999  HEADING BYTES_PROCESSED

SELECT *
  FROM V$PGA_TARGET_ADVICE;

PROMPT
PROMPT ************** PGA CHANGING *************
PROMPT Increase pga_aggregate_target if "workarea executions – multipass" > 1%
PROMPT Decrease pga_aggregate_target if "workarea executions – optimal" = 100%

SELECT NAME PROFILE, cnt,
       DECODE (total, 0, 0, ROUND (cnt * 100 / total)) percentage
  FROM (SELECT NAME, VALUE cnt, (SUM (VALUE) OVER ()) total
          FROM v$sysstat
         WHERE NAME LIKE 'workarea exec%');

PROMPT
PROMPT ************** PGA STATS *************
PROMPT !!!Shows how the PGA area is used!!!
PROMPT Aggregate PGA target parameter - PGA_AGGREGATE_TARGET
PROMPT Global memory bound - max workarea size. Increase PGA if it is < 1M
PROMPT Total PGA allocated - size of max filling

COLUMN BYTES         FORMAT 999,999,999,999  HEADING BYTES
COLUMN NAME          FORMAT A40              HEADING NAME

SELECT NAME, VALUE BYTES
  FROM v$pgastat;

  
  
PROMPT
PROMPT ************** SGA BUFFERS *************
COL class form A25
SELECT   DECODE (GREATEST (CLASS, 10),
                 10, DECODE (CLASS,
                             1, 'Data',
                             2, 'Sort',
                             4, 'Header',
                             TO_CHAR (CLASS)
                            ),
                 'Rollback'
                ) "Class",
         SUM (DECODE (BITAND (flag, 1), 1, 0, 1)) "Not Dirty",
         SUM (DECODE (BITAND (flag, 1), 1, 1, 0)) "Dirty",
         SUM (dirty_queue) "On Dirty", COUNT (*) "Total"
    FROM x$bh
GROUP BY DECODE (GREATEST (CLASS, 10),
                 10, DECODE (CLASS,
                             1, 'Data',
                             2, 'Sort',
                             4, 'Header',
                             TO_CHAR (CLASS)
                            ),
                 'Rollback'
                )
/


PROMPT
PROMPT ************** RESOURCE USAGE *************
PROMPT Here sort_segment_locks shows the APPROXIMATE number of synchronous sorts
PROMPT in the sort_segment_locks parameter.

COLUMN CURRENT_UTILIZATION    FORMAT 999,999,999  HEADING CURR_BYTES
COLUMN MAX_UTILIZATION        FORMAT 999,999,999  HEADING MAX_BYTES
COLUMN RESOURCE_NAME          FORMAT A25          HEADING RESOURCE_NAME
SELECT RESOURCE_NAME, CURRENT_UTILIZATION, MAX_UTILIZATION
  FROM V$RESOURCE_LIMIT;

  
PROMPT
PROMPT ************** DISK SORTS *************
PROMPT !!!This gives the MAX number of synchronous sorts (PEAK_CONCURRENT) and AVERAGE_SIZE
PROMPT !!!Sort_area_size must be not less than the AVERAGE_SIZE
PROMPT !!!PEAK_CONCURRENT is good for counting optimal Sort_area_size:
PROMPT !!!When using WORKAREA_SIZE_POLICY = manual (Oracle 8i) and NOT using PGA_AGGREGATE_TARGET,
PROMPT !!!PEAK_CONCURRENT * (Sort_area_size + Sort_area_retained_size) = summary resourse usage.
PROMPT !!!When using PGA_AGGREGATE_TARGET (NOT WORKAREA_SIZE_POLICY = manual)
PROMPT !!!look at the "NEW PGA TARGET ADVICE" and "NEW PGA STATISTICS".

column average_size format a12

select /*+ ordered */
  s.disk_sorts,
  decode(s.disk_sorts, 0, 'n/a',
    lpad(
      ceil((nvl(w1.kwrites, 0) + nvl(w2.kwrites, 0)) / s.disk_sorts) || 'K',
      12
    )
  )  average_size,
  least(s.disk_sorts, p.peak)  peak_concurrent
from
  (
    select
      value  disk_sorts
    from
      sys.v$sysstat
    where
      name = 'sorts (disk)'
  )  s,
  (
    select /*+ ordered */
      sum(i.kcfiopbw * e.febsz) / 1024  kwrites
    from
      (
	select distinct
	  tempts#
	from
	  sys.user$
	where
	  type# = 1
      )  u,
      sys.file$  f,
      sys.x$kcfio  i,
      sys.x$kccfe  e
    where
      i.inst_id = userenv('Instance') and
      e.inst_id = userenv('Instance') and
      f.ts# = u.tempts# and
      i.kcfiofno = f.file# and
      e.fenum = i.kcfiofno
  )  w1,
  (
    select /*+ ordered use_nl(h) */
      sum(i.kcftiopbw * e.tfbsz) / 1024  kwrites
    from
      (
	select distinct
	  tempts#
	from
	  sys.user$
	where
	  type# = 1
      )  u,
      sys.x$ktfthc  h,
      sys.x$kcftio  i,
      sys.x$kcctf  e
    where
      h.inst_id = userenv('Instance') and
      i.inst_id = userenv('Instance') and
      e.inst_id = userenv('Instance') and
      h.ktfthctsn = u.tempts# and
      i.kcftiofno = h.ktfthctfno and
      e.tfnum = i.kcftiofno
  )  w2,
  (
    select /*+ ordered */
      sum(l.max_utilization)  peak
    from
      (
	select /*+ ordered */ distinct
	  t.contents$
	from
	  (
	    select distinct
	      tempts#
	    from
	      sys.user$
	    where
	      type# = 1
	  )  u,
	  sys.ts$  t
	where
	  t.ts# = u.tempts#
      )  y,
      sys.v_$resource_limit  l
    where
      (y.contents$ = 0 and l.resource_name = 'temporary_table_locks') or
      (y.contents$ = 1 and l.resource_name = 'sort_segment_locks')
  )  p
/


PROMPT
PROMPT ************** INSTANCE RATIOS *************
PROMPT Parse Ratio usually falls between 1.15 and 1.45. If it is higher, then
PROMPT it is usually a sign of poorly written Pro* programs or unoptimized
PROMPT SQL*Forms applications.
PROMPT
PROMPT Recursive Call Ratio will usually be between:
PROMPT
PROMPT   7.0 - 10.0 for tuned production systems
PROMPT  10.0 - 14.5 for tuned development systems
PROMPT
PROMPT Buffer Hit Ratio is dependent upon RDBMS size, SGA size and
PROMPT the types of applications being processed. This shows the %-age
PROMPT of logical reads from the SGA as opposed to total reads - the
PROMPT figure should be as high as possible. The hit ratio can be raised
PROMPT by increasing DB_BUFFERS, which increases SGA size. By turning on
PROMPT the "Virtual Buffer Manager" (db_block_lru_statistics = TRUE and
PROMPT db_block_lru_extended_statistics = TRUE in the init.ora parameters),
PROMPT you can determine how many extra hits you would get from memory as
PROMPT opposed to physical I/O from disk.
PROMPT
PROMPT **NOTE: Turning these on will impact performance. One shift of
PROMPT statistics gathering should be enough to get the required information.
COLUMN pcc   HEADING 'PARSE|RATIO'            FORMAT 999.99
COLUMN rcc   HEADING 'RECURSIVE|CURSOR'       FORMAT 999.99
COLUMN hr    HEADING 'BUFFER|RATIO'           FORMAT 999,999,999,999.999
COLUMN rwr   HEADING 'READ/WRITE|RATIO'       FORMAT 999,999.9
COLUMN bpfts HEADING 'Blks per|FULL TS'       FORMAT 999,999,999

SELECT   SUM (DECODE (a.NAME, 'parse count', VALUE, 0))
       / SUM (DECODE (a.NAME,
                      'opened cursors cumulative', VALUE,
                      .00000000001
                     )
             ) pcc,
         SUM (DECODE (a.NAME, 'recursive calls', VALUE, 0))
       / SUM (DECODE (a.NAME,
                      'opened cursors cumulative', VALUE,
                      .00000000001
                     )
             ) rcc,
       (  1
        -   (    SUM (DECODE (a.NAME, 'physical reads', VALUE, 0))
               / SUM (DECODE (a.NAME, 'db block gets', VALUE, .00000000001))
             + SUM (DECODE (a.NAME, 'consistent gets', VALUE, 0))
            )
          * (-1)
       ) hr,
         SUM (DECODE (a.NAME, 'physical reads', VALUE, 0))
       / SUM (DECODE (a.NAME, 'physical writes', VALUE, .00000000001)) rwr,
         (  SUM (DECODE (a.NAME, 'table scan blocks gotten', VALUE, 0))
          - SUM (DECODE (a.NAME, 'table scans (short tables)', VALUE, 0)) * 4
         )
       / SUM (DECODE (a.NAME,
                      'table scans (long tables)', VALUE,
                      .00000000001
                     )
             ) bpfts
  FROM v$sysstat a
/




PROMPT
PROMPT ************** BUFFER CACHE GETS *************
SELECT name,value
  FROM v$sysstat
 WHERE NAME IN ('consistent gets', 'db block gets', 'physical reads');

PROMPT HIT_RATIO = 1-(PHYSICAL READS / (DB BLOCK_GETS + CONSISTENT_GETS)
PROMPT If HIT_RATIO < 0.7 - DB_BLOCK_BUFFERS Increase

SELECT    'HIT RATIO: '
       || ROUND (((  1
                   -   SUM (DECODE (a.NAME, 'physical reads', VALUE, 00))
                     / (  SUM (DECODE (a.NAME, 'db block gets', VALUE, 00))
                        + SUM (DECODE (a.NAME, 'consistent gets', VALUE, 00))
                       )
                  )
                 ),
                 5
                )
       || '%'
  FROM v$sysstat a
 WHERE NAME IN ('consistent gets', 'db block gets', 'physical reads');


 
PROMPT
PROMPT ************** SHARED POOL SIZES *************
SELECT TO_NUMBER (VALUE) shared_pool_size, sum_obj_size, sum_sql_size,
       sum_user_size,
       (sum_obj_size + sum_sql_size + sum_user_size) * 1.3 min_shared_pool
  FROM (SELECT SUM (sharable_mem) sum_obj_size
          FROM v$db_object_cache),
       (SELECT SUM (sharable_mem) sum_sql_size
          FROM v$sqlarea),
       (SELECT SUM (250 * users_opening) sum_user_size
          FROM v$sqlarea),
       v$parameter
 WHERE NAME = 'shared_pool_size';

 
 
PROMPT
PROMPT ************** SHARED POOL LIBRARY CACHE HIT RATIO *************
PROMPT If "Cache Hit" < 90% - Shared Pool needs to be INCREASED.
SET HEADING OFF
SELECT 'Pins - ' || SUM (pins) || ', Reloads - ' || SUM (reloads) || ', Cache Hit - ' || round( ( 1 -  SUM (reloads) / (SUM (pins) + 0.00000000001) ) * 100 , 2 ) || '%'
  FROM v$librarycache;
SET HEADING ON



PROMPT
PROMPT ************** SHARED POOL DICTIONARY CACHE HIT RATIO  *************
PROMPT If "Cache Hit" < 90% - Shared Pool needs to be INCREASED.
SET HEADING OFF
SELECT 'Gets - ' || SUM (gets) || ', Getmisses - ' || SUM (getmisses) || ', Cache Hit - ' || round( ( 1 -  SUM (getmisses) / (SUM (gets) + 0.00000000001) ) * 100 , 2 ) || '%'
  FROM v$rowcache;
SET HEADING ON
  
  
  
PROMPT
PROMPT ************** WAIT STATS *************
SELECT   CLASS, COUNT, TIME,
         DECODE (CLASS,
                 'undo header', DECODE (COUNT,
                                        0, '',
                                        'Add rollback segments?'
                                       ),
                 'undo block', DECODE (COUNT,
                                       0, '',
                                       'Add rollback segments?'
                                      ),
                 'system undo header', DECODE (COUNT,
                                               0, '',
                                               'Add rollback segments?'
                                              ),
                 'system undo block', DECODE (COUNT,
                                              0, '',
                                              'Add rollback segments?'
                                             ),
                 'free list', DECODE (COUNT, 0, '', 'Make more freelists?')
                ) recommendation
    FROM v$waitstat
ORDER BY CLASS;


PROMPT
PROMPT ************** TOTAL WAITS *************
select event, total_waits,
round(time_waited/100) "TIME(s)",
average_wait*10 "AVG(ms)",
TO_CHAR(SYSDATE, 'DD-MON-YYYY HH:MI:SS') time
from v$system_event order by time_waited; 


PROMPT
PROMPT ************** SESSION WAITS *************
COLUMN nl NEWLINE
SELECT '/* ' nl,
       'USER ' || v$session.username || '(' || v$session_wait.SID || ')' nl,
       v$sqlarea.sql_text nl, ' */' nl,
       'SELECT segment_name, segment_type ' nl, 'FROM dba_extents ' nl,
       'WHERE file_id = ' || v$session_wait.p1 nl,
          'AND '
       || v$session_wait.p2
       || ' BETWEEN block_id AND (block_id + blocks - 1) ;'
  FROM v$session, v$sqlarea, v$session_wait
 WHERE (   v$session_wait.event LIKE '%buffer%'
        OR v$session_wait.event LIKE '%write%'
        OR v$session_wait.event LIKE '%read%'
       )
   AND v$session_wait.SID = v$session.SID
   AND v$session.sql_address = v$sqlarea.address
   AND v$session.sql_hash_value = v$sqlarea.hash_value
/


PROMPT
PROMPT ************** SYSTEM EVENTS *************
COLUMN event            FORMAT A45               HEADING 'EVENT'
COLUMN total_waits      FORMAT 9,999,999,999     HEADING 'TOTAL|WAITS'
COLUMN time_waited      FORMAT 9,999,999,999     HEADING 'TIME WAIT|In Hndrds'
COLUMN total_timeouts   FORMAT 999,999,999       HEADING 'TIMEOUT'
COLUMN average_wait     FORMAT 999,999.999       HEADING 'AVERAGE|TIME'
SELECT *
  FROM v$system_event;



PROMPT
PROMPT
PROMPT
PROMPT #########
PROMPT ####################
PROMPT ### 6 UNDO AND RBS INFO ###
PROMPT ####################
PROMPT #########
PROMPT

PROMPT  
PROMPT ************** UNDO STATUSES *************
PROMPT "EXPIRED" - can be used by the DB
PROMPT "UNEXPIRED" - can't be used by the DB yet
PROMPT "ACTIVE" - it's required to wait for transactions to be completed or to look where they are coming from
SELECT   status, tablespace_name, SUM (BYTES) / 1024 / 1024, COUNT (*)
    FROM dba_undo_extents
GROUP BY status, tablespace_name;


PROMPT
PROMPT ************** UNDO SEGMENTS LOGICAL *************
SELECT segment_name, owner, r.tablespace_name, r.status, t.extent_management
  FROM dba_rollback_segs r, dba_tablespaces t
 WHERE r.tablespace_name = t.tablespace_name;

 
PROMPT ************** UNDO SEGMENTS PHYSICAL *************
SELECT NAME, file#, block#, status$, user#,
       undosqn, xactsqn, scnbas, scnwrp,
       DECODE (inst#, 0, NULL, inst#), ts#, spare1
  FROM undo$;


PROMPT
PROMPT ************** UNDO SEGMENTS GETS AND WAITS *************
PROMPT If the ratio of waits to gets is more than 1% or 2%, consider
PROMPT creating more rollback segments.
PROMPT GETS  = # of gets on the rollback segment header
PROMPT WAITS = # of waits for the rollback segment header
COLUMN name     FORMAT A30
COLUMN gets     FORMAT 9,999,999
COLUMN waits    FORMAT 9,999,999
SELECT NAME, waits, gets
  FROM v$rollstat, v$rollname
 WHERE v$rollstat.usn = v$rollname.usn;
 SET HEADING OFF
SELECT    'The average of waits/gets is '
       || ROUND ((SUM (waits) / SUM (gets)) * 100, 2)
       || '%.'
  FROM v$rollstat;
SET HEADING ON

PROMPT If the percentage for an area is more than 1% or 2%, consider creating
PROMPT more rollback segments. Note: This value is usually very small and has
PROMPT been rounded to 4 places.
COLUMN xn1 FORMAT 999,999,999
COLUMN xv1 NEW_VALUE xxv1 NOPRINT
SELECT CLASS, COUNT
  FROM v$waitstat
 WHERE CLASS IN
          ('system undo header',
           'system undo block',
           'undo header',
           'undo block'
          );
SET HEADING OFF
SELECT 'Total requests = ' || SUM (COUNT) xn1, SUM (COUNT) xv1
  FROM v$waitstat
/
SELECT    'Contention for system undo header = '
       || (ROUND (COUNT / (&xxv1 + 0.00000000001), 4)) * 100
       || '%'
  FROM v$waitstat
 WHERE CLASS = 'system undo header'
/
SELECT    'Contention for system undo block = '
       || (ROUND (COUNT / (&xxv1 + 0.00000000001), 4)) * 100
       || '%'
  FROM v$waitstat
 WHERE CLASS = 'system undo block'
/
SELECT    'Contention for undo header = '
       || (ROUND (COUNT / (&xxv1 + 0.00000000001), 4)) * 100
       || '%'
  FROM v$waitstat
 WHERE CLASS = 'undo header'
/
SELECT    'Contention for undo block = '
       || (ROUND (COUNT / (&xxv1 + 0.00000000001), 4)) * 100
       || '%'
  FROM v$waitstat
 WHERE CLASS = 'undo block'
/
SET HEADING ON
PROMPT


PROMPT
PROMPT ************** ADDITIONAL UNDO STATS *************
COLUMN extents      FORMAT 999              HEADING 'EXTENTS'
COLUMN rssize       FORMAT 999,999,999      HEADING 'SIZE IN|BYTES'
COLUMN optsize      FORMAT 999,999,999      HEADING 'OPTIMAL|SIZE'
COLUMN hwmsize      FORMAT 999,999,999,999  HEADING 'HIGH WATER|MARK'
COLUMN shrinks      FORMAT 9,999            HEADING 'NUM OF|SHRINKS'
COLUMN wraps        FORMAT 9,999            HEADING 'NUM OF|WRAPS'
COLUMN extends      FORMAT 999,999          HEADING 'NUM OF|EXTENDS'
COLUMN aveactive    FORMAT 999,999,999      HEADING 'AVERAGE SIZE|ACTIVE EXTENTS'
COLUMN rownum       NOPRINT
SELECT   rssize, optsize, hwmsize, shrinks, wraps, EXTENDS, aveactive
    FROM v$rollstat
ORDER BY ROWNUM
/
BREAK ON REPORT
COMPUTE SUM OF gets waits writes ON REPORT
SELECT   ROWNUM, extents, rssize, xacts, gets, waits, writes
    FROM v$rollstat
ORDER BY ROWNUM
/

 
 
PROMPT
PROMPT
PROMPT
PROMPT #########
PROMPT ####################
PROMPT ### 7 REDO AND WAITS INFO ###
PROMPT ####################
PROMPT #########
PROMPT

PROMPT ************** REDO DYNAMICS DURING LAST DAYS *****************
DEFINE REDO_HIST_DAYS = 2;
PROMPT Period defined for this select - &&REDO_HIST_DAYS days.

COLUMN SWITCH_PERIOD FORMAT A14 HEADING "Switch Period"     trunc
COLUMN LOGS_SWITCHES FORMAT 999,999.99 HEADING "# of Switches"     trunc
COLUMN MB_PER_MIN FORMAT 999,999.99 HEADING "MBs Written"     trunc
SELECT   'Per 1 Min:' AS SWICH_PERIOD,
         ROUND ( (SELECT   COUNT (1)
                    FROM   V_$LOG_HISTORY
                   WHERE   FIRST_TIME >= (SYSDATE - &&REDO_HIST_DAYS))
                / (&&REDO_HIST_DAYS * 24 * 60), 2)
            AS LOGS_SWITCHES,
         ROUND (  (SELECT   COUNT (1)
                     FROM   V_$LOG_HISTORY
                    WHERE   FIRST_TIME >= (SYSDATE - &&REDO_HIST_DAYS))
                / (&&REDO_HIST_DAYS * 24 * 60)
                * ( (SELECT   BYTES
                       FROM   V_$LOG
                      WHERE   GROUP# = 1)
                   / (1024 * 1024)), 2)
            AS MB_PER_MIN
  FROM   DUAL
UNION ALL
SELECT   'Per 1 Hour:',
         ROUND ( (SELECT   COUNT (1)
                    FROM   V_$LOG_HISTORY
                   WHERE   FIRST_TIME >= (SYSDATE - &&REDO_HIST_DAYS))
                / (&&REDO_HIST_DAYS * 24), 2),
         ROUND (  (SELECT   COUNT (1)
                     FROM   V_$LOG_HISTORY
                    WHERE   FIRST_TIME >= (SYSDATE - &&REDO_HIST_DAYS))
                / (&&REDO_HIST_DAYS * 24)
                * ( (SELECT   BYTES
                       FROM   V_$LOG
                      WHERE   GROUP# = 1)
                   / (1024 * 1024)), 2)
  FROM   DUAL; 
 
PROMPT
PROMPT ************** REDO BUFFER MISSES *****************
COLUMN NAME     FORMAT A30
COLUMN VALUE     FORMAT 9,999,999
 SELECT vst.VALUE
  FROM V$SYSSTAT vst
 WHERE NAME = 'redo buffer allocation retries';
 
PROMPT
PROMPT ************** REDOLOG CONFLICTS *****************
SELECT NAME, gets, misses, sleeps, immediate_gets, immediate_misses
  FROM v$latch
 WHERE NAME IN ('REDO ALLOCATION', 'REDO COPY');

PROMPT
PROMPT ************** REDO CONTENTION *****************
PROMPT This value should be near 0. If this value increments consistently,
PROMPT processes have had to wait for space in the redo buffer. If this
PROMPT condition exists over time, increase the size of LOG_BUFFER in the
PROMPT init.ora file in increments of 5% until the value nears 0.
PROMPT The following shows how often user processes had to wait for space in
PROMPT the redo log buffer:
SELECT NAME || ' = ' || VALUE || 65000
  FROM v$sysstat
 WHERE NAME = 'redo log space requests';



PROMPT
PROMPT ************** LATCH CONTENTION *****************
PROMPT GETS = # of successful willing-to-wait requests for a latch.
PROMPT MISSES = # of times an initial willing-to-wait request was unsuccessful.
PROMPT IMMEDIATE_GETS = # of successful immediate requests for each latch.
PROMPT IMMEDIATE_MISSES = # of unsuccessful immediate requests for each latch.
PROMPT SLEEPS = # of times a process waited and requests a latch after an
PROMPT initial willing-to-wait request.
PROMPT
PROMPT If the latch requested with a willing-to-wait request is not
PROMPT available, the requesting process waits a short time and requests again.
PROMPT If the latch requested with an immediate request is not available,
PROMPT the requesting process does not wait, but continues processing.
PROMPT
PROMPT If either ratio exceeds 1%, performance will be affected.
PROMPT
PROMPT Decreasing the size of LOG_SMALL_ENTRY_MAX_SIZE reduces the number of
PROMPT processes copying information on the redo allocation latch.
PROMPT
PROMPT Increasing the size of LOG_SIMULTANEOUS_COPIES will reduce contention
PROMPT for redo copy latches.
COLUMN name                                  FORMAT A15
COLUMN gets                                  FORMAT 999,999,999
COLUMN misses                                FORMAT 9,999,999
COLUMN immediate_gets   HEADING 'IMMED GETS' FORMAT 999,999,999
COLUMN immediate_misses HEADING 'IMMED MISS' FORMAT 9,999,999
COLUMN sleeps                                FORMAT 999,999
SELECT NAME, gets, misses, immediate_gets, immediate_misses, sleeps
  FROM v$latch
 WHERE NAME IN ('redo allocation', 'redo copy')
/
SET HEADING OFF
SELECT    'Ratio of MISSES to GETS: '
       || ROUND ((SUM (misses) / (SUM (gets) + 0.00000000001) * 100), 2)
       || '%'
  FROM v$latch
 WHERE NAME IN ('redo allocation', 'redo copy');
SELECT    'Ratio of IMMEDIATE_MISSES to IMMEDIATE_GETS: '
       || ROUND ((  SUM (immediate_misses)
                  / (SUM (immediate_misses + immediate_gets) + 0.00000000001)
                  * 100
                 ),
                 2
                )
       || '%'
  FROM v$latch
 WHERE NAME IN ('redo allocation', 'redo copy');
SET HEADING ON



PROMPT
PROMPT ************** GETHIT RATIO *****************
PROMPT GETHITRATIO is number of GETHTS/GETS. PINHIT RATIO is number of
PROMPT PINHITS/PINS - number close to 1 indicates that most objects requested
PROMPT for pinning have been cached. Pay close attention to PINHIT RATIO.
COLUMN namespace    FORMAT A20          HEADING 'NAME'
COLUMN gets         FORMAT 999,999,999  HEADING 'GETS'
COLUMN gethits      FORMAT 999,999,999  HEADING 'GETHITS'
COLUMN gethitratio  FORMAT 999.99       HEADING 'GET HIT|RATIO'
COLUMN pins         FORMAT 999,999,999  HEADING 'PINHITS'
COLUMN pinhitratio  FORMAT 999.99       HEADING 'PIN HIT|RATIO'
SELECT namespace, gets, gethits, gethitratio, pins, pinhitratio
  FROM v$librarycache;



PROMPT
PROMPT ************** I/O FOR DBFILES *****************
PROMPT This looks at overall I/O activity against individual files within
PROMPT a tablespace.
PROMPT
PROMPT Look for a mismatch across disk drives in terms of I/O.
PROMPT
PROMPT Also, examine the Blocks per Read Ratio for heavily accessed
PROMPT TSs - if this value is significantly above 1 then you may have
PROMPT full tablescans occurring (with multi-block I/O).
PROMPT
PROMPT If activity on the files is unbalanced, move files around to balance
PROMPT the load. Should see an approximately even set of numbers across files.
COLUMN sum_io NEW_VALUE divide_by NOPRINT
SELECT SUM (phyrds + phywrts) sum_io
  FROM v$filestat;
COLUMN name     FORMAT A50    HEADING "FILE NAME"
COLUMN read                   HEADING "BLOCKS|READ"
COLUMN ratio    FORMAT 999.9  HEADING "BLOCKS|PER READ"
COLUMN write                  HEADING "BLOCKS|WRITTEN"
COLUMN total                  HEADING "TOTAL IO|BLOCKS"
COLUMN percent  FORMAT 999.99 HEADING "PERCENT|Of IO"
BREAK ON REPORT
COMPUTE SUM OF read     ON REPORT
COMPUTE SUM OF write    ON REPORT
COMPUTE SUM OF total    ON REPORT
COMPUTE SUM OF percent  ON REPORT
SELECT   df.NAME NAME, fs.phyblkrd READ,
         fs.phyblkrd / DECODE (fs.phyrds, 0, 1, fs.phyrds) ratio,
         fs.phyblkwrt WRITE, fs.phyblkrd + fs.phyblkwrt total,
         ((fs.phyrds + fs.phywrts) / &divide_by) * 100 PERCENT
    FROM v$filestat fs, v$datafile df
   WHERE df.file# = fs.file#
ORDER BY fs.phyblkrd + fs.phyblkwrt DESC;
UNDEFINE divide_by



PROMPT
PROMPT ************** I/O CONFLICTS *****************
SELECT d.NAME, f.phyrds, f.phywrts
  FROM v$datafile d, v$filestat f
 WHERE d.file# = f.file#;

 
PROMPT
PROMPT ************** WAITS STATS *****************
PROMPT Look at the wait statistics generated. They will
PROMPT tell you where there is contention in the system. There will
PROMPT usually be some contention in any system - but if the ratio of
PROMPT waits for a particular operation starts to rise, you may need to
PROMPT add additional resource, such as more database buffers, log buffers,
PROMPT or rollback segments.
COLUMN class  HEADING "Waited on"
COLUMN count  HEADING "Times waited"  FORMAT 99,999,999
COLUMN time   HEADING "Total time (sec)"   FORMAT 99,999,999
SELECT   CLASS, COUNT, TIME
    FROM v$waitstat
   WHERE COUNT > 0
ORDER BY CLASS;


PROMPT
PROMPT ************** SORTWORK STATS *****************
PROMPT To make best use of sort memory, the initial extent of your Users
PROMPT sort-work Tablespace should be sufficient to hold at least one sort
PROMPT run from memory to reduce dynamic space allocation. If you are getting
PROMPT a high ratio of disk sorts as opposed to memory sorts, setting
PROMPT sort_area_retained_size = 0 in init.ora will force the sort area to be
PROMPT released immediately after a sort finishes.
SELECT a.NAME "Type", VALUE "Bytes"
  FROM v$statname a, v$sysstat
 WHERE a.statistic# = v$sysstat.statistic#
   AND a.NAME IN ('sorts (disk)', 'sorts (memory)', 'sorts (rows)');

   
   
PROMPT
PROMPT
PROMPT
PROMPT #########
PROMPT ####################
PROMPT ### 8 STATS AND TRANSACTIONS INFO ###
PROMPT ####################
PROMPT #########
PROMPT   
   
   
PROMPT
PROMPT ************** NOT ANALYZED TABLES *****************
DEFINE AnalPeriod = 180
PROMPT Getting tables that were not analyzed at last &&AnalPeriod days or
PROMPT were not analyzed at all. Default and system users are not included.
COLUMN owner            FORMAT A20            HEADING "Owner"
COLUMN table_name       FORMAT A50            HEADING "Table"
COLUMN last_analyzed    FORMAT DATE           HEADING "Analyzed"
SELECT owner, table_name, last_analyzed
FROM dba_tables
WHERE owner NOT IN ('ANONYMOUS','SYS','SYSTEM','SYSMAN','DBSNMP','OUTLN','SCOTT','XDB','RMAN','MGMT_VIEW','ORDPLUGINS',
					'CTXSYS','LBACSYS','WMSYS','WKSYS','TSMSYS','DMSYS','EXFSYS','MDSYS','OLAPSYS','ORDSYS','OWBSYS',
					'BI','HR','OE','PM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','IX','ODM','ODM_MTR',
					'SI_INFORMTN_SCHEMA','WK_TEST','WKPROXY','APEX_PUBLIC_USER','DIP','FLOWS_30000','FLOWS_FILES',
					'MDDATA','ORACLE_OCM','PUBLIC','SPATIAL_CSW_ADMIN_USER','SPATIAL_WFS_ADMIN_USR','XS$NULL')
AND ( last_analyzed < SYSDATE - &&AnalPeriod OR last_analyzed IS NULL )
AND temporary IN ('N')
ORDER BY owner asc, last_analyzed asc, table_name asc;


PROMPT
PROMPT ************** RECYCLE BIN OBJECTS *****************
COLUMN CAN_UNDROP       FORMAT A10 
COLUMN OBJSIZE          FORMAT A10 
  SELECT   TYPE,
           OWNER,
           ORIGINAL_NAME,
		   TS_NAME,
           OPERATION,
           DROPTIME,
           CAN_UNDROP,
           ROUND((SPACE + 0) * (SELECT VALUE FROM v$parameter WHERE NAME = 'db_block_size')/1024/1024,0) || 'Mb' OBJSIZE
    FROM   DBA_RECYCLEBIN
   WHERE   OWNER NOT IN ('ANONYMOUS','SYS','SYSTEM','SYSMAN','DBSNMP','OUTLN','SCOTT','XDB','RMAN','MGMT_VIEW','ORDPLUGINS',
					'CTXSYS','LBACSYS','WMSYS','WKSYS','TSMSYS','DMSYS','EXFSYS','MDSYS','OLAPSYS','ORDSYS','OWBSYS',
					'BI','HR','OE','PM','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','SH','IX','ODM','ODM_MTR',
					'SI_INFORMTN_SCHEMA','WK_TEST','WKPROXY','APEX_PUBLIC_USER','DIP','FLOWS_30000','FLOWS_FILES',
					'MDDATA','ORACLE_OCM','PUBLIC','SPATIAL_CSW_ADMIN_USER','SPATIAL_WFS_ADMIN_USR','XS$NULL')
ORDER BY   2,3;


PROMPT
PROMPT ************** ACTIVE TRANSACTIONS *****************
SELECT a.SID, a.username, b.xidusn, b.used_urec, b.used_ublk
  FROM v$session a, v$transaction b
 WHERE a.saddr = b.ses_addr;

 
 
PROMPT
PROMPT ************** UNFINISHED TRANSACTIONS *****************
SELECT A.TERMINAL,A.OSUSER, A.USERNAME
FROM V$SESSION A,V$TRANSACTION B
WHERE B.SES_ADDR = A.SADDR AND 
       A.AUDSID <> USERENV('SESSIONID');

	   
PROMPT
PROMPT ************** SCHEDULER *****************

SELECT   owner,
         job_name,
         start_date,
         job_class,
         enabled,
         state,
         last_start_date,
         last_run_duration,
         next_run_date
  FROM   all_scheduler_jobs;

  
PROMPT
PROMPT ************** RUNNNING JOBS *****************
SELECT * FROM ALL_SCHEDULER_RUNNING_JOBS;


PROMPT
PROMPT ************** SCHEDULER DETAILS *****************
COLUMN owner                FORMAT A15
COLUMN job_name             FORMAT A25
COLUMN LOG_DATE             FORMAT A45
COLUMN STATUS               FORMAT A10
COLUMN ERROR#               FORMAT 99
COLUMN REQ_START_DATE       FORMAT A45
COLUMN RUN_DURATION         FORMAT A40
COLUMN CPU_USED             FORMAT A40
SELECT   OWNER,
         JOB_NAME,
		 LOG_DATE,
         STATUS,
         ERROR#,
         REQ_START_DATE,
         RUN_DURATION,
         CPU_USED
  FROM   ALL_SCHEDULER_JOB_RUN_DETAILS
 WHERE   RUN_DURATION > '+00 00:01:00.000000';	   

 

PROMPT
PROMPT
PROMPT
PROMPT #########
PROMPT #####################
PROMPT ### 9 ALERTS AND REPORTS ###
PROMPT #####################
PROMPT #########
PROMPT


PROMPT ************** DBA ALERTS HISTORY *************
PROMPT Shows different warnings. Notifications and instance restart warnings are excluded.
column reason  				heading "What happened?"  	format A110		trunc
column obj_name 			heading "Where?" 			format A20  	trunc
column create_time   		heading "When?"  			format date		trunc
column suggested_action   	heading "What can I do?"  	format A110 	trunc
select reason, trim(object_name) obj_name, CAST(creation_time AS DATE) create_time, suggested_action from DBA_ALERT_HISTORY
WHERE NOT (MESSAGE_TYPE IN ('Notification'))
AND NOT (REASON_ID IN (135));


PROMPT
PROMPT ************** ADDM REPORT *************

define end_snap = 0;
define begin_snap = 0;

column end_snap  heading "End Snap"  new_value end_snap format 9999;
column begin_snap heading "Begin Snap"  new_value begin_snap format 9999;
select MAX(snap_id) AS end_snap, MAX(snap_id) - 2 AS begin_snap
from dba_hist_snapshot;

var tname VARCHAR2(60);
var bid number;
var eid number;
DECLARE
    id number;
BEGIN
  :bid       :=  &begin_snap;
  :eid       :=  &end_snap;
  :tname := 'ADDM' || TO_CHAR(SYSDATE,'_MONDDHH24MISS');

  dbms_advisor.create_task('ADDM',id,:tname,'Report for SEL_FROM_RECOVER',null);
  dbms_advisor.set_task_parameter(:tname, 'START_SNAPSHOT', :bid);
  dbms_advisor.set_task_parameter(:tname, 'END_SNAPSHOT', :eid); 
  dbms_advisor.execute_task(:tname);  
END;
/
set long 1000000 pagesize 0 longchunksize 1000
column get_clob format a300
select dbms_advisor.get_task_report(:tname, 'TEXT', 'TYPICAL') from dual;
SET LINESIZE 300
SET PAGESIZE 75

PROMPT
PROMPT ************** ADVISOR FINDINGS *************
column Impact format a15
column Message format a100
column MORE_INFO format a150
SELECT ROUND(IMPACT/1000000,2) || ' Sec' AS "Impact", MESSAGE, MORE_INFO
FROM DBA_ADVISOR_FINDINGS
WHERE TYPE_ID NOT IN (3,4)
AND FINDING_NAME NOT IN ('normal, successful completion')
AND ROWNUM <= 25
ORDER BY IMPACT DESC;

PROMPT  
PROMPT ************** ALERT LOG *****************
SET LINESIZE 1000
SET PAGESIZE 700
DECLARE
	var_alert_dir varchar2(255);
	var_db_name varchar2(64);

BEGIN	

select trim(i.INSTANCE_NAME)
  into var_db_name
  from v$instance i;	
	
select v.value
  into var_alert_dir
  from v$parameter v
 where v.NAME = 'background_dump_dest';

execute immediate ('create or replace directory alert_log as ''' || var_alert_dir || ''' ');
DECLARE
  ObjectExists EXCEPTION;
  PRAGMA EXCEPTION_INIT(ObjectExists,-955);
BEGIN
execute immediate ('create table t_alert_log(msg varchar2(1000), rcn number) organization external(type oracle_loader default directory ' || 
	'alert_log access parameters(records delimited by newline fields (msg CHAR(1000), rcn RECNUM)) location(''alert_' || var_db_name || '.log'')) reject limit 1000');
EXCEPTION WHEN ObjectExists THEN 
 execute immediate ('drop table t_alert_log cascade constraints');
 execute immediate ('create table t_alert_log(msg varchar2(1000), rcn number) organization external(type oracle_loader default directory ' || 
	'alert_log access parameters(records delimited by newline fields (msg CHAR(1000), rcn RECNUM)) location(''alert_' || var_db_name || '.log'')) reject limit 1000');
END;

END;
/

select tt.msg from (select t.msg, t.rcn from T_ALERT_LOG t
order by t.rcn desc) tt
where rownum < 500
order by tt.rcn asc;

drop table t_alert_log cascade constraints;
SET LINESIZE 300
SET PAGESIZE 75




PROMPT
PROMPT
PROMPT
PROMPT #########
PROMPT #####################
PROMPT ### 10 LOCAL INFO ###
PROMPT #####################
PROMPT #########
PROMPT



PROMPT ************** SCRIPT END TIME *************
SET HEADING OFF
select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') from dual;
SET HEADING ON
 
 
PROMPT
PROMPT ************** LOCAL ORACLE REGISTRY *************
CL BUFF
GET sel_oracle_key.log
GET sel_oracle_key2.log
CL BUFF


PROMPT
PROMPT
PROMPT ************** LOCAL LISTENER *************
CL BUFF
GET sel_listener.log
CL BUFF

PROMPT
PROMPT
PROMPT ************** LOCAL ENVIRONMENT VARIABLE (PATH) *************
CL BUFF
GET sel_set.log
CL BUFF



PROMPT
PROMPT
PROMPT ************** LOCAL OS INFO *************
PROMPT In Sysinfo.log file!


SPOOL OFF
SET TERMOUT ON
SET ECHO ON
EXIT
