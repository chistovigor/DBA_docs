SET TERMOUT ON
SET ECHO OFF
SET VERIFY OFF
SET LINESIZE 400
SET PAGESIZE 1600

SPOOL check_tablespaces.log

PROMPT *** instance at the current server status ***

connect / as sysdba;

column STARTUP_TIME   format A25
column INSTANCE_NAME  format A10
column HOST_NAME      format A16
column STARTED        format A25
column DESTINATION    format A35
column CHANGE_TIME    format A25

select INSTANCE_NAME,HOST_NAME,to_char(STARTUP_TIME,'dd/mm/yyyy hh24:mi:ss') as STARTED,STATUS from v$instance;

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
PROMPT ************** TS PROPERTIES *****************
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
COLUMN USERNAME                     FORMAT A15
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
COLUMN USERNAME                     FORMAT A15
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
COLUMN grantee			        FORMAT A15         HEADING "User"		trunc
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

SPOOL OFF

exit;
