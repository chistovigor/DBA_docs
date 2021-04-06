select nvl(object_type,'_TOTAL_NUMBER_') object_type, 
       status, 
       count(1) number_obj 
from user_objects 
where status='INVALID' 
group by cube(object_type) , status 
order by 1
/
