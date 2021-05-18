#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

#set variables

patch_dir='/mnt/data_fc/disk50G/distrib/patchset_11.2.0.3.10/18031683'

cd $patch_dir

opatch apply

lsnrctl start

emctl start dbconsole

sqlplus -S / as sysdba <<!

STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT;
select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v\$database;

!

exit
