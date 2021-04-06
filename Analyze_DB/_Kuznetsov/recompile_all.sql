--
-- Перекомпиляция всех плохих объектов
-- в базе
--

set head off
spool recompile_all.log

select   distinct 'execute sys.utl_recomp.recomp_serial(''' || owner || ''');' Recompile
from     dba_objects
where    status = 'INVALID'
/

set head on
spool off

@recompile_all.log
host erase recompile_all.log

