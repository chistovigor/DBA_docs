/*
A full database copy will be performed during the first backup. Subsequently, an incremental backup to disk will be performed every day. The backups on disk will be retained so that you can always perform a full database recovery or a point-in-time recovery to any time within the past day.
*/

run {
allocate channel oem_disk_backup1 device type disk;
recover copy of database with tag 'ORA_OEM_LEVEL_0';
backup incremental level 1 cumulative  copies=1 for recover of copy with tag 'ORA_OEM_LEVEL_0' database;
}