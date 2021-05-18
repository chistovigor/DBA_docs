#!/bin/bash

# Set environment
. /home/oracle/.bash_profile

# variables

day_of_backup=7 #day of week for backup RO tablespaces (1..7); 1 is Monday

timestamp=`date +%%Y%%m%%d_%%H%%M`
day_of_week=`date +%%u`
sqlplus_header='set heading off feedback off termout off trimspool on serveroutput off linesize 2000 pagesize 10000'
backup_ro_ts=`sqlplus -S / as sysdba <<!
$sqlplus_header
SELECT 'BACKUP TAG RO_TS_%orcl_gtp_comment%_%orcl_gtp_location%_${timestamp} FILESPERSET 1 TABLESPACE '||LISTAGG (TABLESPACE_NAME, ',') WITHIN GROUP (ORDER BY TABLESPACE_NAME) ||'  FORMAT ''RO_TS_%TargetName%_%%U_%%c'';' FROM DBA_TABLESPACES WHERE STATUS = 'READ ONLY' ORDER BY TABLESPACE_NAME;
!`

#run script

rman target sys/$db_pass <<!
CONFIGURE CONTROLFILE AUTOBACKUP ON;
SELECT CAST(TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS VARCHAR2(30)) AS BACKUP_DB_STEP_1 FROM DUAL;
BACKUP FILESPERSET 1 DATABASE tag 'DB_%orcl_gtp_comment%_%orcl_gtp_location%_$timestamp' FORMAT 'DB_%TargetName%_%%U_%%c';
exit
!

rman target sys/$db_pass <<!
SELECT CAST(TO_CHAR(SYSDATE,'DD-MM-YYYY HH24:MI:SS') AS VARCHAR2(30)) AS BACKUP_ARCHLOG_STEP_2 FROM DUAL;
CROSSCHECK ARCHIVELOG ALL;
BACKUP FILESPERSET 1 ARCHIVELOG ALL tag 'ARCH_%orcl_gtp_comment%_%orcl_gtp_location%_$timestamp' FORMAT 'ARCH_%TargetName%_%%U_%%c' KEEP UNTIL TIME 'SYSDATE+3';
CONFIGURE CONTROLFILE AUTOBACKUP OFF;
BACKUP CURRENT CONTROLFILE tag 'CTL_%orcl_gtp_comment%_%orcl_gtp_location%_$timestamp' format 'CTL_%orcl_gtp_comment%_%%U_%%c';
LIST BACKUP SUMMARY;
exit
!

echo
echo "backup RO TS rman current script is:"
echo "$backup_ro_ts"
echo

if [ $day_of_week -eq $day_of_backup ]; then
echo "$backup_ro_ts" | rman checksyntax log backup_ro_ts.log
if [ $? -eq 0 ]; then
rman target / <<!
$backup_ro_ts
exit
!
else
echo
echo
echo "no read only tablespaces in database"
fi
else
  echo
  echo "today is" `date +%%A`", backup RO tablespaces only in" $day_of_backup "day of week"
fi