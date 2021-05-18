DROP TRIGGER EQ.TRG_LOGON_RUSAKOV;

CREATE OR REPLACE TRIGGER EQ.trg_logon_rusakov
after logon on SCHEMA
begin
-- ужасно расстраивает необходимость каждый раз вручную вызывать ALTER SESSION SET nls_date_format...
    if (  lower(SYS_CONTEXT ('USERENV', 'OS_USER')) = 'rusakov' 
      and lower(SYS_CONTEXT ('USERENV', 'MODULE')) = 'sql developer') then
          execute immediate 'ALTER SESSION SET nls_date_format = ''DD.MM.YYYY hh24:mi:ss''';
    end if;
end;
/