#!/bin/sh

if [ "$#" -le 1 ]
  then
   echo -e "the number of positional variables given is $#"
   echo -e "script $0 must be run with the 2 positional variable(s) = 1 - patch number, 2 - folder for backup OMS_HOME default: /u01/app/oracle/oradata/backup/oracle_home/u01_appem_oracle"
    exit
  else
 echo -e "script $0 was executed with positional variables = $*"
# 0) Export patch number and backup dir
  patch=$1
  oms_backup_dir=$2
  echo patch=$patch
  echo oms_backup_dir=$oms_backup_dir
  # 1) Set home to OMS_HOME (middleware)
  . ~/.setmwhome
  echo "create folder for OMS bin folder backup"
  mkdir $oms_backup_dir/MW_`date +%Y%m%d`_before_patch_$patch
  echo "stop OMS"
  emctl stop oms
  echo "backup OMS bin folder in zip MW.zip (log $oms_backup_dir/MW_`date +%Y%m%d`_before_patch_$patch/archive.log"
  cd $oms_backup_dir/MW_`date +%Y%m%d`_before_patch_$patch
  zip -r9 MW.zip $ORACLE_HOME > archive.log 2>&1
  . ~/.bash_profile
  echo "create restore point before_patch_$patch in OMS repository database"
  echo "create restore point before_patch_$patch;" | sqlplus -s / as sysdba
  echo "list restore point all;" | rman target /
  echo
  echo "ready to perform patching steps, when finished run"
  echo "emctl start oms"
fi

exit