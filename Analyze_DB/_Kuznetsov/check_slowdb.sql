col username format a15
col module format a46
col spid format a12

-- sessions with highest DB Time usage
SELECT s.sid, s.serial#, p.spid , s.status, s.sql_id, s.username, st.value/100 as "DB Time (sec)", stcpu.value/100 as "CPU Time (sec)", round(stcpu.value / st.value * 100,2) as "% CPU"
FROM v$sesstat st, v$statname sn, v$session s, v$sesstat stcpu, v$statname sncpu, v$process p
WHERE sn.name = 'DB time' -- CPU
AND st.statistic# = sn.statistic#
AND st.sid = s.sid
AND sncpu.name = 'CPU used by this session' -- CPU
AND stcpu.statistic# = sncpu.statistic#
AND stcpu.sid = st.sid
AND s.paddr = p.addr
AND s.username not in ('SYS')
AND s.last_call_et < 1800 -- active within last 1/2 hour
AND s.logon_time > (SYSDATE - 240/1440) -- sessions logged on within 4 hours
AND st.value > 0
order by 7 desc;

/*
-- sessions with highest CPU consumption
SELECT s.sid, s.serial#, p.spid ,s.username, s.module, st.value/100 as "CPU sec"
FROM v$sesstat st, v$statname sn, v$session s, v$process p
WHERE sn.name = 'CPU used by this session' -- CPU
AND st.statistic# = sn.statistic#
AND st.sid = s.sid
AND s.paddr = p.addr
AND s.username not in ('SYS')
AND s.last_call_et < 1800 -- active within last 1/2 hour
AND s.logon_time > (SYSDATE - 240/1440) -- sessions logged on within 4 hours
ORDER BY st.value;

*/
