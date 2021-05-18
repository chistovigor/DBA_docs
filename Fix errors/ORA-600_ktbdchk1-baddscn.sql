Проблема описана в Doc ID 8895202.8, одно из решений - в Doc ID 1608167.1 (in Physical Standby after switch-over)

-- Для того, чтобы избежать проблемы, задать параметр (на Primary и на Standby БД):

ALTER SYSTEM SET "_ktb_debug_flags"=8 COMMENT='Oracle support Doc ID 1608167.1, set 14.07.2015' SCOPE=BOTH SID='*';

-- Проверяем все файлы DBV
dbv FILE=/u01/oradata/dbfiles/ULTRADB/aud01.dbf blocksize=8192

если видим в результате:

DBVERIFY - Verification starting : FILE = /u01/oradata/dbfiles/ULTRADB/aud01.dbf
itl[2] has higher commit scn(0x0882.f103caac) than block scn (0x0882.29820f67)
Page 34863 failed with check code 6056

-- ищем этот блок

-- среди занятых

select segment_type, segment_name, owner 
from dba_extents 
 WHERE file_id = 8 AND 34863 BETWEEN block_id AND block_id + blocks - 1;
 
 --Пересоздаем индексы, которые затронуты
 
alter index xxx rebuild online;

-- если его нет, среди свободных

Select *
from dba_free_space 
 WHERE file_id = 8 AND 34863 BETWEEN block_id AND block_id + blocks - 1;
 
 -- после этого по возможности уменьшаем файл данных, в котором этот свободный блок, чтобы он исчез
 --(shrink tablespace, resize datafile)
 
 