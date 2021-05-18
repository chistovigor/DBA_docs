#!/bin/bash

timestamp() 
{ 
date +"%F %T" 
}


filter() 
{ 
while IFS= read -r line; do 
 echo "$line" | tee -a "$1" 
 done 
 } 


stdintoexitstatus() 
{ 
read exitstatus 
 return $exitstatus 
 } 


executeBinaryOperation() 
 { 
 $1 
 }  


mainProg() 
 { 


export EMDROOT=/u01/appem/oracle/MW

EMBEDDED_HOST_NAME=emcc

CURRENT_SCRIPT_NAME=`basename $0`

CURRENT_SCRIPT_LOCATION=`dirname $0`

OPATCHAUTO_SCRIPT_PATH=/u01/appem/oracle/MW/.omspatcher_storage/oms_session/scripts_2016-11-25_13-39-52PM/run_script_singleoms_resume.sh

OPATCHAUTO_SCRIPT_DIR=/u01/appem/oracle/MW/.omspatcher_storage/oms_session/scripts_2016-11-25_13-39-52PM


if [ !  -d "/u01/appem/oracle/MW/.omspatcher_storage" ]; then 
  mkdir /u01/appem/oracle/MW/.omspatcher_storage; 
 RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command "mkdir /u01/appem/oracle/MW/.omspatcher_storage" failed with error code $RESULT";  
        return ${RESULT} 
    fi
 fi 

if [ !  -d "/u01/appem/oracle/MW/.omspatcher_storage/oms_session" ]; then 
  mkdir /u01/appem/oracle/MW/.omspatcher_storage/oms_session; 
 RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command "mkdir /u01/appem/oracle/MW/.omspatcher_storage/oms_session" failed with error code $RESULT";  
        return ${RESULT} 
    fi
 fi 

if [ ! -f "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" ]; then 
  echo "Creating  master log file "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"..."; 
  touch /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;   
 RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command "touch /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" failed with error code $RESULT";  
        return ${RESULT} 
    fi
   chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log; 
fi


 echo "

Start of new session at $(timestamp)" >> /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log

 echo "-------------------------------------------" >> /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log



/u01/appem/oracle/MW/oracle_common/jdk/bin/java -cp /u01/appem/oracle/MW/OMSPatcher/jlib/oracle.omspatcher.classpath.jar:.: oracle.opatchauto.oms.OMSHostInterfaceChecker emcc

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The script failed with error code $RESULT";  
        exit ${RESULT} 
    fi
if [ ! -f "/u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM" ]; then 
  echo "Creating  session file "/u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM"..."; 
  touch /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM;   
 RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command "touch /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM" failed with error code $RESULT";  
        return ${RESULT} 
    fi
   chmod 660 /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM; 
  echo "script=/u01/appem/oracle/MW/.omspatcher_storage/oms_session/scripts_2016-11-25_13-39-52PM/run_script_singleoms_resume.sh" > /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM; 
  echo "Step1=
Step2=
Step3=
Step4=
Step5=
Step6=
Step7=
Step8=
Step9=
Step10=
Step11=
Step12=
Step13=
Step14=
Step15=
Step16=
Step17=
Step18=
Step19=
Step20=
Step21=
Step22=
Step23=
Step24=
Step25=
Step26=
Step27=
Step28=
Step29=
Step30=
Step31=
Step32=
Step33=
Step34=
Step35=
Step36=
Step37=
Step38=
Step39=
Step40=
Step41=
Step42=
Step43=
Step44=
Step45=
Step46=
Step47=
Step48=
Step49=
Step50=
Step51=
Step52=
Step53=
Step54=
Step55=
Step56=
Step57=
Step58=
Step59=
Step60=
Step61=
Step62=
Step63=
Step64=
Step65=
Step66=
Step67=
Step68=
Step69=
Step70=
Step71=
Step72=
Step73=
Step74=
Step75=
Step76=
Step77=
Step78=
Step79=
Step80=
Step81=
Step82=
Step83=
Step84=
Step85=
Step86=
Step87=
Step88=
Step89=
Step90=
Step91=
Step92=
Step93=
Step94=
Step95=
Step96=
Step97=
Step98=
Step99=
Step100=
Step101=
Step102=
Step103=
Step104=
Step105=
Step106=
Step107=
Step108=
Step109=
Step110=
Step111=
Step112=
Step113=
Step114=
Step115=
Step116=
Step117=
Step118=
Step119=
Step120=
Step121=
Step122=
Step123=
Step124=
Step125=
Step126=
Step127=
Step128=
Step129=
Step130=
Step131=
Step132=
" >> /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM; 
fi
if [ -f "/u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker" ] && [ ! -s "/u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker" ]; then 
 rm /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker; 
fi 
if [ !  -f "/u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker" ]; then 
  touch /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker; 
 RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command "touch /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker" failed with error code $RESULT";  
        return ${RESULT} 
    fi
   chmod 660 /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker; 
  echo "session_file=/u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM" >> /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker;
  echo "log_file=/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" >> /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker;
  else
  OLD_SESSION_FILE=`grep "session_file=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker |  sed 's/session_file=//g'`
 if [ "/u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM" != "$OLD_SESSION_FILE" ]; then 
grep -l "Step.*=$" $OLD_SESSION_FILE >/dev/null 2>&1 
MATCH1=$?
grep -l "Step.*=PASS$" $OLD_SESSION_FILE >/dev/null 2>&1 
MATCH2=$?
if [ $MATCH1 -eq 0 ] && [ $MATCH2 -eq 0 ]; then 
active_script_path=`grep "script=" $OLD_SESSION_FILE |  sed 's/script=//g'`
echo "Previous session is not completed. To complete previous session, please execute script $active_script_path";
return 1; 
fi 
grep -l "Step.*=FAIL$" $OLD_SESSION_FILE >/dev/null 2>&1 
MATCH3=$?
if [ $MATCH3 -eq 0 ]; then 
active_script_path=`grep "script=" $OLD_SESSION_FILE |  sed 's/script=//g'`
echo "Previous session is not completed. To complete previous session, please execute script $active_script_path";
return 1; 
fi 
fi 
rm /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker; 
 RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command "rm /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker" failed with error code $RESULT";  
        return ${RESULT} 
    fi
   touch /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker; 
 RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command "touch /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker" failed with error code $RESULT";  
        return ${RESULT} 
    fi
   chmod 660 /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker; 
  echo "session_file=/u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM" >> /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker;
  echo "log_file=/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" >> /u01/appem/oracle/MW/.omspatcher_storage/oms_session/execution_tracker;
fi 
 if [ ! -f "$OPATCHAUTO_SCRIPT_PATH" ]; then 
  mkdir -p $OPATCHAUTO_SCRIPT_DIR; 
 RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command "mkdir -p $OPATCHAUTO_SCRIPT_DIR" failed with error code $RESULT";  
        return ${RESULT} 
    fi
   echo "Copying your script to OMSPatcher defined path "$OPATCHAUTO_SCRIPT_PATH"..."; 
cp $CURRENT_SCRIPT_LOCATION/$CURRENT_SCRIPT_NAME $OPATCHAUTO_SCRIPT_PATH; 
 RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command "cp $CURRENT_SCRIPT_LOCATION/$CURRENT_SCRIPT_NAME $OPATCHAUTO_SCRIPT_PATH" failed with error code $RESULT";  
        return ${RESULT} 
    fi
 fi 


RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The script failed with error code $RESULT";  
        exit ${RESULT} 
    fi

 echo "Execute Commands:" >> /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log

echo "Step 1: echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24667625 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 1: /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent

Step 1: rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 1: mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24667625_Oct_4_2016_06_25_40; cp -Rf /u01/appem/oracle/MW/.patch_storage/24667625_Oct_4_2016_06_25_40/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24667625_Oct_4_2016_06_25_40

Step 2: echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24667671 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 2: /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent

Step 2: rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 2: mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24667671_Oct_4_2016_07_33_03; cp -Rf /u01/appem/oracle/MW/.patch_storage/24667671_Oct_4_2016_07_33_03/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24667671_Oct_4_2016_07_33_03

Step 3: echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842833 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 3: /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent

Step 3: rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 3: mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842833_Oct_26_2016_22_22_05; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842833_Oct_26_2016_22_22_05/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842833_Oct_26_2016_22_22_05

Step 4: echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842850 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 4: /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent

Step 4: rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 4: mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842850_Oct_26_2016_22_48_31; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842850_Oct_26_2016_22_48_31/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842850_Oct_26_2016_22_48_31

Step 5: echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842878 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 5: /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent

Step 5: rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 5: mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842878_Oct_27_2016_00_52_09; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842878_Oct_27_2016_00_52_09/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842878_Oct_27_2016_00_52_09

Step 6: echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842919 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 6: /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent

Step 6: rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

Step 6: mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842919_Oct_26_2016_01_06_54; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842919_Oct_26_2016_01_06_54/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842919_Oct_26_2016_01_06_54

Step 7: /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24667671_Oct_4_2016_07_33_03/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0

Step 8: /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24842833_Oct_26_2016_22_22_05/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0

Step 9: /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24842850_Oct_26_2016_22_48_31/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0

Step 10: /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24842878_Oct_27_2016_00_52_09/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0

Step 11: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetPatchingImplRegistration -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetpatchingregister/RegisterWLSTargetForPatching.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 12: /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/swlib -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 13: /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/swlib/patch -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 14: /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/swlib/dbprovision/dbprov -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 15: /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/swlib -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 16: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/CloudDeploySoftware.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%

Step 17: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/PdbaasCleanUpDP.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%

Step 18: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/DBCAProv.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%

Step 19: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/DBAASDP.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%

Step 20: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/DbaasCleanupDP.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%

Step 21: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DBThinProv.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 22: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DNFSProvisioning.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 23: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/ClusterSwitchover.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 24: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/RMANLiveRestore.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 25: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DbProvUpgradeDeploymentProcedure.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 26: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/FleetMaintenanceDP.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 27: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PDBDisableTM.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 28: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateSIDBToGoldImageOH.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 29: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PDBEnableTM.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 30: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateListener.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 31: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchPostOOP.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 32: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/EnableTM.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 33: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CreateDatabase.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 34: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRollingRAC.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 35: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DataMasking.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 36: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/RMANBackup.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 37: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/ExtendClusterNG.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 38: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchAllNodesRAC.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 39: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchAllNodesCRSDB12.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 40: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PDBClone.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 41: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateRACDBToGoldImageOH.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 42: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DNFSProfile.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 43: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CleanupOracleHomeTargets.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 44: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DataMigration.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 45: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateListenerToGoldImage.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 46: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchSADB.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 47: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRestart.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 48: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/SihaSwitchover.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 49: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CloudMaintenancePatchDB.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 50: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DBContSyncProv.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 51: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRollingCRS.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 52: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/provrac.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 53: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRollingCRSDB12.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 54: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/SoftMaintPatching.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 55: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/provsidb.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 56: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/RMANRestore.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 57: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/configASM.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 58: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DisableTM.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 59: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PostPatchSIHAOOP.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 60: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateDBToGoldImageOH.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 61: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DBClone.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 62: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRestartDB12.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 63: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchAllNodesCRS.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 64: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/ConvertToRAC.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 65: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CleanupSihaSidb.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 66: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CloneAndPatchSADB.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 67: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/LbrWrapperDP.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 68: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/PatchWLSParallel.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 69: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/SOAaaSOuterDP.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 70: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/JavaEEAppDeployment.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 71: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/PatchWLSRolling.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 72: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/WlaaSSetupDomain.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 73: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/WlaaSAppProvisioning.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 74: /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/JavaEEDP.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 75: /u01/appem/oracle/MW/bin/emctl register oms metadata -service omsPropertyDef -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/omsProperties/definition/DBPropDefinition.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 76: /u01/appem/oracle/MW/bin/emctl register oms metadata -service omsPropertyDef -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/omsProperties/definition/ProvisioningPropDefinition.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 77: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/cluster.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 78: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 79: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_dbsvc.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 80: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_pdb.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 81: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 82: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_exadata.xml -pluginId oracle.sysman.xa -sysman_pwd %EM_REPOS_PASSWORD%

Step 83: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 84: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_apm.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 85: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/scheduler_service.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 86: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_bi_publisher.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 87: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_j2eeagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 88: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_webcenter.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 89: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_standaloneagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 90: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application_domain.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 91: /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_oam.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 92: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_dbsvc.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 93: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 94: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 95: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_pdb.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 96: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/cluster.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 97: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_exadata.xml -pluginId oracle.sysman.xa -sysman_pwd %EM_REPOS_PASSWORD%

Step 98: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_oam.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 99: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_j2eeagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 100: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_bi_publisher.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 101: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/scheduler_service.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 102: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_apm.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 103: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application_domain.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 104: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_webcenter.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 105: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 106: /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_standaloneagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 107: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/cluster.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 108: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 109: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 110: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_pdb.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 111: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_exadata.xml -pluginId oracle.sysman.xa -sysman_pwd %EM_REPOS_PASSWORD%

Step 112: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_odi_standaloneagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 113: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_oam.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 114: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_webcenter.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 115: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/j2ee_application.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 116: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/j2ee_application_domain.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 117: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_odi_j2eeagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 118: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/scheduler_service.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 119: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_bi_publisher.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 120: /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_apm.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 121: /u01/appem/oracle/MW/bin/emctl register oms metadata -service systemStencil -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/systemStencil/cluster.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 122: /u01/appem/oracle/MW/bin/emctl register oms metadata -service systemStencil -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/systemStencil/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 123: /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/DisablePDBaaSCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 124: /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/EnablePDBaaSRacCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 125: /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/EnablePDBaaSCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 126: /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/DisablePDBaaSRacCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 127: /u01/appem/oracle/MW/bin/emctl register oms metadata -service CfwServiceFamily -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/cfw/serviceFamily/mw_service_family.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 128: /u01/appem/oracle/MW/bin/emctl register oms metadata -service assoc -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/assoc/coherence_allowed_pairs.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%

Step 129: /u01/appem/oracle/MW/bin/emctl register oms metadata -service CfwResourceProvider -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/cfw/resourceProviderType/ssa_pdbaas_resource_provider.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%

Step 130: /u01/appem/oracle/MW/bin/emctl register oms metadata -service jobTypes -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/jobTypes/SQLScriptSec.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%

Step 131: /u01/appem/oracle/MW/OMSPatcher/omspatcher commit -id 24667625 -oh /u01/appem/oracle/MW -skip_patch_ids 24460784,23592229,23178160,23592089  -system_patch_id 24940833 -invPtrLoc /u01/appem/oracle/MW/oraInst.loc

Step 132: /u01/appem/oracle/MW/OMSPatcher/omspatcher updateIdenticalPatches  -oh /u01/appem/oracle/MW -skip_patch_ids 24460784,23592229,23178160,23592089  -system_patch_id 24940833 -invPtrLoc /u01/appem/oracle/MW/oraInst.loc



" >> /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log


echo "
Please provide credential for OMS repository SYSMAN user: "
stty -echo
read EM_REPOS_PASSWORD
stty echo

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The script failed with error code $RESULT";  
        exit ${RESULT} 
    fi

echo "Command to execute (Step 1): echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24667625 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 1): /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent"


echo "Command to execute (Step 1): rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 1): mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24667625_Oct_4_2016_06_25_40; cp -Rf /u01/appem/oracle/MW/.patch_storage/24667625_Oct_4_2016_06_25_40/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24667625_Oct_4_2016_06_25_40"

grep -l 'Step1=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step1=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step1=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step1=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24667625 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt
 
    else 
    echo "SKIP command for step 1..."
    fi 
    else 
       echo "SKIP command for step 1..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step1=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step1=.*/Step1=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step1=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step1=.*/Step1=PASS/g';
    fi

((((executeBinaryOperation "/u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent" ;echo $? >&3) | filter emcc2016-11-25_13-57-25.a.out >&4) 3>&1) | stdintoexitstatus) 4>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step1=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step1=.*/Step1=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi

 grep  'OPatch stopped on request\|OPatch failed' emcc2016-11-25_13-57-25.a.out >/dev/null 2>&1;
RESULT=$? 
    if [ $RESULT == 0 ]; then 
        echo "The script can't proceed further as patching operations are not completed.";  
        grep -l "Step1=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step1=.*/Step1=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return 1 
    fi

 rm emcc2016-11-25_13-57-25.a.out 
rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step1=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step1=.*/Step1=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24667625_Oct_4_2016_06_25_40; cp -Rf /u01/appem/oracle/MW/.patch_storage/24667625_Oct_4_2016_06_25_40/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24667625_Oct_4_2016_06_25_40

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step1=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step1=.*/Step1=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
 
    else 
    echo "SKIP command for step 1..."
    fi 
    else 
       echo "SKIP command for step 1..."
    fi 


echo "Command to execute (Step 2): echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24667671 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 2): /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent"


echo "Command to execute (Step 2): rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 2): mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24667671_Oct_4_2016_07_33_03; cp -Rf /u01/appem/oracle/MW/.patch_storage/24667671_Oct_4_2016_07_33_03/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24667671_Oct_4_2016_07_33_03"

grep -l 'Step2=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step2=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step2=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step2=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24667671 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt
 
    else 
    echo "SKIP command for step 2..."
    fi 
    else 
       echo "SKIP command for step 2..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step2=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step2=.*/Step2=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step2=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step2=.*/Step2=PASS/g';
    fi

((((executeBinaryOperation "/u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent" ;echo $? >&3) | filter emcc2016-11-25_13-57-25.a.out >&4) 3>&1) | stdintoexitstatus) 4>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step2=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step2=.*/Step2=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi

 grep  'OPatch stopped on request\|OPatch failed' emcc2016-11-25_13-57-25.a.out >/dev/null 2>&1;
RESULT=$? 
    if [ $RESULT == 0 ]; then 
        echo "The script can't proceed further as patching operations are not completed.";  
        grep -l "Step2=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step2=.*/Step2=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return 1 
    fi

 rm emcc2016-11-25_13-57-25.a.out 
rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step2=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step2=.*/Step2=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24667671_Oct_4_2016_07_33_03; cp -Rf /u01/appem/oracle/MW/.patch_storage/24667671_Oct_4_2016_07_33_03/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24667671_Oct_4_2016_07_33_03

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step2=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step2=.*/Step2=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
 
    else 
    echo "SKIP command for step 2..."
    fi 
    else 
       echo "SKIP command for step 2..."
    fi 


echo "Command to execute (Step 3): echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842833 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 3): /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent"


echo "Command to execute (Step 3): rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 3): mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842833_Oct_26_2016_22_22_05; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842833_Oct_26_2016_22_22_05/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842833_Oct_26_2016_22_22_05"

grep -l 'Step3=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step3=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step3=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step3=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842833 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt
 
    else 
    echo "SKIP command for step 3..."
    fi 
    else 
       echo "SKIP command for step 3..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step3=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step3=.*/Step3=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step3=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step3=.*/Step3=PASS/g';
    fi

((((executeBinaryOperation "/u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent" ;echo $? >&3) | filter emcc2016-11-25_13-57-25.a.out >&4) 3>&1) | stdintoexitstatus) 4>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step3=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step3=.*/Step3=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi

 grep  'OPatch stopped on request\|OPatch failed' emcc2016-11-25_13-57-25.a.out >/dev/null 2>&1;
RESULT=$? 
    if [ $RESULT == 0 ]; then 
        echo "The script can't proceed further as patching operations are not completed.";  
        grep -l "Step3=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step3=.*/Step3=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return 1 
    fi

 rm emcc2016-11-25_13-57-25.a.out 
rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step3=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step3=.*/Step3=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842833_Oct_26_2016_22_22_05; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842833_Oct_26_2016_22_22_05/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842833_Oct_26_2016_22_22_05

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step3=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step3=.*/Step3=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
 
    else 
    echo "SKIP command for step 3..."
    fi 
    else 
       echo "SKIP command for step 3..."
    fi 


echo "Command to execute (Step 4): echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842850 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 4): /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent"


echo "Command to execute (Step 4): rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 4): mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842850_Oct_26_2016_22_48_31; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842850_Oct_26_2016_22_48_31/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842850_Oct_26_2016_22_48_31"

grep -l 'Step4=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step4=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step4=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step4=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842850 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt
 
    else 
    echo "SKIP command for step 4..."
    fi 
    else 
       echo "SKIP command for step 4..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step4=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step4=.*/Step4=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step4=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step4=.*/Step4=PASS/g';
    fi

((((executeBinaryOperation "/u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent" ;echo $? >&3) | filter emcc2016-11-25_13-57-25.a.out >&4) 3>&1) | stdintoexitstatus) 4>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step4=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step4=.*/Step4=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi

 grep  'OPatch stopped on request\|OPatch failed' emcc2016-11-25_13-57-25.a.out >/dev/null 2>&1;
RESULT=$? 
    if [ $RESULT == 0 ]; then 
        echo "The script can't proceed further as patching operations are not completed.";  
        grep -l "Step4=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step4=.*/Step4=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return 1 
    fi

 rm emcc2016-11-25_13-57-25.a.out 
rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step4=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step4=.*/Step4=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842850_Oct_26_2016_22_48_31; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842850_Oct_26_2016_22_48_31/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842850_Oct_26_2016_22_48_31

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step4=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step4=.*/Step4=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
 
    else 
    echo "SKIP command for step 4..."
    fi 
    else 
       echo "SKIP command for step 4..."
    fi 


echo "Command to execute (Step 5): echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842878 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 5): /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent"


echo "Command to execute (Step 5): rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 5): mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842878_Oct_27_2016_00_52_09; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842878_Oct_27_2016_00_52_09/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842878_Oct_27_2016_00_52_09"

grep -l 'Step5=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step5=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step5=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step5=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842878 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt
 
    else 
    echo "SKIP command for step 5..."
    fi 
    else 
       echo "SKIP command for step 5..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step5=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step5=.*/Step5=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step5=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step5=.*/Step5=PASS/g';
    fi

((((executeBinaryOperation "/u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent" ;echo $? >&3) | filter emcc2016-11-25_13-57-25.a.out >&4) 3>&1) | stdintoexitstatus) 4>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step5=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step5=.*/Step5=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi

 grep  'OPatch stopped on request\|OPatch failed' emcc2016-11-25_13-57-25.a.out >/dev/null 2>&1;
RESULT=$? 
    if [ $RESULT == 0 ]; then 
        echo "The script can't proceed further as patching operations are not completed.";  
        grep -l "Step5=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step5=.*/Step5=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return 1 
    fi

 rm emcc2016-11-25_13-57-25.a.out 
rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step5=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step5=.*/Step5=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842878_Oct_27_2016_00_52_09; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842878_Oct_27_2016_00_52_09/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842878_Oct_27_2016_00_52_09

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step5=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step5=.*/Step5=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
 
    else 
    echo "SKIP command for step 5..."
    fi 
    else 
       echo "SKIP command for step 5..."
    fi 


echo "Command to execute (Step 6): echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842919 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 6): /u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent"


echo "Command to execute (Step 6): rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt"


echo "Command to execute (Step 6): mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842919_Oct_26_2016_01_06_54; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842919_Oct_26_2016_01_06_54/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842919_Oct_26_2016_01_06_54"

grep -l 'Step6=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step6=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step6=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step6=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo /u01/app/oracle/oradata/distrib/patches/oms/24940833/24940833/24842919 >> /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt
 
    else 
    echo "SKIP command for step 6..."
    fi 
    else 
       echo "SKIP command for step 6..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step6=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step6=.*/Step6=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step6=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step6=.*/Step6=PASS/g';
    fi

((((executeBinaryOperation "/u01/appem/oracle/MW/OPatch/opatch napply -phBaseFile /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt -invPtrLoc /u01/appem/oracle/MW/oraInst.loc -oh /u01/appem/oracle/MW -silent" ;echo $? >&3) | filter emcc2016-11-25_13-57-25.a.out >&4) 3>&1) | stdintoexitstatus) 4>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step6=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step6=.*/Step6=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi

 grep  'OPatch stopped on request\|OPatch failed' emcc2016-11-25_13-57-25.a.out >/dev/null 2>&1;
RESULT=$? 
    if [ $RESULT == 0 ]; then 
        echo "The script can't proceed further as patching operations are not completed.";  
        grep -l "Step6=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step6=.*/Step6=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return 1 
    fi

 rm emcc2016-11-25_13-57-25.a.out 
rm /u01/appem/oracle/MW/.phBaseFile2016-11-25_13-39-52PM.txt

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step6=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step6=.*/Step6=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
mkdir -p /u01/appem/oracle/MW/.omspatcher_storage/24842919_Oct_26_2016_01_06_54; cp -Rf /u01/appem/oracle/MW/.patch_storage/24842919_Oct_26_2016_01_06_54/original_patch /u01/appem/oracle/MW/.omspatcher_storage/24842919_Oct_26_2016_01_06_54

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step6=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step6=.*/Step6=FAIL/g';
        echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    fi
 
    else 
    echo "SKIP command for step 6..."
    fi 
    else 
       echo "SKIP command for step 6..."
    fi 


echo "Command to execute (Step 7): /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24667671_Oct_4_2016_07_33_03/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0"

grep -l 'Step7=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step7=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step7=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step7=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo $EM_REPOS_PASSWORD | /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24667671_Oct_4_2016_07_33_03/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0
 
    else 
    echo "SKIP command for step 7..."
    fi 
    else 
       echo "SKIP command for step 7..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step7=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step7=.*/Step7=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step7=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step7=.*/Step7=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 7..."
    fi 
    else 
       echo "SKIP command for step 7..."
    fi 


echo "Command to execute (Step 8): /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24842833_Oct_26_2016_22_22_05/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0"

grep -l 'Step8=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step8=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step8=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step8=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo $EM_REPOS_PASSWORD | /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24842833_Oct_26_2016_22_22_05/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0
 
    else 
    echo "SKIP command for step 8..."
    fi 
    else 
       echo "SKIP command for step 8..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step8=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step8=.*/Step8=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step8=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step8=.*/Step8=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 8..."
    fi 
    else 
       echo "SKIP command for step 8..."
    fi 


echo "Command to execute (Step 9): /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24842850_Oct_26_2016_22_48_31/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0"

grep -l 'Step9=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step9=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step9=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step9=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo $EM_REPOS_PASSWORD | /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24842850_Oct_26_2016_22_48_31/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0
 
    else 
    echo "SKIP command for step 9..."
    fi 
    else 
       echo "SKIP command for step 9..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step9=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step9=.*/Step9=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step9=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step9=.*/Step9=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 9..."
    fi 
    else 
       echo "SKIP command for step 9..."
    fi 


echo "Command to execute (Step 10): /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24842878_Oct_27_2016_00_52_09/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0"

grep -l 'Step10=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step10=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step10=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step10=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo $EM_REPOS_PASSWORD | /u01/appem/oracle/MW/bin/emctl applypatch repos -patchHome /u01/appem/oracle/MW/.omspatcher_storage/24842878_Oct_27_2016_00_52_09/original_patch -pluginHome /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0
 
    else 
    echo "SKIP command for step 10..."
    fi 
    else 
       echo "SKIP command for step 10..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step10=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step10=.*/Step10=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step10=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step10=.*/Step10=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 10..."
    fi 
    else 
       echo "SKIP command for step 10..."
    fi 


echo "Command to execute (Step 11): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetPatchingImplRegistration -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetpatchingregister/RegisterWLSTargetForPatching.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step11=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step11=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step11=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step11=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetPatchingImplRegistration -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetpatchingregister/RegisterWLSTargetForPatching.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 11..."
    fi 
    else 
       echo "SKIP command for step 11..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step11=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step11=.*/Step11=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step11=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step11=.*/Step11=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 11..."
    fi 
    else 
       echo "SKIP command for step 11..."
    fi 


echo "Command to execute (Step 12): /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/swlib -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step12=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step12=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step12=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step12=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/swlib -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 12..."
    fi 
    else 
       echo "SKIP command for step 12..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step12=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step12=.*/Step12=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step12=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step12=.*/Step12=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 12..."
    fi 
    else 
       echo "SKIP command for step 12..."
    fi 


echo "Command to execute (Step 13): /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/swlib/patch -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step13=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step13=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step13=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step13=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/swlib/patch -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 13..."
    fi 
    else 
       echo "SKIP command for step 13..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step13=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step13=.*/Step13=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step13=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step13=.*/Step13=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 13..."
    fi 
    else 
       echo "SKIP command for step 13..."
    fi 


echo "Command to execute (Step 14): /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/swlib/dbprovision/dbprov -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step14=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step14=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step14=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step14=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/swlib/dbprovision/dbprov -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 14..."
    fi 
    else 
       echo "SKIP command for step 14..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step14=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step14=.*/Step14=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step14=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step14=.*/Step14=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 14..."
    fi 
    else 
       echo "SKIP command for step 14..."
    fi 


echo "Command to execute (Step 15): /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/swlib -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step15=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step15=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step15=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step15=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service swlib -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/swlib -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 15..."
    fi 
    else 
       echo "SKIP command for step 15..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step15=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step15=.*/Step15=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step15=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step15=.*/Step15=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 15..."
    fi 
    else 
       echo "SKIP command for step 15..."
    fi 


echo "Command to execute (Step 16): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/CloudDeploySoftware.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step16=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step16=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step16=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step16=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/CloudDeploySoftware.xml -pluginId oracle.sysman.ssa -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 16..."
    fi 
    else 
       echo "SKIP command for step 16..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step16=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step16=.*/Step16=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step16=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step16=.*/Step16=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 16..."
    fi 
    else 
       echo "SKIP command for step 16..."
    fi 


echo "Command to execute (Step 17): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/PdbaasCleanUpDP.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step17=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step17=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step17=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step17=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/PdbaasCleanUpDP.xml -pluginId oracle.sysman.ssa -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 17..."
    fi 
    else 
       echo "SKIP command for step 17..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step17=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step17=.*/Step17=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step17=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step17=.*/Step17=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 17..."
    fi 
    else 
       echo "SKIP command for step 17..."
    fi 


echo "Command to execute (Step 18): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/DBCAProv.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step18=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step18=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step18=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step18=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/DBCAProv.xml -pluginId oracle.sysman.ssa -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 18..."
    fi 
    else 
       echo "SKIP command for step 18..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step18=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step18=.*/Step18=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step18=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step18=.*/Step18=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 18..."
    fi 
    else 
       echo "SKIP command for step 18..."
    fi 


echo "Command to execute (Step 19): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/DBAASDP.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step19=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step19=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step19=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step19=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/DBAASDP.xml -pluginId oracle.sysman.ssa -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 19..."
    fi 
    else 
       echo "SKIP command for step 19..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step19=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step19=.*/Step19=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step19=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step19=.*/Step19=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 19..."
    fi 
    else 
       echo "SKIP command for step 19..."
    fi 


echo "Command to execute (Step 20): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/DbaasCleanupDP.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step20=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step20=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step20=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step20=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/procedures/DbaasCleanupDP.xml -pluginId oracle.sysman.ssa -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 20..."
    fi 
    else 
       echo "SKIP command for step 20..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step20=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step20=.*/Step20=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step20=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step20=.*/Step20=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 20..."
    fi 
    else 
       echo "SKIP command for step 20..."
    fi 


echo "Command to execute (Step 21): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DBThinProv.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step21=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step21=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step21=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step21=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DBThinProv.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 21..."
    fi 
    else 
       echo "SKIP command for step 21..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step21=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step21=.*/Step21=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step21=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step21=.*/Step21=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 21..."
    fi 
    else 
       echo "SKIP command for step 21..."
    fi 


echo "Command to execute (Step 22): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DNFSProvisioning.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step22=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step22=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step22=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step22=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DNFSProvisioning.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 22..."
    fi 
    else 
       echo "SKIP command for step 22..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step22=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step22=.*/Step22=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step22=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step22=.*/Step22=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 22..."
    fi 
    else 
       echo "SKIP command for step 22..."
    fi 


echo "Command to execute (Step 23): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/ClusterSwitchover.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step23=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step23=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step23=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step23=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/ClusterSwitchover.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 23..."
    fi 
    else 
       echo "SKIP command for step 23..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step23=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step23=.*/Step23=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step23=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step23=.*/Step23=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 23..."
    fi 
    else 
       echo "SKIP command for step 23..."
    fi 


echo "Command to execute (Step 24): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/RMANLiveRestore.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step24=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step24=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step24=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step24=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/RMANLiveRestore.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 24..."
    fi 
    else 
       echo "SKIP command for step 24..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step24=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step24=.*/Step24=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step24=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step24=.*/Step24=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 24..."
    fi 
    else 
       echo "SKIP command for step 24..."
    fi 


echo "Command to execute (Step 25): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DbProvUpgradeDeploymentProcedure.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step25=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step25=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step25=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step25=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DbProvUpgradeDeploymentProcedure.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 25..."
    fi 
    else 
       echo "SKIP command for step 25..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step25=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step25=.*/Step25=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step25=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step25=.*/Step25=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 25..."
    fi 
    else 
       echo "SKIP command for step 25..."
    fi 


echo "Command to execute (Step 26): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/FleetMaintenanceDP.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step26=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step26=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step26=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step26=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/FleetMaintenanceDP.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 26..."
    fi 
    else 
       echo "SKIP command for step 26..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step26=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step26=.*/Step26=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step26=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step26=.*/Step26=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 26..."
    fi 
    else 
       echo "SKIP command for step 26..."
    fi 


echo "Command to execute (Step 27): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PDBDisableTM.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step27=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step27=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step27=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step27=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PDBDisableTM.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 27..."
    fi 
    else 
       echo "SKIP command for step 27..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step27=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step27=.*/Step27=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step27=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step27=.*/Step27=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 27..."
    fi 
    else 
       echo "SKIP command for step 27..."
    fi 


echo "Command to execute (Step 28): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateSIDBToGoldImageOH.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step28=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step28=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step28=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step28=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateSIDBToGoldImageOH.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 28..."
    fi 
    else 
       echo "SKIP command for step 28..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step28=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step28=.*/Step28=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step28=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step28=.*/Step28=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 28..."
    fi 
    else 
       echo "SKIP command for step 28..."
    fi 


echo "Command to execute (Step 29): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PDBEnableTM.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step29=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step29=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step29=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step29=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PDBEnableTM.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 29..."
    fi 
    else 
       echo "SKIP command for step 29..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step29=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step29=.*/Step29=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step29=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step29=.*/Step29=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 29..."
    fi 
    else 
       echo "SKIP command for step 29..."
    fi 


echo "Command to execute (Step 30): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateListener.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step30=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step30=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step30=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step30=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateListener.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 30..."
    fi 
    else 
       echo "SKIP command for step 30..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step30=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step30=.*/Step30=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step30=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step30=.*/Step30=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 30..."
    fi 
    else 
       echo "SKIP command for step 30..."
    fi 


echo "Command to execute (Step 31): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchPostOOP.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step31=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step31=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step31=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step31=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchPostOOP.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 31..."
    fi 
    else 
       echo "SKIP command for step 31..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step31=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step31=.*/Step31=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step31=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step31=.*/Step31=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 31..."
    fi 
    else 
       echo "SKIP command for step 31..."
    fi 


echo "Command to execute (Step 32): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/EnableTM.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step32=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step32=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step32=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step32=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/EnableTM.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 32..."
    fi 
    else 
       echo "SKIP command for step 32..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step32=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step32=.*/Step32=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step32=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step32=.*/Step32=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 32..."
    fi 
    else 
       echo "SKIP command for step 32..."
    fi 


echo "Command to execute (Step 33): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CreateDatabase.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step33=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step33=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step33=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step33=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CreateDatabase.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 33..."
    fi 
    else 
       echo "SKIP command for step 33..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step33=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step33=.*/Step33=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step33=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step33=.*/Step33=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 33..."
    fi 
    else 
       echo "SKIP command for step 33..."
    fi 


echo "Command to execute (Step 34): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRollingRAC.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step34=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step34=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step34=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step34=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRollingRAC.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 34..."
    fi 
    else 
       echo "SKIP command for step 34..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step34=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step34=.*/Step34=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step34=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step34=.*/Step34=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 34..."
    fi 
    else 
       echo "SKIP command for step 34..."
    fi 


echo "Command to execute (Step 35): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DataMasking.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step35=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step35=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step35=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step35=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DataMasking.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 35..."
    fi 
    else 
       echo "SKIP command for step 35..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step35=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step35=.*/Step35=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step35=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step35=.*/Step35=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 35..."
    fi 
    else 
       echo "SKIP command for step 35..."
    fi 


echo "Command to execute (Step 36): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/RMANBackup.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step36=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step36=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step36=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step36=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/RMANBackup.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 36..."
    fi 
    else 
       echo "SKIP command for step 36..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step36=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step36=.*/Step36=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step36=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step36=.*/Step36=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 36..."
    fi 
    else 
       echo "SKIP command for step 36..."
    fi 


echo "Command to execute (Step 37): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/ExtendClusterNG.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step37=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step37=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step37=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step37=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/ExtendClusterNG.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 37..."
    fi 
    else 
       echo "SKIP command for step 37..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step37=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step37=.*/Step37=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step37=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step37=.*/Step37=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 37..."
    fi 
    else 
       echo "SKIP command for step 37..."
    fi 


echo "Command to execute (Step 38): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchAllNodesRAC.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step38=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step38=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step38=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step38=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchAllNodesRAC.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 38..."
    fi 
    else 
       echo "SKIP command for step 38..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step38=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step38=.*/Step38=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step38=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step38=.*/Step38=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 38..."
    fi 
    else 
       echo "SKIP command for step 38..."
    fi 


echo "Command to execute (Step 39): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchAllNodesCRSDB12.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step39=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step39=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step39=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step39=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchAllNodesCRSDB12.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 39..."
    fi 
    else 
       echo "SKIP command for step 39..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step39=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step39=.*/Step39=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step39=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step39=.*/Step39=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 39..."
    fi 
    else 
       echo "SKIP command for step 39..."
    fi 


echo "Command to execute (Step 40): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PDBClone.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step40=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step40=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step40=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step40=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PDBClone.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 40..."
    fi 
    else 
       echo "SKIP command for step 40..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step40=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step40=.*/Step40=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step40=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step40=.*/Step40=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 40..."
    fi 
    else 
       echo "SKIP command for step 40..."
    fi 


echo "Command to execute (Step 41): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateRACDBToGoldImageOH.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step41=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step41=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step41=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step41=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateRACDBToGoldImageOH.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 41..."
    fi 
    else 
       echo "SKIP command for step 41..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step41=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step41=.*/Step41=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step41=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step41=.*/Step41=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 41..."
    fi 
    else 
       echo "SKIP command for step 41..."
    fi 


echo "Command to execute (Step 42): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DNFSProfile.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step42=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step42=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step42=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step42=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DNFSProfile.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 42..."
    fi 
    else 
       echo "SKIP command for step 42..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step42=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step42=.*/Step42=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step42=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step42=.*/Step42=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 42..."
    fi 
    else 
       echo "SKIP command for step 42..."
    fi 


echo "Command to execute (Step 43): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CleanupOracleHomeTargets.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step43=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step43=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step43=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step43=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CleanupOracleHomeTargets.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 43..."
    fi 
    else 
       echo "SKIP command for step 43..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step43=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step43=.*/Step43=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step43=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step43=.*/Step43=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 43..."
    fi 
    else 
       echo "SKIP command for step 43..."
    fi 


echo "Command to execute (Step 44): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DataMigration.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step44=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step44=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step44=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step44=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DataMigration.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 44..."
    fi 
    else 
       echo "SKIP command for step 44..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step44=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step44=.*/Step44=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step44=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step44=.*/Step44=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 44..."
    fi 
    else 
       echo "SKIP command for step 44..."
    fi 


echo "Command to execute (Step 45): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateListenerToGoldImage.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step45=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step45=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step45=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step45=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateListenerToGoldImage.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 45..."
    fi 
    else 
       echo "SKIP command for step 45..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step45=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step45=.*/Step45=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step45=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step45=.*/Step45=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 45..."
    fi 
    else 
       echo "SKIP command for step 45..."
    fi 


echo "Command to execute (Step 46): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchSADB.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step46=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step46=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step46=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step46=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchSADB.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 46..."
    fi 
    else 
       echo "SKIP command for step 46..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step46=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step46=.*/Step46=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step46=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step46=.*/Step46=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 46..."
    fi 
    else 
       echo "SKIP command for step 46..."
    fi 


echo "Command to execute (Step 47): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRestart.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step47=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step47=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step47=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step47=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRestart.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 47..."
    fi 
    else 
       echo "SKIP command for step 47..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step47=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step47=.*/Step47=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step47=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step47=.*/Step47=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 47..."
    fi 
    else 
       echo "SKIP command for step 47..."
    fi 


echo "Command to execute (Step 48): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/SihaSwitchover.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step48=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step48=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step48=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step48=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/SihaSwitchover.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 48..."
    fi 
    else 
       echo "SKIP command for step 48..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step48=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step48=.*/Step48=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step48=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step48=.*/Step48=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 48..."
    fi 
    else 
       echo "SKIP command for step 48..."
    fi 


echo "Command to execute (Step 49): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CloudMaintenancePatchDB.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step49=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step49=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step49=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step49=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CloudMaintenancePatchDB.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 49..."
    fi 
    else 
       echo "SKIP command for step 49..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step49=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step49=.*/Step49=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step49=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step49=.*/Step49=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 49..."
    fi 
    else 
       echo "SKIP command for step 49..."
    fi 


echo "Command to execute (Step 50): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DBContSyncProv.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step50=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step50=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step50=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step50=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DBContSyncProv.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 50..."
    fi 
    else 
       echo "SKIP command for step 50..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step50=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step50=.*/Step50=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step50=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step50=.*/Step50=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 50..."
    fi 
    else 
       echo "SKIP command for step 50..."
    fi 


echo "Command to execute (Step 51): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRollingCRS.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step51=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step51=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step51=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step51=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRollingCRS.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 51..."
    fi 
    else 
       echo "SKIP command for step 51..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step51=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step51=.*/Step51=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step51=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step51=.*/Step51=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 51..."
    fi 
    else 
       echo "SKIP command for step 51..."
    fi 


echo "Command to execute (Step 52): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/provrac.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step52=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step52=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step52=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step52=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/provrac.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 52..."
    fi 
    else 
       echo "SKIP command for step 52..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step52=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step52=.*/Step52=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step52=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step52=.*/Step52=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 52..."
    fi 
    else 
       echo "SKIP command for step 52..."
    fi 


echo "Command to execute (Step 53): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRollingCRSDB12.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step53=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step53=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step53=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step53=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRollingCRSDB12.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 53..."
    fi 
    else 
       echo "SKIP command for step 53..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step53=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step53=.*/Step53=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step53=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step53=.*/Step53=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 53..."
    fi 
    else 
       echo "SKIP command for step 53..."
    fi 


echo "Command to execute (Step 54): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/SoftMaintPatching.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step54=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step54=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step54=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step54=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/SoftMaintPatching.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 54..."
    fi 
    else 
       echo "SKIP command for step 54..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step54=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step54=.*/Step54=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step54=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step54=.*/Step54=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 54..."
    fi 
    else 
       echo "SKIP command for step 54..."
    fi 


echo "Command to execute (Step 55): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/provsidb.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step55=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step55=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step55=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step55=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/provsidb.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 55..."
    fi 
    else 
       echo "SKIP command for step 55..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step55=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step55=.*/Step55=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step55=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step55=.*/Step55=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 55..."
    fi 
    else 
       echo "SKIP command for step 55..."
    fi 


echo "Command to execute (Step 56): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/RMANRestore.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step56=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step56=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step56=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step56=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/RMANRestore.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 56..."
    fi 
    else 
       echo "SKIP command for step 56..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step56=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step56=.*/Step56=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step56=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step56=.*/Step56=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 56..."
    fi 
    else 
       echo "SKIP command for step 56..."
    fi 


echo "Command to execute (Step 57): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/configASM.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step57=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step57=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step57=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step57=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/configASM.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 57..."
    fi 
    else 
       echo "SKIP command for step 57..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step57=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step57=.*/Step57=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step57=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step57=.*/Step57=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 57..."
    fi 
    else 
       echo "SKIP command for step 57..."
    fi 


echo "Command to execute (Step 58): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DisableTM.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step58=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step58=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step58=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step58=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DisableTM.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 58..."
    fi 
    else 
       echo "SKIP command for step 58..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step58=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step58=.*/Step58=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step58=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step58=.*/Step58=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 58..."
    fi 
    else 
       echo "SKIP command for step 58..."
    fi 


echo "Command to execute (Step 59): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PostPatchSIHAOOP.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step59=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step59=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step59=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step59=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PostPatchSIHAOOP.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 59..."
    fi 
    else 
       echo "SKIP command for step 59..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step59=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step59=.*/Step59=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step59=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step59=.*/Step59=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 59..."
    fi 
    else 
       echo "SKIP command for step 59..."
    fi 


echo "Command to execute (Step 60): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateDBToGoldImageOH.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step60=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step60=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step60=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step60=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/MigrateDBToGoldImageOH.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 60..."
    fi 
    else 
       echo "SKIP command for step 60..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step60=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step60=.*/Step60=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step60=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step60=.*/Step60=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 60..."
    fi 
    else 
       echo "SKIP command for step 60..."
    fi 


echo "Command to execute (Step 61): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DBClone.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step61=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step61=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step61=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step61=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/DBClone.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 61..."
    fi 
    else 
       echo "SKIP command for step 61..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step61=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step61=.*/Step61=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step61=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step61=.*/Step61=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 61..."
    fi 
    else 
       echo "SKIP command for step 61..."
    fi 


echo "Command to execute (Step 62): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRestartDB12.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step62=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step62=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step62=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step62=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchRestartDB12.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 62..."
    fi 
    else 
       echo "SKIP command for step 62..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step62=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step62=.*/Step62=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step62=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step62=.*/Step62=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 62..."
    fi 
    else 
       echo "SKIP command for step 62..."
    fi 


echo "Command to execute (Step 63): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchAllNodesCRS.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step63=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step63=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step63=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step63=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/PatchAllNodesCRS.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 63..."
    fi 
    else 
       echo "SKIP command for step 63..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step63=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step63=.*/Step63=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step63=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step63=.*/Step63=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 63..."
    fi 
    else 
       echo "SKIP command for step 63..."
    fi 


echo "Command to execute (Step 64): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/ConvertToRAC.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step64=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step64=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step64=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step64=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/ConvertToRAC.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 64..."
    fi 
    else 
       echo "SKIP command for step 64..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step64=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step64=.*/Step64=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step64=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step64=.*/Step64=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 64..."
    fi 
    else 
       echo "SKIP command for step 64..."
    fi 


echo "Command to execute (Step 65): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CleanupSihaSidb.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step65=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step65=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step65=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step65=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CleanupSihaSidb.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 65..."
    fi 
    else 
       echo "SKIP command for step 65..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step65=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step65=.*/Step65=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step65=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step65=.*/Step65=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 65..."
    fi 
    else 
       echo "SKIP command for step 65..."
    fi 


echo "Command to execute (Step 66): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CloneAndPatchSADB.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step66=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step66=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step66=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step66=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/procedures/CloneAndPatchSADB.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 66..."
    fi 
    else 
       echo "SKIP command for step 66..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step66=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step66=.*/Step66=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step66=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step66=.*/Step66=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 66..."
    fi 
    else 
       echo "SKIP command for step 66..."
    fi 


echo "Command to execute (Step 67): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/LbrWrapperDP.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step67=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step67=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step67=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step67=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/LbrWrapperDP.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 67..."
    fi 
    else 
       echo "SKIP command for step 67..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step67=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step67=.*/Step67=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step67=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step67=.*/Step67=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 67..."
    fi 
    else 
       echo "SKIP command for step 67..."
    fi 


echo "Command to execute (Step 68): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/PatchWLSParallel.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step68=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step68=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step68=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step68=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/PatchWLSParallel.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 68..."
    fi 
    else 
       echo "SKIP command for step 68..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step68=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step68=.*/Step68=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step68=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step68=.*/Step68=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 68..."
    fi 
    else 
       echo "SKIP command for step 68..."
    fi 


echo "Command to execute (Step 69): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/SOAaaSOuterDP.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step69=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step69=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step69=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step69=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/SOAaaSOuterDP.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 69..."
    fi 
    else 
       echo "SKIP command for step 69..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step69=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step69=.*/Step69=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step69=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step69=.*/Step69=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 69..."
    fi 
    else 
       echo "SKIP command for step 69..."
    fi 


echo "Command to execute (Step 70): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/JavaEEAppDeployment.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step70=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step70=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step70=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step70=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/JavaEEAppDeployment.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 70..."
    fi 
    else 
       echo "SKIP command for step 70..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step70=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step70=.*/Step70=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step70=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step70=.*/Step70=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 70..."
    fi 
    else 
       echo "SKIP command for step 70..."
    fi 


echo "Command to execute (Step 71): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/PatchWLSRolling.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step71=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step71=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step71=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step71=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/PatchWLSRolling.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 71..."
    fi 
    else 
       echo "SKIP command for step 71..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step71=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step71=.*/Step71=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step71=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step71=.*/Step71=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 71..."
    fi 
    else 
       echo "SKIP command for step 71..."
    fi 


echo "Command to execute (Step 72): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/WlaaSSetupDomain.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step72=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step72=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step72=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step72=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/WlaaSSetupDomain.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 72..."
    fi 
    else 
       echo "SKIP command for step 72..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step72=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step72=.*/Step72=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step72=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step72=.*/Step72=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 72..."
    fi 
    else 
       echo "SKIP command for step 72..."
    fi 


echo "Command to execute (Step 73): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/WlaaSAppProvisioning.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step73=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step73=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step73=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step73=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/WlaaSAppProvisioning.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 73..."
    fi 
    else 
       echo "SKIP command for step 73..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step73=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step73=.*/Step73=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step73=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step73=.*/Step73=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 73..."
    fi 
    else 
       echo "SKIP command for step 73..."
    fi 


echo "Command to execute (Step 74): /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/JavaEEDP.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step74=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step74=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step74=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step74=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service procedures -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/procedures/JavaEEDP.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 74..."
    fi 
    else 
       echo "SKIP command for step 74..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step74=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step74=.*/Step74=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step74=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step74=.*/Step74=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 74..."
    fi 
    else 
       echo "SKIP command for step 74..."
    fi 


echo "Command to execute (Step 75): /u01/appem/oracle/MW/bin/emctl register oms metadata -service omsPropertyDef -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/omsProperties/definition/DBPropDefinition.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step75=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step75=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step75=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step75=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service omsPropertyDef -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/omsProperties/definition/DBPropDefinition.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 75..."
    fi 
    else 
       echo "SKIP command for step 75..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step75=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step75=.*/Step75=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step75=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step75=.*/Step75=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 75..."
    fi 
    else 
       echo "SKIP command for step 75..."
    fi 


echo "Command to execute (Step 76): /u01/appem/oracle/MW/bin/emctl register oms metadata -service omsPropertyDef -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/omsProperties/definition/ProvisioningPropDefinition.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step76=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step76=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step76=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step76=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service omsPropertyDef -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/omsProperties/definition/ProvisioningPropDefinition.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 76..."
    fi 
    else 
       echo "SKIP command for step 76..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step76=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step76=.*/Step76=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step76=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step76=.*/Step76=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 76..."
    fi 
    else 
       echo "SKIP command for step 76..."
    fi 


echo "Command to execute (Step 77): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/cluster.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step77=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step77=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step77=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step77=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/cluster.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 77..."
    fi 
    else 
       echo "SKIP command for step 77..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step77=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step77=.*/Step77=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step77=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step77=.*/Step77=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 77..."
    fi 
    else 
       echo "SKIP command for step 77..."
    fi 


echo "Command to execute (Step 78): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step78=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step78=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step78=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step78=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_database.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 78..."
    fi 
    else 
       echo "SKIP command for step 78..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step78=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step78=.*/Step78=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step78=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step78=.*/Step78=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 78..."
    fi 
    else 
       echo "SKIP command for step 78..."
    fi 


echo "Command to execute (Step 79): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_dbsvc.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step79=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step79=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step79=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step79=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_dbsvc.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 79..."
    fi 
    else 
       echo "SKIP command for step 79..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step79=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step79=.*/Step79=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step79=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step79=.*/Step79=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 79..."
    fi 
    else 
       echo "SKIP command for step 79..."
    fi 


echo "Command to execute (Step 80): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_pdb.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step80=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step80=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step80=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step80=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_pdb.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 80..."
    fi 
    else 
       echo "SKIP command for step 80..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step80=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step80=.*/Step80=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step80=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step80=.*/Step80=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 80..."
    fi 
    else 
       echo "SKIP command for step 80..."
    fi 


echo "Command to execute (Step 81): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step81=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step81=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step81=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step81=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 81..."
    fi 
    else 
       echo "SKIP command for step 81..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step81=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step81=.*/Step81=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step81=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step81=.*/Step81=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 81..."
    fi 
    else 
       echo "SKIP command for step 81..."
    fi 


echo "Command to execute (Step 82): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_exadata.xml -pluginId oracle.sysman.xa -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step82=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step82=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step82=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step82=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_exadata.xml -pluginId oracle.sysman.xa -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 82..."
    fi 
    else 
       echo "SKIP command for step 82..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step82=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step82=.*/Step82=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step82=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step82=.*/Step82=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 82..."
    fi 
    else 
       echo "SKIP command for step 82..."
    fi 


echo "Command to execute (Step 83): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step83=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step83=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step83=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step83=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 83..."
    fi 
    else 
       echo "SKIP command for step 83..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step83=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step83=.*/Step83=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step83=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step83=.*/Step83=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 83..."
    fi 
    else 
       echo "SKIP command for step 83..."
    fi 


echo "Command to execute (Step 84): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_apm.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step84=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step84=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step84=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step84=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_apm.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 84..."
    fi 
    else 
       echo "SKIP command for step 84..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step84=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step84=.*/Step84=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step84=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step84=.*/Step84=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 84..."
    fi 
    else 
       echo "SKIP command for step 84..."
    fi 


echo "Command to execute (Step 85): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/scheduler_service.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step85=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step85=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step85=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step85=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/scheduler_service.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 85..."
    fi 
    else 
       echo "SKIP command for step 85..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step85=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step85=.*/Step85=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step85=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step85=.*/Step85=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 85..."
    fi 
    else 
       echo "SKIP command for step 85..."
    fi 


echo "Command to execute (Step 86): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_bi_publisher.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step86=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step86=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step86=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step86=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_bi_publisher.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 86..."
    fi 
    else 
       echo "SKIP command for step 86..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step86=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step86=.*/Step86=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step86=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step86=.*/Step86=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 86..."
    fi 
    else 
       echo "SKIP command for step 86..."
    fi 


echo "Command to execute (Step 87): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_j2eeagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step87=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step87=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step87=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step87=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_j2eeagent.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 87..."
    fi 
    else 
       echo "SKIP command for step 87..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step87=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step87=.*/Step87=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step87=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step87=.*/Step87=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 87..."
    fi 
    else 
       echo "SKIP command for step 87..."
    fi 


echo "Command to execute (Step 88): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_webcenter.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step88=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step88=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step88=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step88=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_webcenter.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 88..."
    fi 
    else 
       echo "SKIP command for step 88..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step88=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step88=.*/Step88=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step88=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step88=.*/Step88=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 88..."
    fi 
    else 
       echo "SKIP command for step 88..."
    fi 


echo "Command to execute (Step 89): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_standaloneagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step89=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step89=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step89=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step89=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_standaloneagent.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 89..."
    fi 
    else 
       echo "SKIP command for step 89..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step89=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step89=.*/Step89=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step89=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step89=.*/Step89=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 89..."
    fi 
    else 
       echo "SKIP command for step 89..."
    fi 


echo "Command to execute (Step 90): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application_domain.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step90=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step90=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step90=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step90=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application_domain.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 90..."
    fi 
    else 
       echo "SKIP command for step 90..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step90=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step90=.*/Step90=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step90=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step90=.*/Step90=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 90..."
    fi 
    else 
       echo "SKIP command for step 90..."
    fi 


echo "Command to execute (Step 91): /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_oam.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step91=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step91=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step91=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step91=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service targetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_oam.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 91..."
    fi 
    else 
       echo "SKIP command for step 91..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step91=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step91=.*/Step91=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step91=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step91=.*/Step91=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 91..."
    fi 
    else 
       echo "SKIP command for step 91..."
    fi 


echo "Command to execute (Step 92): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_dbsvc.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step92=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step92=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step92=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step92=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_dbsvc.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 92..."
    fi 
    else 
       echo "SKIP command for step 92..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step92=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step92=.*/Step92=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step92=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step92=.*/Step92=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 92..."
    fi 
    else 
       echo "SKIP command for step 92..."
    fi 


echo "Command to execute (Step 93): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step93=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step93=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step93=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step93=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 93..."
    fi 
    else 
       echo "SKIP command for step 93..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step93=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step93=.*/Step93=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step93=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step93=.*/Step93=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 93..."
    fi 
    else 
       echo "SKIP command for step 93..."
    fi 


echo "Command to execute (Step 94): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step94=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step94=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step94=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step94=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_database.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 94..."
    fi 
    else 
       echo "SKIP command for step 94..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step94=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step94=.*/Step94=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step94=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step94=.*/Step94=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 94..."
    fi 
    else 
       echo "SKIP command for step 94..."
    fi 


echo "Command to execute (Step 95): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_pdb.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step95=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step95=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step95=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step95=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_pdb.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 95..."
    fi 
    else 
       echo "SKIP command for step 95..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step95=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step95=.*/Step95=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step95=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step95=.*/Step95=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 95..."
    fi 
    else 
       echo "SKIP command for step 95..."
    fi 


echo "Command to execute (Step 96): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/cluster.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step96=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step96=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step96=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step96=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/targetType/cluster.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 96..."
    fi 
    else 
       echo "SKIP command for step 96..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step96=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step96=.*/Step96=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step96=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step96=.*/Step96=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 96..."
    fi 
    else 
       echo "SKIP command for step 96..."
    fi 


echo "Command to execute (Step 97): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_exadata.xml -pluginId oracle.sysman.xa -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step97=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step97=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step97=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step97=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_exadata.xml -pluginId oracle.sysman.xa -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 97..."
    fi 
    else 
       echo "SKIP command for step 97..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step97=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step97=.*/Step97=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step97=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step97=.*/Step97=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 97..."
    fi 
    else 
       echo "SKIP command for step 97..."
    fi 


echo "Command to execute (Step 98): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_oam.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step98=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step98=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step98=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step98=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_oam.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 98..."
    fi 
    else 
       echo "SKIP command for step 98..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step98=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step98=.*/Step98=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step98=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step98=.*/Step98=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 98..."
    fi 
    else 
       echo "SKIP command for step 98..."
    fi 


echo "Command to execute (Step 99): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_j2eeagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step99=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step99=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step99=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step99=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_j2eeagent.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 99..."
    fi 
    else 
       echo "SKIP command for step 99..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step99=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step99=.*/Step99=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step99=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step99=.*/Step99=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 99..."
    fi 
    else 
       echo "SKIP command for step 99..."
    fi 


echo "Command to execute (Step 100): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_bi_publisher.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step100=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step100=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step100=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step100=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_bi_publisher.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 100..."
    fi 
    else 
       echo "SKIP command for step 100..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step100=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step100=.*/Step100=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step100=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step100=.*/Step100=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 100..."
    fi 
    else 
       echo "SKIP command for step 100..."
    fi 


echo "Command to execute (Step 101): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/scheduler_service.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step101=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step101=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step101=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step101=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/scheduler_service.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 101..."
    fi 
    else 
       echo "SKIP command for step 101..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step101=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step101=.*/Step101=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step101=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step101=.*/Step101=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 101..."
    fi 
    else 
       echo "SKIP command for step 101..."
    fi 


echo "Command to execute (Step 102): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_apm.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step102=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step102=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step102=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step102=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_apm.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 102..."
    fi 
    else 
       echo "SKIP command for step 102..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step102=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step102=.*/Step102=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step102=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step102=.*/Step102=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 102..."
    fi 
    else 
       echo "SKIP command for step 102..."
    fi 


echo "Command to execute (Step 103): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application_domain.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step103=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step103=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step103=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step103=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application_domain.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 103..."
    fi 
    else 
       echo "SKIP command for step 103..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step103=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step103=.*/Step103=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step103=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step103=.*/Step103=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 103..."
    fi 
    else 
       echo "SKIP command for step 103..."
    fi 


echo "Command to execute (Step 104): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_webcenter.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step104=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step104=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step104=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step104=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_webcenter.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 104..."
    fi 
    else 
       echo "SKIP command for step 104..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step104=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step104=.*/Step104=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step104=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step104=.*/Step104=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 104..."
    fi 
    else 
       echo "SKIP command for step 104..."
    fi 


echo "Command to execute (Step 105): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step105=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step105=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step105=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step105=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/j2ee_application.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 105..."
    fi 
    else 
       echo "SKIP command for step 105..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step105=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step105=.*/Step105=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step105=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step105=.*/Step105=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 105..."
    fi 
    else 
       echo "SKIP command for step 105..."
    fi 


echo "Command to execute (Step 106): /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_standaloneagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step106=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step106=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step106=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step106=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service storeTargetType -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/targetType/oracle_odi_standaloneagent.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 106..."
    fi 
    else 
       echo "SKIP command for step 106..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step106=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step106=.*/Step106=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step106=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step106=.*/Step106=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 106..."
    fi 
    else 
       echo "SKIP command for step 106..."
    fi 


echo "Command to execute (Step 107): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/cluster.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step107=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step107=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step107=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step107=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/cluster.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 107..."
    fi 
    else 
       echo "SKIP command for step 107..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step107=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step107=.*/Step107=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step107=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step107=.*/Step107=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 107..."
    fi 
    else 
       echo "SKIP command for step 107..."
    fi 


echo "Command to execute (Step 108): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step108=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step108=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step108=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step108=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 108..."
    fi 
    else 
       echo "SKIP command for step 108..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step108=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step108=.*/Step108=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step108=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step108=.*/Step108=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 108..."
    fi 
    else 
       echo "SKIP command for step 108..."
    fi 


echo "Command to execute (Step 109): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step109=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step109=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step109=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step109=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_database.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 109..."
    fi 
    else 
       echo "SKIP command for step 109..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step109=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step109=.*/Step109=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step109=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step109=.*/Step109=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 109..."
    fi 
    else 
       echo "SKIP command for step 109..."
    fi 


echo "Command to execute (Step 110): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_pdb.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step110=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step110=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step110=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step110=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_pdb.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 110..."
    fi 
    else 
       echo "SKIP command for step 110..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step110=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step110=.*/Step110=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step110=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step110=.*/Step110=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 110..."
    fi 
    else 
       echo "SKIP command for step 110..."
    fi 


echo "Command to execute (Step 111): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_exadata.xml -pluginId oracle.sysman.xa -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step111=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step111=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step111=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step111=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.xa.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_exadata.xml -pluginId oracle.sysman.xa -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 111..."
    fi 
    else 
       echo "SKIP command for step 111..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step111=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step111=.*/Step111=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step111=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step111=.*/Step111=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 111..."
    fi 
    else 
       echo "SKIP command for step 111..."
    fi 


echo "Command to execute (Step 112): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_odi_standaloneagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step112=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step112=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step112=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step112=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_odi_standaloneagent.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 112..."
    fi 
    else 
       echo "SKIP command for step 112..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step112=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step112=.*/Step112=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step112=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step112=.*/Step112=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 112..."
    fi 
    else 
       echo "SKIP command for step 112..."
    fi 


echo "Command to execute (Step 113): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_oam.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step113=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step113=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step113=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step113=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_oam.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 113..."
    fi 
    else 
       echo "SKIP command for step 113..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step113=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step113=.*/Step113=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step113=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step113=.*/Step113=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 113..."
    fi 
    else 
       echo "SKIP command for step 113..."
    fi 


echo "Command to execute (Step 114): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_webcenter.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step114=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step114=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step114=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step114=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_webcenter.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 114..."
    fi 
    else 
       echo "SKIP command for step 114..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step114=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step114=.*/Step114=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step114=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step114=.*/Step114=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 114..."
    fi 
    else 
       echo "SKIP command for step 114..."
    fi 


echo "Command to execute (Step 115): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/j2ee_application.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step115=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step115=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step115=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step115=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/j2ee_application.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 115..."
    fi 
    else 
       echo "SKIP command for step 115..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step115=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step115=.*/Step115=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step115=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step115=.*/Step115=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 115..."
    fi 
    else 
       echo "SKIP command for step 115..."
    fi 


echo "Command to execute (Step 116): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/j2ee_application_domain.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step116=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step116=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step116=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step116=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/j2ee_application_domain.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 116..."
    fi 
    else 
       echo "SKIP command for step 116..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step116=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step116=.*/Step116=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step116=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step116=.*/Step116=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 116..."
    fi 
    else 
       echo "SKIP command for step 116..."
    fi 


echo "Command to execute (Step 117): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_odi_j2eeagent.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step117=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step117=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step117=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step117=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_odi_j2eeagent.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 117..."
    fi 
    else 
       echo "SKIP command for step 117..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step117=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step117=.*/Step117=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step117=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step117=.*/Step117=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 117..."
    fi 
    else 
       echo "SKIP command for step 117..."
    fi 


echo "Command to execute (Step 118): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/scheduler_service.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step118=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step118=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step118=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step118=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/scheduler_service.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 118..."
    fi 
    else 
       echo "SKIP command for step 118..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step118=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step118=.*/Step118=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step118=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step118=.*/Step118=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 118..."
    fi 
    else 
       echo "SKIP command for step 118..."
    fi 


echo "Command to execute (Step 119): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_bi_publisher.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step119=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step119=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step119=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step119=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_bi_publisher.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 119..."
    fi 
    else 
       echo "SKIP command for step 119..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step119=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step119=.*/Step119=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step119=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step119=.*/Step119=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 119..."
    fi 
    else 
       echo "SKIP command for step 119..."
    fi 


echo "Command to execute (Step 120): /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_apm.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step120=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step120=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step120=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step120=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service default_collection -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/default_collection/oracle_apm.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 120..."
    fi 
    else 
       echo "SKIP command for step 120..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step120=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step120=.*/Step120=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step120=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step120=.*/Step120=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 120..."
    fi 
    else 
       echo "SKIP command for step 120..."
    fi 


echo "Command to execute (Step 121): /u01/appem/oracle/MW/bin/emctl register oms metadata -service systemStencil -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/systemStencil/cluster.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step121=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step121=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step121=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step121=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service systemStencil -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/systemStencil/cluster.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 121..."
    fi 
    else 
       echo "SKIP command for step 121..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step121=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step121=.*/Step121=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step121=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step121=.*/Step121=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 121..."
    fi 
    else 
       echo "SKIP command for step 121..."
    fi 


echo "Command to execute (Step 122): /u01/appem/oracle/MW/bin/emctl register oms metadata -service systemStencil -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/systemStencil/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step122=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step122=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step122=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step122=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service systemStencil -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/systemStencil/rac_database.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 122..."
    fi 
    else 
       echo "SKIP command for step 122..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step122=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step122=.*/Step122=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step122=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step122=.*/Step122=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 122..."
    fi 
    else 
       echo "SKIP command for step 122..."
    fi 


echo "Command to execute (Step 123): /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/DisablePDBaaSCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step123=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step123=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step123=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step123=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/DisablePDBaaSCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 123..."
    fi 
    else 
       echo "SKIP command for step 123..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step123=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step123=.*/Step123=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step123=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step123=.*/Step123=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 123..."
    fi 
    else 
       echo "SKIP command for step 123..."
    fi 


echo "Command to execute (Step 124): /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/EnablePDBaaSRacCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step124=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step124=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step124=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step124=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/EnablePDBaaSRacCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 124..."
    fi 
    else 
       echo "SKIP command for step 124..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step124=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step124=.*/Step124=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step124=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step124=.*/Step124=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 124..."
    fi 
    else 
       echo "SKIP command for step 124..."
    fi 


echo "Command to execute (Step 125): /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/EnablePDBaaSCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step125=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step125=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step125=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step125=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/EnablePDBaaSCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 125..."
    fi 
    else 
       echo "SKIP command for step 125..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step125=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step125=.*/Step125=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step125=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step125=.*/Step125=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 125..."
    fi 
    else 
       echo "SKIP command for step 125..."
    fi 


echo "Command to execute (Step 126): /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/DisablePDBaaSRacCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step126=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step126=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step126=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step126=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service OracleCertifiedTemplate -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/monitoringTemplate/oracleCertified/DisablePDBaaSRacCollectionsTemplate.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 126..."
    fi 
    else 
       echo "SKIP command for step 126..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step126=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step126=.*/Step126=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step126=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step126=.*/Step126=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 126..."
    fi 
    else 
       echo "SKIP command for step 126..."
    fi 


echo "Command to execute (Step 127): /u01/appem/oracle/MW/bin/emctl register oms metadata -service CfwServiceFamily -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/cfw/serviceFamily/mw_service_family.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step127=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step127=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step127=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step127=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service CfwServiceFamily -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/cfw/serviceFamily/mw_service_family.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 127..."
    fi 
    else 
       echo "SKIP command for step 127..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step127=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step127=.*/Step127=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step127=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step127=.*/Step127=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 127..."
    fi 
    else 
       echo "SKIP command for step 127..."
    fi 


echo "Command to execute (Step 128): /u01/appem/oracle/MW/bin/emctl register oms metadata -service assoc -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/assoc/coherence_allowed_pairs.xml -pluginId oracle.sysman.emas -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step128=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step128=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step128=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step128=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service assoc -file /u01/appem/oracle/MW/plugins/oracle.sysman.emas.oms.plugin_13.1.1.0.0/metadata/assoc/coherence_allowed_pairs.xml -pluginId oracle.sysman.emas -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 128..."
    fi 
    else 
       echo "SKIP command for step 128..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step128=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step128=.*/Step128=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step128=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step128=.*/Step128=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 128..."
    fi 
    else 
       echo "SKIP command for step 128..."
    fi 


echo "Command to execute (Step 129): /u01/appem/oracle/MW/bin/emctl register oms metadata -service CfwResourceProvider -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/cfw/resourceProviderType/ssa_pdbaas_resource_provider.xml -pluginId oracle.sysman.ssa -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step129=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step129=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step129=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step129=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service CfwResourceProvider -file /u01/appem/oracle/MW/plugins/oracle.sysman.ssa.oms.plugin_13.1.1.0.0/metadata/cfw/resourceProviderType/ssa_pdbaas_resource_provider.xml -pluginId oracle.sysman.ssa -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 129..."
    fi 
    else 
       echo "SKIP command for step 129..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step129=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step129=.*/Step129=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step129=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step129=.*/Step129=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 129..."
    fi 
    else 
       echo "SKIP command for step 129..."
    fi 


echo "Command to execute (Step 130): /u01/appem/oracle/MW/bin/emctl register oms metadata -service jobTypes -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/jobTypes/SQLScriptSec.xml -pluginId oracle.sysman.db -sysman_pwd %EM_REPOS_PASSWORD%"

grep -l 'Step130=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step130=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step130=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step130=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/bin/emctl register oms metadata -service jobTypes -file /u01/appem/oracle/MW/plugins/oracle.sysman.db.oms.plugin_13.1.1.0.0/metadata/jobTypes/SQLScriptSec.xml -pluginId oracle.sysman.db -sysman_pwd $EM_REPOS_PASSWORD
 
    else 
    echo "SKIP command for step 130..."
    fi 
    else 
       echo "SKIP command for step 130..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step130=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step130=.*/Step130=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step130=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step130=.*/Step130=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 130..."
    fi 
    else 
       echo "SKIP command for step 130..."
    fi 


echo "Command to execute (Step 131): /u01/appem/oracle/MW/OMSPatcher/omspatcher commit -id 24667625 -oh /u01/appem/oracle/MW -skip_patch_ids 24460784,23592229,23178160,23592089  -system_patch_id 24940833 -invPtrLoc /u01/appem/oracle/MW/oraInst.loc"

grep -l 'Step131=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step131=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step131=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step131=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/OMSPatcher/omspatcher commit -id 24667625 -oh /u01/appem/oracle/MW -skip_patch_ids 24460784,23592229,23178160,23592089  -system_patch_id 24940833 -invPtrLoc /u01/appem/oracle/MW/oraInst.loc
 
    else 
    echo "SKIP command for step 131..."
    fi 
    else 
       echo "SKIP command for step 131..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step131=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step131=.*/Step131=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step131=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step131=.*/Step131=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 131..."
    fi 
    else 
       echo "SKIP command for step 131..."
    fi 


echo "Command to execute (Step 132): /u01/appem/oracle/MW/OMSPatcher/omspatcher updateIdenticalPatches  -oh /u01/appem/oracle/MW -skip_patch_ids 24460784,23592229,23178160,23592089  -system_patch_id 24940833 -invPtrLoc /u01/appem/oracle/MW/oraInst.loc"

grep -l 'Step132=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step132=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        grep -l 'Step132=ANALYZED_PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
RESULT=$? 
    if [ $RESULT != 0 ]; then 
    grep -l 'Step132=PASS$' /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM >/dev/null 2>&1 
     RESULT=$? 
    if [ $RESULT != 0 ]; then 
        /u01/appem/oracle/MW/OMSPatcher/omspatcher updateIdenticalPatches  -oh /u01/appem/oracle/MW -skip_patch_ids 24460784,23592229,23178160,23592089  -system_patch_id 24940833 -invPtrLoc /u01/appem/oracle/MW/oraInst.loc
 
    else 
    echo "SKIP command for step 132..."
    fi 
    else 
       echo "SKIP command for step 132..."
    fi 

RESULT=$? 
    if [ $RESULT != 0 ]; then 
        echo "The command failed with error code $RESULT";  
        grep -l "Step132=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step132=.*/Step132=FAIL/g';
        echo "

Script execution has failed. Please refer to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log" for more details
        
Please fix the failures and re-run the same script to complete the patching session.";
	chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;
        return ${RESULT} 
    else 
	grep -l "Step132=" /u01/appem/oracle/MW/.omspatcher_storage/oms_session/oms_session_2016-11-25_13-39-52PM | xargs /u01/appem/oracle/MW/perl/bin/perl -pi -w -e 's/Step132=.*/Step132=PASS/g';
    fi
 
    else 
    echo "SKIP command for step 132..."
    fi 
    else 
       echo "SKIP command for step 132..."
    fi 

echo "

All operations for this script are appended to log file: "/u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log"";

chmod 660 /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log;


} 

((((mainProg;echo $? >&3) | filter /u01/appem/oracle/MW/cfgtoollogs/omspatcher/24940833/omspatcher_2016-11-25_13-39-57PM_deploy.log >&4) 3>&1) | stdintoexitstatus) 4>&1
