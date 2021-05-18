1) Download latest OPatch utility to a temporary directory.
For each Oracle RAC database home and the GI home that are being patched, run the following commands as the home owner to extract the OPatch utility.

$ unzip <OPATCH-ZIP> -d <ORACLE_HOME>
$ <ORACLE_HOME>/OPatch/opatch version
The version output of the previous command should be 12.1.0.1.7 or later.

2) 2.1.2 OCM Configuration (do this only once at each server)

The OPatch utility will prompt for your OCM (Oracle Configuration Manager)
response file when it is run. You should enter a complete path of OCM response file 
if you already have created this in your environment. OCM response file is required and is not optional.

If you do not have the OCM response file (ocm.rsp), see the following My Oracle Support Document 966023.1

3) Validation of Oracle Inventory

Before beginning patch application, check the consistency of inventory information for GI home
and each database home to be patched. Run the following command as respective Oracle home owner to check the consistency.

$ <ORACLE_HOME>/OPatch/opatch lsinventory -detail -oh <ORACLE_HOME>

4) Unzip the patch as grid home owner except for installations that do not have any grid homes.
For installations where this patch will be applied to the Database home only, the patch 
needs to be unzipped as the database home owner.

$ unzip p22243551_121020_<platform>.zip

as root user run: chmod -R 777 <UNZIPPED_PATCH_LOCATION>/

5) Run OPatch Conflict Check (example for Patch for Engineered Systems and DB In-Memory 12.1.0.2.160119 (Jan2016) 22243551)

For Grid Infrastructure Home, as home user:

% $ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir <UNZIPPED_PATCH_LOCATION>/22243551/21949015
% $ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir <UNZIPPED_PATCH_LOCATION>/22243551/22329617 
% $ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir <UNZIPPED_PATCH_LOCATION>/22243551/21948341
% $ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir <UNZIPPED_PATCH_LOCATION>/22243551/21436941 

For Database home, as home user:

% $ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir <UNZIPPED_PATCH_LOCATION>/22243551/21949015
% $ORACLE_HOME/OPatch/opatch prereq CheckConflictAgainstOHWithDetail -phBaseDir <UNZIPPED_PATCH_LOCATION>/22243551/22329617

6) Run OPatch SystemSpace Check (example for Patch for Engineered Systems and DB In-Memory 12.1.0.2.160119)

Check if enough free space is available on the ORACLE_HOME filesystem for the patches to be applied as given below:

For Grid Infrastructure Home, as home user:

Create file /tmp/patch_list_gihome.txt with the following content:

% cat /tmp/patch_list_gihome.txt
<UNZIPPED_PATCH_LOCATION>/22243551/21436941
<UNZIPPED_PATCH_LOCATION>/22243551/21948341
<UNZIPPED_PATCH_LOCATION>/22243551/22329617
<UNZIPPED_PATCH_LOCATION>/22243551/21949015
Run the opatch command to check if enough free space is available in the Grid Infrastructure Home:

% $ORACLE_HOME/OPatch/opatch prereq CheckSystemSpace -phBaseFile /tmp/patch_list_gihome.txt
For Database home, as home user:

Create file /tmp/patch_list_dbhome.txt with the following content:

% cat /tmp/patch_list_dbhome.txt
<UNZIPPED_PATCH_LOCATION>/22243551/22329617 
<UNZIPPED_PATCH_LOCATION>/22243551/21949015
Run opatch command to check if enough free space is available in the Database Home:

% $ORACLE_HOME/OPatch/opatch prereq CheckSystemSpace -phBaseFile /tmp/patch_list_dbhome.txt
The command output reports pass and fail messages as per the system space availability:

If OPatch reports Prereq "checkSystemSpace" failed., then cleanup the system space
as the required amount of space is not available.

If OPatch reports Prereq "checkSystemSpace" passed., then no action is needed. Proceed with patch installation.

7) One-off Patch Conflict Detection and Resolution

The following commands check for conflicts in both the 12.1 GI home and the 12.1 DB homes.

In case you are applying the patch, run this command (!!!) as root user:

GRID_HOME/OPatch/opatchauto apply <UNZIPPED_PATCH_LOCATION>/22243551 -analyze

In case you are rolling back the patch, run this command:
#GRID_HOME/OPatch/opatchauto rollback <UNZIPPED_PATCH_LOCATION>/22243551 -analyze

Смотрим сформированный лог, в нем ссылки на логи для GRID_HOME и ORACLE_HOME, в которых указаны детали выполнения

8) opatchauto

Add the directory containing the opatchauto to the $PATH environment variable. For example:

$ export PATH=$PATH:<GI_HOME>/OPatch
To patch the GI home and all Oracle RAC database homes of the same version:

As (!!!) root user, execute the following command on each node of the cluster:
opatchauto apply <UNZIPPED_PATCH_LOCATION>/22243551 -ocmrf <ocm response file>

#example: 
#opatchauto apply /u01/app/oracle/patches/12.1.0.2.160119_JAN2016/22243551 -ocmrf /u01/app/12.1.0.2/grid/OPatch/ocm.rsp

To roll back the patch from the Oracle RAC database home:
# opatchauto rollback <UNZIPPED_PATCH_LOCATION>/22243551 -oh <oracle_home1_path>,<oracle_home2_path> 

OPatchAuto calls datapatch to complete post patch actions
upon installation of the binary patch and restart of the database. (10) 

sqlplus / as sysdba
@utlrp.sql
exit

9) If setup is not suceeded, then as root user MANUALLY start patched cluster: crsctl start crs

Check all services (must be online): 
crsctl check crs
when all online check state of resources (must be ONLINE, details: STABLE):
crsctl stat res -t

10) Manually loading Modified SQL Files into the Database (Standalone DB) - (!!!) done automaticaly when using opatchauto

(if DB is not started already)
sqlplus / as sysdba
startup
exit

cd $ORACLE_HOME/OPatch
./datapatch -verbose

sqlplus / as sysdba
@utlrp.sql
exit

11) Select patches in from DB

set linesize 250
set pagesize 10000

select patch_id, patch_uid, version, status, description from dba_registry_sqlpatch;

WITH a AS (SELECT dbms_qopatch.get_opatch_lsinventory patch_output FROM DUAL)
SELECT x.*
  FROM a,
       XMLTABLE ('InventoryInstance/patches/*'
                 PASSING a.patch_output
                 COLUMNS patch_id NUMBER PATH 'patchID',
                         patch_uid NUMBER PATH 'uniquePatchID',
                         description VARCHAR2 (80) PATH 'patchDescription',
                         applied_date VARCHAR2 (30) PATH 'appliedDate',
                         sql_patch VARCHAR2 (8) PATH 'sqlPatch',
                         rollbackable VARCHAR2 (8) PATH 'rollbackable') x order by 4 desc;
						 
-- Resolve problems

1) ./datapatch -verbose 
fails with error: ORA-20008: Timed out, Job Load_opatch_inventory_2execution time is more than 120Secs

try 

alter session set events '18219841 trace name context forever'; 
first (before select dbms_sqlpatch.verify_queryable_inventory from dual;)

when finish: alter session set events '18219841 trace name context off';

select dbms_sqlpatch.verify_queryable_inventory from dual; - the same error

https://chandlerdba.wordpress.com/tag/verify_queryable_inventory/

--during execution:

select job_name,state,job_action from dba_scheduler_jobs where job_name like '%PATCH%' order by job_name;

If '18219841 trace' not helps, then:

1.1 cp -p $ORACLE_HOME/QOpatch/qopiprep.bat $ORACLE_HOME/QOpatch/qopiprep.bat.sav
1.2 $ORACLE_HOME/OPatch/opatch lsinventory -xml $ORACLE_HOME/QOpatch/xml_file.xml -retry 0 -invPtrLoc $ORACLE_HOME/oraInst.loc >> $ORACLE_HOME/QOpatch/stout.txt
1.3 echo "UIJSVTBOEIZBEFFQBL" >> $ORACLE_HOME/QOpatch/xml_file.xml
1.4 comment all lines except: echo `cat $ORACLE_HOME/QOpatch/xml_file.xml` in qopiprep.bat file
1.5 select dbms_sqlpatch.verify_queryable_inventory from dual; - runs OK
1.6 run ./datapatch -verbose
1.7 rollback changes (remove $ORACLE_HOME/QOpatch/xml_file.xml and $ORACLE_HOME/QOpatch/stout.txt)








