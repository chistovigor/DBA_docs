#!/bin/bash

. $HOME/.bash_profile
. $HOME/.bashrc

echo start `date`
echo
date_start=`date +%s`
logfile=/mnt/oracle/temp/ONLINE_ARCHIVE/cng_loader_13_`date +%Y%m%d`.log

sqlldr TCTDBS/tctdbs -control=/mnt/oracle/temp/ONLINE_ARCHIVE/cng_loader_13.ctl -log=$logfile -SILENT=ALL

retcode=`echo $?` 
case "$retcode" in 
0) echo "SQL*Loader execution successful" ;; 
1) echo "SQL*Loader execution exited with EX_FAIL, see logfile" ;; 
2) echo "SQL*Loader execution exited with EX_WARN, see logfile" ;; 
3) echo "SQL*Loader execution encountered a fatal error" ;; 
*) echo "unknown return code" ;; 
esac

echo finish `date`
date_end=`date +%s`
echo
load_time=$(((date_end-date_start)/60))
echo load_time = $load_time minutes
