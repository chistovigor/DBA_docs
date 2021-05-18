#!/bin/bash

echo start `date`
echo
date_start=`date +%s`

sqlldr TCTDBS/tctdbs -control=cng_loader.ctl -log=sql_loader_`date +%Y%m%d`.log -SILENT=ALL

retcode=`echo $?` 
case "$retcode" in 
0) echo "SQL*Loader execution successful" ;; 
1) echo "SQL*Loader execution exited with EX_FAIL, see logfile" ;; 
2) echo "SQL*Loader execution exited with EX_WARN, see logfile" ;; 
3) echo "SQL*Loader execution encountered a fatal error" ;; 
*) echo "unknown return code";; 
esac

echo finish `date`
date_end=`date +%s`
echo
load_time=$(((date_end-date_start)/60))
echo load_time = $load_time minutes
