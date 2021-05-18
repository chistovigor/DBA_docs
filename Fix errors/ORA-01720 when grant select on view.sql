1) Grant with grant option as a workaround for ORA-01720
 
User 1 needs select privileges on tables and views owned by schema owners. 
These are one of the daily re-occuring DBA tasks. Sometimes I get bored with it, I still like a challenge.

However while I tried to grant select privileges on some views I came accross a somewhat particular error


grant select on OWNER_VIEW.VIEW_1 to USER_1
                          *
ERROR at line 1:
ORA-01720: grant option does not exist for 'OWNER_TABLE.TABLE_1'

The reason for it is that the view VIEW_1 owned by OWNER_VIEW is built on top of the table TABLE_1 owned by someone else ie OWNER_TABLE.

OWNER_VIEW cannot give privileges on these kind of views to someone else ie USER_1 as long as OWNER_VIEW has not the privileges WITH GRANT OPTION for the underlying tables


The solution
 
DB_USER >Grant select on OWNER_TABLE.TABLE_1 to OWNER_VIEW with grant option;

Grant succeeded.

DB_USER >grant select on OWNER_VIEW.VIEW_1 to USER_1;

Grant succeeded.

2) Если не получается - выдаем privileges WITH GRANT OPTION от имени sys