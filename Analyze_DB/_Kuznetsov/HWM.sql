--
-- Определение HWM
-- 

select ue.segment_name, sum(ue.blocks) Total_Blocks
from user_extents ue
where segment_name = 'MON_OCURSORS'
group by segment_name
/

select ut.table_name, ut.empty_blocks
from user_tables ut
where table_name='MON_OCURSORS'
/


--
-- Определение HWM для таблиц
-- 

define seg_name='DBS'
select ut.table_name segmentname, ut.empty_blocks, ue.total_blocks, (ue.total_blocks - ut.empty_blocks) hwm_blocks
from user_tables ut,
     (select ue.segment_name, sum(ue.blocks) total_blocks 
      from user_extents ue 
      where ue.segment_name = upper('&&seg_name')
      group by segment_name
     ) ue
where ut.table_name=upper('&&seg_name')
/
