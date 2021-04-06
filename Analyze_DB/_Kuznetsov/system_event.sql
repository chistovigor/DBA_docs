--
-- События ожидания экземпляра
--
select *
from (select event, 
             round(time_waited/100,4) time_waited_sec, 
             total_waits,
             time_waited
      from v$system_event
      where event not in ('client message', 'dispatcher timer', 'gcs for action', 
                 'gcs remote message', 'ges remote message', 'i/o slave wait',
                 'jobq slave wait', 'lock manager wait for remote message',
                 'null event', 'Null event', 'parallel query dequeue', 'pipe get',
                 'PL/SQL lock timer', 'pmon timer', 'PX Deq Credit: need buffer',
                 'PX Deq Credit: send blkd', 'PX Deq: Execute Reply',
                 'PX Deq: Execution Msg', 'PX Deq: Signal ACK', 
                 'PX Deq: Table Q Normal', 'PX Deque Wait', 'PX Idle Wait',
                 'queue messages', 'rdbms ipc message', 'slave wait', 
                 'smon timer', 'SQL*Net message to client',
                 'SQL*Net message from client', 'SQL*Net more data from client',
                 'virtual circuit status', 'wakeup time manager') 
           order by 4 desc)
where time_waited_sec>0
/

