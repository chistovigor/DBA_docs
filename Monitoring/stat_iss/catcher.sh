cd /opt/scripts/zabbix/stat_iss/

echo "***** catcher.sh - stat" `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"

sqlplus -S $ONLUSER/$ONLPASS@$ONLBASE<<!
spool ./issue_stat.unl
set heading off feedback off trimspool on serveroutput off
@stat_new;
!

echo "Data unloaded at " `date '+%a %d.%m.%Y-%H:%M:%S'`
date=`/bin/date +%s`
host=s-msk-p-scripts01
key1=stat.mastauthall
key2=stat.visaauthall
key3=stat.visaauthunsuc
key4=stat.mastauthunsuc
key5=stat.arqcunsuc
key6=stat.msg130all
key7=stat.msg410all
key8=stat.deb430all
key9=stat.msg120all
key10=stat.no1vtecherl
key11=stat.no2vtecherl
key12=stat.no1mtecherl
key13=stat.no2mtecherl
key14=stat.no1otecherl
key15=stat.no2otecherl
key16=stat.mantauthall
key17=stat.vinaauthall
key18=stat.vinaauthunsuc
key19=stat.mantauthunsuc




value1=`grep "Mast Auth  All" issue_stat.unl |cut -f2 -d "|"`
value2=`grep "Visa Auth All" issue_stat.unl |cut -f2 -d "|"`
value3=`grep "Visa Auth Unsuccsess" issue_stat.unl |cut -f2 -d "|"`
value4=`grep "Mast Auth Unsuccsess" issue_stat.unl |cut -f2 -d "|"`
value5=`grep "ARQC Problem" issue_stat.unl |cut -f2 -d "|"`
value6=`grep "MsgType 0130 All" issue_stat.unl |cut -f2 -d "|"`
value7=`grep "MsgType 0410 All" issue_stat.unl |cut -f2 -d "|"`
value8=`grep "Interim 0430 All" issue_stat.unl |cut -f2 -d "|"`
value9=`grep "MsgType 0120 All" issue_stat.unl |cut -f2 -d "|"`
value10=`grep "Node_1_V_Tech_Err" issue_stat.unl |cut -f2 -d "|"`
value11=`grep "Node_2_V_Tech_Err" issue_stat.unl |cut -f2 -d "|"`
value12=`grep "Node_1_M_Tech_Err" issue_stat.unl |cut -f2 -d "|"`
value13=`grep "Node_2_M_Tech_Err" issue_stat.unl |cut -f2 -d "|"`
value14=`grep "Node_1_O_Tech_Err" issue_stat.unl |cut -f2 -d "|"`
value15=`grep "Node_2_O_Tech_Err" issue_stat.unl |cut -f2 -d "|"`
value16=`grep "Mant Auth  All" issue_stat.unl |cut -f2 -d "|"`
value17=`grep "Vina Auth All" issue_stat.unl |cut -f2 -d "|"`
value18=`grep "Vina Auth Unsuccsess" issue_stat.unl |cut -f2 -d "|"`
value19=`grep "Mant Auth Unsuccsess" issue_stat.unl |cut -f2 -d "|"`


echo $host $key1 $date $value1 > stat_all.txt
echo $host $key2 $date $value2 >>stat_all.txt
echo $host $key3 $date $value3 >>stat_all.txt
echo $host $key4 $date $value4 >>stat_all.txt
echo $host $key5 $date $value5 >>stat_all.txt
echo $host $key6 $date $value6 >>stat_all.txt
echo $host $key7 $date $value7 >>stat_all.txt
echo $host $key8 $date $value8 >>stat_all.txt
echo $host $key9 $date $value9 >>stat_all.txt
echo $host $key10 $date $value10 >>stat_all.txt
echo $host $key11 $date $value11 >>stat_all.txt
echo $host $key12 $date $value12 >>stat_all.txt
echo $host $key13 $date $value13 >>stat_all.txt
echo $host $key14 $date $value14 >>stat_all.txt
echo $host $key15 $date $value15 >>stat_all.txt
echo $host $key16 $date $value16 >>stat_all.txt
echo $host $key17 $date $value17 >>stat_all.txt
echo $host $key18 $date $value18 >>stat_all.txt
echo $host $key19 $date $value19 >>stat_all.txt



/usr/bin/zabbix_sender -c /etc/zabbix/zabbix_agentd.conf  -T -i stat_all.txt

echo "   "
