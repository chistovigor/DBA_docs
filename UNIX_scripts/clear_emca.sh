#!/bin/bash
# clr_alrts.sh
# Delete old stale alert messages interactively from OEM.
# Usage: clr_alrts.sh
# Run as sys
. $HOME/.bash_profile

function GetNumLines
{
echo "set heading off linesize 200 pagesize 0 echo off verify off feedback off
select count(*) from sysman.mgmt_current_severity;
quit
" | sqlplus -s "/ as sysdba" | sed 's/^\[ \t]*//;s/\[ \t]*$//'
}
NUMLINES=$(GetNumLines)
let i=1
while \[ "$i" -le "$NUMLINES" ]
do
echo "i = $i"
function GetMsg
{
echo "set heading off linesize 300 pagesize 0 echo off verify off feedback off
select message from sysman.mgmt_current_severity;
quit
" | sqlplus -s "/ as sysdba" | head -"$i" | tail -1 | sed "s/$/'/" | sed "s/^/'/"
}
MSG=$(GetMsg)
function GetCmd
{
echo "set heading off linesize 300 pagesize 0 echo off verify off feedback off
select 'exec sysman.em_severity.delete_current_severity('''||target_guid||''','''||metric_guid||''','''||key_value||''')' mcs from sysman.mgmt_current_severity where message=${MSG};
quit
" | sqlplus -s "/ as sysdba"
}
CMD=$(GetCmd)
echo ' '
echo "Do you want to delete the following OEM alert message?"
echo ' '
echo "$MSG"
echo ' '
echo "$CMD"
echo ' '
select yn in "Yes" "No"; do
case $yn in
Yes )
echo "$CMD;
quit
" | sqlplus -s "/ as sysdba"; break;;
No ) break;;
esac
done
let i="$i"+1
echo "i=$i"
done

# --- end of script --- 
