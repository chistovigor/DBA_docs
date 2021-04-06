--
-- События ожидания сеансов
--
column event format a35
select y.sid, y.osuser, y.username, x.event, x.time_waited_sec, x.total_waits
from (select sid,
             event, 
             round(time_waited/100,4) time_waited_sec, 
             total_waits 
      from v$session_event
      where event not in ('rdbms ipc message',
                          'pmon timer',
                          'wakeup time manager',
                          'smon timer',
                          'SQL*Net message from client',
                          'PX Idle Wait',
                          'SQL*Net message to client',
                          'SQL*Net more data from client',
                          'SQL*Net break/reset to client',
                          'SQL*Net more data to client',
                          'PX Deq: Join ACK',
                          'PX Deq: Signal ACK',
                          'PX Deq Credit: need buffer',
                          'PX Deq Credit: send blkd',
                          'PX Deq: Execution Msg',
                          'PX Deq: Execute Reply',
                          'PX qref latch')
           ) x,
           v$session y
where y.sid = x.sid and 
      x.time_waited_sec>0
order by 1 asc
/

