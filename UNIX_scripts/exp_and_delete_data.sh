#!/bin/bash

. $HOME/.bash_profile
. $HOME/.bashrc

#set variables
#keep data in production DB for the given pariod in months
months_keep=24
#paths tothe dump and log files
dump_path=/mnt/data2/dump
#keep exported dump and log files for the given pariod in days
dump_keep=90

#set constants
sqlstring='select max(ID) from DDDSPROC_TRANSACT_INFO_ARC where TRUNC(TRANSDATE) < TRUNC(ADD_MONTHS(SYSDATE, -'$months_keep'));'
max_ID=`echo $sqlstring | sqlplus -S VSMC3DS/VSMC3DS@ULTRA_SERVICE | tail -n-2 | head -n+1`

echo max_ID $max_ID

expdp VSMC3DS/VSMC3DS@ULTRA_SERVICE tables=DDDSPROC_TRANSACT_INFO_ARC,TANDEM_TRANSACT_INFO_ARC,DDDSPROC_TRNATTR_INFO_ARC,FM_TRANSACT_INFO_ARC,DDDSPROC_FLAGS_ARC DIRECTORY=EXP_DIR DUMPFILE=DDDSPROC_TRANSACT_INFO_ARC.dmp LOGFILE=DDDSPROC_TRANSACT_INFO_ARC.LOG content=ALL QUERY='"where ID < '$max_ID'"' parallel=2

retcode=`echo $?`

#script body

case "$retcode" in
0) echo "expdp execution successful"
echo retcode=$retcode
echo
echo delete exported data from DDDSPROC_TRANSACT_INFO_ARC table
echo
sqlplus -S VSMC3DS/VSMC3DS@ULTRA_SERVICE<<EOF
 set termout on serveroutput on
 spool DDDSPROC_TRANSACT_INFO_ARC_delete.log
 select 'start at ' || to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
 PROMPT *** min(ID) in DDDSPROC_TRANSACT_INFO_ARC before delete ***
 select min(ID) from DDDSPROC_TRANSACT_INFO_ARC;
 begin
  DELETE_OLD_TRANSACT_INFO($months_keep);
 end;
 /
 commit;
 PROMPT *** min(ID) in DDDSPROC_TRANSACT_INFO_ARC after delete ***
 select min(ID) from DDDSPROC_TRANSACT_INFO_ARC;
 select 'finish at ' || to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
 spool off
EOF
 ;;
1) echo "expdp execution encountered a fatal error"
echo retcode=$retcode
echo ;;
5) echo "expdp execution exited with EX_SUCC_ERR, see logfile"
echo retcode=$retcode
echo ;;
*) echo "unknown return code"
echo retcode=$retcode
echo ;;
esac

cd $dump_path
mkdir `date +%Y%m%d`

zip $dump_path/`date +%Y%m%d`/DDDSPROC_TRANSACT_INFO_ARC_`date +%g%m%d`.zip * -x exp_VSMC3DS.log -9 -mDj
zip $dump_path/`date +%Y%m%d`/DDDSPROC_TRANSACT_INFO_ARC_`date +%g%m%d`.zip exp_VSMC3DS.log -9 -Dj

find $dump_path/* -type d -mtime +$dump_keep -exec rm -rf {} \;

exit
