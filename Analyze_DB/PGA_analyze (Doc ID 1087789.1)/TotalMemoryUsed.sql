
REM
REM  Investigate memory from the database side
REM

col TTL format 999,999,999,999 heading "Total Memory"

break on report
compute sum on report of TTL


select bytes TTL from v$sgainfo where name='Maximum SGA Size'
union
select value from v$pgastat where name='total PGA allocated'
/

