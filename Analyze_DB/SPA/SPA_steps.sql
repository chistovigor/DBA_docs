export file from source db

sqlplus / as sysdba

@?/rdbms/admin/awrextr

-- export will be in choosen data pump directory

import file in destination db

create STS (using script get_sql_from_awr_dbid.sql) - передаем созданную функцию в качестве параметра процедуре создания STS

RUN SPA


