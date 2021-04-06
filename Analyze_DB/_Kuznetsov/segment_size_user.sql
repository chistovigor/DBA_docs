--
-- Size of Table segments
--
select  nvl(segment_name,'TOTAL SIZE') table_name, round(sum(bytes)/(1024*1024),3) SIZE_MB
from user_segments
where segment_type='TABLE'
group by cube(segment_name)
order by 2
/
--
-- Size of Index segments
--
select  nvl(segment_name,'TOTAL SIZE') index_name, round(sum(bytes)/(1024*1024),3) SIZE_MB
from user_segments
where segment_type='INDEX'
group by cube(segment_name)
order by 2
/

