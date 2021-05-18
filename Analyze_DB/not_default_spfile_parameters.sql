select     name || '=' || decode(type, 2, '''') || value 
    || decode(type, 2, '''') parameter
from    v$parameter
where    isdefault = 'FALSE'
and    value is not null
order    by name
/