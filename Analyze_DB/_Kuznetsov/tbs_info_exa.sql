column tablespace_name   format a23
column mbytes_size       format 99,999,999
column mbytes_used       format 99,999,999
column mbytes_free       format 99,999,999
column mbytes_max        format 99,999,999
column extent_type       format a12
column extent_alloc      format a15
column space_manag       format a12
column block_size        format a10

break on report

compute sum of mbytes_size on report
compute sum of mbytes_used on report
compute sum of mbytes_free on report
compute sum of count_files on report


select /*+ ALL_ROWS opt_param('OPTIMIZER_INDEX_COST_ADJ',100)  */ 
       t.tablespace_name,
       round(t.bytes / (1024 * 1024),2) mbytes_size,
       round((t.bytes - nvl(f.bytes, 0)) / 1024 / 1024, 2) mbytes_used,
       round(f.bytes / (1024 * 1024),2) mbytes_free,
       round(t.max_bytes / (1024*1024),2) mbytes_max,
       t.cnt count_files,
       ts.extent_management extent_type,
       decode(ts.allocation_type
             , 'USER', null
             , 'UNIFORM', 'UNIFORM (' || case
                                          when ts.initial_extent < (1024*1024)
                                               then to_char(ts.initial_extent/1024) || 'K'
                                          else to_char(ts.initial_extent/(1024*1024)) || 'M'
                                         end || ')'
             , ts.allocation_type) extent_alloc,
       decode( ts.segment_space_management
             , 'MANUAL',  null
             , ts.segment_space_management
             )  space_manag,
       to_char(ts.block_size / 1024) || 'K' Block_size,
       ts.compress_for
from   dba_tablespaces ts,
      ( select
                tablespace_name
         ,      sum(bytes) bytes
         ,      sum(decode(autoextensible, 'YES',maxbytes,'NO',bytes)) max_bytes
         ,      count(*) cnt
         from   dba_data_files
         group by tablespace_name
       ) t,
      ( select tablespace_name
         ,      sum(bytes) bytes
         ,      max(bytes) max_bytes
         ,      count(*)   cnt
         from   dba_free_space
         group by tablespace_name
       ) f
where  t.tablespace_name  = f.tablespace_name (+)
and    ts.tablespace_name = t.tablespace_name
UNION ALL
select t.tablespace_name,
       t.bytes / (1024 * 1024),
       (select round(sum(bytes_used) / (1024 * 1024),3) 
        from v$temp_space_header 
        where tablespace_name=t.tablespace_name
        group by tablespace_name),
       (select round(sum(bytes_free) / (1024 * 1024),3) 
        from v$temp_space_header 
        where tablespace_name=t.tablespace_name
        group by tablespace_name),
        round(t.max_bytes / (1024*1024),2) mbytes_max,
        t.cnt count_files,
        ts.extent_management,
        decode(ts.allocation_type
             , 'USER', null
             , 'UNIFORM', 'UNIFORM (' || case
                                          when ts.initial_extent < (1024*1024)
                                               then to_char(ts.initial_extent/1024) || 'K'
                                          else to_char(ts.initial_extent/(1024*1024)) || 'M'
                                         end || ')'
             , ts.allocation_type) alloc
,      decode(ts.segment_space_management, 'MANUAL', null, ts.segment_space_management)  space
,      to_char(ts.block_size / 1024) || 'K'               Blocksize
,      ts.compress_for
from   ( select tablespace_name
         ,      sum(bytes) bytes
         ,      sum(decode(autoextensible, 'YES',maxbytes,'NO',bytes)) max_bytes
         ,      count(*) cnt
         from   dba_temp_files
         group by tablespace_name
       ) t
,      v$sort_segment f
,      dba_tablespaces ts
where  f.tablespace_name (+) = t.tablespace_name
and    ts.tablespace_name    = t.tablespace_name
order by 1
/
