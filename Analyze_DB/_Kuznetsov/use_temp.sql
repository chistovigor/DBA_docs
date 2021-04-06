--alter session set optimizer_mode=RULE; 


column tablespace format a15 heading 'Tablespace Name'
column segfile# format 9999999999 heading 'File|ID'
column spid format a15 heading 'Unix|ID'
column segblk# format 9999999999 heading 'Block|ID'
column size_mb format 9999999999 heading "Mbytes|Used"
column username format a15
column program format a15

select /*+ RULE */ b.tablespace,
       b.segfile#,
       b.segblk#,
       b.segtype,
       round(((b.blocks*p.value)/1024/1024),2) size_mb,
       c.spid,
       a.sid,
       a.serial#,
       a.username,
       a.osuser,
       a.program,
       a.status
from v$session a,
     v$sort_usage b,
     v$process c,
     v$parameter p
where p.name='db_block_size' and 
      a.saddr = b.session_addr and
      a.paddr=c.addr
order by b.tablespace,b.segfile#,b.segblk#,b.blocks
/

/*

select s.sid "sid",
       s.username "user",
       s.program "program", 
       u.tablespace "tablespace",
       u.contents "contents", 
       u.extents "extents", 
       u.blocks*8/1024 "used space in mb", 
       q.sql_text "sql text",
       a.object "object", 
       k.bytes/1024/1024 "temp file size"
from v$session s, 
     v$sort_usage u, 
     v$access a, 
     dba_temp_files k, 
     v$sql q
where s.saddr=u.session_addr and 
      s.sql_address=q.address and 
      s.sid=a.sid and 
      u.tablespace=k.tablespace_name
/

-- For dictionary managed temporary tablespace :

select (s.tot_used_blocks/f.total_blocks)*100 as "percent_used" 
from (select sum(used_blocks) tot_used_blocks from v$sort_segment where tablespace_name='TEMP') s, 
     (select sum(blocks) total_blocks from dba_data_files where tablespace_name='TEMP') f
/

*/

-- For locally managed temporary tablespace

select /*+ RULE */ (s.tot_used_blocks/f.total_blocks)*100 as "percent_used_TEMP"
from (select sum(used_blocks) tot_used_blocks from v$sort_segment where tablespace_name='TEMP') s, 
     (select sum(blocks) total_blocks from dba_temp_files where tablespace_name='TEMP') f
/

