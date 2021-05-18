select * from v$session@cbviewp;
select * from all_ind_columns@cbviewp where table_name = 'ORDERS' and TABLE_OWNER = 'SPUR_DAY_CU';
select * from all_ind_columns@cbviewp where table_name = 'TRADES' and TABLE_OWNER = 'SPUR_DAY' order by 1,2;
select * from all_ind_columns@cbviewp where table_name = 'ORDERS' and TABLE_OWNER = 'SPUR_DAY' order by 1,2;
select * from all_indexes@cbviewp where table_name = 'CU_POSITIONS_BASE';
select * from all_indexes@cbviewp where table_name = 'TRADES';
select * from dba_db_links@cbviewp order by 1,2;
select count(*) from CHECK_RUN_LOG@CBVIEWP; --45296
select * from dba_tab_modifications@cbviewp where PARTITION_NAME = 'TRADES_P_24042017';
select count(1) from SPUR_DAY.TRADES@cbviewp where TRADEDATE = to_date('22022017','DDMMYYYY');
select * from SPUR_DAY.TRADES@cbviewp where TRADEDATE > to_date('31.12.2017','DD.MM.YYYY') and TRADEDATE < to_date('02.01.2018','DD.MM.YYYY');
select * from SPUR_DAY_CU.TRADES@cbviewp where TRADEDATE > to_date('31.12.2017','DD.MM.YYYY') and TRADEDATE < to_date('02.01.2018','DD.MM.YYYY');
select * from SPUR_DAY.param@cbviewp;
-- set flag before starting trades
update SPUR_DAY.param@cbviewp set VAL = 0 where ID = 'BUSY' and SYSTEMID = 'ONLINETRADES' and VAL = 1;
select MAX(TRADETIME) from SPUR_DAY.TRADES@cbviewp where TRADEDATE = trunc(sysdate);
select MAX(TRADETIME) from SPUR_DAY_CU.TRADES@cbviewp where TRADEDATE = trunc(sysdate);
select MAX(ENTRYTIME) from SPUR_DAY.ORDERS@cbviewp where ENTRYDATE = trunc(sysdate);
select MAX(ENTRYTIME) from SPUR_DAY_CU.ORDERS@cbviewp where ENTRYDATE = trunc(sysdate);
select count(1) from SPUR_DAY_CU.ERRLOG@cbviewp where UPDATEDT = trunc(sysdate);
select count(1) from SPUR_DAY.ERRLOG@cbviewp where UPDATEDT = trunc(sysdate);
select * from spur_day.trades_log@cbviewp where IDATE >= trunc(sysdate) order by IDATE desc;
select * from spur_day_cu.trades_log@cbviewp where IDATE >= trunc(sysdate) order by IDATE desc;
select * from all_tables@cbviewp where owner = 'SPUR_DAY' order by 1,2;
select * from dba_tab_partitions@cbviewp where PARTITION_NAME = 'ORDERS_CU_P_31082015';
select * from dba_tab_partitions@cbviewp where TABLE_OWNER like 'SPUR_DAY%' and PARTITION_NAME like '%2018';
select * from dba_tablespaces@cbviewp where TABLESPACE_NAME like '%2018%';
select * from dba_data_files@cbviewp where TABLESPACE_NAME like '%2018%';
select sum(bytes) from dba_segments@cbviewp where SEGMENT_NAME='MONEY_CLEARING_BASE'; --58 293 682 176
select sum(bytes) from dba_segments@cbviewp where SEGMENT_NAME='FUT_USER_DEAL_BASE'; --154 857 897 984
select * from dba_tables@cbviewp where tablespace_name='GGS';
select * from dba_indexes@cbviewp where tablespace_name='GGS';
select * from dba_dependencies@cbviewp where name = 'ASTS_SE_RM_HOLD';
select * from dba_users@cbviewp;
select * from dba_db_links@cbviewp order by 1,2;
select * from dba_data_files@cbviewp where file_name like '/preview/ora_data7/CBVIEWP%';
select * from dba_data_files@cbviewp where TABLESPACE_NAME like '%/_P/_%122017%' ESCAPE '/' 
and regexp_replace(substr(FILE_NAME,28),'[A-Z,_]','') not like '%201701'
order by to_date(regexp_replace(substr(FILE_NAME,28),'[A-Z,_]',''),'ddmmyyyy');
select * from v$session@cbviewp where PROGRAM like '%vm01%';

--create files for new partitions

SELECT    'create smallfile tablespace '
       || REPLACE (SUBSTR (NAME, 28), '2017', '2018')
       || ' datafile ''/preview/ora_data2/CBVIEWP/'
       || REPLACE (SUBSTR (NAME, 28), '2017', '2018')
       || ''' size 1M reuse autoextend on next 10M maxsize 5000M logging extent management local segment space management auto default compress for oltp;'
  FROM V$DBFILE@CBVIEWP
 WHERE    NAME LIKE '/preview/ora_data6/CBVIEWP/%_%012017'
       OR NAME LIKE '/preview/ora_data6/CBVIEWP/%_%022017'
       OR NAME LIKE '/preview/ora_data6/CBVIEWP/%_%032017'
       OR NAME LIKE '/preview/ora_data6/CBVIEWP/%_%042017';

ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY';

SELECT    'alter table '
       || TABLE_OWNER
       || '.'
       || TABLE_NAME
       || ' add partition '
       || REPLACE (PARTITION_NAME, '2017', '2018')
       || ' values less than ('
       || 'to_date('''
       || TO_CHAR (
                TO_DATE (
                    SUBSTR (PARTITION_NAME, LENGTH (PARTITION_NAME) - 7, 8),
                    'DDMMYYYY')
              + 366)
       || ''','
       || '''DD.MM.YYYY'''
       || ')) tablespace '
       || REPLACE (TABLESPACE_NAME, '2017', '2018')
       || ' compress for oltp;'
  FROM DBA_TAB_PARTITIONS@CBVIEWP
 WHERE    TABLE_OWNER LIKE 'SPUR_DAY%' AND PARTITION_NAME LIKE '%012017'
       OR PARTITION_NAME LIKE '%022017'
       OR PARTITION_NAME LIKE '%032017'
       OR PARTITION_NAME LIKE '%042017';

select sum(MB) from (select OWNER,SEGMENT_NAME,round(sum(bytes)/1024/1024,2) MB from dba_segments@cbviewp where SEGMENT_NAME in (select INDEX_NAME from all_indexes@cbviewp where table_name in ('TRADES','ODERS')) group by OWNER,SEGMENT_NAME);
select OWNER,SEGMENT_NAME,round(sum(bytes)/1024/1024,2) MB from dba_segments@cbviewp where SEGMENT_NAME in (select TABLE_NAME from all_tables@cbviewp where table_name in ('TRADES','ODERS')) group by OWNER,SEGMENT_NAME;
select sum(MB) from (select OWNER,SEGMENT_NAME,round(sum(bytes)/1024/1024,2) MB from dba_segments@cbviewp where SEGMENT_NAME in (select INDEX_NAME from all_indexes@cbviewp where table_name in ('TRADES','ODERS')) group by OWNER,SEGMENT_NAME);
select OWNER,SEGMENT_NAME,round(sum(bytes)/1024/1024,2) MB from dba_segments@cbviewp where SEGMENT_NAME in (select TABLE_NAME from all_tables@cbviewp where table_name in ('TRADES','ODERS')) group by OWNER,SEGMENT_NAME;

select sum(MB) from (select OWNER,SEGMENT_NAME,round(sum(bytes)/1024/1024,2) MB from dba_segments@cbviewp where SEGMENT_NAME in (select INDEX_NAME from all_indexes@cbviewp where table_name = 'TRADES' and owner = 'SPUR_DAY') group by OWNER,SEGMENT_NAME);
select OWNER,SEGMENT_NAME,round(sum(bytes)/1024/1024,2) MB from dba_segments@cbviewp where SEGMENT_NAME in (select TABLE_NAME from all_tables@cbviewp where table_name in 'TRADES' and owner = 'SPUR_DAY') group by OWNER,SEGMENT_NAME;

select sum(MB) from (select OWNER,SEGMENT_NAME,round(sum(bytes)/1024/1024,2) MB from dba_segments@cbviewp where SEGMENT_NAME in (select INDEX_NAME from all_indexes@cbviewp where table_name = 'TRADES' and owner = 'SPUR_DAY_CU') group by OWNER,SEGMENT_NAME);
select OWNER,SEGMENT_NAME,round(sum(bytes)/1024/1024,2) MB from dba_segments@cbviewp where SEGMENT_NAME in (select TABLE_NAME from all_tables@cbviewp where table_name in 'TRADES' and owner = 'SPUR_DAY') group by OWNER,SEGMENT_NAME;

select * from dba_tablespaces@cbviewp where CONTENTS = 'TEMPORARY';
select * from dba_temp_files@cbviewp where tablespace_name = 'TEMP';
select * from dba_data_files@cbviewp where tablespace_name = 'UNDOTBS1';
select * from all_tab_statistics@cbviewp where TABLE_NAME = 'ORDERS';
