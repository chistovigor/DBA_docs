select nvl(object_type,'хрнцн') obj_type, count(1) from user_objects group by cube(object_type) order by 1
/
