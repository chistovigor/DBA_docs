Для решения проблемы дисковые ASM группа DATAC1 основной базы SPUR были подключены к ASM на сервере mr01vm03 
(без остановки сервисов на mr01vm03):
---
  ALTER SYSTEM SET asm_diskstring='o/*/DATAC3_*','o/*/RECOC3_*','o/*/DATAC1_*','o/*/RECOC1_*' SCOPE=MEMORY;
  alter diskgroup DATAC1 mount;
  alter diskgroup RECOC1 mount;

С подключенной ASM группы скопировали  redo логи.
После этого дисковые группы была отключены от ASM на mr01vm03 
---
alter diskgroup DATAC1 dismount;
alter diskgroup RECOC1 dismount;
ALTER SYSTEM SET asm_diskstring='o/*/DATAC3_*','o/*/RECOC3_*' SCOPE=BOTH;
