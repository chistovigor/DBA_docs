-- Добавление сервисов для STANDBY БД

На mr01vm01:
srvctl add service -d spur -service DWH_PRIM -role PRIMARY -preferred spur1
srvctl add service -d spur -service DWH_STB -role PHYSICAL_STANDBY -preferred spur1
srvctl add service -d spur -service DWH_SNAP -role SNAPSHOT_STANDBY -preferred spur1

На var01vm01:
srvctl add service -d spurstb -service DWH_PRIM -role PRIMARY -preferred spurstb
srvctl add service -d spurstb -service DWH_STB -role PHYSICAL_STANDBY -preferred spurstb
srvctl add service -d spurstb -service DWH_SNAP -role SNAPSHOT_STANDBY -preferred spurstb


Сервисы запущены и должны автоматически останавливаться и запускаться при изменении ролей баз.

TNS Записи для новых сервисов:

DWH_PRIM =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = DWH_PRIM)
    )
  )

DWH_STB =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = DWH_STB)
    )
  )

DWH_SNAP =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (FAILOVER=YES)
      (ADDRESS = (PROTOCOL = TCP)(HOST = mr-scan.moex.com)(PORT = 1521))
      (ADDRESS = (PROTOCOL = TCP)(HOST = var-scan.moex.com)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SERVICE_NAME = DWH_STB)
    )
  )

-- Рекомендации по сбору системной статистикм на Экзадате (Doc ID 1274318.1)

exec dbms_stats.gather_system_stats('EXADATA');
при этом заполняется строка с PNAME = MBRC (=128, было NULL) из представления: select * from sys.aux_stats$;
Это говорит оптимизатору отдавать предпочтение SMART_SCAN, а не индексному доступу.

-- проблема в планах запросов с ANSI синтаксивом (описана в документе "ANSI SQL Statement Running Slow in 12C" (Doc ID 2255117.1)) по сравнению с oracle синтаксисом

следующие обходные решения:
1. Set OPTIMIZER_FEATURES_ENABLE = '11.2.0.4' in init.ora or as hint to SQL ie /*+ OPTIMIZER_FEATURES_ENABLE('11.2.0.4') */
2. Set _OPTIMIZER_UNNEST_SCALAR_SQ = FALSE in init.ora or as hint to SQL ie /*+ OPT_PARAM('_OPTIMIZER_UNNEST_SCALAR_SQ' 'FALSE') */
3. Use SQL Patch for the problem SQL with any one of the above parameters without modifying application code: Document 1931944.1

--Включение smart scan, отключение доступа по индексам:

Установка в сесии параметра 
alter session set "_serial_direct_read" = TRUE;
и добавления хинтов для отключения работы по индекскам:
  /*+
      BEGIN_OUTLINE_DATA
      OUTLINE_LEAF(@"SEL$2")
      OUTLINE_LEAF(@"SEL$3")
      FULL("ORDERS_BASE"@"SEL$2")
      FULL("ORDERS"@"SEL$3")
      END_OUTLINE_DATA
  */
  
  -- MOVE партиции и автоматическая перестройка индексов по ней
  
  ALTER TABLE EQ.ORDERS_BASE MOVE PARTITION EQ_ORDERS_BASE_P_20150604 UPDATE INDEXES PARALLEL;  
  
  --Изменение параметра OPTIMIZER_INDEX_COST_ADJ в сессии не приводит к значительному улучшению производительности, 
  --план по прежнему использует индексы даже при крайнем значении OPTIMIZER_INDEX_COST_ADJ=1000

--mr01vm02 (CLUSTER VDRF)
исправление ошибки ORA-12514: TNS:listener does not currently know of service requested in connect descriptor

ALTER SYSTEM SET remote_listener = 'mr-scan2:1521', 'mr-scan2:1521', 'mr-scan2:1521' SCOPE=BOTH SID='dbm021';

-- загрузка данных в большие таблицы CURR и EQ
-- порядок заливки:
/*
1) ORDERS_BASE (spurtab) - 
2) TRADES_BASE (spur) - индексы по ORDERNO и PK
3) 
4) 
5) 
*/ 

-- информация о дисках ASM

select * from v$asm_disk;

select * from V$ASM_DISKGROUP;

-- Включение ILM для БД (для того, чтобы иметь возможость автоматический архивации данных)

http://www.oracle.com/webfolder/technetwork/tutorials/obe/db/12c/r1/ilm/compression_tiering/compression_tiering.html

alter system set heat_map=ON scope=both sid='*';

sho parameter compatible (должен быть минимум '12.1.0.0.0')

Просмотр для пользователя:

select * from user_ilmdatamovementpolicies order by 1;
select * from user_ilmobjects order by 3,4;
select * from user_ilmevaluationdetails; 

На уровне БД:

select * from dba_ilmparameters;

-- включение пераметра, отвечающего за приоритет SMART_SCAN (на уровне экземпляра): см. Exadata Smart Scan FAQ (Doc ID 1927934.1)

alter system set "_serial_direct_read" = true COMMENT = 'changed at 27/06/2016, see Exadata Smart Scan FAQ (Doc ID 1927934.1)' scope=both sid = '*';

-- space usage of EACH database

  SELECT SUBSTR (alias_path,
                 2,
                   INSTR (alias_path,
                          '/',
                          1,
                          2)
                 - 2)
            Database,
         ROUND (SUM (alloc_bytes) / 1024 / 1024 / 1024, 1) "GB"
    FROM (    SELECT SYS_CONNECT_BY_PATH (alias_name, '/') alias_path, alloc_bytes
                FROM (SELECT g.name disk_group_name,
                             a.parent_index pindex,
                             a.name alias_name,
                             a.reference_index rindex,
                             f.space alloc_bytes,
                             f.TYPE TYPE
                        FROM v$asm_file f
                             RIGHT OUTER JOIN v$asm_alias a
                                USING (group_number, file_number)
                             JOIN v$asm_diskgroup g USING (group_number))
               WHERE TYPE IS NOT NULL
          START WITH (MOD (pindex, POWER (2, 24))) = 0
          CONNECT BY PRIOR rindex = pindex)
GROUP BY SUBSTR (alias_path,
                 2,
                   INSTR (alias_path,
                          '/',
                          1,
                          2)
                 - 2)
ORDER BY 2 DESC;

-- для того, чтобы не было ошибки ORA-02085 при работы с DB_LINK

ALTER SESSION SET global_names = FALSE;

SELECT MIN (s.tradedate), MAX (s.tradedate)
  FROM curr.tradelog_base@spur30 s;

  SELECT distinct D.PARTITION_NAME,DD.SEGMENT_NAME,round(DD.BYTES / 1024 / 1024) MB_INDEX
    FROM dba_segments@spur30 d,dba_segments@spur30 dd
   WHERE     D.OWNER = 'CURR'
         AND D.SEGMENT_NAME IN ('TRADELOG_BASE','INDEX1')
         AND DD.SEGMENT_NAME IN ('TRADELOG_BASE','INDEX1')
         AND D.OWNER = DD.OWNER and D.PARTITION_NAME = DD.PARTITION_NAME
ORDER BY 1,2 desc;

  SELECT D.PARTITION_NAME,D.SEGMENT_NAME,
         round(D.BYTES / 1024 / 1024) MB
    FROM dba_segments d
   WHERE     D.OWNER = 'CURR'
         AND D.SEGMENT_NAME IN ('TRADELOG_BASE','TRADELOG_CURR_UIDX')
ORDER BY 1;

SELECT 'spur' AS database,
       COUNT (*),
       '30-11-2015' till_time,
       MIN (tradedate)
  FROM curr.tradelog_base@spur30 s
 WHERE S.TRADEDATE < TO_DATE ('30-11-2015', 'dd-mm-yyyy')
UNION ALL
SELECT 'exadata',
       COUNT (*),
       '30-11-2015',
       MIN (tradedate)
  FROM curr.tradelog_base s
 WHERE S.TRADEDATE < TO_DATE ('30-11-2015', 'dd-mm-yyyy');

-- вставляем строки, затем двигаем партицию, чтобы она сжалась и перестраиваем партицию индекса (NOCOMPRESS занимает меньше места при префиксе 3)

INSERT INTO curr.tradelog_base
   SELECT *
     FROM curr.tradelog_base@spur30 s
    WHERE S.TRADEDATE BETWEEN TO_DATE ('01-02-2015', 'dd-mm-yyyy')
                          AND TO_DATE ('28-02-2015', 'dd-mm-yyyy');
						  
alter table curr.tradelog_base move partition  CURR_TRADELOG_P_201512;

ALTER INDEX CURR.TRADELOG_CURR_UIDX
 REBUILD PARTITION CURR_TRADELOG_P_201512 nocompress;

ALTER INDEX CURR.TRADELOG_CURR_UIDX
 MODIFY PARTITION CURR_TRADELOG_P_201512
 DEALLOCATE UNUSED;

 
 
 
						  

						  
						  