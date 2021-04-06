COL OWNER FORMAT A12
COL DB_LINK_NAME FORMAT A30
COL DB_LINK_USER FORMAT A30
COL DB_LINK_PASSWORD FORMAT A30
COL HOST FORMAT A40

select nvl(u.username,'PUBLIC') as owner,
       l.name as db_link_name,
       l.userid as db_link_user,
       l.password as db_link_password,
       l.host
from link$ l,
    dba_users u
where u.user_id(+)=l.owner#
order by 1,2
/

