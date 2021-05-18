create or replace function to_dec
( p_str in varchar2, 
  p_from_base in number default 16 ) return number
is
	l_num   number default 0;
	l_hex   varchar2(16) default '0123456789ABCDEF';
begin
	if ( p_str is null or p_from_base is null )
	then
		return null;
	end if;
	for i in 1 .. length(p_str) loop
		l_num := l_num * p_from_base + instr(l_hex,upper(substr(p_str,i,1)))-1;
	end loop;
	return l_num;
end to_dec;
/
Code:
create or replace function hex2Char
( p_str in varchar2 ) return VARCHAR2
is
	v_ret	varchar2(15000) default '';
	st      number default 1;
begin
	WHILE st < length(p_str) LOOP
		v_ret 	:= v_ret || chr(to_dec(substr(p_str, st, 2)));
		st 		:= st + 2;
	END LOOP;
	return v_ret;
end hex2Char;
/