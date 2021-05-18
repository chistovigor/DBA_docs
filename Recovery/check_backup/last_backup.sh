#!/bin/bash

last_backup=`sqlplus / as sysdba < last_backup.sql | awk '(NR == 12)'`

echo "last successful backup" ${last_backup}
