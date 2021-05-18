expdp infoware/infoware DUMPFILE=exp_par4%U.dmp filesize=1G DIRECTORY=DATA_PUMP_DIR NOLOGFILE=Y SCHEMAS=infoware COMPRESSION=ALL REUSE_DUMPFILES=Y PARALLEL=4 METRICS=YES

Самый быстрый способ: PARALLEL=номер процессоров (nproc) разделить на 2

expdp infoware/infoware DUMPFILE=exp_par4%U.dmp filesize=1G DIRECTORY=DATA_PUMP_DIR NOLOGFILE=Y SCHEMAS=infoware COMPRESSION=ALL REUSE_DUMPFILES=Y PARALLEL=2 METRICS=YES

Без параллелизма с компрессией (занимает почти столько же времени)

expdp infoware_enc/infoware DIRECTORY=DATA_PUMP_DIR NOLOGFILE=Y SCHEMAS=infoware_enc COMPRESSION=ALL REUSE_DUMPFILES=Y METRICS=YES

Оценка размера схем БД (никаких файлов не создается, только оценка)

expdp infoware/infoware NOLOGFILE=y ESTIMATE_ONLY=y

В UNIX shell:

expdp router/loopexamspit NOLOGFILE=Y ESTIMATE_ONLY=y INCLUDE=TABLE:\"LIKE \'\%`date '+%Y%m'`\'\" 2>&1 | grep Total | grep GB | cut -f6 -d' '

если статистика собрана недавно, то следующий результат будет точнее:

expdp infoware/infoware NOLOGFILE=y ESTIMATE_ONLY=y ESTIMATE=STATISTICS

Экспорт, исключая таблицы по имени:

expdp infoware/infoware DUMPFILE=exp_par4_EXCL_%U.dmp filesize=1500K DIRECTORY=DATA_PUMP_DIR NOLOGFILE=Y SCHEMAS=infoware EXCLUDE=TABLE:\"LIKE \'\%201403\'\" COMPRESSION=ALL REUSE_DUMPFILES=Y PARALLEL=2 METRICS=YES

Экспорт, включая таблицы по имени (месячные таблицы):

expdp infoware/infoware DUMPFILE=exp_par4_INCL_%U.dmp filesize=1500K DIRECTORY=DATA_PUMP_DIR NOLOGFILE=Y SCHEMAS=infoware INCLUDE=TABLE:\"LIKE \'\%`date '+%Y%m'`\'\" COMPRESSION=ALL REUSE_DUMPFILES=Y PARALLEL=2 METRICS=YES

Для контроллера:

1) Немесячные данные (мегабайты)

expdp router/loopexamspit NOLOGFILE=Y ESTIMATE_ONLY=y EXCLUDE=TABLE:\"LIKE \'\%`date '+%Y'`%\'\" 2>&1 | grep Total | grep  '[MB|GB]' | cut -f6 -d' '

2) Данные за предыдущие месяцы (гигабайты)

expdp router/loopexamspit NOLOGFILE=Y ESTIMATE_ONLY=y EXCLUDE=TABLE:\"LIKE \'\%`date '+%Y%m'`\'\" 2>&1 | grep Total | grep  '[MB|GB]' | cut -f6 -d' '

3) Данные за текущий месяц (гигабайт)

expdp router/loopexamspit NOLOGFILE=Y ESTIMATE_ONLY=y INCLUDE=TABLE:\"LIKE \'\%`date '+%Y%m'`\'\" 2>&1 | grep Total | grep  '[GB]' | cut -f6 -d' '

