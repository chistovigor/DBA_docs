--
-- Размер сегментов в буферном кэше
-- Григорий Кузнецов 
-- 23.09.2004 11:41
--

column owner heading 'Owner|Objects' justify left
column object_name heading 'Segment|Name' justify left
column segment_type heading 'Segment|Type' justify left
column number_of_blocks heading 'Number of|blocks' justify right
column pool heading 'Pool|name' justify left
column pool_block_size heading 'Block Size|KBytes'  format a10 justify right
column segment_size_kbytes heading 'Segment Size|KBytes'  justify right
column segment_size_bytes heading 'Segment Size|Bytes'  justify right


compute sum of segment_size_bytes on owner
compute sum of number_of_blocks on owner
break on owner skip 1

select distinct
       x.owner, 
       x.object_name, 
       s.segment_type,
       x.number_of_blocks, 
       s.buffer_pool pool,
       trim(to_char(y.pool_block_size/(1024),'99'))||'k' pool_block_size,
       trim(to_char((x.number_of_blocks * y.pool_block_size)/(1024),'999,999,999'))||'k' segment_size_kbytes,
       x.number_of_blocks * y.pool_block_size segment_size_bytes
from dba_segments s,
     ( select o.owner, o.object_name, count(1) number_of_blocks
       from dba_objects o, 
            v$bh bh
       where o.object_id  = bh.objd and 
             o.owner != 'SYS'
       group by o.owner, o.object_name
      ) x,
      (select name, block_size pool_block_size 
       from v$buffer_pool_statistics) y
where s.segment_name = x.object_name and 
      s.buffer_pool = y.name
order by 4 desc
/
