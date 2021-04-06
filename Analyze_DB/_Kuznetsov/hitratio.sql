set serveroutput on size 200000 

declare

 dg_row     float;
 dm_row     float;
 dcr_row    float;
 bcr_row    float;
 dsr_row    float;
 bbw_row    float;
 fbw_row    float;
 lchr_row   float;
 lcpr_row   float;
 rswr_row   float;
 cfr_row    float;
 per_row    float;
 cpo_row    float;
 tsr_row    float;
 dbwra_row  float;
 dbwrs_row  float;

begin
 select sum(gets) dict_gets , sum(getmisses) dict_misses, round((sum(gets-getmisses)*100/sum(gets)),5) rate 
   into dg_row, dm_row, dcr_row 
   from sys.v_$rowcache;
 begin  
 select round((congets.value+dbgets.value-physreads.value)*100/(congets.value+dbgets.value),5) 
   into bcr_row     
   from v$sysstat congets, v$sysstat dbgets, v$sysstat physreads 
  where congets.name='consistent gets'
    and dbgets.name='db block gets'
    and physreads.name='physical reads';
  EXCEPTION  
   WHEN OTHERS THEN 
    bcr_row := 0;
 end;   
      
 begin
 select round((ds.value/decode( (ds.value+ms.value), 0,1,(ds.value+ms.value))*100),5)
   into dsr_row
   from v$sysstat ds, v$sysstat ms
  where ms.name='sorts (memory)'
    and ds.name='sorts (disk)';
  EXCEPTION  
   WHEN OTHERS THEN 
    dsr_row := 0;
 end;   
     
 begin
 select round((bbc.total_waits*100/(cg.value+dbg.value)),5)
   into bbw_row
   from v$system_event bbc,
        v$sysstat cg,  v$sysstat dbg 
  where bbc.event='buffer busy waits'
    and cg.name ='consistent gets' 
    and dbg.name='db block gets';
  EXCEPTION  
   WHEN OTHERS THEN 
    bbw_row := 0;
 end;                
 begin
 select round((bbw.total_waits*100/(cg.value+dbg.value)),5)
   into fbw_row
   from v$system_event bbw,
        v$sysstat cg, v$sysstat dbg
  where bbw.event='free buffer waits'
    and cg.name ='consistent gets'
    and dbg.name='db block gets';
  EXCEPTION  
   WHEN OTHERS THEN 
    fbw_row := 0;
 end;
  
 begin
 select round((sum(gethits)*100/sum(gets)),5)
   into lchr_row  
   from v$librarycache;
  EXCEPTION  
   WHEN OTHERS THEN 
    lchr_row := 0;
 end;
     
 begin    
 select round((sum(pinhits)*100/sum(pins)),5)
   into lcpr_row
   from v$librarycache;
  EXCEPTION  
   WHEN OTHERS THEN 
    lcpr_row := 0;
 end;
 
 begin
    select round(((sw.value)*100/lw.value),5)
     into rswr_row 
     from v$sysstat sw, v$sysstat lw
    where sw.name='redo log space requests'
      and lw.name='redo writes';
  EXCEPTION  
   WHEN OTHERS THEN 
    rswr_row := 0;
 end;
     
 begin
 select round((rfcr.value*100/(tsrg.value+tfbr.value)),5)
   into cfr_row
   from v$sysstat rfcr,
        v$sysstat tsrg,
        v$sysstat tfbr
  where rfcr.name='table fetch continued row'
    and tsrg.name='table scan rows gotten'
    and tfbr.name='table fetch by rowid';
  EXCEPTION  
   WHEN OTHERS THEN 
    cfr_row := 0;
 end;
 begin         
 select round((pc.value*100/decode(ec.value,0,1,ec.value)),5)
   into per_row 
   from v$sysstat ec,  v$sysstat pc
  where ec.name='execute count'
      and pc.name='parse count (total)';
  EXCEPTION  
   WHEN OTHERS THEN 
    per_row := 0;
 end;
    
 begin
 select round((pc.value*100/decode(ec.value,0,1,ec.value)),5)
   into cpo_row
   from v$sysstat ec, v$sysstat pc
  where ec.name='CPU used by this session'
    and pc.name='parse time cpu';
  EXCEPTION  
   WHEN OTHERS THEN 
    cpo_row := 0;
 end;
 
 begin
 select round(((r.value/(r.value+s.value))*100),5)
   into tsr_row
   from v$sysstat r, v$sysstat s
  where r.name='table fetch by rowid'
    and s.name='table scan rows gotten';
  EXCEPTION  
   WHEN OTHERS THEN 
    tsr_row := 0;
 end;
 
 begin
 select round((decode(dlu.value, NULL, 0, 0, 0,  dbs.value/dlu.value)),5)
   into dbwra_row
   from v$sysstat dbs, v$sysstat dlu
  where dbs.name='DBWR summed scan depth'
    and dlu.name='DBWR lru scans';
  EXCEPTION  
   WHEN OTHERS THEN 
    dbwra_row := 0;
 end;
 
 begin
 select round((decode(dlu.value, NULL, 0, 0, 0,  dbs.value/dlu.value)),5)
   into dbwrs_row
   from v$sysstat dbs, v$sysstat dlu
  where dbs.name='DBWR buffers scanned'
    and dlu.name='DBWR lru scans';
   EXCEPTION  
   WHEN OTHERS THEN 
    dbwrs_row := 0;
 end;

dbms_output.put_line ('============================================='); 
dbms_output.put_line ('Dictionary Gets             : ' || dg_row ); 
dbms_output.put_line ('Dictionary Miss             : ' || dm_row ); 
dbms_output.put_line ('Dictionary Cache Hit Ratio  : ' || dcr_row ); 
dbms_output.put_line ('Buffer Cache Hit Ratio      : ' || bcr_row ); 
dbms_output.put_line ('Buffer Busy Wait Ratio      : ' || bbw_row ); 
dbms_output.put_line ('Free Buffer Wait Ratio      : ' || fbw_row ); 
dbms_output.put_line ('Library Cache Get Hit Ratio : ' || lchr_row ); 
dbms_output.put_line ('Library Cache Pin Hit Ratio : ' || lcpr_row ); 
dbms_output.put_line ('Disk Sort Ratio             : ' || dsr_row ); 
dbms_output.put_line ('Redo Space Wait Ratio       : ' || rswr_row ); 
dbms_output.put_line ('Chained Fetch Ratio         : ' || cfr_row ); 
dbms_output.put_line ('Parse To Execute Ratio      : ' || per_row ); 
dbms_output.put_line ('CPU Parse Overhead          : ' || cpo_row ); 
dbms_output.put_line ('Ratio Rows Index/Total Rows : ' || tsr_row ); 
dbms_output.put_line ('DBWR Average Scan Depth     : ' || dbwra_row ); 
dbms_output.put_line ('DBWR Average Bufers Scanned : ' || dbwrs_row ); 
dbms_output.put_line ('============================================='); 
end; /* of all */ 

/


exec dbms_output.put_line ('System HitRatio'); 
select 
SUM(DECODE(Name, 'consistent gets',Value,0)) Consistent,
SUM(DECODE(Name, 'db block gets',Value,0)) Dbblockgets,
SUM(DECODE(Name, 'physical reads',Value,0)) Physrds,
ROUND(((SUM(DECODE(Name, 'consistent gets', Value, 0))+
SUM(DECODE(Name, 'db block gets', Value, 0)) -
SUM(DECODE(Name, 'physical reads', Value, 0)) )/
(SUM(DECODE(Name, 'consistent gets',Value,0))+
SUM(DECODE(Name, 'db block gets', Value, 0))))*100,2) Hitratio
from V$SYSSTAT
/

exec dbms_output.put_line ('Sessions HitRatio'); 
column HitRatio format 999.99
select Username, osuser, Consistent_Gets, Block_Gets, Physical_Reads, 
100*(Consistent_Gets+Block_Gets-Physical_Reads)/(Consistent_Gets+Block_Gets) HitRatio 
from V$SESSION, V$SESS_IO
where V$SESSION.SID = V$SESS_IO.SID and 
     (Consistent_Gets+Block_Gets)>0 and 
     Username is not null
/

