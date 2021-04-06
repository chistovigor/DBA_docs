--
-- Фактор кластеризации и селективность индексов
--
-- selectivity_ratio должно быть равно 1
-- clustering_factor должен быть равен количеству блоков таблицы
--
select b.table_name, 
       a.index_name, 
	   a.index_type, 
	   a.distinct_keys, 
	   b.num_rows,
	   b.blocks, 
	   round(a.distinct_keys/(case b.num_rows 
                                 when 0 then -1 
                                 else b.num_rows 
                              end),3) selectivity_ratio, 
	   a.clustering_factor
from user_indexes a,
     user_tables b
where a.table_name=b.table_name
order by 1,2,3,7,8
