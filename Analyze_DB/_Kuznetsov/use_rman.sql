SELECT *
FROM (
SELECT sid, serial#, username, opname,
       round(sofar/decode(totalwork,0,-1,totalwork)*100,2) Complete
FROM v$session_longops
WHERE opname LIKE 'RMAN:%'
)
WHERE Complete>=0 and Complete<100
/
