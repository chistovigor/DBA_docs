-- SQL Patch hints list
-- Usage: SQL> @SQL_PATCH_HINTS "Patch Name"
-- http://iusoltsev.wordpress.com/profile/oracle_tools/scripts/

 
select substr(extractvalue(value(d), '/hint'), 1, 512) as sql_patch_hints
  from xmltable('/outline_data/hint' passing
                (select xmltype(comp_data) as xmlval
                   from sys.sqlobj$data od, sys.sqlobj$ o
                  where od.obj_type = 3
                    and (o.name = '&&1' and o.obj_type = 3)
                    and o.signature = od.signature
                    and comp_data is not null)) d
/