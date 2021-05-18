#!/bin/bash

echo start `date`
echo
date_start=`date +%s`

sqlldr TCTDBS/tctdbs -control=cng_loader_12.ctl -log=cng_loader_12_`date +%Y%m%d`.log -SILENT=ALL

retcode=`echo $?` 
case "$retcode" in 
0) echo "SQL*Loader execution successful" >> cng_loader_12_`date +%Y%m%d`.log ;; 
1) echo "SQL*Loader execution exited with EX_FAIL, see logfile" >> cng_loader_12_`date +%Y%m%d`.log ;; 
2) echo "SQL*Loader execution exited with EX_WARN, see logfile" >> cng_loader_12_`date +%Y%m%d`.log ;; 
3) echo "SQL*Loader execution encountered a fatal error" >> cng_loader_12_`date +%Y%m%d`.log ;; 
*) echo "unknown return code" >> cng_loader_12_`date +%Y%m%d`.log ;; 
esac

echo finish `date` >> cng_loader_12_`date +%Y%m%d`.log
date_end=`date +%s` >> cng_loader_12_`date +%Y%m%d`.log
echo >> cng_loader_12_`date +%Y%m%d`.log
load_time=$(((date_end-date_start)/60))
echo load_time = $load_time minutes >> cng_loader_12_`date +%Y%m%d`.log
