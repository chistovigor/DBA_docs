RDBMS Online Patching Aka Hot Patching (Doc ID 761111.1)

Whenever a patch command is executed - by any process, it will write messages to the alert log :

* The alert log will contain the message:

Online patch {patch_name}.pch has been installed|enabled|disabled|removed

All OPatch versions after 11.1.0.6 are Online Patch aware.

The syntax to install an Online Patch is:

opatch apply online -connectString <SID>:<USERNAME>:<PASSWORD>:<NODE>

example:

$ opatch apply online -connectString db11202:sys:oracle -invPtrLoc /u01/app/oracle/product/11.2.0/dbhome_1/oraInst.loc

When multiple databases are running from the same ORACLE_HOME and You need to apply online patch on each database the commands to do it are as following:

- Apply the online patch to the first database:

opatch apply online -connectString OP1:sys:manager:

- Then enable the fix for the other SIDs as following:

opatch util enableonlinepatch -connectString OP2:sys:manager: -id 10188727 (NOTE: use the 'patch id' (not the 'Unique Patch ID')

If you want disable or remove the fix for some SIDs, You need to use the opatch util DisableOnlinePatch  as following :

opatch util DisableOnlinePatch -connectString <SID>:<USERNAME>:<PASSWORD>:<NODE> -ph Patch location

-ph - Specify the valid patch directory area. This utility will disable the given patch in the database instances.

better way to check if a patch is online is to use the following command

$ cd <PATCH_TOP>/10188727
$ opatch query -all

result:

...
Patch is an online patch: true

(if false then online patching is impossible)

Using "opatch" you can rollback the patch

opatch rollback -id <patchID> -connectString <SID>:<USERNAME>:<PASSWORD>:<NODE1>,<SID2>:<USERNAME>:<PASSWORD>:<NODE2>, ...

()The USERNAME and PASSWORD are those of a user that has SYSDBA privileges. The USERNAME and PASSWORD can be left blank if the OS user applying the patch has the SYSDBA privilege. Also the NODE is optional if the patch is being applied locally). Using opatch does not remove the patch, it simply disables it (rolls it back) and removes the patch entry from the inventory. This behavior may change in the future.

Example:

$ opatch rollback -id 10188727 -connectString db11202:sys:oracle -invPtrLoc /u01/app/oracle/product/11.2.0/dbhome_1/oraInst.loc
Invoking OPatch 11.2.0.1.4

!!! Online Patching Best Practices

It is strongly recommended to rollback all online patches and replace them with regular (offline) patches on next instance shutdown
Online patches should be used when the patch needs to be applied urgently and a downtime cannot be scheduled. IMPORTANT: It is strongly recommended to rollback all online patches and replace them with regular (offline) patches on next instance shutdown
Apply one instance at a time
When rolling back online patches, ensure all patched instances are included
Avoids the dangerous and confusing situation of having different software across instances using the same $ORACLE_HOME
Assess memory impact on a test system before deploying to production
Example: pmap command
Never remove $ORACLE_HOME/hpatch directory