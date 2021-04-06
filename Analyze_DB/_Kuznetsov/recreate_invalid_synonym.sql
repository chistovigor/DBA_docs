set head off;
spool inv.sql;
SELECT 'Drop Synonym '||object_name||';' 
 FROM user_synonyms, user_objects
WHERE object_type = 'SYNONYM'
AND status = 'INVALID'
AND synonym_name = object_name
order by object_name
/

SELECT 'Create Synonym '||synonym_name||' for '||table_owner||'.'||table_name||';'
FROM user_synonyms, user_objects
WHERE object_type = 'SYNONYM'
AND status = 'INVALID'
AND synonym_name = object_name
/
spool off;
set head on;
@inv;
