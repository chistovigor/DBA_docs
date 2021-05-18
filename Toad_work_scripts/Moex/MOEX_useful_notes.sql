# Переработки

сообщил:
09.10.2016 - проверка всех БД после перехода на основной луч сетевой конфигурации, настройка standby Exadata на DSP
15.10.2016 - работы по проверке БД (ЦБ, SPUR, SPURTAB) после сетевых работ совместно с провайдером Мастертел
29.10.2016 - переконфигурация ICDB, подготовка к переключению и проверка после переключения ролей БД, исправление ошибок процедур MIRROR (воскресенье) между двумя БД на Exadata
04.11.2016, 05.11.2016 - проверка всех сервисов после переезда в ЦОД DSP, работы по настройке CBVIEWP - ЦБ standby для загрузки c Exadata (VDRF) - исправление отставания Standby
13.11.2016 - завершение установки QFDSP (Jul2016) на комплексы Exadata
19.11.2016 - устранение ошибки ORA-07445 по SR 3-13652822821, аварии с дисковой группой на CELL03
26,27.11.2016 - исправление проблемы, вызвавшей полную недоступность EMCC 13c после очередной установки Bundle патчей за ноябрь (patch 24940833)
10.12.2016 - перенастройка параметров БД SPUR (процессы, асинхронная запись на диск)
18.12.2016 - установка диагностического патча 24901520 на DWH,VDRF, перенастройка ФС domU (увеличение места под логи), изменение open_links_per_instance,open_links на DWH,VDRF
14.01.2017 установка патча 20144669 (SR 3-12940642121, изменение 3357) на БД на Exadata. Остановка/запуск/проверка БД до/после обновления ядра ОС (заявка 872046) на сервере БД spur.
28.01.2017 - проверка системы после установки квартальных патчей на основную Exadata (mr)
11.02.2017 - работы по физическому переносу серверов ДКС loadrp (196.1.12.42), dbcbrp(196.1.12.41), 172.22.10.42
18.02.2017 Работы на оптическом канале Варшавка-Кисловский/Спартаковская - поднятие сервисов после выполнения работ
04.03.2017 Работы по установке патча 25470351 for for DB BP 12.1.0.2.161018 на БД на Exadata, а также SR 3-14309121760 и SR 3-14301052021 (ORA-00600: internal error code, arguments: [25027] error in SMCO - системная ошибка в таблицах записей аудита)
11.03.2017 Проверка БД на Exadata на M1 после выполнения работ по замене материнской платы на storage cell varceladm01.moex.com проверены
25.03.2017 - проверка standby БД (spurstb) и виртулаьных машин mr01vm01,mr01vm05 на Exadata DSP после настройки kdump на сервере mrdbadm01. (изменение 3643)
Проверка серверов БД prot и spurtab после работ на СХД (замена контроллера 0 в СХД 3Par2-К в ЦОД К13) (изменение 3644)
13.04.2017 (вечер) - Установка патча от вендора p25451612_12102161018ProactiveBP_Linux-x86-64​, выполняющего исправление ошибки в работе алгоритма сбора инкрементальной статистики по объектам БД (изменение 3759)
15.04.2017 - Тестирование процедуры сбора kdump (совместно с коллегами из ДЭ) на сервере vardbadm02
29.04.2017 - проверка системы после установки QFDSP Jan2017 на основную Exadata (M1)
08-09.05.2017 - восстановление работоспособности системы после аварии процесса FBDA (+1 день)
13.05.2017 - проверка системы после установки QFDSP Jan2017 на основную Exadata (DSP)
20.05.2017 - Переключение ролей БД VDRF Exadata (изменение 3899)
21.05.2017 - перенос шлюзов на Exadata (http://jira.moex.com/browse/DKSMON-296)
28.05.2017 - Исправление связи БД Primary-Standby после падения связи с DSP, проверка работы БД после работ на 3-PAR
03.06.2017 - DR test 2017
07.06.2017 - перезапуск обеих БД (DWH+VDRF) для выполнения задачи http://jira.moex.com/browse/DKSMON-301 (после 23-55)
10.06.2017 - нагрузочное тестирование Exadata M1 (изменение 3976)
08.07.2017 - проверка БД после работ по замене ОС на сетевых коммутаторах DSP
13.08.2017 - вышли в OFFLINE диски для всех ASM на Exadata DSP
16.08.2017 - вышли в OFFLINE диски для ASM DWH на Exadata DSP, исправление проблемы в падением основной БД
26.08.2017 - проверка систем после сетевых работ, восстановление работоспособности Exadata DSP
02.09.2017 проверка системы после установки QFDSP Apr2017 на резервную Exadata (DSP) (изменение 4269)
16.09.2017 проверка системы после установки QFDSP Apr2017 на основную Exadata (DSP) (изменение 4342)
30.09.2017 переключение ролей БД на Exadata с Primary DSP на M1 (изменение 4387)
03.10.2017 перезапуск PRIMARY экземпляров БД DWH и VDRF для включения функционала RESULT CACHE (ночью с 03 на 04)
07.10.2017 биржевое нагрузочное тестирование
28.10.2017 переключение ролей БД на Exadata с Primary DSP на M1, увеличение CPU на 50% - до 36 на Primary сервере БД DWH (изменение 4435)
04.11.2017 перенастройка ONLINE импорта сделок на валютном рынке на ограниченное до 6 месяцев представление
11.11.2017 перенастройка ONLINE импорта сделок на фондовом рынке на ограниченное до 6 месяцев представление
23.12.2017 перемонтирование дисковых пакетов (с остановкой БД) на серверах planningpr (сервер 172.20.16.30,172.20.16.172) и oraesspr (сервер 172.20.16.173, 172.20.16.31) (изменение 4760)
20.01.2018 - вывод из эксплуатации всех презентованных серверу planningpr (172.20.16.172) дисков (изменение 4848, совместно с коллегами из ДЭ)
27.01.2018 - мониторинг состояния БД и ETL после изменения параметра _serial_direct_read (в значение по умолчанию AUTO с текущего TRUE) для DWH и VDRF на обеих Exadata
03.02.2018 - восстановление работоспособности БД (часть назначенных заданий не отработала корректно, перенос сверок обратно на Standby с Primary) после тестирования восст. бекапов на Store ONCE (изменение 4920)
17.03.2018 - проверка и перенастройка системы после выполнения SWICHOVER на DWH и VDRF, изменение настроек гипервизора для DWH на DSP
12.05.2018 - возврат дисков в сервера standby spur на DSP, переконфигурация сервера
19.05.2018 - возврат дисков в сервера Prot, переконфигурация сервера. Проверка системы после внедрения изменений в конфигурацию серверов OVD (новый сервер + join адаптер)
02.06.2018 - возврат дисков в серверов vmolt2, sbd* (старые сервере ЕКБД)

не сообщил:



Oracle support:

CSI ФОРС (Exadata SW requests): 20254093
CSI Борлас (non Exadata SW requests): 21002586

Номера CSI (для X-7):

21822210 апгрейды
21822227 трансиверы
21822228 кабели

Серийные номера апгрейдов:
AK00426643
AK00426642

Действительно у нас есть дополнительная опция по инициации проверки  отдельно взятой запчасти, однако это применимо в случаях когда необходимо установить причину сбоя,
в нашем случае мы видим, что причина сбоя- компонент SYS/MB  материнская плата (т.е. некорректное функционирование одного из ее компоентов), после замены компонента проблема разрешилась. Очевидно, что аналитика была проведена корректно и причина была действительно в системной плате.
В случаях когда заказчику по каим-то внутренним соображениям нужно получить полный отчет о специфике сбоя конкретного компонента, анализ может быть заказан и делается за счет заказчика. Для справки, процедура в Oracle  именуется как процесс CPAS.

# Комитет по изменениям 0315, (был 0808 - Варварка)
Необходимо делать информирование о работах, связанных с доступностью нашей БД, на адрес RiskMonitor_support@moex.com после утверждения выполнения очередных изменений на комитете.

Топология серверов:

1) 
Exadata primary стоит на ДСП (Шарикоподшипниковская, д.11, стр.9, м. Дубровка) - s/n AK00323357
Exadata Standby стоит на M1 (Варшавское ш., д.125, м. Южная) - s/n AK00323353
Дежурный инженер МБ в ЦОД DSP - +7(965)278-0816

Адрес для заказа пропусков: dspdeng@moex.com
копию заявки просьба направлять:  Konstantin.Logachev@moex.com

Дата-центр М1 (Stack.M1)
117587, г. Москва, Варшавское шоссе, д. 125, стр. 1
Дежурный инженер МБ 8(903)160-0058 – круглосуточно

Дата центр DSP                                   
115088, г. Москва, ул. Шарикоподшипниковская, д.11/9
Тел. 8(965)278-0816

SPURTAB на Большом Кисловском пер., д.13 (м. Охотный ряд)
EMCC - DSP (Шарикоподшипниковская, д.11, стр.9, м. Дубровка) стойка C-89 юнит 36 (сервер HPDL 380pGen8 s/n CZ224601KH)
Авторизация AD для Exadata (via OVD 11.1.1.9) - Primary OVD 172.20.16.177 (piampr), - Secondary OVD - 10.63.140.54 (ksdam-auth00-fmb)
Авторизация OAM для Финдепа - app сервер - 10.63.140.54 (ksdam-auth00-fmb), сервер БД репозитория - 172.20.16.173 (oraesspr)

ЦОД DSP тел. дежурных инженеров 1742 или 1991(мобильный).

Сетевики: Дмитрий Осипов

Support:

-- доступ к ПО монитор (monitor)
  
  CREATE USER SapozhnikovaAS
  IDENTIFIED BY sapozhnikovaas123
  DEFAULT TABLESPACE USERS
  TEMPORARY TABLESPACE TEMP
  PROFILE DEFAULT
  ACCOUNT UNLOCK;
  -- 1 Role for SapozhnikovaAS 
  GRANT ROLE_PROT_VIEW TO SapozhnikovaAS;
  ALTER USER SapozhnikovaAS DEFAULT ROLE ALL;
  -- 1 Tablespace Quota for SapozhnikovaAS 
  ALTER USER SapozhnikovaAS QUOTA 10M ON USERS;
-- 1 Object Privileges for SapozhnikovaAS 
GRANT EXECUTE ON PROT.INP_COUNT_FUNC TO SapozhnikovaAS; --this privilege already granted to ROLE_PROT_VIEW !

-- общая папка для нашего подразделения
\\office.micex.com\Public\Files\CIS_Support

Бекапные скрипты (dpump и rman) для БД на Exadata в SVN:
---
http://172.20.16.132:18080/svn/CSD/MOEX_COMMON/development/LDWH/BACKUP/

1) По заявкам в поддержку Oracle по Exadata: после заведения заявки буду присылать ее номер на почту: mbex_support@rdtex.ru и nikolay.azovskiy@oracle.com
2) По другим заявкам в поддержку Oracle (не связанным с Exadata) писать на почту: support@rdtex.ru

При ошибках ONLINE (схемы SPUR_DAY,SPUR_DAY_CU) импорта нужно:

1) После исправления ошибок в ONLINE (БД CBVIEWP)
нужно выполнить truncate таблицы SPUR_DAY.PARAM - фондовый рынок (или SPUR_DAY_CU.PARAM - валютный рынок)
2) Сообщить коллегам из департамента эксплуатации, чтобы повторили импорт.
--! после согласования с сотрудниками УСТС (Дахин Антон, Рогов Святослав)
Либо в таблице PARAM (в схеме SPUR_DAY для фондового рынка, SPUR_DAY_CU для валютного) менять поле VAL для столбца с ID = 'BUSY' c 1 на 0

Импорт валютного рынка - тел. 1124, oe@moex.com: Винников, Воронков, Камынина, Морозов Сергей Евгеньевич (ночью) (dgw1 10.63.1.101, mgw1 10.61.1.101)
Импорт фондового рынка: Дахин Антон Пейсахович,Рогов Святослав Юрьевич (кафедра фондового рынка тел.1485)
(DSP: 10.63.1.0,10.63.3.0 M1: 196.1.2.0,196.1.5.0, новый сервер на M1 – 10.61.1.101,10.61.3.101)

мониторинг ONLINE: select * from  monitor_online;

Информация об ошибках с CBVIEWP:
-- сверки
select * from CHECK_TABLES_LOG@CBVIEWP where UPDATEDT > trunc(sysdate) and R1 <> 'Ok' order by UPDATEDT desc;
--DWH_PRIM
select * from COMPARE_ARDB.Check_Run_Log order by run_id desc; (Подробности по таблице у Карпова)

3) bug tracker для ошибок, возвращаемых системой мониторинга: таблица MONITOR_PROD.BUG_TRACKER 
2) Логи выполнения процедур импорта данных в БД spur типа FORTS_AR.OPT_AR_DEAL_UPDBASE(P_ID=>0)
при запуске процедуры выполняется импорт данных из таблицы XXX_LM в таблицу XXX_BASE смотреть в таблице логов:

select * from FORTS_AR.ERRLOG where trunc(UPDATEDT) > trunc(sysdate) and proc like 'OPT_AR_DEAL_UPDBASE%' order by 1;

3) UNIX администраторы: Мещеряков Павел, Фомичев Андрей; 1745 - дежурный UNIX админов

4) Создание TMP таблиц LDWH на основе меппинга Руслана:

- Загружаем лист LDWH-STRUCT файла меппинга в таблицу LDWH.LDWH_STRUCT_LM (перед этм обязательно выполняем ее TRUNCATE)
- Запускаем процедуру LDWH.LDWH_STRUCT_UPDBASE без параметров, данные оттуда попадают в таблицу LDWH.LDWH_STRUCT_BASE
- Запускаем процедуру с параметром p_TABLE_NAME, равным имени создаваемой таблицы: exec LDWH.CREATE_T_TABLE(p_TABLE_NAME=>'ISSUE_BOARD_STATS'), получаем DDL или ALTER для таблицы TMP
- Настраиваем ILM для созданной таблицы при необходимости!


-- Трассировка в процедурах на DWH

Я сделал процедуру включения трассировки для сессии, для того, чтобы разбираться в подобных проблемах.
Для того ,чтобы ей воспользоваться, нужно в интересующий нас код (в данном случае это процедура COMPARE_ARDB.CORRECT_TRADES_THIS_DAY, насколько я понимаю) вставить в начало выполнения (в блок begin end; кода) строку 

TRACE_SESSION;

В конец – троку

TRACE_SESSION(V_START=>FALSE);

И обязательно (!!!) убрать эти строки после того, как выполнение с ними сделано и я получил трейсы, т.к. подобные трассировки могут занять много места в ОС сервера БД.

-- Управление GG на сервере CBVIEWP

set ORACLE_HOME to DB_HOME

run /preview/home/oracle/ggsci/ggsci

info all --show all processes
stop REPLICAT <group name> --stop REPLICAT processes
-- after all other processes were stopped run
stop manager [!] -- stops manager process, ! - to avoid confirmation

-- Пользователь для бизнесс аналитиков на DWH Exadata:
G_TDBA - Ерпылев, Дюкель, Абрамов, Алексеева Жанна, Пиманов Дмитрий, Мельникова Алина

-- Пользователь для департамента стратегии развития на DWH Exadata:
G_STRATEG_DEVEL - Конкин (увольняется),Реджепов,Коченков

-- Пользователь для управления мониторинга и валидации рисков на DWH Exadata:

G_RISK_MONITORING - Гусев А.Г., Насонов, Власов С.В., Трегуб, Крылов Д.А.

-- mapping (меппинг) пользователей в AD в боевом OVD (на примере пользователя G_KONKINSV БД spur кластера DWH) с помощью eusm 11g

/u01/prprot/ora_db/product/11.2.0/dbhome_1/bin/eusm createMapping database_name="spur" realm_dn="dc=ovd1,dc=micex,dc=com" map_type="ENTRY" map_dn="cn=Конкин Сергей Викторович,cn=Users,dc=ovd1,dc=micex,dc=com" schema="G_STRATEG_DEVEL" ldap_host="172.20.16.187" ldap_port=6502 ldap_user_dn="cn=orcladmin" ldap_user_password="q1q1q1q1"
-- для тестовой БД на DSP
eusm createMapping database_name=dbm05 realm_dn="dc=ovd,dc=micex,dc=com" map_type=ENTRY map_dn="cn=Ахметзянов Руслан Талгатович,cn=Users,dc=ovd,dc=micex,dc=com" schema="G_AKHMETZYANOVRT" ldap_host=172.22.10.28 ldap_port=6501 ldap_user_dn=cn="orcladmin" ldap_user_password="ovdm1562"

-- список текущих привязок из OVD (для каждого из серверов OVD):

eusm listMappings database_name="spur" realm_dn="dc=ovd,dc=micex,dc=com" ldap_host="ksap-wlwebv-h.office.micex.com" ldap_port=6501 ldap_user_dn="cn=orcladmin" ldap_user_password="ovdm1562"
--/u01/prprot/ora_db/product/11.2.0/dbhome_1/bin/eusm listMappings database_name="spur" realm_dn="dc=ovd1,dc=micex,dc=com" ldap_host="172.20.16.187" ldap_port=6502 ldap_user_dn="cn=orcladmin" ldap_user_password="q1q1q1q1"
/u01/prprot/ora_db/product/11.2.0/dbhome_1/bin/eusm listMappings database_name="spur" realm_dn="dc=ovd1,dc=micex,dc=com" ldap_host="ksdam-auth00-fmb" ldap_port=6501 ldap_user_dn="cn=orcladmin" ldap_user_password="q1q1q1q1"

-- для тестовой БД на DSP
eusm listMappings database_name="dbm05" realm_dn="dc=ovd,dc=micex,dc=com" ldap_host="ksap-wlwebv-h.office.micex.com" ldap_port=6501 ldap_user_dn="cn=orcladmin" ldap_user_password="ovdm1562"
-- вывод ТОЛЬКО имени схемы БД и имени схемы AD
eusm listMappings database_name="spur" realm_dn="dc=ovd,dc=micex,dc=com" ldap_host="ksap-wlwebv-h.office.micex.com" ldap_port=6501 ldap_user_dn="cn=orcladmin" ldap_user_password="ovdm1562" | grep -E "(^Mapping DN|^Mapping schema:)"
--eusm listMappings database_name="spur" realm_dn="dc=ovd1,dc=micex,dc=com" ldap_host="172.20.16.187" ldap_port=6502 ldap_user_dn="cn=orcladmin" ldap_user_password="q1q1q1q1" | grep -E "(^Mapping DN|^Mapping schema:)"

-- удаление меппинга (mapping_name из списка listMappings)

/u01/prprot/ora_db/product/11.2.0/dbhome_1/bin/eusm deleteMapping database_name="spur" realm_dn="dc=ovd1,dc=micex,dc=com" mapping_name="MAPPING9" ldap_host="172.20.16.187" ldap_port=6502 ldap_user_dn="cn=orcladmin" ldap_user_password="q1q1q1q1"
eusm deleteMapping database_name=dbm05 realm_dn="dc=ovd,dc=micex,dc=com" map_type=ENTRY map_dn="cn=Ахметзянов Руслан Талгатович,cn=Users,dc=ovd,dc=micex,dc=com" schema="G_AKHMETZYANOVRT" ldap_host=172.22.10.28 ldap_port=6501 ldap_user_dn=cn="orcladmin" ldap_user_password="ovdm1562"

-- выбор атрибута orclpassword для пользователя (должен быть для авторизации в БД через AD и меняться при смене AD пароля пользователя)

ldapsearch -h ksap-wlwebv-h.office.micex.com -p 6501 -D cn=orcladmin -w ovdm1562 -b "cn=Users,dc=ovd,dc=micex,dc=com" "(uid=Kiseleva)" dn authpassword orclpassword orclguid
--ldapsearch -h 172.20.16.187 -p 6502 -D cn=orcladmin -w q1q1q1q1 -b "cn=Users,dc=ovd1,dc=micex,dc=com" "(uid=AbramovDO)" dn authpassword orclpassword orclguid

[oracle@mr01vm01 log]$ ldapsearch -h 172.20.16.187 -p 6502 -D cn=orcladmin -w q1q1q1q1 -b "cn=Users,dc=ovd1,dc=micex,dc=com" "(uid=Korchagina)" dn authpassword orclpassword orclguid
cn=Корчагина Ирина Сергеевна,cn=Users,dc=ovd1,dc=micex,dc=com
authpassword;orclcommonpwd={SSHA}y0q+/peOtPUuhOSA0u2OLuCrw98E6nuUDp3HsA==
orclGUID=fcf75f8636df4a278a41b98505c84701

[oracle@mr01vm01 log]$ ldapsearch -h 172.20.16.187 -p 6502 -D cn=orcladmin -w q1q1q1q1 -b "cn=Users,dc=ovd1,dc=micex,dc=com" "(uid=VlasovSV)" dn authpassword orclpassword orclguid
cn=Власов Сергей Викторович,cn=Users,dc=ovd1,dc=micex,dc=com
authpassword;orclcommonpwd={SSHA}CEp54RB5x6mZxL1mL1IZ24m8GK/bNJSUFw2ncA==

cn=Баймухаметова Лия Ринатовна,cn=Users,dc=ovd1,dc=micex,dc=com
authpassword;orclcommonpwd={SSHA}kQjBFGhHoAev0mbTyeE3mOKRHiC/ZEZhlXg2nQ==
orclGUID=c6207ca62be6409892f4e02f47129917

cn=Михайлов Леонид Владимирович,cn=Users,dc=ovd1,dc=micex,dc=com
authpassword;orclcommonpwd={SSHA}Gm1evsLcQ4poRwWoWQlZg35l9zuxHnjKolrgLg==
orclGUID=fc763530efe94c9880288623e0b5607e

-- до изменения (07.03.2017)

cn=Малахов Виктор Владимирович,cn=Users,dc=ovd1,dc=micex,dc=com
authpassword;orclcommonpwd={SSHA}VCxDe0xdHU00y2v9jJ9vC5/eN9DY3ekJ2l/CRw==
orclGUID=3a485354710442fd8d5dae7f08fff259

-- после изменения

cn=Малахов Виктор Владимирович,cn=Users,dc=ovd1,dc=micex,dc=com
authpassword;orclcommonpwd={SSHA}K+mTlefZ9mc3JfbSpw72+JD+E6U+dcXG0oS7wg==
orclGUID=3a485354710442fd8d5dae7f08fff259

до 16.02.2017 19:30

cn=Крылов Дмитрий Алексеевич,cn=Users,dc=ovd1,dc=micex,dc=com
authpassword;orclcommonpwd={SSHA}i+P2GbZlKvh8aAJC/3gBi79/sR0wqxku6nFNtw==
orclGUID=01d2293c224945dcb5db7658e236002a

после 16.02.2017 19:30

cn=Крылов Дмитрий Алексеевич,cn=Users,dc=ovd1,dc=micex,dc=com
authpassword;orclcommonpwd={SSHA}l2UzmFgekbe3yF8gk2Xtp/jApdbgtReVf6DOUg==
orclGUID=01d2293c224945dcb5db7658e236002a

-- информация для пользователей

В AD пароле нельзя использовать кавычки!!!

Для доступа на новую БД нужно сделать заявку на 2222, указав, какие права необходимы. 
После согласования доступа права будут предоставлены и созданное соединение в SQL developer можно будеn использовать для работы с новой БД.

Доступ предоставлен с использованием интеграции с Active directory.  Доступ к БД будет осуществляться с теми же именем пользователя и паролем, что используются в AD. 
Для того, чтобы использовать предоставленный доступ необходимо самостоятельно поменять текущий пароль AD, после чего использовать заданный пароль и текущий логин AD для подключения к БД.

4) -- Загрузка в spur (через несколько дней после этого вставленные строки из таблицы должны автоматически удалиться)

на примере OPT_AR_DEAL_BASE (из таблицы forts.OPT_ARDEAL БД SPURTAB):
--1
INSERT /*+ PARALLEL */ INTO FORTS_AR.OPT_AR_DEAL_LM SELECT * FROM FORTS.OPT_ARDEAL@SPURTAB;
--2
exec FORTS_AR.OPT_AR_DEAL_UPDBASE(P_ID=>0);
commit;
--3
смотрим результат в таблице OPT_AR_DEAL_BASE;
и лог: 
select * from FORTS_AR.ERRLOG where trunc(UPDATEDT) = trunc(sysdate) and proc like 'OPT_AR_DEAL_UPDBASE%' order by 1;

5) Выдача прав к Oracle BI отчетам пользователям (вместо Димы Силаева)

- заходим в Stimkit админку 
http://172.22.10.34:7001/strimkit/welcome.do
- находим группы: вводим в поле "код группы" FINSTAT - витрина рыночной статистики (Смоленчук), SPUR - наши отчеты
- нажимаем кнопку с двумя стрелками (вверх и вниз)
- нажимаем на группу
- ставим флаг на нужном пользователе
- нажимаем кнопку сохранить
- запускаем функцию IDM_AUTH_PR.sync_users
DECLARE 
V_RESULT VARCHAR2(3000);
BEGIN
V_RESULT:=IDM_AUTH_PR.SYNC_USERS;
DBMS_OUTPUT.PUT_LINE(V_RESULT);
COMMIT;
END;

-- обновление матвью LDWH

set timing on
begin dbms_mview.refresh( 'LDWH.MV_POS_CLIENT_ASSET', method=>'C', atomic_refresh=>false); end;

-- импорт дампов со SPUR на DWH через линк

impdp expimp/$EXP_DB_ACCOUNT_PASS schemas=FMD_API network_link=spur30 logfile=imp_FMD_API remap_tablespace=USERS:SMALL_TABLES_DATA
impdp expimp/$EXP_DB_ACCOUNT_PASS schemas=prot remap_tablespace=URK_DATA:PROT_DATA,URK_LOBS:PROT_DATA,URK_INDX:PROT_DATA logfile=imp_prot network_link=spur30 parallel=4

-- доступ к сегментной аналитике в витрине данных

Группа BI_SPUR_FINMODEL (Гейнц Денис в согласующих)

6) Права на МДМ.

Объекты МДМ находятся в двух схемах MOSCOW_EXCHANGE и MDMWORK на SPUR30.
В MOSCOW_EXCHANGE находятся все таблицы с сырыми данными и плоские таблицы с результатами. 
В MDMWORK созданы view на основе таблиц MOSCOW_EXCHANGE.T_% c уже переработанной информацией. 

Права:
1.Пользователям, которые хотят видеть сырые результаты надо давать права таблицы MOSCOW_EXCHANGE.T_%. 
2.Бизнес пользователям надо давать права на view из MDMWORK. Список надо уточнить и Славы.
3.Пользователям, которым необходимо видеть (или править) процесс обработки данных надо давать права
на все объекты схемы MOSCOW_EXCHANGE.

-- ограничение доступа к объектам БД для пользователей

В данном случае требуется согласование коллег из ИБ на предоставление доступа к неанонимным данным для отдельной схемы БД, нужной коллеге. Можно ли предоставлять неограниченный по времени доступ или его нужно ограничить?

Список объектов со сделками: 
BL.TRADES_BASE
EQ.EXTTRADES_BASE
CURR.TRADES_BASE
EQ.REFUND_BASE
FORTS_AR.FUT_AR_REPOTRADE_BASE  
FORTS_CLEARING.DEAL_BASE  
FORTS_JAVA.ADJUSTED_FEE_BASE 
EQ.TRADES_BASE
FORTS_JAVA.OTC_DEALS_REPL_LOG_BASE 
FORTS_JAVA.FUTDEAL_BASE
SPUR_DAY.EXTTRADES
SPUR_DAY.TRADES
SPUR_DAY_CU.TRADES
EQ.RPT40_BASE
EQ.REP40_BASE
EQ.REPOTRADEHIST_BASE

-- адреса доменных серверов НРД

telnet 172.22.19.200 389
telnet 172.20.18.200 389
telnet 172.20.18.201 389
telnet 172.23.10.200 389
telnet 172.19.138.200 389
telnet 172.22.18.200 389
telnet 172.19.139.200 389
telnet 172.23.31.208 389

-- адреса виртуальных машин на Exadata

mr01vm01.moex.com 10.63.140.1, var01vm01.moex.com 172.22.140.1
mr01vm02.moex.com 10.63.141.2, var01vm02.moex.com 172.22.141.1
(остальные адреса из списка ниже - это vip и scan (3 шт) адреса)

7) Доступ на Exadata (DHW) с рабочих станций

Данные представления с актуальной информацией есть на Exadata. Пользователь KONKINSV (аналогичный пользователю на БД SPUR) там заведен и ему выданы необходимые привилегии для доступа к нужным объектам. 
Для подключения к БД на Exadata (кластер DWH, о котором идет речь) необходимо сделать заявку на 2222 для открытия порта 1521 для доступа со своей рабочей станции на адреса 

DSP

10.63.140.1
10.63.140.2
10.63.140.3
10.63.140.4
10.63.140.5

M1

172.22.140.1
172.22.140.2
172.22.140.3
172.22.140.4
172.22.140.5

После этого обязательно проверьте наличие доступа к каждому из адресов через telnet, были преценденты, когда заявка на открытие доступа закрывается, а доступ открыт не на все адреса и подключиться к БД из-за этого не удавалось.
TNS строка подключения к БД:

DWH_PRIM =
  (DESCRIPTION =
   (TRANSPORT_CONNECT_TIMEOUT=3)
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = DWH_PRIM)
    )
  )

--EZconnect
  
spur_day/пароль @(DESCRIPTION=(TRANSPORT_CONNECT_TIMEOUT=3)(ADDRESS_LIST=(FAILOVER=YES)(ADDRESS=(PROTOCOL=TCP)(HOST=mr-scan.moex.com)(PORT=1521))(ADDRESS=(PROTOCOL=TCP)(HOST=var-scan.moex.com)(PORT=1521)))(CONNECT_DATA=(SERVICE_NAME=DWH_PRIM)))

--JDBC

jdbc:oracle:thin:@(DESCRIPTION =
   (TRANSPORT_CONNECT_TIMEOUT=3)
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = DWH_PRIM)
    )
  )
  
-- Дескриптор соединения с тестовой БД для НАС:
--С var-scan5 (M1) возможен доступ к боевым данным
--С mr-scan5 (DSP) НЕ возможен доступ к боевым данным

DWH_PRIM_TEST =
(DESCRIPTION =
 (ADDRESS_LIST =
  (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan5.moex.com)(PORT = 1521))
 )
  (CONNECT_DATA =
   (SERVICE_NAME = DWH_PRIM_DEV)
  )
)
 
Для работы с ним необходимы сетевые доступы на порт 1521, пул адресов БД следующий:
10.63.144.29
10.63.144.32
10.63.144.33
10.63.144.34
10.63.144.35

для площадки M1:
172.22.144.1
172.22.144.2
172.22.144.3
172.22.144.4
172.22.144.5
  
-- непрозрачный дескриптор соединения

SPUR_EXADATA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan.moex.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = spur)
    )
  )

Для разрешения сетевых имен mr-scan.moex.com и var-scan.moex.com (в случае, если на машинах, где они будут исопльзоваться нет доступа в DNS) необходимо добавить следующие записи в файл /etc/hosts:

10.63.140.3 mr-scan.moex.com
10.63.140.4 mr-scan.moex.com
10.63.140.5 mr-scan.moex.com

172.22.140.3 var-scan.moex.com
172.22.140.4 var-scan.moex.com
172.22.140.5 var-scan.moex.com
  
8) Доступ на Exadata (VDRF) с рабочих станций

Для подключения к БД на Exadata (кластер VDRF, о котором идет речь) необходимо сделать заявку на 2222 для открытия порта 1521 для доступа со своей рабочей станции на адреса 

10.63.141.2
10.63.141.30
10.63.141.40
10.63.141.41
10.63.141.42

172.22.141.1
172.22.141.2
172.22.141.3
172.22.141.4
172.22.141.5

После этого обязательно проверьте наличие доступа к каждому из адресов через telnet, были преценденты, когда заявка на открытие доступа закрывается, а доступ открыт не на все адреса и подключиться к БД из-за этого не удавалось.
TNS строка подключения к БД:

VDRF_EXADATA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan2.moex.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = dbm02)
    )
  ) 
  
VDRF_PRIM =
  (DESCRIPTION =
   (TRANSPORT_CONNECT_TIMEOUT=3)
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan2.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan2.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = VDRF_PRIM)
    )
  )
  
Строка соединения с БД nrprod 

NR_PRIM =
  (DESCRIPTION =
   (TRANSPORT_CONNECT_TIMEOUT=3)
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan4.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan4.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = NR_PRIM)
    )
  )

Чтобы получить доступ к exadata, нужно отправить такую заявку на 2222 (можно указать список сотрудников): 

«Прошу предоставить доступ к Витрине Торговых Данных (ВТД) на exadata сотруднику <имя_сотрудника> , для этого прошу 
1) открыть сетевой доступ к порту 1521 на сетевых адресах 
10.63.140.1 
10.63.140.2
10.63.140.3
10.63.140.4
10.63.140.5 
с адреса <указать_свой_ip_адрес>
2) завести на exadata пользователя для сотрудника <имя сотрудника> и предоставить ему права, аналогичные правам пользователя в текущей ВТД»

Тестовый сервер на mr01vm05:

DWH_PRIM_TEST_DSP =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan5.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = DWH_PRIM_DEV)
    )
  )
  
Тестовый сервер на var01vm05:
  
DWH_PRIM_TEST_M1 =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan5.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = DWH_PRIM_DEV)
    )
  )

Адреса для доступа к БД:

10.63.144.29
10.63.144.32
10.63.144.33
10.63.144.34
10.63.144.35

Адреса для доступа к БД НКЦ (dbm04):

10.63.143.40
10.63.143.41
10.63.143.42
10.63.143.43
10.63.143.44

NCC_DBM04_EXADATA =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan4.moex.com)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = dbm04)
    )
  )
   
9) Желаемые изменения и результаты анализа текущих системой

-- Change to fix current issues

--for change during the next Exadata DB restart


--for change during the next SPUR DB restart


--Improvement

!!! 09.08.2018 do an export from standby database - via network_link or using snapshot standby (!) or temporary canceling recover (!!)

!!! https://docs.oracle.com/cd/E80920_01/DBMSO/exadata-whatsnew.htm#DBMSO-GUID-308DB849-9796-4424-9025-A27001C12FFD In-Memory Columnar Caching on Storage Servers (why not worked?)

!!! 06.04.2018 - Составить описание объектов витрины, доступное на DWH и автоматически предоставлять доступ к нему всем, кто запросил его к БД (+ инструкция для поддержки)

!!! 29.01.2018 - Внедрить dbms_application_info в функционал ETL для контроля нагрузки на БД и анализа возникающих проблем

!!! 23.01.2018 In-Memory Columnar Caching on Storage Servers (we already have patch for bug 24521608), https://docs.oracle.com/cd/E80920_01/SAGUG/exadata-storage-server-monitoring.htm#SAGUG20883
ALTER TABLE table_name CELLMEMORY MEMCOMPRESS FOR CAPACITY;

!!! 23.01.2018 Faster Performance for Large Analytic Queries and Large Loads (need the patches for bug 24944847)

!!! 21.12.2017 - (сделано) убрать _serial_direct_read = TRUE с уровня БД (MOS doc ID 1269706.1, https://blog.tanelpoder.com/2013/05/29/forcing-smart-scans-on-exadata-is-_serial_direct_read-parameter-safe-to-use-in-production/)

!!! 20.12.2017 - Замена пакета ARDB_USER.LONG_HELP на ARDB_USER.LONG_HELP1 для избежания PGA memory leak (PIPELINED function > TYPE function)

!!! рассмотреть возможность сохранения подсчитанных хешей для READ ONLY секций на нашей стороне (или перенести рассчет на STANDBY)

!!! USE AUTOMATIC ROLES/ACCESSES MANAGEMENT

!!! USE JASPERREPORTS SERVER INSTEAD OF SOME BI SERVERS (IF POSSIBLE) - for reports by mail, by schedule for example (it is free, Open source)

!!! USE UNIFIED AUDITING (already relink DB binaries) - tune it for interested objects in DB - prepare list of such objects

!!! USE PERSONIFIED ACCOUNTS FOR ETL/DB admins

!!! Отключение dynamic sampling для запросов с ошибкой ORA-08103, еще отключить параллелизм для них (описание DS - Doc ID 2002108.1)
select /*+ dynamic_sampling(0) */

!!! avoid
ORA-07445 appeared when select data and session terminated (SR 3-14163700481)
ORA-00600: [kkqcscorcbk: correlated string not found.], [], [], [], [], [], [], [], [], [], [], [] error

alter session set "_optimizer_cost_based_transformation" = off;
alter session set "_complex_view_merging" = false; 

!!! Logical standby для CBVIEWP standby c VDRF

!!! InMemory для выборочных столбцов и выборочных партиций (со смещением во времени) 

!!! Процедуры периодического тестирования Disaster recovery

!!! MOVE для LM таблиц

!!! filesystemio_options = setall on CBVIEWP and (on standby this parameter is SETALL)

!!! Использование DRCP способа соединения с БД

!!! Вставки в HCC таблицы с директивой APPEND для того, чтобы вставляемые строки сохраняли компрессию

OK - Для части таблиц (для части нужно доработать адм. процедуры) - Использовать FLASHBACK ARCHIVE

!!! Использовать ACTIVE STANDBY для READ ONLY пользователей

OK - Добавить сервис для прозрачного использования БД (в зависимости от роли БД)

На SPUR FILESYSTEMIO_OPTIONS=NONE (хотя и disk_asynch_io = TRUE)
отключен асинхронный ввод-вывод во все файла БД, нужно менять на SETALL => требуется перезапуск экземпляра

!!! Таблицы LM после удаления данных из них (COUNT = 0) все равно содержат блоки и занимают место в ТП. Пробовать переводить их на TEMPORARY в отдельным TEMP и UNDO (12c)

SELECT * FROM DBA_SEGMENTS WHERE SEGMENT_NAME LIKE '%/_LM' ESCAPE '/' AND BYTES > 10000000 ORDER BY BYTES DESC;
select count(*) from ..., alter table ... move;

10) Выполненные изменения

--http://jira.moex.com/browse/DWH-122 (удаление НЕуникальных ненужных индексов на Exadata)

-- БД spur, HOST dbeqcu (172.22.10.30)

-- resolve connect to DB problems (SPUR)
alter system set processes = 1024 COMMENT='changed from 700 + reset sessions by chistoviy 10.12.2016' scope = spfile;
alter system reset sessions;
-- resolve logfile sync DB problems (SPUR)
alter system set filesystemio_options = setall COMMENT='changed from default (none) by chistoviy 10.12.2016' scope = spfile;

--Exadata

--fix error ORA 3137 [kpotxpop: no ATX frame] (Doc ID 2169788.1)

alter system set open_links = 8 COMMENT='changed from default (4) by chistoviy 16.12.2016' scope = spfile sid = '*';
alter system set open_links_per_instance = 8 COMMENT='changed from default (4) by chistoviy 16.12.2016' scope = spfile  sid = '*';
-- fix error ORA-07445 [lxkTrim()+930] when selecting data (SR 3-13652822821)

apply patch 24901520 (Release Oracle 12.1.0.2.160719 Proactive BP)

(if you cannot single out a session, enable it instance wide) 
alter system set events '22174441 trace name context forever, level 3'; 
-- to turn off --> alter system set events '22174441 trace name context off'; 

(if you know a partilar session will cause the ora-7445 issue) 
alter session set events '22174441 trace name context forever, level 3'; 
-- to turn off just exit the session 

-- add space to LVM disk groups at domU (domU *vm01.moex.com,*vm02.moex.com,*vm05.moex.com added)

C:\Work\Docs\dba_docs\DB Tasks\Exadata\Administrator_procedures\Adding a New LVM Disk to a User Domain.sh