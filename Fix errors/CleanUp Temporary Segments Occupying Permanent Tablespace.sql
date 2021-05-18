--CleanUp Temporary Segments Occupying Permanent Tablespace

--http://askdba.org/weblog/2009/07/cleanup-temporary-segments-in-permanent-tablespace/

-- when ORA-14405 signalled during: DROP tablespace ORDLOG_032015 including contents and datafiles

There are two ways to force the drop of temporary segments:

1. Using event DROP_SEGMENTS
2. Corrupting the segments and dropping these corrupted segments.
1. Using DROP_segments:

Find out the tablespace number (ts#) which contains temporary segments:
SQL> select ts# from sys.ts$ where name = 'tablespace name';

Suppose it comes out to be 10, use the following command to cleanup temporary segments:

SQL> alter session set events 'immediate trace name DROP_SEGMENTS level 11';

level is ts#+1 i.e 10+1=11 in this case.
2. Corrupting temporary segments for drop:
For this following procedures are used:
- DBMS_SPACE_ADMIN.TABLESPACE_VERIFY
- DBMS_SPACE_ADMIN.SEGMENT_CORRUPT
- DBMS_SPACE_ADMIN.SEGMENT_DROP_CORRUPT

-- Verify the tablespace that contains temporary segments (In this case it is KMRPT_DATA)

SQL>DBMS_SPACE_ADMIN.TABLESPACE_VERIFY('KMRPT_DATA');
-- Corrupt the temporary segments in tablespace KMRPT_DATA

SQL>DBMS_SPACE_ADMIN.SEGMENT_CORRUPT(' || chr(39) || tablespace_name || chr(39) || ',' || HEADER_FILE || ',' || HEADER_BLOCK || ');'  from dba_segments where SEGMENT_TYPE like 'TEMP%' and tablespace_name = 'KMRPT_DATA';

-- Drop the corrupted temporary segments

SQL> select 'exec DBMS_SPACE_ADMIN.SEGMENT_DROP_CORRUPT (' || chr(39) || tablespace_name || chr(39) || ',' || HEADER_FILE || ',' || HEADER_BLOCK || ');' from dba_segments where SEGMENT_TYPE like 'TEMP%' and tablespace_name = 'KMRPT_DATA';

-- Verify the tablespace again to update the new dictionary information:

SQL>DBMS_SPACE_ADMIN.TABLESPACE_VERIFY('KMRPT_DATA');
This will remove temporary segments from permanent tablespace.