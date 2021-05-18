SET COMPRESSION ALGORITHM 'MEDIUM' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD FALSE;
configure controlfile autobackup off;
run {
allocate channel oem_backup_disk1 type disk format '/mnt/oracle/backup/rman/%Y%M%D/BACKUP_%Y%M%D_%U.BCK' maxpiecesize 4 G;
allocate channel oem_backup_disk2 type disk format '/mnt/oracle/backup/rman/%Y%M%D/BACKUP_%Y%M%D_%U.BCK' maxpiecesize 4 G;
allocate channel oem_backup_disk3 type disk format '/mnt/oracle/backup/rman/%Y%M%D/BACKUP_%Y%M%D_%U.BCK' maxpiecesize 4 G;
backup filesperset = 50 force  noexclude  as COMPRESSED BACKUPSET tag 'DB_FULL_curr_date_variable' database;
backup filesperset = 50 as COMPRESSED BACKUPSET tag '%Y%M%D' archivelog all not backed up delete all input;
release channel oem_backup_disk1;
release channel oem_backup_disk2;
release channel oem_backup_disk3;
}
configure controlfile autobackup on;
run {
allocate channel oem_backup_disk1 type disk format '/mnt/oracle/backup/rman/%Y%M%D/CONTROLFILE_%Y%M%D_%U.BCK' maxpiecesize 1 G;
allocate channel oem_backup_disk2 type disk format '/mnt/oracle/backup/rman/%Y%M%D/CONTROLFILE_%Y%M%D_%U.BCK' maxpiecesize 1 G;
backup filesperset = 50 force  noexclude  as COMPRESSED BACKUPSET tag 'controlfile_curr_date_variable' current controlfile;
release channel oem_backup_disk1;
release channel oem_backup_disk2;
}
allocate channel for maintenance type disk;
delete noprompt obsolete device type disk;
release channel;


run
{
 set CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '$backup_folder/$daily_folder/CTL_AND_SPFILE_AUTO_%F.BCK';
 allocate channel oem_backup_disk1 type disk format '$backup_folder/$daily_folder/CONTROLFILE_%T_%U.BCK' maxpiecesize 1 G;
 allocate channel oem_backup_disk2 type disk format '$backup_folder/$daily_folder/CONTROLFILE_%T_%U.BCK' maxpiecesize 1 G;
 backup filesperset = 50 force noexclude as COMPRESSED BACKUPSET tag 'controlfile_$daily_folder' current controlfile;
 release channel oem_backup_disk1;
 release channel oem_backup_disk2;
}
allocate channel for maintenance type disk;
delete noprompt obsolete device type disk;
release channel;
spool log off
exit