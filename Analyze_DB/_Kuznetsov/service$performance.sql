drop public synonym hitratio
/
drop public synonym hitratio_pipe
/
drop view service$performance_view
/
drop view service$performance_view_pipe
/
drop package body service$performance
/
drop package service$performance
/
drop type service$hitratio_table
/
drop type service$hitratio_type
/

create or replace type service$hitratio_type  as object 
  ( hitratio_name  varchar2(32), 
    hitratio_value varchar2(32), 
    hitratio_goal  varchar2(32)
  )
/
create or replace type service$hitratio_table as table of service$hitratio_type
/

create or replace package service$performance
as
--------------------------------------------------------------------------------
-- Grigory Kuznetsov
-- 28-июн-2004 9:27
-- Package service$performance
--------------------------------------------------------------------------------
  function getGlobalName           return varchar2;
  function getHitRatioBufferCache  return varchar2;
  function getHitRatioDataDict     return varchar2;
  function getHitRatioLibraryCache return varchar2;
  function getHitRatioLogBuffer    return varchar2;
  function getHitRatioSort         return varchar2;
  function getHitRatioPGA          return varchar2;
  function getHitRatioRBSWait      return varchar2;
  function getHitRatioRBSHeader    return varchar2;
  function getHitRatioParseSoft    return varchar2;
  function getHitRatioParseHard    return varchar2;
  function getHitRatioParseFails   return varchar2;
  function getHitRatioLatch        return varchar2;
  function getHitRatioSCC          return varchar2;
  function getHitRatioOC           return varchar2;
  function getHitRatioALL          return service$hitratio_table;
  function getHitRatioALL_Pipe     return service$hitratio_table PIPELINED;

end;
/

create or replace package body service$performance
as
   g_GlobalName           varchar2(64);
   g_HitRatioBufferCache  varchar2(32);
   g_HitRatioDataDict     varchar2(32);
   g_HitRatioLibraryCache varchar2(32);
   g_HitRatioLogBuffer    varchar2(32);
   g_HitRatioSort         varchar2(32);
   g_HitRatioPGA          varchar2(32);
   g_HitRatioRBSWait      varchar2(32);
   g_HitRatioRBSHeader    varchar2(32);
   g_HitRatioParseSoft    varchar2(32);
   g_HitRatioParseHard    varchar2(32);
   g_HitRatioParseFails   varchar2(32);
   g_HitRatioLatch        varchar2(32);
   g_HitRatioSCC          varchar2(32);
   g_HitRatioOC           varchar2(32);

   function getGlobalName return varchar2 as
   begin
    return g_GlobalName;
   end;
   
   function getHitRatioBufferCache return varchar2 as
   begin
    select trim(to_char((1 - ((physical.value - direct.value - lobs.value) / logical.value))*100,'900D0000'))||' %' 
           into g_HitRatioBufferCache
    from v$sysstat physical,
         v$sysstat direct,
         v$sysstat lobs,
         v$sysstat logical
    where physical.name = 'physical reads' and
          direct.name   = 'physical reads direct' and
          lobs.name     = 'physical reads direct (lob)' and      
          logical.name  = 'session logical reads';
    return g_HitRatioBufferCache;
   end;

   function getHitRatioDataDict return varchar2 as
   begin
    select trim(to_char((1 - (sum(getmisses)/sum(gets)))*100,'900D0000'))||' %' 
           into g_HitRatioDataDict
    from v$rowcache;
    return g_HitRatioDataDict;
   end;

   function getHitRatioLibraryCache return varchar2 as
   begin
    select trim(to_char((sum(reloads)/sum(pins))*100,'00D0000'))||' %' 
           into g_HitRatioLibraryCache
    from v$librarycache;
    return g_HitRatioLibraryCache;
   end;

   function getHitRatioLogBuffer return varchar2 as
   begin
    select trim(to_char((retries.value/entries.value)*100,'900D0000'))||' %' 
           into g_HitRatioLogBuffer
    from v$sysstat retries,
         v$sysstat entries
    where retries.name = 'redo buffer allocation retries' and
          entries.name = 'redo entries'; 
    return g_HitRatioLogBuffer;
   end;

   function getHitRatioSort return varchar2 as
   begin
    select trim(to_char((mem.value/(disk.value+mem.value))*100,'900D0000'))||' %' 
           into g_HitRatioSort
    from v$sysstat mem, v$sysstat disk
    where  mem.name = 'sorts (memory)' and 
	      disk.name = 'sorts (disk)';
    return g_HitRatioSort;
   end;

   function getHitRatioPGA return varchar2 as
   begin
    begin
     select nvl(trim(to_char(value,'900D0000'))||' %','-')
            into g_HitRatioPGA
     from v$pgastat 
     where name='cache hit percentage';
    exception
      when no_data_found then g_HitRatioPGA := '-';
    end;
    return g_HitRatioPGA;
   end;

   function getHitRatioRBSWait return varchar2 as
   begin
    select trim(to_char((w.rbs_wait/s.value)*100,'900D0000'))||' %'
           into g_HitRatioRBSWait
    from ( select sum(count) rbs_wait
           from v$waitstat
           where class in ('undo header','system undo header') ) w,
          v$sysstat s
    where s.name = 'consistent gets';
    return g_HitRatioRBSWait;
   end;

   function getHitRatioRBSHeader return varchar2 as
   begin
    select trim(to_char((1-sum(s.waits)/sum(s.gets))*100,'900D0000'))||' %'
           into g_HitRatioRBSHeader
    from v$rollstat s;
    return g_HitRatioRBSHeader;
   end;

   function getHitRatioParseSoft return varchar2 as
   begin
    select trim(to_char((((select sum(value) from v$sysstat where name = 'parse count (total)') - 
                          (select sum(value) from v$sysstat where name = 'parse count (failures)') -
                          (select sum(value) from v$sysstat where name = 'parse count (hard)')) /
                          (select sum(value) from v$sysstat where name = 'parse count (total)'))*100,'900D0000'))||' %'
           into g_HitRatioParseSoft
    from dual;
    return g_HitRatioParseSoft;
   end;
   
   function getHitRatioParseHard return varchar2 as
   begin
    select trim(to_char((((select sum(value) from v$sysstat where name = 'parse count (hard)')) /
                          (select sum(value) from v$sysstat where name = 'parse count (total)'))*100,'900D0000'))||' %'
           into g_HitRatioParseHard
    from dual;
    return g_HitRatioParseHard;
   end;

   function getHitRatioParseFails return varchar2 as
   begin
    select trim(to_char((((select sum(value) from v$sysstat where name = 'parse count (failures)')) /
                          (select sum(value) from v$sysstat where name = 'parse count (total)'))*100,'900D0000'))||' %'
           into g_HitRatioParseFails
    from dual;
    return g_HitRatioParseFails;
   end;

   function getHitRatioLatch return varchar2 as
   begin
    select trim(to_char((select sum(gets) - sum(misses) from v$latch)*100 / (select sum(gets) from v$latch),'900D0000'))||' %'
           into g_HitRatioLatch
    from dual;
    return g_HitRatioLatch;
   end;

   function getHitRatioSCC return varchar2 as
   begin
    select decode(value, 0, '-', trim(to_char(100 * used / value, '900D0000')) || ' %')  usage
           into g_HitRatioSCC
    from   ( select max(s.value) used from v$statname n, v$sesstat s where n.name = 'session cursor cache count' and s.statistic# = n.statistic#),
           ( select value from v$parameter where name = 'session_cached_cursors');
    return g_HitRatioSCC;
   end;

   function getHitRatioOC return varchar2 as
   begin
    select decode(value, 0, '-', trim(to_char(100 * used / value, '900D0000')) || ' %')  usage
           into g_HitRatioOC
    from ( select max(sum(s.value))  used from v$statname n, v$sesstat s where n.name in ('opened cursors current', 'session cursor cache count') and s.statistic# = n.statistic# group by s.sid ),
         ( select value from v$parameter where name = 'open_cursors');
    return g_HitRatioOC;
   end;

   function getHitRatioALL return service$hitratio_table
   as
    v_xResult service$hitratio_table := service$hitratio_table();
   begin
     v_xResult.extend;
     v_xResult(1) := service$hitratio_type('Buffer Cache',   getHitRatioBufferCache, '> 90 %');
     v_xResult.extend;
     v_xResult(2) := service$hitratio_type('Data Dict Cache',getHitRatioDataDict,    '> 85 %');
     v_xResult.extend;
     v_xResult(3) := service$hitratio_type('Library Cache',  getHitRatioLibraryCache,'<  1 %');
     v_xResult.extend;
     v_xResult(4) := service$hitratio_type('Log Buffer',     getHitRatioLogBuffer,   '<  1 %');
     v_xResult.extend;
     v_xResult(5) := service$hitratio_type('Sort Ratio',     getHitRatioSort,        '> 95 %');
     v_xResult.extend;
     v_xResult(6) := service$hitratio_type('PGA Ratio',      getHitRatioPGA,         '> 95 %');
     v_xResult.extend;
     v_xResult(7) := service$hitratio_type('RBS Wait',       getHitRatioRBSWait,     '<  1 %');
     v_xResult.extend;
     v_xResult(8) := service$hitratio_type('RBS Header',     getHitRatioRBSHeader,   '> 95 %');
     v_xResult.extend;
     v_xResult(9) := service$hitratio_type('Parse Soft',     getHitRatioParseSoft,   '> 90 %');
     v_xResult.extend;
     v_xResult(10) := service$hitratio_type('Parse Hard',    getHitRatioParseHard,   '-');
     v_xResult.extend;
     v_xResult(11) := service$hitratio_type('Parse Fails',   getHitRatioParseFails,  '-');
     v_xResult.extend;
     v_xResult(12) := service$hitratio_type('Latch Ratio',   getHitRatioLatch,       '> 99%');
     v_xResult.extend;
     v_xResult(13) := service$hitratio_type('Session Cached Cursor',   getHitRatioSCC,       '< 99%');
     v_xResult.extend;
     v_xResult(14) := service$hitratio_type('Open Cursors',  getHitRatioOC,          '< 99%');
     return v_xResult;  
   end;


   function getHitRatioALL_Pipe return service$hitratio_table PIPELINED 
   is
    v_xResult service$hitratio_type := service$hitratio_type(NULL,NULL,NULL);
   begin

     v_xResult.hitratio_name  := 'DB Report Time';
     select trim(to_char(systimestamp,'dd.Mon.yyyy hh24:mi:ss')) into v_xResult.hitratio_value from sys.dual;
     v_xResult.hitratio_goal  := '-';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'DB Global Name';
     select global_name into v_xResult.hitratio_value from global_name;
     v_xResult.hitratio_goal  := '-';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'DB Platform Name';
     v_xResult.hitratio_value := dbms_utility.port_string;
     v_xResult.hitratio_goal  := '-';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Buffer Cache';
     v_xResult.hitratio_value := getHitRatioBufferCache;
     v_xResult.hitratio_goal  := '> 90 %';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Data Dict Cache';
     v_xResult.hitratio_value := getHitRatioDataDict;
     v_xResult.hitratio_goal  := '> 85 %';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Library Cache';
     v_xResult.hitratio_value := getHitRatioLibraryCache;
     v_xResult.hitratio_goal  := '<  1 %';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Log Buffer';
     v_xResult.hitratio_value := getHitRatioLogBuffer;
     v_xResult.hitratio_goal  := '<  1 %';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Sort Ratio';
     v_xResult.hitratio_value := getHitRatioSort;
     v_xResult.hitratio_goal  := '> 95 %';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'PGA Ratio';
     v_xResult.hitratio_value := getHitRatioPGA;
     v_xResult.hitratio_goal  := '> 95 %';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'RBS Wait';
     v_xResult.hitratio_value := getHitRatioRBSWait;
     v_xResult.hitratio_goal  := '<  1 %';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'RBS Header';
     v_xResult.hitratio_value := getHitRatioRBSHeader;
     v_xResult.hitratio_goal  := '> 95 %';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Parse Soft';
     v_xResult.hitratio_value := getHitRatioParseSoft;
     v_xResult.hitratio_goal  := '> 90 %';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Parse Hard';
     v_xResult.hitratio_value := getHitRatioParseHard;
     v_xResult.hitratio_goal  := '-';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Parse Fails';
     v_xResult.hitratio_value := getHitRatioParseFails;
     v_xResult.hitratio_goal  := '-';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Latch Ratio';
     v_xResult.hitratio_value := getHitRatioLatch;
     v_xResult.hitratio_goal  := '> 99%';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Session Cached Cursor';
     v_xResult.hitratio_value := getHitRatioSCC;
     v_xResult.hitratio_goal  := '< 99%';
     PIPE ROW(v_xResult);

     v_xResult.hitratio_name  := 'Open Cursors';
     v_xResult.hitratio_value := getHitRatioOC;
     v_xResult.hitratio_goal  := '< 99%';
     PIPE ROW(v_xResult);

     return;  
   end;

--------------------------------------------------------------------------------
-- Grigory Kuznetsov
-- 28-июн-2004 9:27
-- Package service$performance
--------------------------------------------------------------------------------
begin
  select global_name||' ('||dbms_utility.port_string||')' 
         into g_GlobalName
  from global_name;
end;
/


create or replace view service$performance_view
as
select /*+ ALL_ROWS*/ * from table(cast(service$performance.getHitRatioALL as service$hitratio_table))
with read only
/

create or replace view service$performance_view_pipe
as
select /*+ ALL_ROWS*/ * from table(cast(service$performance.getHitRatioALL_Pipe as service$hitratio_table))
with read only
/

grant select on service$performance_view to public
/

grant select on service$performance_view_pipe to public
/

create or replace public synonym hitratio for service$performance_view
/

create or replace public synonym hitratio_pipe for service$performance_view_pipe
/

--
-- Использование 1
--
-- select service$performance.getGlobalName from dual;
-- select service$performance.getHitRatioBufferCache from dual;
-- select service$performance.getHitRatioDataDict from dual;
-- select service$performance.getHitRatioLibraryCache from dual;
-- select service$performance.getHitRatioLogBuffer from dual;
-- select service$performance.getHitRatioSort from dual;
--
-- Использование 2
--
-- column namehitratio format a25 justify left
-- column hitratio format a15 justify left
-- column goalhitratio format a15 justify left
--
-- select * from sys.service$performance_view;
-- select * from hitratio_pipe;

