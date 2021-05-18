#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

#set variables

patch_dir=$1
patch_prereq=`opatch prereq CheckConflictAgainstOHWithDetail -ph $patch_dir | grep checkConflictAgainstOHWithDetail`

#run script



cd $patch_dir
echo $patch_dir directory was used as PSU directory

if [[ $patch_prereq == 'Prereq "checkConflictAgainstOHWithDetail" passed.' ]];
then
 echo apply patchset
 echo
 emctl stop dbconsole
 lsnrctl stop
 echo 'shutdown immediate;' | sqlplus -S / as sysdba
 cd $patch_dir
 opatch apply
 cd $ORACLE_HOME/rdbms/admin
sqlplus -S / as sysdba <<!
STARTUP;
@catbundle.sql psu apply;
@utlrp;
quit
!

lsnrctl start
emctl start dbconsole
exit
 else
  echo checkConflictAgainstOHWithDetail NOT passed - cannot apply patchset
fi

exit