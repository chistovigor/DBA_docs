#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile
. $HOME/.bashrc

#execute script

backup_dir=`pwd`

sqlplus -S / as sysdba <<SCRIPT
drop restore point FIRST_BACKUP_`date +%Y%m%d`;
exit;
SCRIPT

rman target / <<SCRIPT
spool log to $backup_dir/backup.log
run
{
HOST 'echo start `date`';
}
SET COMPRESSION ALGORITHM 'MEDIUM' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE;
run
{
allocate channel oem_backup_disk1 type disk format '$backup_dir/%U';
allocate channel oem_backup_disk2 type disk format '$backup_dir/%U';
backup filesperset = 50 keep until time 'SYSDATE+999' restore point 'FIRST_BACKUP_`date +%Y%m%d`' as COMPRESSED BACKUPSET tag 'FULL_BACKUP_`date +%Y%m%d`' section size  4 G  database;
release channel oem_backup_disk1;
release channel oem_backup_disk2;
}
spool log off
exit
SCRIPT

backup_state=`cat $backup_dir/backup.log | grep -v ORA-19921 | grep ORA-`

if [ -f ${backup_dir}/backup.log ]; then
 if [[ ${backup_state}  -eq 0 ]];then
    echo backup correct
   else
    echo backup fail
   fi
else
 echo backup fail
 fi

echo finish `date`

exit