#!/bin/bash
#. /usr/local/bin/mount.sh start

#REMOTE_HOST="s-msk08-arch"
export ORACLE_HOME=/usr/oracle/product/10.2.0/db_1
export ORACLE_SID=lanit
export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin

echo "-----------------------------------------"
echo "***** Begin" `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "-----------------------------------------"


#1)backup

rman target / AUXILIARY sys/spotlight@LANIT_RESERVE  < /usr/local/bin/create_standby.sql LOG=/var/logs/create_standby.log
echo "Done!" `date '+%a %d.%m.%Y-%H:%M:%S'`

echo "----------------------------------------"
echo "***** End  " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

