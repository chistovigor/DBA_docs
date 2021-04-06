set doc on
column pga_size format 999,999,999


/*
 *************************************************
  Размер памяти занимаемый одним серв процессом
 *************************************************
*/

select 2048576+a.value+b.value pga_size
from v$parameter a,
     v$parameter b
where a.name='sort_area_size' and
      b.name='hash_area_size'
/

/*
 ******************************************************
  Размер памяти занимаемый всеми серверными процессами
 ******************************************************
*/

select name, round(sum(value)/(1024*1024),3) value_mb
from (select a.name, b.value 
      from v$statname a, v$sesstat b
      where a.statistic#=b.statistic# and a.name like 'session %memory%') 
group by name
/

set doc off
