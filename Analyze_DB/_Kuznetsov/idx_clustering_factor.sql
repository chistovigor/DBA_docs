--
-- ≈сли a.clustering_factor = b.blocks 
-- то строки в таблице упор€дочены по значению ключа индекса
--
-- ≈сли a.clustering_factor = b.num_rows
-- то строки в таблице не упор€дочены по значению ключа индекса
-- это ведет к большиб задерждам при сканировании данных по индексу
--
select a.index_name, 
       b.num_rows, 
       b.blocks,
       a.clustering_factor 
from user_indexes a, user_tables b
where  a.table_name = b.table_name
/
