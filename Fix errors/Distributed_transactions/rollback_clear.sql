select * from dba_2pc_pending;

select * from dba_2pc_neighbors;

select * from pending_sessions$;
select * from pending_trans$;

alter system set "_smu_debug_mode" = 4;

SELECT a.ksppinm "Parameter",
       b.ksppstvl "Session Value",
       c.ksppstvl "Instance Value"
  FROM x$ksppi a, x$ksppcv b, x$ksppsv c
 WHERE     a.indx = b.indx
       AND a.indx = c.indx
       AND a.ksppinm LIKE '/_%' ESCAPE '/'
       AND a.ksppinm LIKE '%smu_debug_mode%' ;

alter system reset "_smu_debug_mode" sid='*';

ALTER SYSTEM DISABLE DISTRIBUTED RECOVERY

exec DBMS_TRANSACTION.rollback_force('20.40.5358640');

--exec DBMS_TRANSACTION.PURGE_MIXED('18.41.5280997');

ROLLBACK FORCE '30.26.139273';
COMMIT FORCE '30.26.139273';

COMMIT FORCE '29.33.234385';
ROLLBACK FORCE '25.15.3972821'
ROLLBACK FORCE '22.44.1571045'
ROLLBACK FORCE '20.40.5358640'

exec dbms_transaction.purge_lost_db_entry('30.26.139273')
exec dbms_transaction.purge_lost_db_entry('18.41.5280997')
exec dbms_transaction.purge_lost_db_entry('25.15.3972821')
exec dbms_transaction.purge_lost_db_entry('22.44.1571045')
exec dbms_transaction.purge_lost_db_entry('20.40.5358640')

/* Formatted on 12.02.2014 13:53:24 (QP5 v5.163.1008.3004) */
BEGIN
   FOR aaa IN (SELECT local_tran_id FROM dba_2pc_pending)
   LOOP
      BEGIN
         DBMS_OUTPUT.PUT_LINE('COMMIT FORCE '''  || aaa.local_tran_id || ''';');
         DBMS_OUTPUT.PUT_LINE('exec DBMS_TRANSACTION.purge_lost_db_entry (''' || aaa.local_tran_id || ''');');
      END;
   END LOOP;
END;
/

ALTER SYSTEM ENABLE DISTRIBUTED RECOVERY;

