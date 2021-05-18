echo off
rem ***********************************
rem ***rm_backup_weekly_compress 1.1***
rem ***********************************

rem ***Установка имени целевой БД***
Set _TargetName=UNOC

rem ***Установка SYS пароля целевой БД***
Set _SysPsw=DUO

rem ***Установка папки резервного копирования***
Set _BackupDir=G:\BACKUP

rem ***Установка кол-ва дней, за которые возможно восстановить БД (1 - один день)***
Set _red_int=7

rem ****************************
rem ****************************
rem ****************************
rem ****************************
rem ****************************
rem ****************************
rem ****************************

rem script name
Set _ScriptName=rm_backup_weekly_compress_%_TargetName%
rem operation name
Set _OperName=Database Compressed Backup Level 0 

Set _Date=%date%
If "%_Date%A" LSS "A" (Set _NumTok=1-3) Else (Set _NumTok=2-4)
:: Default Delimiter of TAB and Space are used
For /F "TOKENS=2*" %%A In ('REG QUERY "HKCU\Control Panel\International" /v iDate') Do Set _iDate=%%B
For /F "TOKENS=2*" %%A In ('REG QUERY "HKCU\Control Panel\International" /v sDate') Do Set _sDate=%%B
IF %_iDate%==0 For /F "TOKENS=%_NumTok% DELIMS=%_sDate% " %%B In ("%_Date%") Do Set _fdate=%%D%%B%%C
IF %_iDate%==1 For /F "TOKENS=%_NumTok% DELIMS=%_sDate% " %%B In ("%_Date%") Do Set _fdate=%%D%%C%%B
IF %_iDate%==2 For /F "TOKENS=%_NumTok% DELIMS=%_sDate% " %%B In ("%_Date%") Do Set _fdate=%%B%%C%%D
Set _Today=%_fdate:~0,4%%_fdate:~4,2%%_fdate:~6,2%


rem создание папки логов
md %_BackupDir%\logs_%_Today%
rem создание папки бекапов
md %_BackupDir%\%_Today%
rem пересоздание файла скрипта
del %_ScriptName%.rcv
fsutil file createnew %_ScriptName%.rcv 0


rem задание команд RMAN
echo CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF %_red_int% DAYS; >> "%_ScriptName%.rcv"
echo CONFIGURE CONTROLFILE AUTOBACKUP OFF; >> "%_ScriptName%.rcv"
echo show all; >> "%_ScriptName%.rcv"
echo ### Making Archivelog Backup >> "%_ScriptName%.rcv"
echo # AND >> "%_ScriptName%.rcv"
echo ### Making database backup Level 0 >> "%_ScriptName%.rcv"
echo # in RUN block >> "%_ScriptName%.rcv"
echo RUN >> "%_ScriptName%.rcv"
echo { >> "%_ScriptName%.rcv"
echo backup spfile format '%_BackupDir%\%_Today%\spfile_%%T_%%d_%%U.rm'; >> "%_ScriptName%.rcv"
echo backup current controlfile format '%_BackupDir%\%_Today%\controlfile_%%T_%%d_%%U.rm'; >> "%_ScriptName%.rcv"
echo backup as compressed backupset incremental level 0 database include current controlfile PLUS ARCHIVELOG format '%_BackupDir%\%_Today%\archlogs_db0_%%T_%%d_%%U.rm' SKIP INACCESSIBLE; >> "%_ScriptName%.rcv"
echo } >> "%_ScriptName%.rcv"
echo # >> "%_ScriptName%.rcv"
echo ### Listing and Clearing Metadata >> "%_ScriptName%.rcv"
echo crosscheck backup; >> "%_ScriptName%.rcv"
echo crosscheck archivelog all; >> "%_ScriptName%.rcv"
echo report obsolete; >> "%_ScriptName%.rcv"
echo list expired archivelog all; >> "%_ScriptName%.rcv"
echo delete noprompt archivelog all completed before 'sysdate-%_red_int%'; >> "%_ScriptName%.rcv"
echo delete noprompt backupset completed before 'sysdate-%_red_int%'; >> "%_ScriptName%.rcv"
echo list backup by file; >> "%_ScriptName%.rcv"
rem окончание задания команд RMAN


rem создание лога операции
echo ================== >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"
echo Запуск RMAN >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"
echo Операция - %_OperName% >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"
time/t >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"
date/t >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"
echo Строка подключения целевой БД - SYS/%_SysPsw%@%_TargetName% >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"
rem echo Строка подключения БД каталога - %_RecUser%/%_RecPsw%@%_RecName% >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"

rem строка запуска RMAN
rman log='%_BackupDir%\logs_%_Today%\%_ScriptName%_%_Today%.log' target sys/%_SysPsw%@%_TargetName% nocatalog @%_ScriptName%.rcv
 
 
rem завершение лога операции
echo Окончание RMAN >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"
time/t >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"
date/t >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"
echo ================== >> "%_BackupDir%\logs_%_Today%\%_Today%__rman.log"
copy %_BackupDir%\logs_%_Today%\%_ScriptName%_%_Today%.log %_BackupDir%\rman_zabbix.log /Y

