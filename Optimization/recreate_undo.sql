select name from v$tablespace;
select name from v$datafile;
CREATE SMALLFILE UNDO TABLESPACE "UNDOTBS2" DATAFILE '/mnt/data1/oradata/ULTRALB/UNDOTBS02.DBF' SIZE 100M REUSE AUTOEXTEND ON NEXT 10M MAXSIZE 30000M RETENTION NOGUARANTEE;

на primary

ALTER SYSTEM SET UNDO_TABLESPACE=UNDOTBS2;

на standby

ALTER SYSTEM SET UNDO_TABLESPACE=UNDOTBS2 scope=spfile;

drop tablespace UNDOTBS1 including contents and datafiles;
select name from v$tablespace;
select name from v$datafile;
