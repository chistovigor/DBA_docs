#!/bin/bash

path=/mnt/oracle/temp/ONLINE_ARCHIVE/BaseI/BaseI.14
file_name=isslog.unl
result_file=/mnt/oracle/temp/ONLINE_ARCHIVE/isslog_14.unl

#set this variable to break at given file
break_file=336

echo start `date`

rm $result_file
touch $result_file

for file in `find $path -name $file_name`
do
if [ `echo ${file}` == `echo $path/$break_file/$file_name` ]
 then
  echo break at file $file
  break
fi
cat $file >> $result_file
done

echo finish `date`
