10.131.17.70 (user - oracle) - ./opatch_test.sh

./work_with_db.sh | grep "ORACLE_HOME is" | cut -f2 -d ":" | uniq > rdbms_home_list_`whoami`

./opatch_test.sh /rbackup/2020_Q4_patches

oracle@uniwayhadb1:/rbackup/2020_Q4_patches/Solaris/19.0/31750108/31771877$ /u01/app/oracle/product/19.0.0/dbhome_1/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -ph ./
Oracle Interim Patch Installer version 12.2.0.1.17
Copyright (c) 2020, Oracle Corporation.  All rights reserved.

PREREQ session

Oracle Home       : /u01/app/oracle/product/19.0.0/dbhome_1
Central Inventory : /u01/app/oraInventory
   from           : /u01/app/oracle/product/19.0.0/dbhome_1/oraInst.loc
OPatch version    : 12.2.0.1.17
OUI version       : 12.2.0.7.0
Log file location : /u01/app/oracle/product/19.0.0/dbhome_1/cfgtoollogs/opatch/opatch2020-11-18_18-10-02PM_1.log

Invoking prereq "checkconflictagainstohwithdetail"

Prereq "checkConflictAgainstOHWithDetail" passed.

OPatch succeeded.
oracle@uniwayhadb1:/rbackup/2020_Q4_patches/Solaris/19.0/31750108/31771877$ echo $?
0


#functions

function find_patches_for_current_server {

echo parent patches folder is $v_positional_var1
echo os is $os_ver
echo

for i in ${home_list[@]}

do

export ORACLE_HOME=$i

if [ -d "$ORACLE_HOME" ];then
var1=`${ORACLE_HOME}/bin/tnsping | grep "TNS Ping Utility" | cut -f2 -d ":" | cut -f3 -d " "`
else
 oracle_home folder $ORACLE_HOME not exists, set version 99.0.0.0
 var1=99.0.0.0
fi
rdbms_ver=`echo $var1 | cut -f1-2 -d "."`

echo oracle_home $i version is $rdbms_ver
echo go to related patch folder
cd $v_positional_var1/$os_ver/$rdbms_ver
if [ -d "$v_positional_var1/$os_ver/$rdbms_ver" ];then
  echo patch folder exists
  cd $v_positional_var1/$os_ver/$rdbms_ver
  patch_folder=`ls -d */`
  echo unzipped patch folder is $v_positional_var1/$os_ver/$rdbms_ver/$patch_folder
  cd $v_positional_var1/$os_ver/$rdbms_ver/$patch_folder
  echo
 else
  echo echo patch folder for oracle version $rdbms_ver not exists, no patching
  echo
fi

done
}