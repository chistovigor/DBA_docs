set serveroutput on size 1000000 format wrapped
set trimspool on

declare

dbname varchar2(15); -- Database Name
tsgasize number; -- Total SGA Size
bcsize number; -- Buffer Cache Size
spsize number; -- Shared Pool Size
jpsize number; -- Java Pool Size
lpsize number; -- Large Pool Size
stsize number:=0; -- Stream Pool Size
fsize number; -- Fixed SGA Size
rbsize number; -- Redo Buffers
imsize number:=0; -- In-Memory Area - 12cR1
used number; -- Used SGA Memory
free number; -- Free SGA Memory
granule_size number; -- Granule Size
tvsize number; -- Total Variable Size

cursor c1 is
select name, value from sys.v$parameter where name in ('java_pool_size', 'large_pool_size','streams_pool_size');

cursor c2 is
select name, value from sys.v$sga;

begin
select name into dbname from sys.v$database;
select x.ksppstvl/(1024*1024) into granule_size from sys.x$ksppsv x, sys.x$ksppi y
where x.indx=y.indx and y.ksppinm='_ksmg_granule_size';

for cur1 in c1 loop
  case cur1.name
      when 'java_pool_size' then jpsize :=cur1.value;
      when 'large_pool_size' then lpsize :=cur1.value;
      when 'streams_pool_size' then stsize :=cur1.value;
  end case;
end loop;

for cur2 in c2 loop
    case cur2.name
     when 'Fixed Size' then fsize := cur2.value;
     when 'Variable Size' then tvsize := cur2.value;
     when 'Database Buffers' then bcsize :=cur2.value;
     when 'Redo Buffers' then rbsize :=cur2.value;
     when 'In-Memory Area' then imsize :=cur2.value;
    end case;
end loop;

select cursiz_kghdsnew*granule_size into spsize
from sys.x$ksmsp_dsnew;

tsgasize := (fsize+tvsize+bcsize+rbsize+imsize);
free := (tvsize - ((spsize*1024*1024)+lpsize+jpsize+stsize));
used := tsgasize - free ;

dbms_output.put_line(' ');
dbms_output.put_line('------------------------------------');
dbms_output.put_line('SGA Configuration for '||dbname);
dbms_output.put_line('------------------------------------');
dbms_output.put_line('Current SGA Size    |  '||lpad(round(used/(1024*1024),2),10)||' MB');
dbms_output.put_line('Maximum SGA Size    |  '||lpad(round(tsgasize/(1024*1024),2),10)||' MB');
dbms_output.put_line('Memory for SGA Grow |  '||lpad(round(free/(1024*1024),2),10)||' MB');
dbms_output.put_line('------------------------------------');
dbms_output.put_line('Buffer Cache Size   |  '||lpad(round(bcsize/(1024*1024),2),10)||' MB');
dbms_output.put_line('Shared Pool Size    |  '||lpad(spsize,10)||' MB');
dbms_output.put_line('Large Pool Size     |  '||lpad(round(lpsize/(1024*1024),2),10) ||' MB');
dbms_output.put_line('Java Pool Size      |  '||lpad(round(jpsize/(1024*1024),2),10) ||' MB');
dbms_output.put_line('Streams Pool Size   |  '||lpad(round(stsize/(1024*1024),2),10) ||' MB');
dbms_output.put_line('------------------------------------');
dbms_output.put_line('Fixed SGA           |  '||lpad(round(fsize/(1024*1024),2),10) ||' MB');
dbms_output.put_line('Redo Buffers        |  '||lpad(round(rbsize/(1024*1024),2),10) ||' MB');
dbms_output.put_line('Granule Size        |  '||lpad(granule_size,10)||' MB');
dbms_output.put_line('--12c-------------------------------');
dbms_output.put_line('In-Memory Area      :  '||lpad(round(imsize/(1024*1024),2),10) ||' MB');
dbms_output.put_line('------------------------------------');
end;
/

/*
 + --------------------------------------------
 | Note:105004.1
 | SCRIPT:ESTIMATE SHARED POOL UTILIZATION
 + -------------------------------------------- 


select round(to_number(value)/(1024*1024),3) shared_pool_size_mb, 
                         round(sum_obj_size/(1024*1024),3) sum_obj_size_mb,
                         round(sum_sql_size/(1024*1024),3) sum_sql_size_mb, 
                         round(sum_user_size/(1024*1024),3) sum_user_size_mb, 
                         round((sum_obj_size + sum_sql_size+sum_user_size)* 1.3/(1024*1024),3) min_shared_pool
  from (select sum(sharable_mem) sum_obj_size 
          from v$db_object_cache),
               (select sum(sharable_mem) sum_sql_size
          from v$sqlarea),
               (select sum(250 * users_opening) sum_user_size
          from v$sqlarea), v$parameter
 where name = 'shared_pool_size'
/

*/

/* 
********************************************************* 
* Note:1012046.6                                        * 
********************************************************* 
* TITLE        : Shared Pool Estimation                 * 
* CATEGORY     : Information, Utility                   * 
* SUBJECT AREA : Shared Pool                            * 
* DESCRIPTION  : Estimates shared pool utilization      * 
*  based on current database usage. This should be      * 
*  run during peak operation, after all stored          * 
*  objects i.e. packages, views have been loaded.       * 
* NOTE:  Modified to work with later versions 4/11/06   * 
*                                                       * 
******************************************************* 

declare 
        object_mem number; 
        shared_sql number; 
        cursor_mem number; 
        mts_mem number; 
        used_pool_size number; 
        free_mem number; 
        pool_size varchar2(512); -- same as V$PARAMETER.VALUE 
        dbname varchar2(15); -- Database Name
begin 
 
select name into dbname from sys.v$database;
 
-- Stored objects (packages, views) 
select sum(sharable_mem) into object_mem from v$db_object_cache; 
 
-- Shared SQL -- need to have additional memory if dynamic SQL used 
select sum(sharable_mem) into shared_sql from v$sqlarea; 
 
-- User Cursor Usage -- run this during peak usage. 
--  assumes 250 bytes per open cursor, for each concurrent user. 
select sum(250*users_opening) into cursor_mem from v$sqlarea; 
 
-- For a test system -- get usage for one user, multiply by # users 
-- select (250 * value) bytes_per_user 
-- from v$sesstat s, v$statname n 
-- where s.statistic# = n.statistic# 
-- and n.name = 'opened cursors current' 
-- and s.sid = 25;  -- where 25 is the sid of the process 
 
-- MTS memory needed to hold session information for shared server users 
-- This query computes a total for all currently logged on users (run 
--  during peak period). Alternatively calculate for a single user and 
--  multiply by # users. 
select sum(value) into mts_mem from v$sesstat s, v$statname n 
       where s.statistic#=n.statistic# 
       and n.name='session uga memory max'; 
 
-- Free (unused) memory in the SGA: gives an indication of how much memory 
-- is being wasted out of the total allocated. 
-- For pre-9i issue
-- select bytes into free_mem from v$sgastat 
--        where name = 'free memory';

-- with 9i and newer releases issue
select bytes into free_mem from v$sgastat 
        where name = 'free memory'
        and pool = 'shared pool';

 
-- For non-MTS add up object, shared sql, cursors and 20% overhead. 
used_pool_size := round(1.2*(object_mem+shared_sql+cursor_mem)); 
 
-- For MTS mts contribution needs to be included (comment out previous line) 
-- used_pool_size := round(1.2*(object_mem+shared_sql+cursor_mem+mts_mem)); 

-- Pre-9i or if using manual SGA management, issue 
-- select value into pool_size from v$parameter where name='shared_pool_size'; 

-- With 9i and 10g and and automatic SGA management, issue
begin
select  c.ksppstvl into pool_size from x$ksppi a, x$ksppcv b, x$ksppsv c
where a.indx = b.indx 
  and a.indx = c.indx
  and a.ksppinm = '__shared_pool_size';
exception  
   when others then 
    begin
     select  c.ksppstvl into pool_size from x$ksppi a, x$ksppcv b, x$ksppsv c
     where a.indx = b.indx 
       and a.indx = c.indx
       and a.ksppinm = 'shared_pool_size';
    end;
end;
 
-- Display results 
dbms_output.put_line(' ');
dbms_output.put_line('-----------------------------------------');
dbms_output.put_line('Shared pool configuration for '||dbname);
dbms_output.put_line('-----------------------------------------');
dbms_output.put_line ('Objects mem : '||to_char (round(object_mem/1024/1024,2)) || ' MB'); 
dbms_output.put_line ('Shared sql  : '||to_char (round(shared_sql/1024/1024,2)) || ' MB'); 
dbms_output.put_line ('Cursors     : '||to_char (round(cursor_mem/1024/1024,2)) || ' MB'); 
-- dbms_output.put_line ('MTS session: '||to_char (mts_mem) || ' bytes'); 
dbms_output.put_line ('Shared pool free memory         : '|| to_char (free_mem) || ' bytes ' || '('|| to_char(round(free_mem/1024/1024,2)) || ' MB)'); 
dbms_output.put_line ('Shared pool utilization (total) : '|| to_char(used_pool_size) || ' bytes ' || '(' || to_char(round(used_pool_size/1024/1024,2)) || ' MB)'); 
dbms_output.put_line ('Shared pool allocation (actual) : '|| pool_size ||' bytes ' || '(' || to_char(round(pool_size/1024/1024,2)) || ' MB)'); 
dbms_output.put_line ('Shared pool percentage utilized : '|| to_char (round(used_pool_size/pool_size*100)) || '%'); 
end; 
/ 


*/


col name format a30
select name, round(bytes/1024/1024,1) size_mb, RESIZEABLE from v$sgainfo where name like 'Maximum SGA%' or name like 'Free SGA%';

col component format a20
break on report
compute sum of current_size_mb on report
select component, round(current_size/1024/1024,1) as current_size_mb  from v$memory_dynamic_components where component like '%Target%';

col value format 9999999999999
col value_mb format 9999999999999
select name, value, unit, round(value/1024/1024, 1) value_mb from  V$PGASTAT where name in ('aggregate PGA target parameter','aggregate PGA auto target','total PGA allocated','total PGA inuse');

