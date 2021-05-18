По умолчанию Oracle TDE использует алгоритм AES192

1) Создаем каталог для ключей

mkdir $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet -p

2) Устанавливаем права на каталог

chmod -R u+rwX,g-rwX,o-rwX $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet

3) И на ключи (если они в нем есть)

chmod 600 $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet/*wallet*

4) Настроить расположение ключа в файле sqlnet.ora

vim $ORACLE_HOME/network/admin/sqlnet.ora

ввести 

#TDE
ENCRYPTION_WALLET_LOCATION=(SOURCE=(METHOD=FILE)(METHOD_DATA=(DIRECTORY=$ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet)))

5) Проверить, что нет открытых wallet

sqlplus / as sysdba

col WRL_TYPE format a10
col WRL_PARAMETER format a43
col STATUS format a10
select * from v$encryption_wallet;

результат

WRL_TYPE   WRL_PARAMETER                               STATUS
---------- ------------------------------------------- ----------
file       $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet   CLOSED

6) Задаем пароль доступа к контейнеру 

ALTER SYSTEM SET ENCRYPTION KEY IDENTIFIED BY "Passw0rd";

где "Passw0rd" – новый пароль доступа к контейнеру Oracle Wallet

Данная команда выполнила следующее:

• создаёт контейнер на базе Oracle Wallet с паролем доступа "Passw0rd"
• создаёт новый мастер ключ, делает его активным и сохраняет в контейнере.
Если существовал старый мастер ключ то он сохраняется и помечается как неактивный. 

select * from v$encryption_wallet;

WRL_TYPE   WRL_PARAMETER                               STATUS
---------- ------------------------------------------- ----------
file       $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet   OPEN

7) Контейнер создан в файловой системе

ls -al $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet

drwx------ 2 oracle oinstall 4096 Apr  3 12:01 .
drwxr-xr-x 3 oracle oinstall 4096 Apr  3 11:52 ..
-rw-r--r-- 1 oracle oinstall 2845 Apr  3 12:01 ewallet.p12

Открытие доступа к Oracle Wallet выполняется следующей командой:

sqlplus / as sysdba
ALTER SYSTEM SET ENCRYPTION WALLET OPEN IDENTIFIED BY "Passw0rd";


Закрытие доступа к Oracle Wallet выполняется следующей командой:

sqlplus / as sysdba
ALTER SYSTEM SET ENCRYPTION WALLET CLOSE IDENTIFIED BY "Passw0rd";

8) Настройка контейнера Oracle Wallet для работы в режиме Auto-Open

orapki wallet create -wallet $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet -auto_login

ввести пароль

9) Просмотреть наличие нового контейнера cwallet.sso на файловой системе

ls -al $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet

drwx------ 2 oracle oinstall 4096 Apr  3 12:08 .
drwxr-xr-x 3 oracle oinstall 4096 Apr  3 11:52 ..
-rw------- 1 oracle oinstall 2923 Apr  3 12:08 cwallet.sso
-rw-r--r-- 1 oracle oinstall 2845 Apr  3 12:01 ewallet.p12

Смена пароля доступа к контейнеру (при необходимости)

orapki wallet change_pwd -wallet $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet
Enter wallet password: *********** | ввести старый пароль

New password:
Enter wallet password: *********** | ввести новый пароль

Выполнить настройку опции Auto-Open для нового пароля

orapki wallet create -wallet $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet -auto_login
Enter wallet password: *********** | ввести новый пароль

Смена Мастер-Ключа (один раз в два года)

sqlplus / as sysdba
ALTER SYSTEM SET ENCRYPTION KEY IDENTIFIED BY "Passw0rdNEW";

!!! Содержимое Oracle Wallet

orapki wallet display -wallet $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet

меняется после смены мастер-ключа

!!! Необходимо запретить любую модификацию(удаление) файлов Oracle Wallet
в директории $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet !!!

10) Настройка прав доступа на файлы контейнера 

chmod 600 $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet/*wallet*

устанавливаем бит ‘immutable’ от имени root на файлы в каталоге $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet
(для защиты от неумышленного удаления)
cd $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet
pwd

sudo su -

chattr +i ewallet.p12
chattr +i ewallet.sso

chattr +i $ORACLE_BASE/admin/$ORACLE_UNQNAME/wallet/*wallet*

!!! перед изменением ключей/паролей снимаем бит:

chattr -i ewallet.p12
chattr -i ewallet.sso

chattr -i *wallet*

проверяем атрибуты файла 

lsattr *wallet*

----i--------e- cwallet.sso
----i--------e- ewallet.p12

11) Создаем ТП для зашифрованных данных

BIGFILE (один файл):

CREATE BIGFILE TABLESPACE ANNUAL_DATAENC 
DATAFILE '/u01/oracle/tables/ATMDB/ANNUAL_DATAENC01.dbf' 
SIZE 100M
AUTOEXTEND ON NEXT 100M
MAXSIZE 300G
LOGGING
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO
DEFAULT STORAGE ( ENCRYPT ) ENCRYPTION USING 'AES192';


SMALLFILE (несколько файлов):

CREATE SMALLFILE TABLESPACE ANNUAL_DATAENC DATAFILE
'/mnt/oracle/tables/ARCHDB/ANNUAL_DATAENC/ANNUAL_DATAENC01.dbf' SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 30000M ,
'/mnt/oracle/tables/ARCHDB/ANNUAL_DATAENC/ANNUAL_DATAENC02.dbf' SIZE 100M AUTOEXTEND ON NEXT 100M MAXSIZE 30000M
LOGGING
EXTENT MANAGEMENT LOCAL
SEGMENT SPACE MANAGEMENT AUTO
DEFAULT STORAGE ( ENCRYPT ) ENCRYPTION USING 'AES192';

12) Проверяем наличие зашифрованных ТП

col TS#       format 99999
col TSNAME    format a20
col ENCRYPTED format a10
col ALGORITM  format a10

select ts.TS#,
       ts.NAME              as TSNAME, 
       enc_ts.ENCRYPTEDTS   as ENCRYPTED, 
       enc_ts.ENCRYPTIONALG as ALGORITM,
       enc_ts.MASTERKEYID
from v$encrypted_tablespaces enc_ts,
     v$tablespace ts
where enc_ts.TS#(+) = ts.TS#
order by 4;

13) Экспорт зашифрованных данных используя открытый wallet без ввода пароля

все данные (и метаданные)

expdp infoware_enc/infoware DUMPFILE=EXP_INFOWARE_ENC_`date '+%d%m%y'`.DMP DIRECTORY=DATA_PUMP_DIR NOLOGFILE=Y SCHEMAS=infoware_enc COMPRESSION=ALL REUSE_DUMPFILES=Y PARALLEL=4 ENCRYPTION=all ENCRYPTION_MODE=TRANSPARENT

только данные (без метаданных)

expdp infoware_enc/infoware DUMPFILE=EXP_INFOWARE_ENC_`date '+%d%m%y'`.DMP DIRECTORY=DATA_PUMP_DIR NOLOGFILE=Y SCHEMAS=infoware_enc COMPRESSION=ALL REUSE_DUMPFILES=Y PARALLEL=4 ENCRYPTION=DATA_ONLY ENCRYPTION_MODE=TRANSPARENT


Problems:

12c Non-Container Database: ORA-28374 on CREATE TABLESPACE (Doc ID 2176258.1)

solution

1) Close the keystore:

  SQL> ADMINISTER KEY MANAGEMENT SET KEYSTORE CLOSE IDENTIFIED BY <wallet_password>;

2) Move the TDE wallet (ewallet.p12) to a backup location.

3) Create a new software keystore. Do NOT use ALTER SYSTEM to do this.

  SQL> ADMINISTER KEY MANAGEMENT CREATE KEYSTORE <wallet_directory> IDENTIFIED BY <wallet_password>;

4) Set the following hidden parameter.   

  SQL> ALTER SYSTEM SET "_db_discard_lost_masterkey"=TRUE SCOPE=MEMORY;

5) Open the keystore:

  SQL> ADMINISTER KEY MANAGEMENT SET KEYSTORE OPEN IDENTIFIED BY <wallet_password>;

6) Set a new master key:

  SQL> ADMINISTER KEY MANAGEMENT SET KEY IDENTIFIED BY <wallet_password> WITH BACKUP;

7) Shut down and restart the database.

8) Reopen the keystore (using step 5).

9) Create an encrypted tablespace.

10) Then re-enable auto_login by executing (see Doc ID 1944507.1)

administer key management create AUTO_LOGIN keystore from keystore '<wallet directory>' identified by  wallet_password;

File cwallet.sso - auto login wallet
File ewallet.p12 - wallet




