--
-- PGA Advice
--
-- http://asktom.oracle.com/pls/ask/f?p=4950:8:10900930648024685944::NO::F4950_P8_DISPLAYID,F4950_P8_CRITERIA:8759826405304
--

cl scr

set doc on

/*
  ----------------------------------------------------------------
  Выбрать тот размер у которого OPTIMAL_EXECUTIONS<=1
  ----------------------------------------------------------------
*/

column pga_size format a30

SELECT
   case when low_optimal_size < 1024*1024
        then to_char(low_optimal_size/1024,'999999') ||
             'kb <= PGA < ' ||
             (HIGH_OPTIMAL_SIZE+1)/1024|| 'kb'
        else to_char(low_optimal_size/1024/1024,'999999') ||
             'mb <= PGA < ' ||
             (high_optimal_size+1)/1024/1024|| 'mb'
        end pga_size,
       optimal_executions,
       onepass_executions,
       multipasses_executions
  from v$sql_workarea_histogram
 where total_executions <> 0
 order by low_optimal_size
/


/*
  ----------------------------------------------------------------
  Выбрать тот размер у которого ESTD_PGA_CACHE_HIT_PERCENTAGE=100%
  ----------------------------------------------------------------
*/

column estd_pga_cache_hit_percentage format a29
column pga_target_factor format a17

select  trunc(pga_target_for_estimate/1024/1024) pga_target_for_estimate,
        to_char(pga_target_factor * 100,'999.9') ||'%' pga_target_factor,
        trunc(bytes_processed/1024/1024) bytes_processed,
        trunc(estd_extra_bytes_rw/1024/1024) estd_extra_bytes_rw,
        to_char(estd_pga_cache_hit_percentage,'999') || '%' estd_pga_cache_hit_percentage,
        estd_overalloc_count
from v$pga_target_advice
/

set doc off
