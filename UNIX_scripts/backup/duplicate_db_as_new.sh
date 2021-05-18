export ORACLE_SID=dmuat04
rman auxiliary / << EOF
CONFIGURE DEVICE TYPE DISK PARALLELISM 8 BACKUP TYPE TO BACKUPSET;
duplicate database to dmuat04  backup location '/oradata/w4uat16/data/dmuat03_rmancbkp_jan4' NOFILENAMECHECK;
exit;
EOF
