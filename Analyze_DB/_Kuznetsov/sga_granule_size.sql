select component, 
       round(current_size/1048576,3) current_size_mb, 
       round(granule_size/1048576,3) granule_size_mb
from v$sga_dynamic_components
/
