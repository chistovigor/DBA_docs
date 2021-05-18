-- Описание Processing Code

Processing Code описывет влияние операции на счет покупателя и тип счета.
Processing Code это шестизначное значение, состоящее из 3х позиций:
1) Позиция 1-2 - 00**** - тип операций
2) Позиция 3-4 - **00** - с какого счета происходит операция
3) Позиция 4-6 - ****00 - на какой счет происходит операция
00 - позиция

В совокупности всех позиций формируется Processing Code. Типы Processing Code:
 
Типы операций (позиция 1-2)

Списание со счета держателя карты

Processing Code Расшифровка
00****          Совершение покупки
01****          Снятие наличных
02****          Дебетовые корректировки
09****          Покупка с «Cash Back»
10****          Пополнение счет. Только для VISA! 
17****          Выдача наличных (кассовая операция)
18****          Снятие бонусов (бонусная эмиссия)

Пополнение счета держателя карты

Processing Code Расшифровка
20****          Возврат покупки
21****          Взнос на счет
22****          Краткосрочный кредит счета
23****          Гарантийный взнос на счет
24****          Чековый взнос на счет
28****          Платежная операция, расчетная операция

Запросы о счете

30****          Запрос баланса (ATM)

Переводы по счету

40****          Перевод по счету

Операции резервирования

90****          Резервирование суммы

Операции с PIN кодом

91****          Разблокировка PIN - кода
92****          Смена PIN - кода

Типы счетов, с которых происходят операции

С какого счета происходит операция (позиция 3-4)

Processing Code Расшифровка
**00**          Стандартный счет (без каких либо спецификаций)
**10**          Накопительный счет
**20**          Чековый счет
**30**          Счет кредитной карты
**38**          Кредитная линия счета
**39**          Корпоративный счет
**40**          Универсальный счет (идентификационный  номер покупателя)
**50**          Инвестиционный счет
**60**          Хранимый счет в памяти карты (Электронный кошелек)
**90**          Револьверный кредитный счет

На какой счет происходит операция (позиция 5-6)

****00          Стандартный счет (без каких либо спецификаций)
****10          Накопительный счет
****20          Чековый счет
****30          Счет кредитной карты
****40          Универсальный счет (идентификационный  номер покупателя)
****50          Инвестиционный счет
****58          IRA счета
****90          Револьверный кредитный счет
****91          Счета к получению в рассрочку
****92          Ссудный счет

-- просмотр кодов отказа в ONLINE

---reason AUTHORIZATIONS --

select * from systemreasons r where r.reasoncode in ('1113');
select * from issacpblocking;
select * from acprofiles where serno = 69;

select * from acpmccs;

--reason ACQUIRERLOG ---

select * from respcodemappings r
where r.inresponse = '900';

-- описание кодов отказа

select * from RESPCODES

-- Debit hosts response 

Если ReasonCode состоит из 4 цифр и начинается с 30 - 30xx (например, 3000, 3051),
то это ответ от New Interim. 3000 означает одобрение от New Interim, 
оно должно соответстовать RespCode=00 и наличию блокировки или холда в New Interim, 30xx,
где xx не равно 00 - означает отказ New Interim. Причину таких отказов нужно просматривать в New Interim.

-- Бриджи по картам находятся в 

\\Raiffeisen\DFS\RBA\MSK\Troitskaya\Workgroups\Retail Banking\Card Center\Personalization\PrimeBridge\PrimeBridge\2007\

--Если карта не блокируется из-за ошибки "Purge date", то т.к. впрайме пропало само поле Purge date, надо ее блокировать через базу Prime:
begin
util_support.Switch_Institution('36','SUPPORT');
il_iss_card.Update_Status( aCardxSerno => 'XXXXXX', aStGeneral =>'NOAU', aLogAction => 'Manual',aToday =>trunc(sysdate));
end;

где XXXXXX серно карты.

-- Выбор данных в RMCP для отображения информации по балансу кредитной карты в ICDB

  SELECT OCARDS.serno,
         OCARDS.groupserno1,
         OAPPLO.ltimestamp,
         OAPPLO.action,
         OAPPLO.oldvalue,
         OAPPLO.newvalue,
         (OAPPLO.newvalue - OAPPLO.oldvalue) AS SUMM,
         OAPPLO.username
    FROM APPLOG OAPPLO, CARDS OCARDS
   WHERE     OAPPLO.TABNAME = 'G'
         AND OAPPLO.COLNAME = 'otb'
         AND OAPPLO.ROWSERNO = OCARDS.GROUPSERNO1
         AND OCARDS.cardnumber IN ('&cardnumber')
ORDER BY OAPPLO.LTIMESTAMP;

-- Выбор данных по транзакциям в PRIME

-- для того, чтобы смотреть, были реждекты или нет, убираем BATCHES с селекте

SELECT *
  FROM MTRANSACTIONS m, MISOTRXNS mi, BATCHES b
 WHERE     M.SERNO = mi.SERNO
       AND M.PARTITIONKEY = mi.PARTITIONKEY
       --and M.INBATCHSERNO = B.SERNO
       AND MI.OUTBATCHSERNO = B.SERNO
       AND M.I002_NUMBER IN
              ('67XXXXXXXX41546236', '5487XXXXXXXX9924')
       AND MI.I037_RET_REF_NUM IN
              ('047189289763', '192748043087')

-- поиск операций (и файлов, в которые они попали) по нашим мерчантам в ONLINE

SELECT *
  FROM ACQUIRERLOG a,edcfile e
 WHERE     A.I041_POS_ID = '37663901'
       AND A.EDCSERNO = E.SERNO
       AND TRUNC (A.LTIMESTAMP) IN ('15-may-2015', '27-jun-2015')
       AND a.TRXNAMT IN (8300, 1600)		

-- если AMEX операции есть в ONLINE но нет в PRIME, хотя EDCSERNO,EDCFLAG стоит то для того, чтобы они попали в PRIME в следующем EDC:

устанавливаем I039_RESP_CD = '000' (вместо '900'), EDCSERNO = NULL, EDCFLAG = 'A'

-- поиск операций в PRIME по нашим мерчантам, когда есть часть номера мерчанта - 39646 - добавляем 15,16,17
-- перед номером и 001 после, и последние 4 цифры номера карты

SELECT *
  FROM mtransactions a, misotrxns b
 WHERE     a.serno = b.serno
       AND a.partitionkey = b.partitionkey
       AND SUBSTR (i002_number, 13, 4) = '&part_pan'
       AND i004_amt_trxn IN (&amnt_trxn)
       AND merserno IN (SELECT serno
                          FROM merchantx
                         WHERE numberx IN ('1539646001'))
			  
-- поиск операций не по нашим мерчантам

  SELECT *
    FROM ctransactions a, cisotrxns b
   WHERE     a.serno = b.serno
         AND a.partitionkey = b.partitionkey
         AND cardserno IN (SELECT serno
                             FROM cardx
                            WHERE numberx IN ('&cardnumber'))
ORDER BY a.serno
						  
-- поиск операций из NI, использую External ID (PRIME)

SELECT * FROM ctransactions a where a.SERNO = &primeid
			  
-- поиск проводок из Prime в Midas

-- serno транзакции из Prime (для новых транзакций -  ALPHA.TRX
select * from ALPHA.TRX_OLD a where A.N_PRIME_SERNO = 808836391;

-- берем N_TRX из предыдущего селекта
select * from ALPHA.A_ENTRIES a where A.N_TRX = 61440734;

-- берем N_ENTRY из предыдущего селекта
select * from ALPHA.ENTRIES e where E.N_ENTRY = 36981866;

-- берем N_JOB из предыдущего селекта
select * from ALPHA.JOBS j where J.N_JOB_ORIG = 18496;

-- соответствие номера счета в Prime и Midas
select * from CACCOUNTS c where C.NUMBERX = '40817810804000049308';

-- берем SERNO из предыдущего селекта, счет Midas - BANKACCOUNT
select * from CACCOUNTSTMT c where C.SERNO = 2402252;

-- поиск информации в APPLOG в PRIME (вводим ROWSERNO из PRIME WEB)

select * from APPLOG a where A.TABNAME = 'ctransactions' and A.ROWSERNO = &SerNo;

-- Выбор информации по счетам и картам клиентов из PRIME по CNUM

SELECT TRIM (CC.NUMBERX) AS CNUM,
       TRIM (CC.CUSTOMERNAME) ACC_CUST,
       CC.EMBCOMPANY,
       C.NUMBERX AS ACCOUNT,
       C.STAUTHORIZATION ACC_AUTH_STATUS,
       C.BALANCE ACC_BALANCE,
       C.PRIMARYCARDSERNO ACC_PRIM_CARD_SERNO,
       TRIM (CA.NUMBERX) AS cardnumber,
       CA.SERNO AS CARD_SERNO,
       CA.EXTERNALREFERENCE CARD_EXT_REF,
       CASE WHEN CA.PRIMARYCARD = 1 THEN 'YES' ELSE 'no' END IS_PRIMARY,
       CASE WHEN CA.EXPIRYDATESTATUS = 'A' THEN 'YES' ELSE 'no' END IS_ACTIVE,
       CA.STGENERAL CARD_GEN_ST,
       CA.STAUTHORIZATION CARD_AUTH_ST,
       CA.EXPIRYDATE EXP_DATE,
       CA.PREVIOUSEXPIRYDATE PREV_EXP_DATE,
       CA.CREATEDATE CARD_CREATED,
       CA.CLOSEDATE CARD_CLOSED,
       CA.PRODUCT CARD_PRODUCT,
       CA.RISKDOMAINSERNO CARD_RISKDOMAIN,
       CC.STGENERAL AS ACC_STGENERAL,
       CC.CREATEDATE ACC_CREATED,
       CC.PEOPLESERNO ACC_PEOPLE,
       C.RISKDOMAINSERNO,
       CC.PRODUCT CUST_PRODUCT,
       C.PRODUCT ACC_PRODUCT,
       CC.CURRENCY CUST_CURR,
       C.CURRENCY ACC_CURR,
       C.CREDITLIMIT ACC_CREDITLIMIT,
       C.FEEPROFSERNO ACC_FEE_PROFILE,
       C.TRXNFEEPROFSERNO ACC_TRXN_FEE,
       C.LASTTRXNPOSTDATE ACC_LAST_POSTING,
       C.LOGACTION ACC_LOCATION,
       CA.PEOPLESERNO CARD_PEOPLE
  FROM CCUSTOMERS cc, CACCOUNTS c, CARDX ca
 WHERE     cc.NUMBERX = '&CNUM'
--       AND SUBSTR(TRIM(CA.NUMBERX),13,4) = '&card_mask'
       AND cc.SERNO = c.CUSTSERNO(+)
       AND CA.CACCSERNO(+) = C.SERNO;

-- Назначение пин кода по карте в IVR

в WEBDB_A в схеме IVR_AUTH выполняем

select * from event_auth_log where cardid = &external_ref

если у нас данных нет, то отвечаем:

До нас запросы по данной карте не дошли. Обращайтесь на группу ONLINE

-- Проверка ACP profiles

-- ищем карту

SELECT *
  FROM cards
 WHERE cardnumber = '&Card_number';

-- смотрим, какие профайлы действуют

SELECT *
  FROM acpcardgrouplink a
 WHERE a.cardserno = (SELECT serno
                        FROM cards
                       WHERE cardnumber = '&Card_number');

-- смотрим, какие профайлы есть в Prime (если их больше, задаем их снова и отправляем карту в ONLINE)

SELECT *
  FROM acplinks@primedblink
 WHERE rowserno = (SELECT PRIMECARDSERNO
                     FROM cards
                    WHERE cardnumber = '&Card_number');
					
-- одним селектом

  SELECT onl.ACPSERNO AS ONL_ACPSERNO,
         prm.ACPROFILESERNO AS PRM_ACPROFILESERNO,
         prm.STATUS AS PRM_STATUS,
         onl.INSTITUTION_ID,
         onl.CARDSERNO AS ONL_CARDSERNO,
         prm.TABINDICATOR AS PRM_TABINDICATOR,
         prm.SERNO AS PRM_SERNO
    FROM acpcardgrouplink onl, acplinks@primedblink prm
   WHERE     onl.cardserno = (SELECT serno
                                FROM cards
                               WHERE cardnumber = '&Card_number')
         AND prm.rowserno = (SELECT PRIMECARDSERNO
                               FROM cards
                              WHERE cardnumber = '&Card_number')
         AND prm.ACPROFILESERNO = ONL.ACPSERNO
         AND prm.STATUS = 'A'                                            --'C'
ORDER BY 1;
 

-- Проверка отправленных смс по картам на PrimeAccounting (кредитные карты)

Ищем serno операции в PrimeWeb, по которой не пришла смс

--В ONLINE

-- выбираем из очереди операции в этим serno
select * from NTFMESSAGES where EVENTENTITYSERNO IN (242850224,242858885);

-- если там сообщений нет, проверяем customer alert profile по карте, если он есть, то 
-- смотрим таблицу логов приложения за время, равное времени авторизации (логи пакета TCTDBS.BL_NOTIFICATION)

  SELECT *
    FROM SYSTEMTRACEERRORLOG
   WHERE APPDATETIMESTAMP BETWEEN TO_TIMESTAMP ('09.07.2015 01:28:00',
                                                'DD.MM.YYYY HH24:MI:SS')
                              AND TO_TIMESTAMP ('09.07.2015 01:28:30',
                                                'DD.MM.YYYY HH24:MI:SS')
ORDER BY APPDATETIMESTAMP;

-- выбираем параметры сообщений (используя serno предыдущих полученных операций)
select * from NTFMESSAGECHANNELS where serno IN (1849658,1851279);

--В PRIME
-- выбираем параметры XML (эти XML отправляются в Rconnect) сообщений (используя serno полученных в ONLINE операций, если статус у них 'SUCC')
select * from QTBL_NTFOUTGOING_RAIFF q where Q.USER_DATA.SERNO IN (1849658,1851279);

-- Поиск данных в схеме АМ

-- выбор информации о клиенте по счету карты в Prime
SELECT * FROM AM.AM_CLIENTS A WHERE A.c3 = 40817810901002803560;
-- выбор сообщений по ROWSERNO этого клиента
SELECT * FROM AM.AM_EVENTS A WHERE a.CLIENTROWSERNO = 4242156 order by TIMESTAMP;

-- БИНы Российских банков

SELECT issuerbin
  FROM tctdbs.visaardef@PRIME_PROD
 WHERE country = 'RU'
UNION ALL
SELECT SUBSTR (m_iss_bin_low, 1, 6) AS issuerbin
  FROM tctdbs.ipmissica@PRIME_PROD
 WHERE m_iss_country = 'RUS';
 
 -- наши БИНы
 
substr(i002_number,1,6) in (select bin from rbt_onus_bins);
 
 -- поиск и изменение PRIMARYCARD для счета (например, при не отправке СМС уведомлений по закрытой PRIMARYCARD)
 
 SELECT *
  FROM CARDX
 WHERE CACCSERNO IN (SELECT serno
                       FROM CACCOUNTS
                      WHERE numberx = '&account_number');
                      
-- ставим флаг PRIMARYCARD

SELECT *
  FROM CACCOUNTS
 WHERE numberx = '&account_number';
 
 -- ставим PRIMARYCARDSERNO = SERNO основной карты
 
 -- поиск транзакций в Prime (ушли от нас или нет)
 
 select * from mtransactions a,misotrxns b where a.serno = b.serno and a.partitionkey = b.partitionkey
and i002_number = '&Card_number' 
and i004_amt_trxn in (10000)

-- смс уведомления и поддержка Rconnect

группа с Remedy ELBA_Retail_admins (Андреев Максим Павлович) -  это поддержка Rconnect
SMS для ЮР лиц - ELBA_Corporate_admins

-- снятие блокировок

По разблокировке суммы вам необходимо обратиться в CardCenter_Operations

-- Информация по СМС-услуге по карте (для получения файла SMS_PHONE.txt добавляем в xls файл формулу):

=E3&"|"&F3&"|N|"

-- определение типа операции по карте (полоса, чип, бесконт.)

поле I022_POS_ENTRY (0510 - чип)

--В Alpha есть представление DBMAN.V_SAS_MRC_ATM, которое содержит данные по списку ATM

C_NATM             -- номер ATM
C_HUB_ABR          -- Название ХАБа (короткое)
C_HUB_NAME         -- Название ХАБа (полное) 
C_MRC_INDEX        -- индекс
C_CITY_NAME        -- название населенного пункта
C_MRC_ADDR         -- Полный адрес (без населенного пункта) 
C_MRC_CMP_NAME     -- название компании
C_MRC_RUB          -- мерчант для RUB
C_MRC_USD          -- мерчант для USD
C_MRC_EUR          -- мерчант для EUR
C_MRC_MOB          -- мерчант для платежей
CF_MRC_ATM_CASH_IN -- признак работы ATM c Cash-In ('Y' - да, 'N' - нет)
CF_MRC_ATM_NET     -- Код сети (A, B)
CF_MRC_ATM_STAT    -- cтатус строки на регистрацию ATM ('P' - готова для заведения в Prime, 'A' - заведена в Prime, 'D' - удалена)
D_ATM_INS          -- дата вставки строки

-- find transaction in AUTHORIZATIONS

SELECT *
  FROM AUTHORIZATIONS
 WHERE 1=1
 --AND ltimestamp BETWEEN TO_TIMESTAMP ('19.05.2014 00:00:00','DD.MM.YYYY HH24:MI:SS') AND TO_TIMESTAMP ('19.05.2014 23:59:59','DD.MM.YYYY HH24:MI:SS')
 AND i002_number = '&Card_number'
-- AND I041_POS_ID = '31948001'
-- AND SERNO = 157086322
-- AND I038_AUTH_ID = '745623'
-- AND I000_MSG_TYPE = '0110'
-- AND substr(I003_PROC_CODE,0,2) = '00'
-- AND serno = 187217570
-- AND  I042_MERCH_ID = '1531693001'
order by 4 desc

  SELECT a.serno,
         A.LTIMESTAMP,
         a.CARDBIN,
         a.SOURCE,
		 A.I039_RSP_CD,
         a.EODSERNO,
         A.EDCSERNO,
         A.I000_MSG_TYPE,
         A.I002_NUMBER,
         A.I003_PROC_CODE,
         A.I004_AMT_TRXN,
         a.I012_LCL_TIME,
         a.I013_LCL_DT,
         a.I014_EXP_DATE,
         A.I037_RET_REF_NUM,
         A.I038_AUTH_ID,
         A.I041_POS_ID,
         A.I043A_MERCH_NAME,
         A.TRANSACTION_ID
    FROM AUTHORIZATIONS a
   WHERE a.i002_number IN
            ('4627XXXXXXXX9881', '4627XXXXXXXX7931', '4627XXXXXXXX2000')
ORDER BY 1

-- поиск транзакция из отчета МКБ в авторизациях по serno

SELECT ltimestamp,
       I022_POS_ENTRY,
       I025_POS_COND,
       I032_ACQUIRER_ID,
       I037_RET_REF_NUM,
       I038_AUTH_ID,
       I042_MERCH_ID,
       I043A_MERCH_NAME
  FROM raiff.authorizations@ONLINE_PROD a
 WHERE a.serno IN (254667184, 255373997, 255512898, 255790967, 259788603)
 
-- find transaction in ACQUIRERLOG

SELECT *
  FROM ACQUIRERLOG
 WHERE 1=1
 --AND ltimestamp BETWEEN TO_TIMESTAMP ('19.05.2014 00:00:00','DD.MM.YYYY HH24:MI:SS') AND TO_TIMESTAMP ('19.05.2014 23:59:59','DD.MM.YYYY HH24:MI:SS')
 AND i002_number = '5417XXXXXXX444'
-- AND SERNO = 142439619
-- AND I038_AUTH_ID = '603757'
-- AND I000_MSG_TYPE = '0212'
-- AND substr(I003_PROC_CODE,0,2) = '00'
-- AND I039_RESP_CD = '00'
-- AND serno = 171390026
-- AND  I042_MERCH_ID = '1531693001'
order by 3 desc
/

  SELECT a.serno,
         A.I000_MSG_TYPE,
         A.I002_NUMBER,
         A.I003_PROC_CODE,
         A.I004_AMT_TRXN,
         A.I037_RET_REF_NUM,
		 A.I038_AUTH_ID,
         A.I039_RESP_CD,
         A.I041_POS_ID,
         A.I043A_MERCH_NAME,
         A.LTIMESTAMP,
         A.ENDTIME,
         A.SOURCE,
         A.PROCESS_NAME,
         A.ORIGSERNUM,
         A.EDCFLAG,
         A.EDCSERNO,
         A.TRXNDATETIME,
         A.TRXNAMT,
         A.TRXNCUR,
         A.TRXNINVOICE,
         A.TERMINALSERNO,
         A.MERCHANTSERNO,
         A.TRANSACTION_ID
    FROM ACQUIRERLOG a
   WHERE     1 = 1
         AND ltimestamp BETWEEN TO_TIMESTAMP ('01.04.2015 11:12:30',
                                              'DD.MM.YYYY HH24:MI:SS')
                            AND TO_TIMESTAMP ('02.04.2015 14:13:59',
                                              'DD.MM.YYYY HH24:MI:SS')
         AND i002_number = '&Card_number'
-- AND SERNO = 142439619
-- AND I038_AUTH_ID = '603757'
-- AND I000_MSG_TYPE = '0212'
-- AND substr(I003_PROC_CODE,0,2) = '00'
-- AND I039_RESP_CD = '00'
-- AND serno = 171390026
ORDER BY 1

-- изменение выгрузки в EDC нереконселированных транзакций

в ACQUIRERLOG поставить EDCFLAG = A (он будет равен R) и проверить ,что EDCSERNO пустой

изменение в TOAD

edit ACQUIRERLOG where serno in (176513560,176512766)

-- анализ операций, прошедших по счету New Interim дважды (поиск по дате и сумме транзакции) - Сторнированием занимается группа RBRU-BO_ICDB_RBM-CBO_Acquiring-MSK

  SELECT t.ltimestamp,
         t.edcflag,
         t.edcserno,
         t.reasoncode,
         t.i003_proc_code,
         t.i000_msg_type,
         t.i002_number,
         t.i004_amt_trxn,
         t.i039_resp_cd,
         t.i038_auth_id,
         t.i037_ret_ref_num,
		 t.I042_MERCH_ID,
         t.I043A_MERCH_NAME,
         t.i018_merch_type
    FROM acquirerlog t
   WHERE     t.ltimestamp >= TO_DATE ('22042015', 'ddmmyyyy')
         AND t.i002_number IN (SELECT c.cardnumber
                                 FROM cards c
                                WHERE c.externalreference = &ref_num)
         AND t.i004_amt_trxn = &Сумма
ORDER BY t.ltimestamp;

-- за вчера и сегодня

  SELECT t.ltimestamp,
         t.edcflag,
         t.edcserno,
         t.reasoncode,
         t.i003_proc_code,
         t.i000_msg_type,
         t.i002_number,
         t.i004_amt_trxn,
         t.i039_resp_cd,
         t.i038_auth_id,
         t.i037_ret_ref_num,
         t.I042_MERCH_ID,
         t.I043A_MERCH_NAME,
         t.i018_merch_type
    FROM acquirerlog t
   WHERE     t.ltimestamp BETWEEN TO_DATE (TO_CHAR (SYSDATE - 1, 'ddmmyyyy'),
                                           'ddmmyyyy')
                              AND TO_DATE (TO_CHAR (SYSDATE, 'ddmmyyyy'),
                                           'ddmmyyyy')
         AND t.i002_number IN (SELECT c.cardnumber
                                 FROM cards c
                                WHERE c.externalreference = &ref_num)
         AND t.i004_amt_trxn = &Сумма
ORDER BY t.ltimestamp;

-- информация из авторизации (НЕ ОБЯЗАТЕЛЬНО)

  SELECT a.ltimestamp,
         a.edcserno,
         a.reasoncode,
         a.i003_proc_code,
         a.i000_msg_type,
         a.i002_number,
         a.i004_amt_trxn,
         a.i039_rsp_cd,
         a.i038_auth_id,
         a.i037_ret_ref_num,
         A.I042_MERCH_ID
    FROM AUTHORIZATIONS a
   WHERE     a.ltimestamp >= TO_DATE ('27072015', 'ddmmyyyy')
         AND a.i002_number IN (SELECT c.cardnumber
                                 FROM cards c
                                WHERE c.externalreference = &ref_num)
         AND a.i004_amt_trxn = &Сумма
ORDER BY a.ltimestamp;

-- анализ переводов C2C

-- переводы в R-connect (схема RC_VSMC в ULTRA)

select * From VMT_REQUESTS r
where R.D_CARDPAN='&Card_number'
order by R.REQUESTID desc;

--

  SELECT t.serno,
         t.ltimestamp "C2C_time",
         A.LTIMESTAMP AS "Destination_card_time",
         t.edcflag,
         t.edcserno,
         t.reasoncode,
         t.i000_msg_type,
         t.i003_proc_code,
         t.i002_number,
         t.i004_amt_trxn "SUMM_TRXN",
         t.i039_resp_cd || '- ' || TRIM (r.description) "Description_error",
         t.i041_pos_id,
         t.i042_merch_id,
         t.i043a_merch_name,
         t.i037_ret_ref_num,
         t.i038_auth_id,
         REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') "CARD_NUM_С2C",
            A.I039_RSP_CD
         || '- '
         || CASE r1.description
               WHEN NULL THEN 'No data in authorizations'
               ELSE TRIM (r1.description)
            END
            "C2C_error",
         CASE TRIM (c.CARDHOLDERDATA)
            WHEN 'R' THEN 'Resident'
            ELSE 'NOT resident or NOT OUR CARD'
         END
            AS "C2C_Residence",
         c.EXPIRYDATE AS "C2C_EXPDATE",
         c.PREVEXPIRY AS "C2C_PREV_EXPDATE",
         c.STAUTHORIZATION AS "C2C_AUTH_STATE",
         c.ACTION_RESCODE AS "C2C_STATUS",
         c.AUTHCURRENCY AS "C2C_AUTH_CURRENCY"
    FROM acquirerlog t,
         respcodes r,
         authorizations a,
         respcodes r1,
         cards c
   WHERE     1 = 1
         AND C.CARDNUMBER(+) =
                CAST (
                   REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
         AND r.code = t.i039_resp_cd
         AND r1.code(+) = a.I039_RSP_CD
         AND A.I037_RET_REF_NUM(+) = T.I037_RET_REF_NUM
         AND A.I002_NUMBER(+) =
                CAST (
                   REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
         AND t.ltimestamp >= TO_DATE ('06032015', 'ddmmyyyy')
         AND T.I000_MSG_TYPE = '0110'
         AND t.i002_number IN ('4627291478269111')
         AND t.i003_proc_code <> '300000'
         AND t.i018_merch_type NOT IN ('6011', '6010', '9999')
         AND r.format = 'V'
         AND r1.format(+) = 'V'
ORDER BY t.ltimestamp;


-- шаблон письма ответа о переводах

SELECT wmsys.wm_concat (
               CHR (10)               
            || CHR (13)|| '******** ПЕРЕВОД ОТ '|| TO_CHAR (t.LTIMESTAMP, 'DD-MM-YYYY HH24:MI:SS')|| ' *********'
            || CHR (13)|| 'ДАТА СОЗДАНИЯ ПЕРЕВОДА: '|| TO_CHAR (t.LTIMESTAMP, 'DD-MM-YYYY HH24:MI:SS')
            || CHR (13)|| 'ДАТА ОСУЩЕСТВЛЕНИЯ ПЕРЕВОДА: '|| TO_CHAR (T1.LTIMESTAMP, 'DD-MM-YYYY HH24:MI:SS')                     
            || CHR (13)|| 'ФИО ОТПРАВИТЕЛЯ: ' || cast(TRIM(pp.lastname)|| ' ' ||TRIM(pp.firstname)|| ' ' || TRIM(pp.midname) as char(40))
            || CHR (13)|| 'CNUM ОТПРАВИТЕЛЯ: ' || caa.numberx
            || CHR (13)|| 'СЧЕТ ОТПРАВИТЕЛЯ: '|| ca.numberx
            || CHR (13)|| 'НОМЕР КАРТЫ ОТПРАВИТЕЛЯ: '|| substr(t.i002_number,1,6)||'******'||substr(t.i002_number,13,4)
            || CHR (13)|| 'EXPIRYDATE КАРТЫ ОТПРАВИТЕЛЯ: '||c1.expirydate
            || CHR (13)|| 'СУММА ПЕРЕВОДА: '|| t.i004_amt_trxn
            || CHR(13) || 'ВАЛЮТА ПЕРЕВОДА: '|| decode(t.i019_acq_country,
                                                     '643','Рубли',
                                                     '840','Доллары',
                                                     '978','Евро',
                                                     t.i004_amt_trxn)
            || CHR (13)|| 'СТАТУС ПЕРЕВОДА ОТ НАС: '|| CASE(t.i039_resp_cd)
                                                       WHEN '00' THEN 'УСПЕШНЫЙ '
                                                       ELSE 'НЕ УСПЕШНЫЙ, '
                                                       END||t.i039_resp_cd ||'- '|| TRIM (r.description)
            || CHR (13)|| 'TERMINAL_ID: '|| t.i041_pos_id
            || CHR (13)|| 'MERCHANT_ID: '|| TRIM (t.i042_merch_id)
            || CHR (13)|| 'MERCHANT_NAME: '|| TRIM (t.i043a_merch_name)
            || CHR (13)|| 'RRN_ОПЕРАЦИИ: '|| t.i037_ret_ref_num
            || CHR (13)|| 'КОД АВТОРИЗАЦИИ: '|| t.i038_auth_id
            || CHR (13)|| '        '||'*** ДАННЫЕ О ПОЛУЧАТЕЛЕ: ***'||'                                   '
            || CHR (13)|| 'СТАТУС ПЕРЕВОДА НА СТОРОНЕ ПОЛУЧАТЕЛЯ: '|| CASE(t1.i039_resp_cd)
                                                                  WHEN '00' THEN 'УСПЕШНЫЙ '
                                                                  ELSE 'НЕ УСПЕШНЫЙ '
                                                                  END  ||t1.i039_resp_cd ||'- '|| r3.description
            || CHR (13)|| 'КАРТА ПОЛУЧАТЕЛЯ: '|| Substr(REPLACE(substr(t.i104_tran_desc,26,35),'F',''),1,6)||'******'||
Substr(REPLACE(substr(t.i104_tran_desc,26,35),'F',''),13,4)
            || CHR (13)|| 'КАРТА ПОЛУЧАТЕЛЯ FULL NUMBER: '|| REPLACE(substr(t.i104_tran_desc,26,35),'F','')
            || CHR (13)|| 'CNUM ПОЛУЧАТЕЛЯ: ' ||NVL (
                  TO_CHAR (caa1.numberx),
                  'НЕТ ДАННЫХ: "Получатель не клиент Raiffeisenbank" ') 
            || CHR (13)|| 'СЧЕТ ПОЛУЧАТЕЛЯ: ' ||NVL (
                  TO_CHAR (ca1.numberx),
                  'НЕТ ДАННЫХ: "Получатель не клиент Raiffeisenbank" ') 
            || CHR (13)|| 'ФИО ПОЛУЧАТЕЛЯ: '||NVL2 (pp1.lastname,TO_CHAR(
                  cast(TRIM(pp1.lastname)|| ' ' ||TRIM(pp1.firstname)|| ' ' || TRIM(pp1.midname) as char(40))),
                  'НЕТ ДАННЫХ: "Получатель не клиент Raiffeisenbank" ')
            || CHR (13)|| 'КАТЕГОРИЯ ПОЛУЧАТЕЛЯ: '|| CASE TRIM (c.CARDHOLDERDATA)
                  WHEN 'R'
                  THEN
                     'Resident'
                  WHEN 'N'
                  THEN
                     'No Resident'
                  WHEN NULL
                  THEN
                     'Клиент банка, нет данных'
                  ELSE
                     'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank"'
               END
            || CHR (13)|| 'EXPIRYDATE КАРТЫ ПОЛУЧАТЕЛЯ: '|| NVL (
                  TO_CHAR (c.EXPIRYDATE),
                  'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank" ')
            || CHR (13)|| 'СТАТУС КАРТЫ ПОЛУЧАТЕЛЯ: '|| NVL (
                  TO_CHAR (c.ACTION_RESCODE),
                  'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank" ')
            || CHR (13)|| 'ВАЛЮТА КАРТЫ ПОЛУЧАТЕЛЯ: '|| NVL (
                  TO_CHAR (DECODE (c.AUTHCURRENCY,
                  '643','Рубли',
                  '840','Доллары',
                  '978','Евро')),
                  'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank" ')
            || CHR (13)|| '===========================================')
            || CHR (13)|| '==========================================='
            AS c2c_info
    FROM acquirerlog t,
         acquirerlog t1,   
         respcodes r,
         authorizations a,
         respcodes r1,
         cards c,
         cards c1,
         respcodes r3,
         cardx@primedblink cp,
         caccounts@primedblink ca,
         ccustomers@primedblink caa,
         people@primedblink pp,
         cardx@primedblink cp1,
         caccounts@primedblink ca1,
         ccustomers@primedblink caa1,
         people@primedblink pp1
         
   WHERE     1 = 1
         AND C.CARDNUMBER(+) =
                CAST (
                   REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
         AND r.code = t.i039_resp_cd
         AND r1.code(+) = a.I039_RSP_CD
         AND r3.code(+) = t1.i039_resp_cd
         AND A.I037_RET_REF_NUM(+) = T.I037_RET_REF_NUM
         AND A.I002_NUMBER(+) =
                CAST (
                   REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
         AND t1.i002_number(+)  =  CAST (
                   REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
         AND t.i002_number = c1.cardnumber          
         AND t.interfacemsgid = t1.interfacemsgid(+)   
         AND t.i002_number = cp.numberx 
         AND ca.serno = cp.caccserno 
         AND ca.custserno = caa.serno
         AND cp.peopleserno = pp.serno
         AND CAST (
                   REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25)) = cp1.numberx (+)
         AND ca1.serno (+) = cp1.caccserno 
         AND ca1.custserno = caa1.serno (+)
         AND cp1.peopleserno = pp1.serno (+)
         AND t.ltimestamp >= TO_DATE ('&Date', 'ddmmyyyy')
         AND T.I000_MSG_TYPE = '0110'
         AND t.i002_number = '&Card_number'
         AND t.i003_proc_code not in ('300000','260000','280000')
         AND t.i018_merch_type NOT IN ('6011', '6010','9999')
         AND r.format(+) = 'V'
         AND r1.format(+) = 'V'
         AND r3.format(+) = 'V'
ORDER BY t.ltimestamp;

-- со сторонним банком

/* Formatted on 17/04/2015 16:01:09 (QP5 v5.227.12220.39754) */
  SELECT    wmsys.wm_concat (
                  CHR (10)
               || CHR (13)
               || '******** ПЕРЕВОД ОТ '
               || TO_CHAR (t.LTIMESTAMP, 'DD-MM-YYYY HH24:MI:SS')
               || ' *********'
               || CHR (13)
               || 'ДАТА СОЗДАНИЯ ПЕРЕВОДА: '
               || TO_CHAR (t.LTIMESTAMP, 'DD-MM-YYYY HH24:MI:SS')
               || CHR (13)
               || 'ДАТА ОСУЩЕСТВЛЕНИЯ ПЕРЕВОДА: '
               || TO_CHAR (T1.LTIMESTAMP, 'DD-MM-YYYY HH24:MI:SS')
               || CHR (13)
               || 'ФИО ОТПРАВИТЕЛЯ: '
               || CAST (
                        TRIM (pp.lastname)
                     || ' '
                     || TRIM (pp.firstname)
                     || ' '
                     || TRIM (pp.midname) AS CHAR (40))
               || CHR (13)
               || 'CNUM ОТПРАВИТЕЛЯ: '
               || caa.numberx
               || CHR (13)
               || 'СЧЕТ ОТПРАВИТЕЛЯ: '
               || ca.numberx
               || CHR (13)
               || 'НОМЕР КАРТЫ ОТПРАВИТЕЛЯ: '
               || SUBSTR (t.i002_number, 1, 6)
               || '******'
               || SUBSTR (t.i002_number, 13, 4)
               || CHR (13)
               || 'EXPIRYDATE КАРТЫ ОТПРАВИТЕЛЯ: '
               || c1.expirydate
               || CHR (13)
               || 'СУММА ПЕРЕВОДА: '
               || t.i004_amt_trxn
               || CHR (13)
               || 'ВАЛЮТА ПЕРЕВОДА: '
               || DECODE (t.i019_acq_country,
                          '643', 'Рубли',
                          '840', 'Доллары',
                          '978', 'Евро',
                          t.i004_amt_trxn)
               || CHR (13)
               || 'СТАТУС ПЕРЕВОДА ОТ НАС: '
               || CASE (t.i039_resp_cd)
                     WHEN '00' THEN 'УСПЕШНЫЙ '
                     ELSE 'НЕ УСПЕШНЫЙ, '
                  END
               || t.i039_resp_cd
               || '- '
               || TRIM (r.description)
               || CHR (13)
               || 'TERMINAL_ID: '
               || t.i041_pos_id
               || CHR (13)
               || 'MERCHANT_ID: '
               || TRIM (t.i042_merch_id)
               || CHR (13)
               || 'MERCHANT_NAME: '
               || TRIM (t.i043a_merch_name)
               || CHR (13)
               || 'RRN_ОПЕРАЦИИ: '
               || t.i037_ret_ref_num
               || CHR (13)
               || 'КОД АВТОРИЗАЦИИ: '
               || t.i038_auth_id
               || CHR (13)
               || '        '
               || '*** ДАННЫЕ О ПОЛУЧАТЕЛЕ: ***'
               || '                                   '
               || CHR (13)
               || 'СТАТУС ПЕРЕВОДА НА СТОРОНЕ ПОЛУЧАТЕЛЯ: '
               || CASE (t1.i039_resp_cd)
                     WHEN '00' THEN 'УСПЕШНЫЙ '
                     ELSE 'НЕ УСПЕШНЫЙ '
                  END
               || t1.i039_resp_cd
               || '- '
               || r3.description
               || CHR (13)
               || 'КАРТА ПОЛУЧАТЕЛЯ: '
               || SUBSTR (REPLACE (SUBSTR (t.i104_tran_desc, 26, 35), 'F', ''),
                          1,
                          6)
               || '******'
               || SUBSTR (REPLACE (SUBSTR (t.i104_tran_desc, 26, 35), 'F', ''),
                          13,
                          4)
               || CHR (13)
               || 'КАРТА ПОЛУЧАТЕЛЯ FULL NUMBER: '
               || REPLACE (SUBSTR (t.i104_tran_desc, 26, 35), 'F', '')
               || CHR (13)
               || 'CNUM ПОЛУЧАТЕЛЯ: '
               || NVL (
                     TO_CHAR (caa1.numberx),
                     'НЕТ ДАННЫХ: "Получатель не клиент Raiffeisenbank" ')
               || CHR (13)
               || 'СЧЕТ ПОЛУЧАТЕЛЯ: '
               || NVL (
                     TO_CHAR (ca1.numberx),
                     'НЕТ ДАННЫХ: "Получатель не клиент Raiffeisenbank" ')
               || CHR (13)
               || 'ФИО ПОЛУЧАТЕЛЯ: '
               || NVL2 (
                     pp1.lastname,
                     TO_CHAR (
                        CAST (
                              TRIM (pp1.lastname)
                           || ' '
                           || TRIM (pp1.firstname)
                           || ' '
                           || TRIM (pp1.midname) AS CHAR (40))),
                     'НЕТ ДАННЫХ: "Получатель не клиент Raiffeisenbank" ')
               || CHR (13)
               || 'КАТЕГОРИЯ ПОЛУЧАТЕЛЯ: '
               || CASE TRIM (c.CARDHOLDERDATA)
                     WHEN 'R'
                     THEN
                        'Resident'
                     WHEN 'N'
                     THEN
                        'No Resident'
                     WHEN NULL
                     THEN
                        'Клиент банка, нет данных'
                     ELSE
                           '"Имя стороннего банка":'
                        || banks.M_MEMBERNAME
                  END
               || CHR (13)
               || 'EXPIRYDATE КАРТЫ ПОЛУЧАТЕЛЯ: '
               || NVL (
                     TO_CHAR (c.EXPIRYDATE),
                     'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank" ')
               || CHR (13)
               || 'СТАТУС КАРТЫ ПОЛУЧАТЕЛЯ: '
               || NVL (
                     TO_CHAR (c.ACTION_RESCODE),
                     'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank" ')
               || CHR (13)
               || 'ВАЛЮТА КАРТЫ ПОЛУЧАТЕЛЯ: '
               || NVL (
                     TO_CHAR (
                        DECODE (c.AUTHCURRENCY,
                                '643', 'Рубли',
                                '840', 'Доллары',
                                '978', 'Евро')),
                     'НЕТ ДАННЫХ: "получатель не клиент Raiffeisenbank" ')
               || CHR (13)
               || '===========================================')
         || CHR (13)
         || '==========================================='
            AS c2c_info
    FROM acquirerlog t,
         acquirerlog t1,
         respcodes r,
         authorizations a,
         respcodes r1,
         cards c,
         cards c1,
         respcodes r3,
         cardx@primedblink cp,
         caccounts@primedblink ca,
         ccustomers@primedblink caa,
         people@primedblink pp,
         cardx@primedblink cp1,
         caccounts@primedblink ca1,
         ccustomers@primedblink caa1,
         people@primedblink pp1,
         ipmissica@primedblink ipm,
         IPMIP0072T1@primedblink banks
   WHERE     1 = 1
         AND C.CARDNUMBER(+) =
                CAST (
                   REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
         AND r.code = t.i039_resp_cd
         AND r1.code(+) = a.I039_RSP_CD
         AND r3.code(+) = t1.i039_resp_cd
         AND A.I037_RET_REF_NUM(+) = T.I037_RET_REF_NUM
         AND A.I002_NUMBER(+) =
                CAST (
                   REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
         AND t1.i002_number(+) =
                CAST (
                   REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25))
         AND t.i002_number = c1.cardnumber
         AND t.interfacemsgid = t1.interfacemsgid(+)
         AND t.i002_number = cp.numberx
         AND ca.serno = cp.caccserno
         AND ca.custserno = caa.serno
         AND cp.peopleserno = pp.serno
         AND CAST (
                REPLACE (SUBSTR (t.i104_tran_desc, 26), 'F', '') AS CHAR (25)) =
                cp1.numberx(+)
         AND ca1.serno(+) = cp1.caccserno
         AND ca1.custserno = caa1.serno(+)
         AND cp1.peopleserno = pp1.serno(+)
         AND t.ltimestamp >= TO_DATE ('&Date', 'ddmmyyyy')
         AND T.I000_MSG_TYPE = '0110'
         AND t.i002_number = '&Card_number'
         AND t.i003_proc_code NOT IN ('300000', '260000', '280000')
         AND t.i018_merch_type NOT IN ('6011', '6010', '9999')
         AND r.format(+) = 'V'
         AND r1.format(+) = 'V'
         AND r3.format(+) = 'V'
         AND SUBSTR (REPLACE (SUBSTR (t.i104_tran_desc, 26, 35), 'F', ''),
                     1,
                     6) = SUBSTR (ipm.m_iss_bin_low(+), 1, 6)
         AND banks.M_MEMBERID(+) = ipm.M_MEMBERID
ORDER BY t.ltimestamp;

-- анализ фишек (FEE - сервисный сбор по транзакциям)

--переключение INSTITUTION для VPD
begin
  util_support.Switch_Institution(36,'SUPPORT');
end;

select * from raiff.rbt_src_list where src='YQ'--RUR_YQ    
select * from profiles where description='RUR_YQ'--1379
select t.*,rowid from trxnfees t where profileserno=1379 
--ищем строку с TRXNTYPESERNO = 2005 - это тип интересующей нас транзакции
select * from trxntypes where usedfor='F'
 
 -- неверные лимиты по картам
 
Таблица GROUPS в ONLINE, столбец AUTHACCOUNTTYPE для второй группы должен быть 40, для первой - 30 (дебетовые карты)
Cash OTB - лимит на снятие (Primary Group 2 - в день, Primary Group 1 - в месяц)
 
select * from GROUPS where NAME = '00112878782643';
 
--Total OTB это общий (месячный) лимит по всем операциям по карте, в том числе и кэш операций. Кэш лимит у клиента обновляется каждый день

--авторизации

select case when (a.i000_msg_type = '0110' and a.i003_proc_code like '0%') or (a.i000_msg_type = '0410' and a.i003_proc_code = '500000') then (-1)*a.i006_amt_bill
  else i006_amt_bill end case,
    a.serno,a.origserno, a.i039_rsp_cd,a.reasoncode,a.i000_msg_type,a.i003_proc_code,trunc(a.ltimestamp+0),a.matchtime+0,a.i002_number,
a.i004_amt_trxn, a.*
from authorizations a where 1=1
and a.i002_number in ('&cardnumber')
and a.i003_proc_code not in ('300000','900000')
order by a.serno desc;

-- Операции в Prime

select * from ctransactions a,cisotrxns b where a.serno = b.serno and a.partitionkey = b.partitionkey
and a.caccserno = 5285236 --and a.i004_amt_trxn = 700
order by a.serno desc

-- ИСТОРИЯ OTB из ONLINE

select l.eodserno,colname, l.ltimestamp,l.newvalue-l.oldvalue as change,oldvalue,newvalue,action from applog l
where l.rowserno = 68128281
and colname = 'otb '
order by eodserno desc
 
 -- не блокируются карты в PRIME вручную (Region purge date should be in future)
 
В поле Purge days from today укажите 100 дней и жмите SAVE.

-- транзакция перевода с карты на карту (номер карты назначения) - убрать F из поля

I104_TRAN_DESC

-- 1117 - ASP Blocking Failed with Reason Code 745623

Добрый день.

Клиент осуществляет перевод на карту не резидента.
Issuer Block: P2P Res -> Non Res
Такие переводы у нас запрещены.

--поиск этой карты (получатель перевода) в ACQUIRERLOG, проверка поля I039_RESP_CD, поиск его в таблице respcodes

-- e-commerce операций нет в ONLINE

-- c 01.09.2015 - 3DS через ACS В основной БД E-COMMERCE

  SELECT A.ID,
         A.CREATION_DATE,
         B.UPDATE_DATE,
         A.PAN,
         B.EXPIRY,
         A.ACQ_BIN,
         A.MERCHANT_ID,
         B.AMOUNT,
         B.CURRENCY,
         A.IS_ATTEMPT_USED,
         B.STATUS,
         A.CLIENTCARD_ID,
         A.VE_RES,
         A.PHONE,
         B.TRUSTFUL_TYPE,
         B.MERCHANT_NAME,
         B.TERM_URL
    FROM ACS_VER_ATTEMPTS a, ACS_AUTH_ATTEMPTS b
   WHERE A.PAN = &cardnumber AND A.ACCOUNT_ID = B.ACCT_ID
ORDER BY 1;

-- до 31.08.2015 - 3DS через ARCOT В БД WEBDB_A таблица ARCOT_CALLOUT_A.DYNAMIC_LOG

  SELECT *
    FROM DYNAMIC_LOG
   WHERE PANdigest IN (SELECT pan ('&Card_number') FROM DUAL)
ORDER BY TIME DESC

-- разблокировка карты, заблокированной в ICDB (передается в PRIME в бриждах) - группа Retail,Cash,CardCenter inhouse (Семченко Илья Сергеевич)

update RBAICDB.CARDS_FULL
set ACTIVITYSTATUS = 0, ACCOUNTSTATUS = null, STATUS = 'U', REASON = null, FREEZED = null 
where CRDN = '&Card_number';
 
 -- Операция не попала в отчет MC Rejected chargebacks

1) Проверить EOD операции

2) Проверить связь этой и оригинальной операции по таблицам mtrxnlinks и trxnlinks

Просмотр этой и оригинальной операции по номеру карты (проверка даты заведения - STARTTIME, сопоставление ее с датой формирования отчета):

SELECT *
  FROM raiff.mtransactions a, raiff.mapplog m, raiff.eods
 WHERE     a.i002_number = 'XXXXXXXXXXXXXX'
  --     AND a.i000_msg_type IN ('0422', '0423')
    --   AND a.originator = 'General'
       AND m.rowserno = a.serno
       AND m.tabname = 'mtransactions'
       AND m.oldvalue = 'NEW'
       AND eods.serno = m.eodserno
	   
-- поиск клиента и карты в Альфе по номеру счета

SELECT *
  FROM ACCOUNTS a, CLIENTS c, cards cc
 WHERE     A.C_NACT = '0020190009146'
       AND A.N_CST = C.N_CST
       AND C.N_CST = CC.N_CST
	   
--карты в Альфе, у которых заканчивается срок действия для всех филиалов и отделений c номерами телефонов:

  SELECT *
    FROM (SELECT C.n_Cst AS N_CST_ALPHA,
                 C_CST_LNAME,
                 C_CST_FNAME,
                 C_CST_MNAME,
                 get_crd_mask (CR.C_NCRD) AS C_NCRD,
                 TO_CHAR (D_CRD_EXPIRY, 'MM/YYYY') AS D_CRD_EXPIRY,
                 R.C_NACT,
                 --brn.n_bank, brn.n_brn, brn.cf_brn_type,
                 --GET_CRD_BRN_INCASS(CR.C_NCRD, brn.n_bank, brn.n_brn, 'N') as BRN_INCASS,
                 TRIM (REPLACE (BIN.c_Bin_Desc, 'IMPX', '')) AS CRD_TYPE,
                 GET_CST_PHONE (C.N_CST) AS PHONE,
                 brn.c_brn_name
            FROM CLIENTS C,
                 CARDS CR,
                 R_CRD_ACT R,
                 branches brn,
                 BIN,
                 accounts A
           WHERE     C.N_CST = CR.N_CST
                 AND CF_CRD_STAT IN ('0', '1')
                 AND D_CRD_EXPIRY = TRUNC (LAST_DAY (TO_DATE (SYSDATE)))
                 AND CR.C_NCRD = R.C_NCRD
                 AND brn.n_bank = CR.n_Bank
                 AND brn.n_brn = CR.n_Brn
                 AND brn.cf_brn_type NOT IN ('B', 'D')
                 AND brn.n_bank = 2
                 AND BIN.n_Bin = CR.n_bin
                 AND R.c_nact = A.c_Nact)
ORDER BY --n_bank, DECODE(cf_brn_type, 'O', 1, 'M', 2, 'F', 3, 4), BRN_INCASS,
        C_CST_LNAME,
         C_CST_FNAME,
         C_NCRD,
         D_CRD_EXPIRY
		 
-- Статистика доступности сервиса ATM->Ecom->RC

-- по часам

  SELECT SUBSTR (time_hours_only, 0, 10) AS "date",
         COUNT (1) AS TOTAL_TRANSACTIONS,
         status
    FROM (  SELECT TO_CHAR (TO_DATE (SZDEVREG, 'YYYY-MM-DD HH24:MI:SS'),
                            'YYYY-MM-DD HH24')
                      time_hours_only,
                   COUNT (1) AS TOTAL_TRANSACTIONS,
                   CASE lresult
                      WHEN 0 THEN 'OK: code ' || lresult
                      WHEN 91 THEN 'ULTRA_FAIL: code ' || lresult
                      ELSE 'OTHER_PROBLEMS: code ' || lresult
                   END
                      AS status
              FROM ib201501 i
             WHERE i.riss = 10379
          GROUP BY TO_CHAR (TO_DATE (SZDEVREG, 'YYYY-MM-DD HH24:MI:SS'),
                            'YYYY-MM-DD HH24'),
                   lresult)
GROUP BY status, SUBSTR (time_hours_only, 0, 10)
ORDER BY 1, 2 DESC, 3;

-- по минутам

  SELECT TO_CHAR (TO_DATE (SZDEVREG, 'YYYY-MM-DD HH24:MI:SS'),
                  'YYYY-MM-DD HH24')
            time_hours_mins_only,
         COUNT (1) AS TOTAL_TRANSACTIONS,
         CASE lresult
            WHEN 0 THEN 'OK: code ' || lresult
            WHEN 91 THEN 'ULTRA_FAIL: code ' || lresult
            ELSE 'OTHER_PROBLEMS: code ' || lresult
         END
            AS status
    FROM ib201501 i
   WHERE i.riss = 10379
GROUP BY TO_CHAR (TO_DATE (SZDEVREG, 'YYYY-MM-DD HH24:MI:SS'),
                  'YYYY-MM-DD HH24'),
         lresult
ORDER BY 1, 2 DESC, 3;

