rman target / << EOF
set encryption off;
run {
SET NEWNAME FOR DATABASE TO '/irisdb2_uat/IRISDBDR/data/IRISDBDR/datafile/%U';
SPFILE SET DB_CREATE_ONLINE_LOG_DEST_1='/irisdb2_uat/IRISDBDR/data/IRISDBDR/onlinelog';
SPFILE SET DB_CREATE_ONLINE_LOG_DEST_2='/irisdb2_uat/IRISDBDR/data/IRISDBDR/onlinelog';
restore database;
switch datafile all;
switch tempfile all;
}
exit;
EOF

