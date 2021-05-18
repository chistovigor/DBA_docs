CREATE OR REPLACE package util_dba_info

-- select objects size in a schema using this package example
-- SELECT * FROM TABLE(UTIL_DBA_INFO.GET_TABLES_SIZE('LDWH',UTIL_DBA_INFO.C_GB_SIZE));

is

  type type_tab_size_info is record(
    table_name varchar2(64),
    total_size number,
    tab_size number,
    ind_size number,
    lob_size number,
    lobind_size number,
    nested_table number,
    rows_count number
  );

  type type_tab_size_infos is table of type_tab_size_info;

  function C_KB_SIZE return number deterministic;
  function C_MB_SIZE return number deterministic;
  function C_GB_SIZE return number deterministic;


  function get_tables_size(
    p_owner varchar2,
    p_measure number default C_MB_SIZE,
    p_extra_fields varchar2 default null --ACTUAL_ROWS_COUNT STAT_ROWS_COUNT
  ) return type_tab_size_infos pipelined;

end util_dba_info;
/



CREATE OR REPLACE package body util_dba_info is

  function C_KB_SIZE return number deterministic is begin return 1024; end;
  function C_MB_SIZE return number deterministic is begin return 1024*1024; end;
  function C_GB_SIZE return number deterministic is begin return 1024*1024*1024; end;

  function get_tables_size(
    p_owner varchar2,
    p_measure number default C_MB_SIZE,
    p_extra_fields varchar2 default null --ACTUAL_ROWS_COUNT STAT_ROWS_COUNT
  ) return type_tab_size_infos pipelined is
    v_owner varchar2(64) := upper(p_owner);
    v_result_row util_dba_info.type_tab_size_info;
    v_extra_fields varchar2(32000) := ' ' || p_extra_fields || ' ';
  begin
    for rec in (
      with segs as (
        select /*+ materialize */ s.owner, s.segment_name, s.segment_type, s.bytes
             , case
                 when s.segment_type in ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'CLUSTER') then 'TAB'
                 when s.segment_type in ('INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION') then 'IND'
                 when s.segment_type in ('LOBSEGMENT', 'LOB PARTITION') then 'LOB'
                 when s.segment_type in ('LOBINDEX') then 'LOBIND'
                 when s.segment_type in ('NESTED TABLE') then 'NESTED_TABLE'
               end seg_class
          from dba_segments s
         where s.segment_type in ('TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'INDEX', 'INDEX PARTITION', 'INDEX SUBPARTITION', 'LOBSEGMENT', 'LOB PARTITION', 'LOBINDEX', 'CLUSTER', 'NESTED TABLE')
           and s.owner = v_owner
      ), indx as (
        select /*+ materialize */ i.table_name, i.index_name
          from dba_indexes i
         where i.table_owner = v_owner
      ), lobs as (
        select /*+ materialize */ l.table_name, l.segment_name, l.index_name
          from dba_lobs l
         where l.owner = v_owner
      ), nt as (
        select /*+ materialize */ nt.parent_table_name table_name, nt.table_name nested_table_name
          from dba_nested_tables nt
         where nt.owner = v_owner
      )
      select table_name
           , round((tab + nvl(ind, 0) + nvl(lob, 0) + nvl(lobind, 0) + nvl(nested_table, 0)) / p_measure, 2) total_size
           , round(tab / p_measure, 2) tab
           , round(nvl(ind, 0) / p_measure, 2) ind
           , round(nvl(lob, 0) / p_measure, 2) lob
           , round(nvl(lobind, 0) / p_measure, 2) lobind
           , round(nvl(nested_table, 0) / p_measure, 2) nested_table

      from
      (
      select s.segment_name table_name, s.bytes, s.seg_class
        from segs s
       where s.seg_class = 'TAB'
      union all
      select i.table_name, s.bytes, s.seg_class
        from indx i, segs s
       where s.segment_name = i.index_name
         and   s.seg_class = 'IND'
      union all
      select l.table_name, s.bytes, s.seg_class
        from lobs l, segs s
       where s.segment_name = l.segment_name
         and s.seg_class = 'LOB'
      union all
      select l.table_name, s.bytes, s.seg_class
        from lobs l, segs s
       where s.segment_name = l.index_name
         and   s.seg_class = 'LOBIND'
      union all
      select nt.table_name, s.bytes, s.seg_class
        from nt, segs s
       where s.segment_name = nt.nested_table_name
         and s.seg_class = 'NESTED_TABLE'

      ) pivot (
        sum(bytes) for seg_class in ('TAB' as tab, 'IND' as ind, 'LOB' as lob, 'LOBINDEX' as lobind, 'NESTED_TABLE' as nested_table)
      )
      order by tab + nvl(ind, 0) + nvl(lob, 0) + nvl(lobind, 0) + nvl(nested_table, 0) desc
    ) loop
      v_result_row.table_name := rec.table_name;
      v_result_row.total_size := rec.total_size;
      v_result_row.tab_size := rec.tab;
      v_result_row.ind_size := rec.ind;
      v_result_row.lob_size := rec.lob;
      v_result_row.lobind_size := rec.lobind;
      v_result_row.nested_table := rec.nested_table;
      
      if (v_extra_fields like '%ACTUAL_ROWS_COUNT%') then
        begin
          execute immediate '
          select count(1)
            from ' || v_owner || '."' || rec.table_name || '"
          ' into v_result_row.rows_count;
        exception
          when others then
            v_result_row.rows_count := -1;
        end;
      end if;
      
      pipe row(v_result_row);
    end loop;

  end;

end util_dba_info;
/
