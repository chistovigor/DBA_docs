col username for a8
col object for a30

select	 s.sid, s.username, s.status
	,decode(p.kglpnreq,0,o.kglnaobj,' '||o.kglnaobj) OBJECT
	,p.kglpnhdl, p.kglpnreq
from v$session s,
    (select * from x$kglpn where kglpnhdl in (select kglpnhdl from x$kglpn where kglpnreq != 0) ) p ,
     x$kglob o
where p.kglpnuse=s.saddr
  and o.kglhdadr=p.kglpnhdl
order by kglpnhdl,KGLPNREQ
;
