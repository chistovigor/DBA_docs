select to_char(ADD_MONTHS(sysdate,-4),'YYYYMM') from dual;
SELECT tab
CREATE PUBLIC DATABASE LINK "LANIT_PROD" CONNECT TO "ROUTER" IDENTIFIED by "loopexamspit" USING 'LANIT_PROD'
impdp router/loopexamspit tables=NB201307,UL201307, content=ALL parallel=2 table_exists_action=REPLACE NETWORK_LINK=lanit_test logfile=DATA_PUMP_DIR:imp_1.log estimate=blocks