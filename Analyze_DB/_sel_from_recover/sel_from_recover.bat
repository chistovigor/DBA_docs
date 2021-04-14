echo off
rem ********************
rem sel_from_recover 4.9
rem ********************

rem Gathering required info
reg query HKLM\SOFTWARE\ORACLE /s >> sel_oracle_key.log
reg query HKLM\SOFTWARE\Wow6432Node\ORACLE /s >> sel_oracle_key2.log

lsnrctl version > sel_listener.log
lsnrctl status >> sel_listener.log
lsnrctl services >> sel_listener.log

echo %path% > sel_set.log

rem Starting SQL
sqlplus /NOLOG @sel_from_recover.sql

rem Deleting unneeded files
del sel_oracle_key.log -y
del sel_oracle_key2.log -y
del sel_listener.log -y
del sel_set.log -y

rem Gathering server info at the end of the log
systeminfo > sel_sysinfo.log
wmic diskdrive get deviceid, model, partitions, size /FORMAT:TABLE >> sel_sysinfo.log
