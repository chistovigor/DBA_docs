select distinct to_char(last_analyzed,'YYYY-MON-DD') as last_analyze,
       count(1) as cnt
from user_tab_statistics 
group by to_char(last_analyzed,'YYYY-MON-DD')
/
