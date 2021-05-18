#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

#set variables

lsnrctl stop

emctl stop dbconsole

echo 'shutdown immediate;' | sqlplus -S / as sysdba

exit
