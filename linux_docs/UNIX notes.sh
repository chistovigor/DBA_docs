Версия RHEL

cat /etc/redhat-release

Версия SLES

cat /etc/issue

изменение релиза (для ПО, которое не устанавливается на данный релиз)

Red Hat Enterprise Linux Server release 6.5 (Santiago)
меняем на
Red Hat Enterprise Linux Server release 5.6 (Tikanga)

Поиск в history по нажатию клавиш вверх/вниз (работает в bash):

добавляем в файл:
cat .inputrc 
"\e[A": history-search-backward
"\e[B": history-search-forward

Добавить пользователя oracle в группу oinstall

usermod -a -G oinstall oracle

Добавление репозитория 

rhnreg_ks --serverUrl=https://kstart.raiffeisen.ru/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=82-Processing_Department_Key --force

CPU info Solaris

psrinfo -pv

--display all the logical/virtual CPUs
psrinfo -v

--command for physical core count in Solaris for M* T* CPUs (cores licenced for Oracle products):

echo "`kstat -m cpu_info | grep -w core_id | wc -l`/8" | bc -l

-- memory allocation for Solaris

echo "::memstat" | mdb -k

-- sort by process/user

prstat -a -s size
prstat -s rss
prstat -t

--User Memory Usage : lists User Memory usage of all processes (except PID 0,2,3)

pmap -x /proc/* > /tmp/pmap-x
egrep "[0-9]:|^total" /tmp/pmap-x

--allocation of memory by user

ps -e -o rss= -o user= |awk '{s[$2]+=$1} END {for (i in s)print i,s[i]}'

-- DAX usage for Solaris (see MOS Doc ID 2174762.1) https://community.oracle.com/docs/DOC-932216

--before 11.3 SRU 19 
busstat -a -w dax,pic0=DAX_SCH_ccb_fetch 5
-- after 11.3 SRU 19 
daxstat -axd
daxinfo

Enable DAX usage monitoring in OS (see https://jira.network.ae/jira/browse/INFRA-1284):

svcadm disable svc:/system/rad:local
svcadm enable svc:/system/rad:remote
svcadm enable svc:/system/rad:local

Прервать выполнение команды CTRL+Z

Включение x сервера для SSH 

в /etc/ssh/sshd_config ставим X11Forwarding yes

service sshd restart

разрешить порт udp/177 на FW, в PUTTY включить SSH X11

Использование массивов переменных в bash

export LOGS_DIR=('/aa/bb' '/cc/dd')
#1 значение массива
echo ${LOGS_DIR[0]}
#2 значение массива
echo ${LOGS_DIR[1]}
#вывод всех элементов массива
for item in ${LOGS_DIR[*]}; do printf "%s\n" $item; done
#или
for item in ${LOGS_DIR[*]}; do echo $item; done

Вывести статус выполнения последней команды

echo $?

Вывод информации о shared сегменте памяти:

ipcs -m -i 322797583

Выключение сервера

shutdown -h now (или poweroff)

перезагрузка

shutdown -r now

Информация о сети:

ip addr
ip link
ifconfig -a (если нет infiniband)

Установить переменные окружения (точка, пробел, имя файла)

. name_of_file_with_env_variables

Вставить/копировать текст в теминале
SHIFT+INS, CTRL+INS

Создать каталог 
mkdir

Скопировать каталог 

cp -r имя-папки имя-копии-папки
затем (если нужно) удалить
rm -r имя-папки

Редактирование файлов vim 
i - редактирование, C - edit, ZZ - save&quit, ZQ - quit, dG - удалить все до конца

vi in Solaris
i - edit, ESC - cancel edit, o - add new line (NOT in edit mode), x - remove symbol under cursor
delete all lines: ESC, gg, dG

Удаление компонентов
yum либо rpm -e 

Просмотр парольной политики для пользователя 

chage –l oracle

отключение устаревания пароля

chage -I -1 -m 0 -M 99999 -E -1 oracle

Сбор диагностики ОС:

sosreport (от имени root)

Corrupt data faults information in Solaris:

fmadm list

Поиск файлов, содержащих текст по маске (в текущем каталоге и всех подкаталогах)

grep -R --include="*.log" "ORA-" ./

поиск в результатах по маске

grep -R --include="*.log" "ORA-" ./ | grep "20170[8|9]"

solaris:
/usr/gnu/bin/grep -R --include="alert_way4db1.log" "ORA-07445" ./

Удаление всех файлов старше 30 дней

find /path/to/files* -mtime +30 -exec rm {} \;

для файлов *.aud в каталоге /mnt/data1/admin/ULTRALB/adump
find /mnt/data1/admin/ULTRALB/adump -name \*.aud -mtime +60 -exec rm {} \;
find -mtime +5 -name "*aud*" -exec rm {} \;

--solaris delete traces in PARTICULAR folder
find . -ctime +5 -name "way4db_ora_*" -exec rm {} \;

Удаление большого кол-ва файлов из каталога (при возникновении ошибки /bin/rm: Argument list too long):
cd /directory/
find /directory -name "*.txt" | xargs -i rm {}
for i in /u01/app/oracle/product/12.1.0.2/dbhome_1/rdbms/audit/*.gz; do rm -rf $i; done

Отключение сервисов
chkconfig <service name> off

Просмотр ответа по запросу к URL (http,https)

curl <адрес>
пример  curl http://172.20.16.187:9702/analytics/saw.dll?bieehome

Просмотр запущенных процессов по имени:

ps -ef | grep -i osw|grep -v grep
ps -e -o pid,args --forest — вывести PIDы и процессы в виде дерева

В HPUX:

ps -ef | grep pmon

Дерево процессов для пользователя: pstree

Просмотр сколько времени процесс уже работает:

ps -p 97301 -o etime=
97301 - pid процесса

Трассировка конкретного процесса:

найдите pid (например) RSM0 процесса БД spur ( pgrep -fl rsm0 ), и запустите strace -ttfo /tmp/rsm0.rdtex -p <pid>

strace -p <pid> -o /tmp/rman_trace.1

or

truss -eafo /tmp/truss_command.out <any command with parameters>

подсчет событий ожидания для процесса:

strace -p <pid>  -c

Просмотр сколько времени работают все процессы (тут в выводе 304-18:20:55 первое число - дни с момента запуска)

ps -eo pid,cmd,etime

С какими файлами работает пользователь

lsof -u username

Кто использует файл

lsof /path/to/file

Solaris

pfiles /proc/* | grep alert

Анализ активности системы по времени

sar - данные за каждые 10 минут последних суток
pmap process_ID - детализация используемой процессом памяти
top - процессы в системе
free - использование памяти
vmstat - использование виртуальной памяти
htop - графическое представление top

vmstat 10 - обновление раз в 10 секунд, смотрим на so - если растет и большие значения - значит в системе своппинг
sar -n DEV 10 - анализ активности сети (sar -n DEV 10 10 - то же самое 10 раз)
sar -p 10 - анализ активности CPU
sar -n DEV -f /var/log/sa/sa08 -s 18:23:00 10 10 - за период времени и конкретную дату
sar -p -f /var/log/sa/sa08 -s 00:00:00 -e 06:00:01 анализ активности процессоров за период времени и конкретную дату (08 число текущего месяца, с 00-00 до 06-00)


Анализ активности дисковой подсистемы

iostat -dhm
sar -bdp 1

Анализ общей активности в системе (по разным ресурсам)

sar -f /var/log/sa/sa14 -s 22:00:01 -e 23:59:59 -BqrRSwW

сопоставление выведенных результатов с точками монтирования в системе

ls -lrt /dev/mapper/
df -lh
lsblk

Найти определенные процессы и завешить их

kill `ps aux | grep 'oracleULTRADB (LOCAL=NO)' | grep -v grep | awk '{print $2}'`
или (если не завершаются)
kill -9 `ps aux | grep 'oracleULTRADB (LOCAL=NO)' | grep -v grep | awk '{print $2}'`

Поиск пользователя и процесса, использующих файл
fuser <filename> -u
ps -ef | grep <найденный ID процесса>

Свободное место на точках монтирования
df -h

Версия Linux
cat /etc/issue
Ядро cat /proc/version

Установлен ли пакет и какой версии
rpm -qa package_name

Безопасное удаление старых ядер

yum install yum-utils
rpm -qa kernel

Поиск установленных пакетов обновлений безопасности от вендора в RHEL:

yum updateinfo list security installed | grep RHSA-2015:1221

Оставить 2 последних ядра (включая текущее):

package-cleanup --oldkernels --count=2

для применения этой настройки на постоянной основе:
vim /etc/yum.conf

installonly_limit=2

Запущенные текущим пользователем процессы
ps -la

Удалить каталог с файлами
rm -rvf

Перемещение каталога (файла)
mv источник приемник

Применение конфига после изменения параметров ядра
sysctl -p

Проверка подключения к AD

ldapsearch -x -b "cn=srv-processing,dc=raiffeisen,dc=ru" -H ldap://raiffeisen.ru:389 -LLL -D "CN=ruatest24,OU=MSK,OU=COMMON,OU=_Users,DC=raiffeisen,DC=ru" -W '(objectClass=*)'

ввести пароль - P@ssw0rd48

Проверка доступности LDAP (AD) сервера (можно указать порт явно через флаг -p , если он отличается от стандартного 389)

ldapsearch -v -x -b "dc=wallen,dc=local" -s sub "objectclass=*" -h 172.20.18.200

Обновление Vmvare tools RHEL

1) Монтировать CD с дистрибутивом Vmvare tools в консоли управления Vmvare в ОС виртуальной машины
2) mkdir /mnt/cdrom
3) mount /dev/cdrom /mnt/cdrom
4) Распаковаваем инсталлятор (/mnt/cdrom/VMwareTools-x.x.x-yyyy.tar.gz) с /mnt/cdrom в /tmp/destination/
5) cd vmware-tools-distrib
6) ./vmware-install.pl 

Ротация логов - logrotate

запускается по расписанию в /etc/cron.daily/logrotate
конфигурация в /etc/logrotate.conf
настройки для отдельных логов в /etc/logrotate.d

проверка работы - запуск с настроенным файлом, например:

logrotate /etc/logrotate.d/oracle -v

И в файле /var/lib/logrotate.status

Пример настройки для ротации syslog

/var/log/cron
/var/log/maillog
/var/log/messages
/var/log/secure
/var/log/spooler
{
 rotate 4
 size 10M
 compress
 delaycompress
 create
 missingok
 sharedscripts
 postrotate
  /bin/kill -HUP `cat /var/run/syslogd.pid 2> /dev/null` 2> /dev/null || true
 endscript
}

Отключить подсветку WIM

:nohlsearch

Размер файлов
ls -l

Показать время файла с точностью до секунды
ls -al --full-time

Подсчет строк,слов,символов

wc -l файл<CR> (число строк)
wc -w файл<CR> (число слов)
wc -c файл<CR> (число символов)

Операции в датой

текущая дата в нужном формате
date +%Y%m%d

Вычесть из текущей даты
date --date "now -4 month" +%Y%m
date --date "now -30 minute" +"%m/%d %k:%M"

каталогов 
du -lh
du -ah - с выводом размера файлов
du --si --max-depth=1 /usr/oracle/app

Solaris

du -sm *
du -hs * | gsort -h

размер на каждой из ФС:
du -sh * | sort -h

Архивация файлов 

zip -9 /mnt/oracle/backup/dump/all_archive_db_dumps/export_router_201306.zip export_router_201306.LOG synchro_router.cmd ROUTER_ANNUAL_201306.EXP > /mnt/oracle/backup/dump/all_archive_db_dumps/zip_router_201306.log
zip -9r zipfile.zip catalog - упаковать каталог
zip -9m zipfile.zip filename - упаковать файл, затем удалить его

ALL files by mask WITHOUT directories in one zip file (windows)

zip test.zip -rj . -i "*.sh"

tar -cvf file.tar /full/path - создать .tar
tar -czvf file.tar.gz /full/path - создать .tar.gz (архив)
tar -cjvf file.tar.bz2 /full/path - создать .tar.bz2 (архив)

распаковать tar: tar -xvf file.tar.gz

Упаковать файлы gzip в файлы с теми же именами .gzip:

gzip -v -f SPUR-30-20151121_181704-1*.dmp
распаковать
gunzip -c SPUR-30-20151121_181704-1.dmp.gz >SPUR-30-20151121_181704-1.dmp

Переместить в архив все файлы *.log в каталоге $log_dir за исключением backup.log и move_tables.log

cd $log_dir
zip move_tables.zip *.log -x backup.log move_tables.log -9 -mDj

Просмотр содержимого архива

zipinfo move_tables.zip

Удалить файлы по маске из архива

zip -d DDDSPROC_TRANSACT_INFO_ARC_141112.zip exp_appl*

Создание вложенных каталогов 
mkdir -p

Установка разрешений на каталог
chmod -R 775 /mount_point

Изменение владельца каталога
chown -R user:group /mount_point

Изменение даты модификации файла

touch -d "2 hours ago" filename

Ввод переменной в скрипте пользователем

echo enter value
read aaa

echo $aaa

#проверка значения введенной переменной и выход из скрипта, если значение не соответствует заданному

if [ $aaa == yes ]
 then echo its yes
 else
  echo its not yes
  exit
fi

#проверка значения первой позиционной переменной

echo $1

if [ $1 == no ]
 then echo its no
 else echo its not no
fi

exit

Список пользователей системы (проверка блокировки пользователя):

List of all locked accounts :
cat /etc/passwd | cut -d : -f 1 | awk '{ system("passwd -S " $0) }' | grep "LK"

List of all unlocked accounts :
cat /etc/passwd | cut -d : -f 1 | awk '{ system("passwd -S " $0) }' | find "PS"

Выполнение команды от имени пользователя (должно быть разрешение на это в /etc/sudoers)

sudo -u пользователь команда

Добавление разрешения выполнять команды c sudo пользователям

для разрешения выполнять пользователю infosec команду 
sudo -u oracle /opt/oracle/app/oracle/product/11.2.0/dbhome_1/OPatch/opatch lsinventory

добавить в файл /etc/sudoers
%infosec ALL=(oracle) NOPASSWD:/opt/oracle/app/oracle/product/11.2.0/dbhome_1/OPatch/opatch lsinventory
(для этого сначала разрешаем запись в файл: chmod u+w /etc/sudoers, после изменения chmod u-w /etc/sudoers)

Цвета в терминале (добавление цветов в вывод терминала):

PS1='\[\e[0;31m\]\u\[\e[m\] \[\e[1;34m\]\w\[\e[m\] \[\e[0;31m\]\$ \[\e[m\]\[\e[0;32m\]'

можно добавить в .bashrc для применения цветовых настроек после входа пользователя в систему

Добавление цветов в bash

https://wiki.archlinux.org/index.php/Color_Bash_Prompt

1) Добавляем переменные

# Regular Colors
Color_Off='\e[0m'       # Text Reset
Black='\e[0;30m'        # Black
Red='\e[0;31m'          # Red
Green='\e[0;32m'        # Green
Yellow='\e[0;33m'       # Yellow
Blue='\e[0;34m'         # Blue
Purple='\e[0;35m'       # Purple
Cyan='\e[0;36m'         # Cyan
White='\e[0;37m'        # White

2) Вывод в цвете
echo -e "${Green}text_to_print"
# отключение цвета в последующем выводе
echo -e "${Color_Off}"


Слежение за процессами

ps aux | grep dbw | grep -v pts

Настройка почты

Прописываем DNS в 

/etc/resolv.conf

search  raiffeisen.ru
nameserver      10.243.122.34
nameserver      10.243.4.2

Сбросить кеш DNS

service nscd restart
service nscd reload

перезапускаем службу и добавляем ее в автозапуск

sudo service sendmail restart
chkconfig sendmail --level 34 on

добавляем информацию о хосте из /etc/hosts в /etc/mail/local-host-names
добавляем информацию о smtp сервере в /etc/hosts

перезапускаем службу
service sendmail restart

отправляем почту
mailx -s "`uname -n`" iruacii2@raiffeisen.ru <<!
test
!

отправить содержимое файла

mailx -s "`uname -n`" iruacii2@raiffeisen.ru < /mnt/oracle/temp/trace/move_tables.log

mailx -s "bash script" iruacii2@raiffeisen.ru < imp-infoware_enc.sh

Логи в /var/log/maillog

Изменение (замена) символов в файле (меняем последнее вхождение символов :Y на :N , за исключенеим строк, содержащих #)

sed -n '/#/!s/:Y/:N/g' /path/file

Вставка символа ( в начало каждой строки

sed 's/^/(/g'

Вставка символов ); в конец каждой строки

sed 's/$/);/g'

Замена всех выражений типа '|2013-*' в начале строки на ' |2013-' в файле isslog_13.unl и запись в файл isslog_13_1.unl

sed 's/^|2013-*/ |2013-/' isslog_13.unl > isslog_13_1.unl

Замена второго вхождения символа | на пробел во всех строках файла acqlog2012.000000 и запись в файл acqlog2012.000000_1:

sed 's/|/ /2' acqlog2012.000000 > acqlog2012.000000_1

Вывод только строк, начинающихся с '|2012-*' в начале строки, из файла isslog_13_1.unl в файл isslog_13_2.bad

sed -n '/^|2013-*/p' isslog_13_1.unl > isslog_13_2.bad

Убрать первую строку из файла ROL.csv

sed '/./!d' ROL.csv

Убрать все пустые строки из файла ROL.csv

sed -e '1d' ROL.csv

Заменить все вхождения двойных кавычек на одинарные в файле ROL.csv

sed "s/\"/\'/g" ROL.csv

Выборка строк (awk) и символов (cut) с нужными номерами:

awk 'NR == 58' | cut -c21-

Выбор конкретного (шестого) символа из строки с разделителем пробел

echo $string | cut -f6 -d' '

Cкрытие сообщений об ошибках в результатах вывода команды

2> /dev/null

Порты

прослушиваемые

netstat -tanp | grep LISTEN

все подключенные (открытые)

netstat -lantp | grep ESTABLISHED |awk '{print $5}' | awk -F: '{print $1}' | sort -u

Анализ сети:

nmap - Network exploration tool and security / port scanner

Сканирование портов 
UDP: nmap -sU servername.domain.com (need root !)
TCP: 
nmap -vv -Anp1-65535 servername.domain.com - полное сканирование с сервисами портов с 1 по 65535
nmap -vv -APn servername.domain.com
nmap -sX servername.domain.com

добавление маршрута к серверу через gw

route add -host 195.1.3.10 gw 172.22.0.247

результат

route

добавление маршрута (временное) для интерфейса bondeth0

ip route add 172.20.18.0/24 via 10.63.144.247 dev bondeth0

удаление добавленного маршрута

ip route del 172.20.18.0/24

Для того, чтобы изменения были постоянны (после растарта сервера), нужно добавить в конфиг для этого интерфейса:

vi /etc/sysconfig/network-scripts/route-bondeth0

строку:

172.20.18.0/24 via 10.63.144.247

ее можно взять из результата (убрав имя интерфейса)

ip route

Открыт порт или нет (bash скрипт)

#!/bin/bash
echo "172.22.10.36 1521" | \
while read host port; do
  r=$(bash -c 'exec 3<> /dev/tcp/'$host'/'$port';echo $?' 2>/dev/null)
  if [ "$r" = "0" ]; then
    echo $host $port is open
  else
    echo $host $port is closed
  fi
done

-- ping адреса с выводом времени пинга и записью сообщений об ошибках в лог в фоне:

ping -i 3 10.63.141.31 | while read pong; do echo "$(date): $pong"; done > ping_another_machine_my.log 2>&1 &

Установка zabbix_sender

1) Добавляем новый репозиторий

echo '
[zabbix]
name=RBA-Zabbix
baseurl=http://kstart.raiffeisen.ru/repo/rba-zabbix/repo.zabbixzone.com/centos/6/x86_64/
enabled=1
gpgcheck=0

[zabbix-noarch]
name=RBA-Zabbix-noarch
baseurl=http://kstart.raiffeisen.ru/repo/rba-zabbix/repo.zabbixzone.com/centos/6/noarch/
enabled=1
gpgcheck=0' >> /etc/yum.repos.d/rba-zabbix.repo


gpgcheck=0

2) yum install zabbix-sender

Firewall

установка сервиса в автозапуск при рестарте системы (уровень 3):

chkconfig iptables --level 3 on

если при добавлении сервиса в автостарт возникает ошибка типа: service X does not support chkconfig
добавляем в скрипт сервиса сразу после #!/bin/bash или #!/bin/sh 
строку # chkconfig: 2345 95 20

текущие правила

iptables-save

iptables-save > /name/of/file

include the current values of all packet and byte counters in the output
iptables-save -c

редактируем правила (файл обычно /etc/sysconfig/iptables)

Применяем

iptables-restore < /name/of/file

перезапускаем сервис service iptables stop / start 

Скрипт для автоматической модификации текущих правил (пример скрипта для atmdb02):

/etc/sysconfig/iptables_cfg.sh

#!/bin/bash

# flush NetFilter
iptables -F

# set FORWARD to block all forward
iptables -P FORWARD DROP

# set OUTPUT to accept all output
iptables -P OUTPUT ACCEPT

# block ut rules input
iptables -P INPUT DROP                                               


# set INPUT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT        # accept all related packets
iptables -A INPUT -i lo -j ACCEPT                                       # accept Loopback
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT            # accept all ping requests

##
## RHEL Standart
##

# Qualys Scanner
iptables -A INPUT -m conntrack --ctstate NEW  -s 10.243.128.26 -j ACCEPT

# Monitoring 
iptables -A INPUT -m conntrack --ctstate NEW -p udp --dport 161 -i eth0 -j ACCEPT                       # zabbix
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 10050 -i eth0 -s 10.243.12.20 -j ACCEPT     # zabbix 1
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 10050 -i eth0 -s 10.243.112.20 -j ACCEPT    # zabbix 2
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 199 -i eth0 -j ACCEPT                       # snmpd
iptables -A INPUT -m conntrack --ctstate NEW -p udp --dport 162 -i eth0 -j ACCEPT                       # snmptrapd

# SSH 
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 22 -i eth0 -s 10.243.68.67 -j ACCEPT        # Terminal server
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 22 -i eth0 -s 10.243.68.98 -j ACCEPT        # Terminal server
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 22 -i eth0 -s 10.243.68.100 -j ACCEPT       # Terminal server Linux
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 22 -i eth0 -s 10.243.4.37 -j ACCEPT         # Terminal server Citrix
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 22 -i eth0 -s 10.242.178.43 -j ACCEPT       # Terminal server Citrix
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 22 -i eth1 -s 172.23.12.0/26  -j ACCEPT     # ssh from internal network
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 22 -i eth1 -s 172.23.112.0/26 -j ACCEPT     # ssh from internal network
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 22 -i eth0 -s 10.243.12.0/26  -j ACCEPT     # ssh from server network
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 22 -i eth0 -s 10.243.112.0/26 -j ACCEPT     # ssh from server network

##
## Application Rules
##

# Oracle
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.12.46 -j ACCEPT       # Oracle gateway
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.12.47 -j ACCEPT       # ATM ctrl app server 1
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.12.48 -j ACCEPT       # ATM exchange/infoware
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.12.49 -j ACCEPT       # ATM ctrl app server 2
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.112.49 -j ACCEPT      # ATM monitoring
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.128.237 -j ACCEPT     # Security (s-msk34-sims-ags1)
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.12.45 -j ACCEPT       # Pair DB server
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.12.44 -j ACCEPT       # Arch DB server
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.12.12 -j ACCEPT       # New ATMdb DB server 1
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.12.13 -j ACCEPT       # New ATMdb DB server 2
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.68.98 -j ACCEPT       # Windows Terminal
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth0 -s 10.243.68.67 -j ACCEPT       # Windows Terminal
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth1 -s 172.23.12.0/26  -j ACCEPT    # from internal network
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1521 -i eth1 -s 172.23.112.0/26 -j ACCEPT    # from internal network
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1158 -i eth0 -s 10.243.68.100 -j ACCEPT      # EMCA Linux Terminal
iptables -A INPUT -m conntrack --ctstate NEW -p tcp --dport 1158 -i eth0 -s 10.243.68.67 -j ACCEPT       # EMCA Windows Terminal

#
# SYSTEM RULES
#

# DROP all packets
iptables -A INPUT -j DROP


# other input packets will be logged and accepted
iptables -A INPUT -j LOG --log-level DEBUG --log-prefix "INPUT PACKET OUT OF RULE ->"

Запрет исходящего трафика по порту 1521

iptables -I OUTPUT ! -o lo -p tcp --dport 1521 -j REJECT
iptables -nvL OUTPUT

удаление этого запрета

iptables -D OUTPUT ! -o lo -p tcp --dport 1521 -j REJECT

Запуск процесса в фоне

./script &

без вывода результата

nohup ./script &

Процессы в Linux
top 

•<Shift>+<N> — сортировка по PID;
•<Shift>+<A> — сортировать процессы по возрасту;
•<Shift>+<P> — сортировать процессы по использованию ЦПУ;
•<Shift>+<M> — сортировать процессы по использованию памяти;
•<Shift>+<T> — сортировка по времени выполнения.

--output with CPU usage sort
top -o cpu -c
--output with MEMORY usage sort
top -o size -c

Преобразование символов из нижнего регистра в верхний

echo 'esempio' | tr '[:lower:]' '[:upper:]'

Применяем изменения в файле .bashrc

source ~/.bashrc

Отключение ip forwarding

vim /etc/sysctl.conf

net.ipv4.ip_forward = 0

sysctl -p

Изменение ip адреса

Зайти под root

ifconfig -a

смотрим MAC, ищем его в файле:

vim /etc/udev/rules.d/70-persistent-net.rules

настраиваем ip интерфейса для этого eth?

Выполнить изменение vlan (если виртуальная машина)
Долговременные настройки хранятся в файлах /etc/sysconfig/network-scripts/ifcfg-???
DNS указываются в файле /etc/resolv.conf
Поменять файл для нужного сетевого интерфейса (смотреть ifconfig)
Меняем ip в файле /etc/hosts
$ sudo /etc/init.d/network restart

Настройки DNS

cat /etc/resolv.conf

Имя хоста

vim /etc/sysconfig/network

Через GIU

system-config-network-tui

Пересоздание RAID (удаление текущего, создание 1+0)

ctrl "slot=1" logicaldrive 2 delete
ctrl "slot=1" create type=ld drives=2I:1:3,2I:1:4,1I:1:5,1I:1:6,1I:1:7,1I:1:8 raid=1+0
ctrl "slot=1" logicaldrive 2 show status

Создание файловой системы
fdisk -l
создать нужную фс
mkfs.ext3 /dev/cciss/c1d1p1
mount /dev/cciss/c1d1p1 /mnt/data
vim /etc/fstab
/dev/cciss/c1d1p1               /mnt/data       ext3    rw      0 0

Комментарий в bash скриптах

одна строка #

много строк

<<comment

comment

Операции с числами в bash скриптах

variable=$((variable+1))

Подключение FC

название адаптера

lspci

locate World Wide Port Number (WWPN)
cat /sys/class/fc_host/host*/port_name

Check Port Status
cat /sys/class/fc_host/host*/port_state

Scan for Fiber Channel Disks without Rebooting
echo "1" > /sys/class/fc_hosts/host*/issue_lip

Check Current HBA Speed
cat /sys/class/fc_host/host*/speed

Check Available HBA Speeds
cat /sys/class/fc_host/host*/supported_speeds

Check HBA Class
cat /sys/class/fc_host/host*/supported_classes

Gather all HBA Details Using One Command
systool -av -c fc_host

Конфигурирование автостарта для сервиса multipathd

простое: 
chkconfig --level 2345 multipathd on
проверка: chkconfig и service multipathd status (после рестарта системы)

если не получается простым способом:

cd /etc/init.d

chkconfig --add multipathd

автоматический старт multipath

vim /etc/init.d/multipathd

#!/bin/bash
#
#       /etc/rc.d/init.d/multipathd
#
# Starts the multipath daemon
#
# chkconfig: - 06 87
# description: Manage device-mapper multipath devices
# processname: multipathd

DAEMON=/sbin/multipathd
prog=`basename $DAEMON`
initdir=/etc/rc.d/init.d
lockdir=/var/lock/subsys
sysconfig=/etc/sysconfig
syspath=/sys/block


system=redhat

if [ $system = redhat ]; then
        # Source function library.
        . $initdir/functions
fi

test -r $sysconfig/$prog && . $sysconfig/$prog

RETVAL=0

teardown_slaves()
{
pushd $1 > /dev/null
if [ -d "slaves" ]; then
for slave in slaves/*;
do
        if [ "$slave" = "slaves/*" ]; then
                read dev <  $1/dev
                tablename=`dmsetup table --target multipath | sed -n "s/\(.*\): .* $dev .*/\1/p"`
                if ! [ -z $tablename ]; then
                        echo "Root is on a multipathed device, multipathd can not be stopped"
                        exit 1
                fi
        else
                local_slave=`readlink -f $slave`;
                teardown_slaves $local_slave;
        fi
        done

else
                read dev <  $1/dev
                tablename=`dmsetup table --target multipath | sed -n "s/\(.*\): .* $dev .*/\1/p"`
                if ! [ -z $tablename ]; then
                        echo "Root is on a multipathed device, multipathd can not be stopped"
                        exit 1
                fi
fi
popd > /dev/null
}

#
# See how we were called.
#

start() {
        test -x $DAEMON || exit 5
        echo -n $"Starting $prog daemon: "
        daemon $DAEMON
        RETVAL=$?
        [ $RETVAL -eq 0 ] && touch $lockdir/$prog
        echo
}

check_root() {
        root_dev=$(awk '{ if ($1 !~ /^[ \t]*#/ && $2 == "/") { print $1; }}' /etc/mtab)
        dm_num=`dmsetup info -c --noheadings -o minor $root_dev 2> /dev/null`
        if [ $? -eq 0 ]; then
                root_dm_device="dm-$dm_num"
                [ -d $syspath/$root_dm_device ] && teardown_slaves $syspath/$root_dm_device
        fi
}

stop() {
        echo -n $"Stopping $prog daemon: "
        killproc $DAEMON
        RETVAL=$?
        [ $RETVAL -eq 0 ] && rm -f $lockdir/$prog
        echo
}

force_queue_without_daemon() {
        $DAEMON -k"forcequeueing daemon"
}

restart() {
        force_queue_without_daemon
        stop
        start
}

reload() {
        echo -n "Reloading $prog: "
        trap "" SIGHUP
        killproc $DAEMON -HUP
        RETVAL=$?
        echo
}

case "$1" in
start)
        start
        ;;
stop)
        check_root
        stop
        ;;
reload)
        reload
        ;;
restart)
        restart
        ;;
condrestart)
        if [ -f $lockdir/$prog ]; then
            restart
        fi
        ;;
status)
        status $prog
        RETVAL=$?
        ;;
*)
        echo $"Usage: $0 {start|stop|status|restart|condrestart|reload}"
        RETVAL=3
esac

exit $RETVAL

Смотреть wwid дисков

scsi_id -g -s /block/sdc

где sdc - диск из списка дисков fdisk -l

конфигурация multipathd

cat /etc/multipath.conf

# This is a basic configuration file with some examples, for device mapper
# multipath.
# For a complete list of the default configuration values, see
# /usr/share/doc/device-mapper-multipath-0.4.7/multipath.conf.defaults
# For a list of configuration options with descriptions, see
# /usr/share/doc/device-mapper-multipath-0.4.7/multipath.conf.annotated


# Blacklist all devices by default. Remove this to enable multipathing
# on the default devices.

defaults {
        user_friendly_names yes
        udev_dir                /dev
        polling_interval        10
        path_selector                "round-robin 0"
        path_grouping_policy    multibus
        getuid_callout          "/sbin/scsi_id -g -u -s /block/%n"
        prio_callout            none
        path_checker            readsector0
        rr_min_io               100
        max_fds                 8192
        rr_weight               priorities
        failback                immediate
        no_path_retry           fail

}


blacklist {
        devnode "*"
}

blacklist_exceptions {
        devnode "^sd[a-d]*"
        device {
                vendor  "HITACHI"
                product "OPEN-V"
        }
}

multipaths {
        multipath {
                wwid                    360060e8016503d000001503d00000053
                alias                   ext_fc_hitachi
                path_grouping_policy    multibus
                path_selector           "round-robin 0"
                failback                immediate
        }
        multipath {
                wwid                    360060e8016503d000001503d00000096
                alias                   ext_fc_hitachi_02
                path_grouping_policy    multibus
                path_selector           "round-robin 0"
                failback                immediate
        }
        multipath {
                wwid                    360060e8016503d000001503d00000095
                alias                   ext_fc_hitachi_03
                path_grouping_policy    multibus
                path_selector           "round-robin 0"
                failback                immediate
        }
}

service multipathd start

Создание файловой системы на новых дисках

fdisk -l
создать нужную фс
mkfs.ext3 /dev/mapper/ext_fc_hitachi
mkfs.ext3 /dev/mapper/ext_fc_hitachi_02
mkfs.ext3 /dev/mapper/ext_fc_hitachi_03

Монтирование новых дисков

mount /dev/mapper/ext_fc_hitachi      /mnt/data_new
mount /dev/mapper/ext_fc_hitachi_03   /mnt/data_fc
mount /dev/mapper/ext_fc_hitachi_02   /mnt/data2_new

Монтирование сетевого диска cifs

mount -t cifs -o username=srv-processing,password=sfcvKi87sd "//s-msk00-xfile01/Bank Cards/BaseI" /mnt/oracle/temp/ONLINE_ARCHIVE/BaseI

либо (если с паролем не получается) в режиме интерактивного ввода пароля:

mount -t cifs -o user=chistoviy "//ehd-01/DB" /spo/spo11/flat_files_for_import/share

Размонтирование

umount /spo/spo11/flat_files_for_import/share

Если при этом возникает сообщение: mount: wrong fs type
проверяем, установлены ли cifs-utils: ll /sbin | grep mount.cifs , если файлов нет, устанавливаем их:
yum install cifs-utils

Запись в fstab
# при закомментированном варианте и включенном асинхронном вводе-выводе возникает ошибка RMAN из Doc ID 464267.1
#//10.242.254.227/s-msk-p-atm-arch       /mnt/oracle/backup cifs uid=502,gid=58995,auto,user,username=srv-processing,password=sfcvKi87sd,rw 1 2
//10.242.254.227/s-msk-p-atm-arch       /mnt/oracle/backup cifs uid=502,gid=58995,auto,user,username=srv-processing,password=sfcvKi87sd 0 0

mount -t cifs -o username=srv-processing,password=sfcvKi87sd "//10.243.112.33/Bank Cards/Reports/Chargebacks" /opt/scripts/PRIME_PROD/retr_visa/reports

Монтирование в режиме rw для всех пользователей

mount -t cifs -o rw,username=srv-processing,password=sfcvKi87sd,file_mode=0777,dir_mode=0777 "//10.243.112.33/Bank Cards/Reports/Chargebacks" /mnt/oracle/temp/REPORTS

для каталогов, содержащих пробелы добавить \040 вместо пробела:
//s-msk00-xfile01/Bank\040Cards/BaseI   /mnt/oracle/temp/ONLINE_ARCHIVE/BaseI cifs uid=502,gid=58995,auto,user,username=srv-processing,password=sfcvKi87sd,rw 1 2

Запись в fstab

vim /etc/fstab

/dev/mapper/ext_fc_hitachi      /mnt/data_fc    ext3    defaults        1 2
/dev/mapper/ext_fc_hitachi_03   /mnt/data       ext3    defaults        1 2
/dev/mapper/ext_fc_hitachi_02   /mnt/data2      ext3    defaults        1 2

Увеличить пути multipath

пересканировать устройства (sdo,sdas,sdan,sdbh - пути к устройствам multipath):

echo 1 > /sys/block/sdo/device/rescan
echo 1 > /sys/block/sdas/device/rescan
echo 1 > /sys/block/sdan/device/rescan
echo 1 > /sys/block/sdbh/device/rescan

Запустить

partprobe
multipathd -k
resize map FC_disk_500G (FC_disk_500G - имя устройства из вывода multipath -ll)

Создание LVM

fdisk -l
pvdisplay 
mount
fdisk -l
pvdisplay
fdisk -l
fdisk /dev/cciss/c0d0
pvs -?
man pvs
pvs
masn pvscan 
man pvscan 
pvscan 
fdisk /dev/cciss/c0d0
partprobe /dev/cciss/c0d0
pvdisplay 
pvcreate /dev/cciss/c0d0p1
vgdisplay 
vgs
vgcreate vg_data2 /dev/cciss/c0d0p1
pvdisplay 
man lvcreate 
lvdisplay 
vgdisplay
lvcreate -L 546.8GB -n data2 vg_data2
lvdisplay
mount
vgdisplay 
lvdisplay 
vim /etc/fstab 
fg
cd /mnt
ll
mkdir data2
chown oracle.oinstall data2
mkfs.ext4 /dev/mapper/vg_data2-data2 
mount -t ext4 /dev/mapper/vg_data2-data2 /mnt/data2
less /root/.bash_history 
exit

Пример добавления нового диска

fdisk -l
pvs
pvcreate /dev/sdf
vgcreate oracle_ctrldata /dev/sdf
cat /dev/mapper/
lvcreate -L 1.50TB -n ctrldata oracle_ctrldata
mkfs.ext4 /dev/mapper/oracle_ctrldata-ctrldata
vim /etc/fstab - добавляем запись:

/dev/oracle_ctrldata/ctrldata /mnt/oracle/ctrldata   ext4    defaults        1 2
mount -a

Добавление диска в LVM

Formatting the new Disk 
Suppose the Disk is /dev/sdb, the second scsi disk,
fdisk /dev/sdb   create as many partitions as you need using command n   Label them with command t as 8e for making it Linux LVM
Write and Exit with the command w.Format the partitions you require using mkfs command 

reboot

mkfs -t ext3 -c /dev/sdb1LVM commands 
pvcreate /dev/sdb1
vgextend VolGroup00 /dev/sdb1
#lvextend -L 15G /dev/system/home for for extending LogVol to 15GB
lvextend -L+10G /dev/system/home for for adding one more 10GB to Logical Volume LogVol01
resize2fs /dev/system/home for resizing the Logical VolumesThats it finished
повторить для каждого тома LVM

Мониторинг дисков 

mount (посмотреть диски)
nmon - d (сравнивать текущую и максимальную скорость i/o)

тестирование производительности дисков:

### Запуск hdparm
sync; sleep 2; echo 3 > /proc/sys/vm/drop_caches; hdparm -t -vvvv /dev/cciss/c1d0p1
sync; sleep 2; echo 3 > /proc/sys/vm/drop_caches; hdparm -tT -vvvv /dev/cciss/c1d0p1

### Запуск dd
dd if=/dev/zero of=/mnt/ids_data/test_speed_1M bs=1M count=100 oflag=direct
dd if=/dev/zero of=/mnt/ids_data/test_speed_1M bs=1M count=100 conv=fdatasync
dd if=/dev/zero of=/mnt/ids_data/test_speed_64k bs=64k count=2000 conv=fdatasync

dd if=/mnt/ids_data/test_speed_1M of=/dev/null

### iozone
Документация расположена на сервере в директории : /usr/local/src/iozone3_420/docs
Запускаемый модуль : /usr/local/src/iozone3_420/src/current/iozone

Примеры команд для запуска:
iozone -a /dev/cciss/c1d0p1 -b iozone_speed_test_onldb02_20130829.xls
iozone -I -a /dev/cciss/c1d0p1 -b iozone_speed_test_onldb02_20130829_direct.xls

iozone -q 8 -y 8 -n 16777216 -g 16777216  -I -o -a /dev/cciss/c1d0p1 -b iozone_speed_test_onldb02_20130829_direct_16G.xls

Запуск иксов

sudo init 5

Просмотр лога (динамический)
tail -f ttt.log

Копирование по сети
scp p10404530_112030_Linux-x86-64_1of7.zip root@10.243.12.31:/usr/oracle
если каталог, то
scp -r /mnt/data1/distrib/database oracle@10.243.12.32:/mnt/data1/distrib
запускается на машине, где находится требуемый файл, root@10.243.12.31:/usr/oracle - хост и каталог куда копируем

scp -r /mnt/data_p400/remote_backup/20140311 oracle@10.242.182.17:/mnt/data2/backup/work_db

Поиск файла
find / -type f -name name_of_file -print
пример вывода результата без вывода ошибок (когда нужен 1 каталог)
find /mnt -type d -name 'backup' -print 2>/dev/null | grep -v $ORACLE_HOME
find /mnt/oracle/temp/ONLINE_ARCHIVE/BaseI/BaseI.12 -name isslog.unl

В SLES

find / -iname file_name

Планировщик
crontab -e

Установка переменных среды в crontab

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

установка переменных и запуск скрипта непосредственно в crontab (min hour day_of_month month week_day - Sunday=0):

*/1 * * * * . $HOME/.bash_profile; echo 'select sysdate from dual;' | sqlplus -S / as sysdba >> /var/logs/oracle/aaa.log 2>&1

пример задания:
00 04 * * * /usr/local/bin/backup.sh >> /var/logs/oracle/backup.log 2>&1

00 - минуты, 04 - часы

00 */2 * * * /usr/local/bin/scripts/check_replication.sh >> /var/logs/check_replication.log 2>&1 - запускать каждые 2 часа

Пользователь, от имени которого запускается задание должен иметь права на скрипты в нем и на каталоги с логами

-- использования результатов команды (даты) с заданиях crontab - экранирование спецсимволов \

*/1 * * * * . ~/.setSpur; tnsping spur && cp /u01/app/oracle/diag/tnsping/tnsping.trc /u01/app/oracle/diag/tnsping/trc_all/tnsping.`date +\%Y\%m\%d_\%H\%M\%S` >> /home/oracle/spur_tnsping_1.log 2>&1

Системные задания

/etc/anacrontab в нем записи /etc/cron. (для ежедневных,еженедельных и т.п. заданий)

--schedules examples
https://tecadmin.net/crontab-in-linux-with-20-examples-of-cron-schedule/

Настройки ssh

/etc/ssh/sshd_config
логи доступа в файлах /var/log/secure и /var/log/messages (имена файлов указаны в /etc/(r)syslog.conf )

Выполнение команд по SSH без ввода пароля

Выполняем от имени пользователей, которыми планируется работать на серверах
1) создаем ключ (2 компоненты id_rsa и id_rsa.pub) ssh-keygen -t rsa создадутся в ~/.ssh на сервере, на котором нужно выполнять команды
2) копируем файл (или его содержимое) в файл ~/.ssh/authorized_keys на удаленный сервер
3) файл authorized_keys делаем доступными только использующими их пользователю: chmod 0640 filename
4) файл id_rsa - только владельцу: chmod g-r id_rsa
5) проверяем с удаленного сервера ssh user@remote-server uptime - должно выполнится без ввода пароля
6) если пароль запрашивается, смотрим лог less /var/log/secure на сервере remote-server
7) исправляем параметры ssh vim /etc/ssh/sshd_config
8) перезапускаем службу ssh: service sshd restart и проверяем еще раз

Запуск команд bash в цикле в прерыванием на заданном файле

#!/bin/bash

path=/mnt/oracle/temp/ONLINE_ARCHIVE/BaseI/BaseI.13
file_name=isslog.unl
result_file=/mnt/oracle/temp/ONLINE_ARCHIVE/isslog_13.unl

#set this variable to break at given file
#break_file=003

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

Синронизация каталогов

rsync -varlp --progress --delete --bwlimit=20000 --exclude "exclude.log" /tmp/source/ oracle@10.243.12.31:/tmp/destination/

с текущего сервера на сервер 10.243.12.31 под пользователем oracle за исключением файла exclude.log со скоростью не более 20000 байт/с

Копирование бекапа на удаленный сервер
#!/bin/bash

echo "-----------------------------------------"
echo "***** Begin" `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "-----------------------------------------"

remote_server=s-msk00-ultra-lb
rsync_target="/mnt/data1/backup/"
rsync_destination="/mnt/data2/remote_backup/"
db_status=`cat ${rsync_destination}db_status`

echo "current DB status is" ${db_status}

if [ "${db_status}" == PRIMARY ]
 then echo "rsync -varlp --progress --delete --exclude "db_status" ${rsync_target} rsync@${remote_server}:${rsync_destination}" | su - rsync
 else echo "not copy"
fi

echo "----------------------------------------"
echo "***** End  " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

для проверки 

rsync -varlpn --delete /mnt/data1/backup/ rsync@s-msk08-ultra-la:/mnt/data2/remote_backup/

Запуск выборки в sqlplus из bash (выбор 14 строки из результата и сравнение его с текстом)

db_status=`echo 'select DATABASE_ROLE from v$database;' | sqlplus / as sysdba | awk '(NR == 14)'`

if [ ${db_status} == PRIMARY ]

 then echo "copy"
 else echo "not copy"
 fi

Скрипт для полного ежедневного бекапа БД по расписанию

vim /usr/local/bin/backup.sh

#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

#set variables

server_admins="iruacii2@raiffeisen.ru,irualys2@raiffeisen.ru,iruakgv8@raiffeisen.ru,iruatza7@raiffeisen.ru"
#server_admins="iruacii2@raiffeisen.ru,iruagov3@raiffeisen.ru,iruafaa1@raiffeisen.ru,iruamaah@raiffeisen.ru,iruakgd5@raiffeisen.ru"
BACKUP_PATH="/mnt/data1/backup"

#set constants (the same for all servers)

subject='oracle backup probably failed'
message='last successful backup was'
db_status_file_dir="/mnt/data2/remote_backup"
table='V$RMAN_BACKUP_JOB_DETAILS'
db_status=`echo 'select DATABASE_ROLE from v$database;' | sqlplus -S / as sysdba | tail -n-2 | head -n+1`
last_backup=`echo "select to_char(max(END_TIME),'dd/mm/yy hh24:mi') from $table where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED','COMPLETED WITH WARNINGS');" | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

echo "-----------------------------------------"
echo "***** Begin" `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "-----------------------------------------"

name=`date +%Y%m%d`

#0)check db_status

echo "current db status is" $db_status

echo ${db_status} > ${db_status_file_dir}/db_status

#1)backup

cd ${BACKUP_PATH}
mkdir ${name}

#[ -d ${name} ] || mkdir ${name}
#cd ${BACKUP_PATH}/${name}
#find ${BACKUP_PATH}/${name}  -name "*.BCK" -print -exec rm -rf {} \;

rman target / < /usr/local/bin/backup.sql LOG=${BACKUP_PATH}/${name}/backup.log
echo "Done!" `date '+%a %d.%m.%Y-%H:%M:%S'`

#2)Check backup

tail -n 20 ${BACKUP_PATH}/${name}/backup.log | grep "objects"
   if [ $? -eq 0 ]
                then
echo "backup correct"

#3) Moving backup to reserve
#                EXEC="rsync -e ssh -avz --progress ${BACKUP_PATH} $REMOTE_HOST:/mnt/backup"
#                su rsync -c "${EXEC}"
#                echo " "
#                echo "Done!" `date '+%a %d.%m.%Y-%H:%M:%S'`

#                cd ${REMOTE_PATH}
#                cp -R ${BACKUP_PATH}/${name}/ ${REMOTE_PATH}/
#echo "Done!" `date '+%a %d.%m.%Y-%H:%M:%S'`
#
#3)Removing remote files
#           echo "Removing old backup files in " ${REMOTE_PATH} "..."
#                find ${REMOTE_PATH} -name '20*' -mmin +700
#          find ${REMOTE_PATH} -name '20*' -mmin +700 |xargs rm -R -f
#                echo "Done!" `date '+%a %d.%m.%Y-%H:%M:%S'`
#
                else
                        mailx -s "`uname -n`: $subject" $server_admins <<!
$message $last_backup. current db status is $db_status
!

        fi

cp -f ${BACKUP_PATH}/${name}/backup.log ${BACKUP_PATH}
		
echo "----------------------------------------"
echo "***** End  " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

Скрипт для RMAN, запускемый системным скриптом бекапа

vim /usr/local/bin/backup.sql 

RUN 
{
  BACKUP AS COMPRESSED BACKUPSET DATABASE PLUS ARCHIVELOG NOT BACKED UP 1 TIMES DELETE ALL INPUT SKIP INACCESSIBLE;
  DELETE FORCE NOPROMPT OBSOLETE;
  CROSSCHECK BACKUP;
}

EXIT;

Скрипт для мониторинга успешности бекапа (ещет ORA- в логе бекапа с одним исключением):

vim /usr/local/bin/scripts/check_backup/bk_check.sh

#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

#set variables

server_admins="iruacii2@raiffeisen.ru,irualys2@raiffeisen.ru,iruakgv8@raiffeisen.ru,iruatza7@raiffeisen.ru"
#server_admins="iruacii2@raiffeisen.ru,iruagov3@raiffeisen.ru,iruafaa1@raiffeisen.ru,iruamaah@raiffeisen.ru,iruakgd5@raiffeisen.ru"
BACKUP_PATH="/mnt/data1/backup"

#set constants (the same for all servers)

subject='oracle backup probably failed'
message='last successful backup was'
CURRENT_HOSTNAME=`uname -n`
zabbix_server='10.243.12.20'
backup_state=`cat ${BACKUP_PATH}/backup.log | grep -v ORA-19921 | grep ORA-`
table='V$RMAN_BACKUP_JOB_DETAILS'
db_status=`echo 'select DATABASE_ROLE from v$database;' | sqlplus -S / as sysdba | tail -n-2 | head -n+1`
last_backup=`echo "select to_char(max(END_TIME),'dd/mm/yy hh24:mi') from $table where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED','COMPLETED WITH WARNINGS');" | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

#execute script

echo "----------------------------------------"
echo "***** Hostname " `hostname` "******"
echo "***** Date " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

echo "current db status is" $db_status
echo "last successful backup" $last_backup
echo "0 - error"
echo "1 - ok"
echo "current state"

if [ -f ${BACKUP_PATH}/backup.log ]; then

        if [[ ${backup_state}  -eq 0 ]];then
                echo "1"
         else
                echo "0"
                mailx -s "`uname -n`: $subject" $server_admins <<!
$message $last_backup. current db status is $db_status
!
        fi
else

  echo "0"
  mailx -s "`uname -n`:  $subject" $server_admins <<!
$message $last_backup. current db status is $db_status
!
fi

echo "sending to zabbix"

if [ -f ${BACKUP_PATH}/backup.log ]; then
 if [[ ${backup_state}  -eq 0 ]];then
    zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k backup_status -o 1
   else
    zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k backup_status -o 0
   fi
else
zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k backup_status -o 0
 fi

rm -f ${BACKUP_PATH}/backup.log

Просмотр времени последнего успешного бекапа

vim last_backup.sql

set heading off
set feedback off
set termout off
set trimspool on

select to_char(max(END_TIME),'dd/mm/yy hh24:mi') LAST_BACKUP from V$RMAN_BACKUP_JOB_DETAILS
 where INPUT_TYPE = 'DB FULL' and STATUS IN ('COMPLETED','COMPLETED WITH WARNINGS');
 
vim last_backup.sh

#!/bin/bash

last_backup=`sqlplus / as sysdba < last_backup.sql | awk '(NR == 12)'`

echo "last successful backup" ${last_backup}

Проверка репликации:

1) Проверка со сбором информации на каждом сервере отдельно (разницу между логами вычисляет zabbix):

vim /usr/local/bin/scripts/check_replication.sh

#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

export ORACLE_SID=`env | grep ORACLE_SID | cut -c12-`
export ORACLE_HOME=`env | grep ORACLE_HOME | cut -c13-`
export PATH=$PATH:$HOME/bin:$ORACLE_HOME/bin
CURRENT_HOSTNAME=`uname -n`
sqlstring='select SEQUENCE# from V$LOG_HISTORY where SEQUENCE# = (SELECT MAX(SEQUENCE#) FROM V$LOG_HISTORY);'
max_archlog=`echo $sqlstring | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

echo `uname -n` max_achlog
echo $max_archlog
echo `date`

zabbix_sender -z 10.243.12.20 -s "${CURRENT_HOSTNAME}" -k max_archlog -o "${max_archlog}"

2) Проверка с любого сервера с вычислением разницы между логами

vim /usr/local/bin/scripts/replication/check_data_guard.sql

SET TERMOUT ON
SET ECHO OFF
SET VERIFY OFF

SPOOL check_data_guard.log

PROMPT *** instance at server 10.243.12.45 current status ***

connect sys/spotlight@LANIT_LIVE as sysdba;

column STARTUP_TIME   format A25
column INSTANCE_NAME  format A10
column HOST_NAME      format A16
column STARTED        format A25
column DESTINATION    format A35
column CHANGE_TIME    format A25

select INSTANCE_NAME,HOST_NAME,to_char(STARTUP_TIME,'dd/mm/yyyy hh24:mi:ss') as STARTED,STATUS from v$instance;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';

PROMPT *** archived logs ***

column first_time  format A25

select to_char(first_time,'dd/mm/yyyy hh24:mi:ss') as CHANGE_TIME,SEQUENCE# from V$LOG_HISTORY where SEQUENCE# = (SELECT MAX(SEQUENCE#) FROM V$LOG_HISTORY);

PROMPT *** instance at server 10.243.112.45 current status ***

connect sys/spotlight@LANIT_STB as sysdba;

select INSTANCE_NAME,HOST_NAME,to_char(STARTUP_TIME,'dd/mm/yyyy hh24:mi:ss') as STARTED,STATUS from v$instance;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';

PROMPT *** archived logs ***

select to_char(first_time,'dd/mm/yyyy hh24:mi:ss') as CHANGE_TIME,SEQUENCE# from V$LOG_HISTORY where SEQUENCE# = (SELECT MAX(SEQUENCE#) FROM V$LOG_HISTORY);

SPOOL OFF

exit;

vim /usr/local/bin/scripts/replication/check_replication.sh

#!/bin/bash

SCRIPT_DIR="/usr/local/bin/scripts/replication"
server1_string="spotlight@LANIT_LIVE"
server2_string="spotlight@LANIT_STB"

server1_max_archlog=`sqlplus sys/${server1_string} as sysdba < ${SCRIPT_DIR}/check_data_guard.sql | awk 'NR == 34' | cut -c21-`
server2_max_archlog=`sqlplus sys/${server2_string} as sysdba < ${SCRIPT_DIR}/check_data_guard.sql | awk 'NR == 58' | cut -c21-`
archlog_difference=`expr ${server1_max_archlog} - ${server2_max_archlog}`

echo "--------------------------"
echo "server1_max_archlog" ${server1_max_archlog}
echo
echo "server2_max_archlog" ${server2_max_archlog}
echo
echo "archlog_difference" ${archlog_difference}
echo "--------------------------"

vim /usr/local/bin/scripts/replication/max_archlog.sql

SET TERMOUT ON
SET ECHO OFF
SET VERIFY OFF

SPOOL max_archlog.log

connect / as sysdba;

column STARTUP_TIME   format A25
column INSTANCE_NAME  format A10
column HOST_NAME      format A16
column STARTED        format A25
column DESTINATION    format A35
column CHANGE_TIME    format A25

select INSTANCE_NAME,HOST_NAME,to_char(STARTUP_TIME,'dd/mm/yyyy hh24:mi:ss') as STARTED,STATUS from v$instance;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';

PROMPT *** archived logs ***

column first_time  format A25

select to_char(first_time,'dd/mm/yyyy hh24:mi:ss') as CHANGE_TIME,SEQUENCE# from V$LOG_HISTORY where SEQUENCE# = (SELECT MAX(SEQUENCE#) FROM V$LOG_HISTORY);

SPOOL OFF

exit;

Проверка репликации каждый 2 часа

00 */2 * * * /usr/local/bin/scripts/replication/check_replication.sh >> /var/logs/oracle/check_replication.log 2>&1

Проверка статуса БД

vim /usr/local/bin/scripts/db_status.sh

#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

db_status_file_dir="/mnt/data2/remote_backup"
db_status=`echo 'select DATABASE_ROLE from v$database;' | sqlplus -S / as sysdba | tail -n-2 | head -n+1`

echo ${db_status}

if [ ${db_status} == PRIMARY ]

 then echo ${db_status} > ${db_status_file_dir}/db_status
  else echo "not copy"
fi

скрипт для копирования от имени rsync (запускать в crontab для пользователя root)

vim /usr/local/bin/scripts/copy_backup.sh

#!/bin/bash

echo "-----------------------------------------"
echo "***** Begin" `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "-----------------------------------------"

remote_server=s-msk08-ultra-la
rsync_target="/mnt/data1/backup/"
rsync_destination="/mnt/data2/remote_backup/"
db_status=`cat ${rsync_destination}db_status`

echo "current DB status is" ${db_status}

if [ ${db_status} == PRIMARY ]
 then echo "rsync -varlp --progress --bwlimit=20000 --delete --exclude "db_status" ${rsync_target} rsync@${remote_server}:${rsync_destination}" | su - rsync
 else echo "not copy"
fi

echo "----------------------------------------"
echo "***** End  " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

root> crontab -e

00 04 * * * /usr/local/bin/scripts/copy_backup.sh >> /var/logs/oracle/copy_backup.log 2>&1

Проверка текущего статуса онлайн-логов (задержки записи на диск) - мертика oracle_active_logs в zabbix

vim /usr/local/bin/scripts/check_logs.sh

#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

#server_admins="iruacii2@raiffeisen.ru,irualys2@raiffeisen.ru,iruakgv8@raiffeisen.ru,iruatza7@raiffeisen.ru"
server_admins="iruacii2@raiffeisen.ru,iruagov3@raiffeisen.ru,iruafaa1@raiffeisen.ru,iruamaah@raiffeisen.ru,iruakgd5@raiffeisen.ru"
BACKUP_PATH="/mnt/data2/backup"
CURRENT_HOSTNAME=`uname -n`
zabbix_server='10.243.12.20'
table='V$LOG'
oracle_active_logs=`echo "select count(1) from $table where status = 'ACTIVE';" | sqlplus -S / as sysdba | tail -n-2`

echo "----------------------------------------"
echo "***** Date " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

echo "number of active online logs is" $oracle_active_logs

echo "sending to zabbix"

zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k oracle_active_logs -o $oracle_active_logs

exit

Запуск нескольких sql команд из shell

#!/bin/bash

# Set environment -- not done by cron (usually file .bash_profile or .bashrc in HOME)
. $HOME/.bash_profile

sqlplus / as sysdba <<!
set linesize 200
set pagesize 1000

spool startup_standby.log

prompt *** start standby database ***

STARTUP NOMOUNT;
ALTER DATABASE MOUNT STANDBY DATABASE;
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

prompt *** db_info ***

SELECT MAX(SEQUENCE#),thread# FROM V$LOG_HISTORY group by thread#;

select switchover_status,database_role,PROTECTION_MODE,PROTECTION_LEVEL from v$database;

column DESTINATION format a40
SELECT DESTINATION, STATUS, ARCHIVED_THREAD#, ARCHIVED_SEQ# FROM V$ARCHIVE_DEST_STATUS
 WHERE STATUS <> 'DEFERRED' AND STATUS <> 'INACTIVE';
 
select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;

spool off
exit;
!

echo "----------------------------------------"
echo "***** Hostname " `hostname` "******"
echo "***** Date " `date '+%a %d.%m.%Y-%H:%M:%S'` "*****"
echo "----------------------------------------"

exit

Ожидание на коммит из-за переключения логов (архивации архивлогов на тот же диск)

[oracle@s-msk08-atmdb01 /usr/local/bin/scripts/logfile_wait]$ cat logfile_wait.sh
#!/bin/bash

. $HOME/.bash_profile
. $HOME/.bashrc

#set constants (the same for all servers)

CURRENT_HOSTNAME=`uname -n`

logs_dir='/var/logs/oracle'

zabbix_server='10.2xx.12.20'

echo `date '+%a %d.%m.%Y-%H:%M:%S'` > $logs_dir/logfile_wait.log

sqlplus -S / as sysdba <<!
set heading off feedback off termout off trimspool on serveroutput off

set pagesize 1000
set linesize 200

column minute format A10
column event  format A15
column WAITS  format 999,999,999

spool $logs_dir/logfile_wait.log
select to_char(sysdate,'DD.MM.YYYY HH24:MI:SS') "DATE" from dual;
  SELECT COUNT (COUNT (session_id)) waits,
         ROUND (SUM ( (SUM (time_waited) / 1000000))) total_wait_time,
         ROUND (((SUM ( (SUM (time_waited) / 1000000))) / COUNT (COUNT (session_id))),2) avg_time_waited
from v\$active_session_history
where event = 'log file sync' AND sample_time >= (SYSDATE - 1 / 1440)
GROUP BY session_id
/
spool off
!

wait_event=`tail -n-1 $logs_dir/logfile_wait.log`

waits=`echo $wait_event | cut -f1 -d' '`
total_wait_time=`echo $wait_event | cut -f2 -d' '`
avg_time_waited=`echo $wait_event | cut -f3 -d' '`

echo
echo -e wait_event = \\n $wait_event
echo
echo -e total_wait_time = \\n $total_wait_time
echo
echo -e waits = \\n $waits
echo
echo -e avg_time_waited = \\n $avg_time_waited

zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k total_wait_time -o "${total_wait_time}"

zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k waits -o "${waits}"

zabbix_sender -z $zabbix_server -s "${CURRENT_HOSTNAME}" -k avg_time_waited -o "${avg_time_waited}"

exit

set display for X server use (ip - is your local ip):

export DISPLAY=10.1xx.50.17:0.0

--cycle with variables example, CPU number dependent

# variables

num_cpu="$(("`kstat -m cpu_info | grep -w core_id | wc -l`/8"))"
parallelism=$(($num_cpu/18))
export prod_db_host=$1
export db_name=$2
SBT_PARMS="\"SBT_PARMS=(NSR_SERVER=lnibkpprd1,NSR_CLIENT=$prod_db_host,NSR_RECOVER_POOL=OracleADClone)\""

# execution

echo $num_cpu
echo $parallelism

export ORACLE_SID=$db_name

rman_channels=`for i in $(eval echo "{1..$parallelism}")
do
echo ALLOCATE CHANNEL CH$i TYPE DISK PARMS $SBT_PARMS";"
done`

echo
echo $rman_channels

rman target / <<EOF
set echo on
run
{
$rman_channels
}
exit;
EOF

exit










