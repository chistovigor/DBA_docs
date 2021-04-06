set doc on 
col block_size format a10

/*
 **********************************************************
  Determining Which Segments Have Many Buffers in the Pool
  Show only Top 10
 **********************************************************
*/

select owner, 
       object_name,
       number_of_blocks,
       (select value from v$parameter where name='db_block_size') block_size,
       (select to_char((value*number_of_blocks)/(1024*1024),'9999990D00')||' MB' from v$parameter where name='db_block_size') object_size
from (
       select o.owner, 
              o.object_name, 
              count(1) number_of_blocks, 
              row_number() over (order by count(1) desc ) row_n
         from dba_objects o, v$bh bh
        where o.data_object_id = bh.objd
          and o.owner != 'SYS'
     group by o.owner, o.object_name
     order by count(1) desc
)
where row_n<11
/

set doc off
