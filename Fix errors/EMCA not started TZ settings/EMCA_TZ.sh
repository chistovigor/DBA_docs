#!/bin/bash

. $HOME/.bash_profile
. $HOME/.bashrc

unset TZ
export TZ=Etc/GMT-4 #For Moscow
hostname=`uname -n`
emca_param=`find $ORACLE_HOME -wholename *$hostname*/emd.properties`

#script body

echo emca parameter file is $emca_param
echo emca parameter file backup is ${emca_param}_backup
cp ${emca_param} ${emca_param}_backup -f

echo change file

sed '/agentTZRegion=*/d' $emca_param > ${emca_param}_new
cp ${emca_param}_new $emca_param -f
emctl config agent getTZ
emctl resetTZ agent

echo restart dbconsole

emctl stop dbconsole
emctl start dbconsole
emctl status dbconsole
emctl status agent

exit
