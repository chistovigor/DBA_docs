#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

#set variables

#uncomment test_mode variable to prevent running full database backup!!!
#test_mode="#"
#uncomment backup_archivelogs_only variable to backup only archived logs!!!
#backup_archivelogs_only='BACKUP AS COMPRESSED BACKUPSET ARCHIVELOG ALL tag 'archivelogs_$daily_folder' NOT BACKED UP DELETE ALL INPUT SKIP INACCESSIBLE;'

backup_folder='/u01/backup/local/rman'
remote_backup_folder='/u01/backup/remote'

#set constants (the same for all servers)

remote_instance=`sqlplus -S / as sysdba <<EOF
set heading off feedback off termout off trimspool on
select value from v\\$parameter where name = 'fal_server';
EOF`
cut_host=5
daily_folder=`date +%Y%m%d`
server_admins="iruacii2@raiffeisen.ru,iruakgd5@raiffeisen.ru"
CURRENT_HOSTNAME=`uname -n`
subject='oracle backup probably failed'
message='last successful backup was'
zabbix_server='10.243.12.20'
remote_server=`tnsping $remote_instance | grep HOST -A0 | cut -f$cut_host -d'=' | cut -f1 -d')' | cut -f2 -d' '`
table='V$RMAN_BACKUP_JOB_DETAILS'
db_status=`echo 'select DATABASE_ROLE from v$database;' | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

#execute script

echo "----------------------------------------"
echo "***** Start " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

mkdir $backup_folder/$daily_folder

rman target sys/spotlight <<!
spool log to $backup_folder/$daily_folder/backup.log
CONFIGURE CONTROLFILE AUTOBACKUP ON;
SET COMPRESSION ALGORITHM 'MEDIUM' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD FALSE;
run
{
 set CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '$backup_folder/$daily_folder/CTL_AND_SPFILE_AUTO_%F.BCK';
 allocate channel oem_backup_disk1 type disk format '$backup_folder/$daily_folder/BACKUP_%Y%M%D_%U.BCK' MAXPIECESIZE 4 G;
 allocate channel oem_backup_disk2 type disk format '$backup_folder/$daily_folder/BACKUP_%Y%M%D_%U.BCK' MAXPIECESIZE 4 G;
 allocate channel oem_backup_disk3 type disk format '$backup_folder/$daily_folder/BACKUP_%Y%M%D_%U.BCK' MAXPIECESIZE 4 G;
 allocate channel oem_backup_disk4 type disk format '$backup_folder/$daily_folder/BACKUP_%Y%M%D_%U.BCK' MAXPIECESIZE 4 G;
 $backup_archivelogs_only
 $test_mode backup filesperset = 50 force noexclude as COMPRESSED BACKUPSET tag 'DB_full_$daily_folder' database;
 backup filesperset = 50 as COMPRESSED BACKUPSET tag 'archivelogs_$daily_folder' archivelog all not backed up delete all input;
 sql "alter database backup controlfile to trace as ''$backup_folder/$daily_folder/control_norstlogs_$daily_folder.sql'' reuse noresetlogs";
 sql "alter database backup controlfile to trace as ''$backup_folder/$daily_folder/control_rstlogs_$daily_folder.sql'' reuse resetlogs";
 sql "create pfile=''$backup_folder/$daily_folder/init$ORACLE_SID.ora'' from spfile";
 release channel oem_backup_disk1;
 release channel oem_backup_disk2;
 release channel oem_backup_disk3;
 release channel oem_backup_disk4;
}
allocate channel for maintenance type disk;
delete noprompt obsolete device type disk;
release channel;
spool log off
exit
!

backup_state=`cat $backup_folder/$daily_folder/backup.log | grep -v ORA-19921 | grep ORA-`
last_backup=`echo "select to_char(max(END_TIME),'dd/mm/yy hh24:mi') from $table where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED','COMPLETED WITH WARNINGS');" | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

echo "current db status is" $db_status
echo "last successful backup" ${last_backup}
echo "0 - error"
echo "1 - ok"
echo "current state"

if [ -f $backup_folder/$daily_folder/backup.log ]; then
        if [[ ${backup_state} -eq 0 ]];then
                echo "1"
         else
                echo "0"
                mailx -s "`uname -n`: $CURRENT_HOSTNAME $subject" $server_admins <<!
$message $last_backup. current db status is $db_status
!
        fi
else

  echo "0"
  mailx -s "`uname -n`: $CURRENT_HOSTNAME $subject" $server_admins <<!
$message $last_backup. current db status is $db_status
!
fi

echo "sending to zabbix"

if [ -f $backup_folder/$daily_folder/backup.log ]; then
 if [[ ${backup_state}  -eq 0 ]];then
    zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k backup_status -o 1
   else
    zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k backup_status -o 0
   fi
else
zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k backup_status -o 0
 fi

rm -f ${backup_folder}/backup.log
find $backup_folder* -name backup.log -mtime +60 -exec rm {} \;
find $backup_folder* -name init$ORACLE_SID.ora -mtime +60 -exec rm {} \;
find $backup_folder* -name *.sql -mtime +60 -exec rm {} \;
find $backup_folder -empty -type d -delete


if [ "${db_status}" == PRIMARY ]
 then rsync -varlp --progress --bwlimit=20000 --delete $backup_folder oracle@$remote_server:$remote_backup_folder
 else echo "not copy"
fi

echo "----------------------------------------"
echo "***** Finish " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

exit
