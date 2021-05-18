#!/bin/bash

#variables

export ORACLE_SID=$1

#functions

function find_ora_home {
export ORACLE_SID=$ORACLE_SID
export PROC_INFO=`ps -ef | grep pmon | grep $ORACLE_SID | awk '{print $2}'`

if [ `ps -ef | grep pmon | grep $ORACLE_SID | wc -l` -gt 1 ]; then
#clear
echo more than 1 pmon process for INSTANCE is running ! exit
echo `ps -ef | grep pmon | grep $ORACLE_SID`
exit 2
fi

#echo PROC_INFO $PROC_INFO
export ORACLE_HOME_STRING=`pwdx $PROC_INFO | cut -f2 -d':'`
#echo ORACLE_HOME_STRING $ORACLE_HOME_STRING
if [ -z "$ORACLE_HOME_STRING" ]; then
#clear
echo wrong SID or INSTANCE not running ! exit
exit $?
fi

unset ORACLE_HOME
unset _
export ORACLE_HOME=`echo ${ORACLE_HOME_STRING/\/dbs/}`
#export PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch:$PATH
#echo ORACLE_HOME is $ORACLE_HOME
#echo rman is `which rman`
#echo sqlplus is `which sqlplus`
echo $ORACLE_HOME
}

#run script

find_ora_home

exit