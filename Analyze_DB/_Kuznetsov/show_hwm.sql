set doc on
/*
-----------------------------------------------------------
--
--  How to View High Water Mark - Step-by-Step Instructions
--
--  Note:262353.1
--  
--  Content Type:       TEXT/X-HTML 
--  Creation Date:      30-JAN-2004 
--  Last Revision Date: 01-JUL-2005
--
-----------------------------------------------------------
*/
set doc off

ACCEPT tName CHAR DEFAULT "T1" PROMPT "Enter table name in UPPER case: "

set verify off

begin
 dbms_stats.gather_table_stats(ownname=> USER, tabname=> '&tName', estimate_percent=>30, granularity=>'ALL', cascade=>FALSE);
end;
/

select u.blocks,
       x.used_blocks,
       u.empty_blocks,
       u.num_rows 
from user_tables u,
     (select count (distinct dbms_rowid.rowid_block_number(rowid)) used_blocks from "&tName") x
where u.table_name='&tName'
/

set verify on
