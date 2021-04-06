rem =========================================================================
rem 
rem                     current_tx.sql
rem 
rem     Copyright (C) Oriole Software, 1999
rem 
rem     Downloaded from http//:www.oriolecorp.com
rem 
rem     This script for Oracle database administration is free software; you
rem     can redistribute it and/or modify it under the terms of the GNU General
rem     Public License as published by the Free Software Foundation; either
rem     version 2 of the License, or any later version.
rem 
rem     This script is distributed in the hope that it will be useful,
rem     but WITHOUT ANY WARRANTY; without even the implied warranty of
rem     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem     GNU General Public License for more details.
rem 
rem     You should have received a copy of the GNU General Public License
rem     along with this program; if not, write to the Free Software
rem     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
rem 
rem =========================================================================
--
--    The following query (to be run by a DBA) lists for currently
--    active transactions who is running them (username + program
--    info when available, complete with session id ready to be used
--    in some 'ALTER SYSTEM KILL SESSION' command), the text of the 
--    associated SQL query, how many rollback segment blocks we have
--    used so far and for how long the transaction has been running,
--    and the name of the table(s) on which the running transaction
--    has put row-locks. Note that some innocent-looking UPDATE can
--    indeed put row-locks on many tables if there are triggers updating,
--    inserting or deleting other tables.
--    Transactions are ordered by duration (transactions which have
--    been running the longer first).
--
--    This is quite useful for monitoring long-running updates and
--    locking problems. Works on Oracle7 and Oracle8.
--
set recsep off
column "WHO" format A35
column "TEXT" format A40 word_wrapped
column "RB BLKS/S RUNNING" format A17
clear breaks
break on "WHO" on "ROLLBACK BLOCKS" on "RB BLKS/S RUNNING" on "TEXT" skip 1
select to_char(se.sid ) || ',' || to_char(se.serial#) || ' ' || se.username
        || '/' ||            
       decode(ltrim(se.module || ' ' || se.action || ' ' || se.client_info),
                '', se.program,
                ltrim(se.module || ' ' || se.action || ' ' || se.client_info))
                   "WHO",
       s.sql_text "TEXT",
       to_char(x.used_ublk )||'/'||
       to_char((sysdate-to_date(x.start_time,'MM/DD/RR HH24:MI:SS'))*86400)
              "RB BLKS/S RUNNING",
       o.name "TABLE"
from v$sqlarea s,
     v$session se,
     sys.obj$ o,
     v$locked_object l,
     v$transaction x,
     v$lock l2
where se.sql_address = s.address
  and x.ses_addr = se.saddr
  and o.obj# = l.object_id
  and l.xidusn = x.xidusn
  and l.xidslot = x.xidslot
  and l.xidsqn = x.xidsqn
  and l2.id2 = x.xidsqn
  and l2.id1 = 65536 * x.xidusn + x.xidslot
  and l2.type = 'TX'
order by (sysdate-to_date(x.start_time,'MM/DD/RR HH24:MI:SS'))*86400 desc,
         1, 4
/

