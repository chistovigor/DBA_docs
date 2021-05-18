OPTIONS ( DIRECT=TRUE, PARALLEL=TRUE)
LOAD DATA
CHARACTERSET UTF8
INFILE 'TickersDict.txt'
BADFILE 'TickersDict.bad'
DISCARDFILE 'TickersDict.dsc'
DISCARDMAX 10

INTO TABLE "DAKR_MSSQL"."TICKERSDICT"
APPEND
FIELDS TERMINATED BY X'9'
(TICKER,
MARKET,
NAME)






Либо в качестве параметров окружения клиента, в которм запускается sqlloader нужно установить правильную локаль и набор символов 
(пример для Locale: English (US), Code page: 1251 (ANSI - Cyrillic))

#!!! set LOCALE and characterset the same as when export from mssql !!!
export NLS_LANG=AMERICAN_AMERICA.CL8MSWIN1251