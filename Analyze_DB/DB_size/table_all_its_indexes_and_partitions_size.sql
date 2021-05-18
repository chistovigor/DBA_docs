/* Formatted on 21/10/2015 19:04:37 (QP5 v5.277) */
  SELECT owner,
         table_name,
         SEGMENT_TYPE,
         TRUNC (SUM (bytes) / 1024 / 1024 / 1024) GB
    FROM (SELECT segment_name table_name,
                 owner,
                 SEGMENT_TYPE,
                 bytes
            FROM dba_segments@ARBDLINK_NCC
           WHERE segment_type IN ('TABLE', 'TABLE PARTITION')
          UNION ALL
          SELECT i.table_name,
                 i.owner,
                 SEGMENT_TYPE,
                 s.bytes
            FROM dba_indexes@ARBDLINK_NCC i, dba_segments@ARBDLINK_NCC s
           WHERE     s.segment_name = i.index_name
                 AND s.owner = i.owner
                 AND s.segment_type IN ('INDEX', 'INDEX PARTITION')
          UNION ALL
          SELECT l.table_name,
                 l.owner,
                 SEGMENT_TYPE,
                 s.bytes
            FROM dba_lobs@ARBDLINK_NCC l, dba_segments@ARBDLINK_NCC s
           WHERE     s.segment_name = l.segment_name
                 AND s.owner = l.owner
                 AND s.segment_type IN ('LOBSEGMENT', 'LOB PARTITION')
          UNION ALL
          SELECT l.table_name,
                 l.owner,
                 SEGMENT_TYPE,
                 s.bytes
            FROM dba_lobs@ARBDLINK_NCC l, dba_segments@ARBDLINK_NCC s
           WHERE     s.segment_name = l.index_name
                 AND s.owner = l.owner
                 AND s.segment_type = 'LOBINDEX')
   WHERE table_name = '&table_name'
GROUP BY owner, table_name, SEGMENT_TYPE
ORDER BY SUM (bytes) DESC