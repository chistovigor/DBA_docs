col NAME format a30
select NAME, VALUE from v$dataguard_stats;


col ITEM format a65
col TYPE format a16
select START_TIME, TYPE, 
case 
 when ITEM='Active Apply Rate' then 'Active Apply Rate => '||SOFAR||' ('||UNITS||')'
 when ITEM='Last Applied Redo' then 'Last Applied Redo => '||TIMESTAMP||' ('||COMMENTS||')'
else NULL
end as ITEM
from v$recovery_progress 
where ITEM in ('Active Apply Rate','Last Applied Redo') 
  and START_TIME = (select max(START_TIME) from v$recovery_progress);


