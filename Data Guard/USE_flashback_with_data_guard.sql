--FLASHBACK MUST be enables on both PRIMARY and STANDBY

select database_role,flashback_on from v$database;

--Step 1 Determine the SCN before the RESETLOGS operation occurred.

On the primary database, use the following query to obtain the value of the system change number (SCN) that is 2 SCNs before the RESETLOGS operation occurred on the primary database:

SELECT TO_CHAR(RESETLOGS_CHANGE# - 2) FROM V$DATABASE;

TO_CHAR(RESETLOGS_CHANGE#-2)
----------------------------------------
15629737644

--Step 2 Obtain the current SCN on the standby database.

On the standby database, obtain the current SCN with the following query:

SELECT TO_CHAR(CURRENT_SCN) FROM V$DATABASE;


TO_CHAR(CURRENT_SCN)
----------------------------------------
15629780927

--Step 3 Determine if it is necessary to flash back the database.

If the value of CURRENT_SCN is larger than the value of resetlogs_change# - 2, issue the following statement to flash back the standby database.

FLASHBACK STANDBY DATABASE TO SCN resetlogs_change# -2;
