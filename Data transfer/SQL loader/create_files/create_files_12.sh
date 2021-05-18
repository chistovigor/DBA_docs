#!/bin/bash

echo start `date`

/dev/null > /mnt/oracle/temp/ONLINE_ARCHIVE/isslog_12.unl

for file in `find /mnt/oracle/temp/ONLINE_ARCHIVE/BaseI/BaseI.12 -name isslog.unl`
do
cat $file >> /mnt/oracle/temp/ONLINE_ARCHIVE/isslog_12.unl
done

echo finish `date`
