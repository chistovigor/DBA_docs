select * from all_objects where object_name = 'SECHIST_BASE';
select * from all_objects@spur30 where object_name = 'SECHIST_BASE';

SELECT DISTINCT OWNER, OBJECT_NAME
  FROM ALL_OBJECTS
 WHERE     OWNER || '.' || OBJECT_NAME IN
              (  SELECT OWNER || '.' || SEGMENT_NAME
                   FROM DBA_SEGMENTS@SPURTAB
                  WHERE SEGMENT_TYPE NOT LIKE 'INDEX%'
               GROUP BY OWNER, SEGMENT_NAME
                 HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) >= 1)
       AND OWNER <> 'SYS';

  SELECT OWNER, SEGMENT_NAME, ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) GB
    FROM DBA_SEGMENTS@SPURTAB
   WHERE     SEGMENT_TYPE NOT LIKE 'INDEX%'
         AND OWNER || '.' || SEGMENT_NAME NOT IN
                (SELECT DISTINCT OWNER || '.' || OBJECT_NAME
                   FROM ALL_OBJECTS
                  WHERE OWNER || '.' || OBJECT_NAME IN
                           (  SELECT OWNER || '.' || SEGMENT_NAME
                                FROM DBA_SEGMENTS@SPURTAB
                               WHERE SEGMENT_TYPE NOT LIKE 'INDEX%'
                            GROUP BY OWNER, SEGMENT_NAME
                              HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024),
                                            1) >= 1))
GROUP BY OWNER, SEGMENT_NAME
  HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) >= 1
ORDER BY OWNER, 3 DESC;

  SELECT OWNER, SEGMENT_NAME, ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) GB
    FROM DBA_SEGMENTS@SPURTAB
   WHERE     SEGMENT_TYPE NOT LIKE 'INDEX%'
         AND OWNER || '.' || SEGMENT_NAME NOT IN
                (SELECT DISTINCT OWNER || '.' || OBJECT_NAME
                   FROM ALL_OBJECTS
                  WHERE OWNER || '.' || OBJECT_NAME IN
                           (  SELECT OWNER || '.' || SEGMENT_NAME
                                FROM DBA_SEGMENTS@SPURTAB
                               WHERE SEGMENT_TYPE NOT LIKE 'INDEX%'
                            GROUP BY OWNER, SEGMENT_NAME
                              HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024),
                                            1) <= 1))
         AND OWNER NOT IN ('APEX_050000',
                           'APEX_SPUR_DEV',
                           'ARDB_USER',
                           'CTXSYS',
                           'CU_ARC',
                           'DBSNMP',
                           'EXFSYS',
                           'FLOWS_FILES',
                           'MDSYS',
                           'OLAPSYS',
                           'ORDDATA',
                           'OUTLN',
                           'SCOTT',
                           'SYS',
                           'SYSMAN',
                           'SYSTEM',
                           'WMSYS',
                           'XDB')
GROUP BY OWNER, SEGMENT_NAME
  HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) < 1
ORDER BY OWNER, 3 DESC;

  SELECT OWNER, SEGMENT_NAME, ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) GB
    FROM DBA_SEGMENTS@SPUR30
   WHERE     SEGMENT_TYPE NOT LIKE 'INDEX%'
         AND OWNER NOT IN ('SYS',
                           'TEST_LOADRP31',
                           'POLYANTSEVNA',
                           'MOSCOW_EXCHANGE_TST',
                           'MOSCOW_EXCHANGE',
                           'KUNETSAS',
                           'LOAD_ALAMEDA',
                           'MDMWORK_TST')
         AND OWNER || '.' || SEGMENT_NAME NOT IN
                (SELECT DISTINCT OWNER || '.' || OBJECT_NAME
                   FROM ALL_OBJECTS
                  WHERE OWNER || '.' || OBJECT_NAME IN
                           (  SELECT OWNER || '.' || SEGMENT_NAME
                                FROM DBA_SEGMENTS@SPUR30
                               WHERE SEGMENT_TYPE NOT LIKE 'INDEX%'
                            GROUP BY OWNER, SEGMENT_NAME
                              HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024),
                                            1) >= 1))
GROUP BY OWNER, SEGMENT_NAME
  HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) >= 1
ORDER BY OWNER, 3 DESC;

  SELECT OWNER, SEGMENT_NAME, ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) GB
    FROM DBA_SEGMENTS@SPUR30
   WHERE     SEGMENT_TYPE NOT LIKE 'INDEX%'
         AND OWNER NOT IN ('EXPIMP',
                           'ORDSYS',
                           'VVM',
                           'APEX_050000',
                           'APEX_SPUR_DEV',
                           'ARDB_USER',
                           'CTXSYS',
                           'CU_ARC',
                           'DBSNMP',
                           'EXFSYS',
                           'FLOWS_FILES',
                           'MDSYS',
                           'OLAPSYS',
                           'ORDDATA',
                           'OUTLN',
                           'SCOTT',
                           'SYS',
                           'SYSMAN',
                           'SYSTEM',
                           'WMSYS',
                           'XDB')
         AND OWNER || '.' || SEGMENT_NAME NOT IN
                (SELECT DISTINCT OWNER || '.' || OBJECT_NAME
                   FROM ALL_OBJECTS
                  WHERE OWNER || '.' || OBJECT_NAME IN
                           (  SELECT OWNER || '.' || SEGMENT_NAME
                                FROM DBA_SEGMENTS@SPUR30
                               WHERE SEGMENT_TYPE NOT LIKE 'INDEX%'
                            GROUP BY OWNER, SEGMENT_NAME
                              HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024),
                                            1) <= 1))
GROUP BY OWNER, SEGMENT_NAME
  HAVING ROUND (SUM (BYTES / 1024 / 1024 / 1024), 1) < 1
ORDER BY OWNER, 3 DESC;

-- logical objects in DWH

  SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT LIKE '%SYS%'
         AND OWNER NOT IN ('PUBLIC',
                           'ORACLE_OCM',
                           'GSMADMIN_INTERNAL',
                           'APEX_050000',
                           'OUTLN',
                           'APEX_LISTENER',
                           'TOAD',
                           'DBSNMP',
                           'XDB')
ORDER BY OWNER, STATUS, OBJECT_NAME;

-- logical objects in SPUR

  SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS@SPUR30
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT IN ('CBPROXYUSER',
                           'APPQOSSYS',
                           'TOAD',
                           'ORDPLUGINS',
                           'ORDSYS',
                           'PUBLIC',
                           'OWBSYS',
                           'EXPIMP',
                           'CBSYSUSER',
                           'OWBSYS_AUDIT',
                           'APEX_050000',
                           'APEX_SPUR_DEV',
                           'ARDB_USER',
                           'CTXSYS',
                           'CU_ARC',
                           'DBSNMP',
                           'EXFSYS',
                           'FLOWS_FILES',
                           'MDSYS',
                           'OLAPSYS',
                           'ORDDATA',
                           'OUTLN',
                           'SCOTT',
                           'SYS',
                           'SYSMAN',
                           'SYSTEM',
                           'WMSYS',
                           'XDB')
ORDER BY OWNER, STATUS, OBJECT_NAME;

-- logical objects in SPURTAB

  SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS@SPURTAB
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT IN ('ORACLE_OCM',
                     'CBMVUSER',
                     'JET',
                     'CBMIRROR',
                     'CBPROXYUSER',
                     'APPQOSSYS',
                     'TOAD',
                     'ORDPLUGINS',
                     'ORDSYS',
                     'PUBLIC',
                     'OWBSYS',
                     'EXPIMP',
                     'CBSYSUSER',
                     'OWBSYS_AUDIT',
                     'APEX_050000',
                     'APEX_SPUR_DEV',
                     'ARDB_USER',
                     'CTXSYS',
                     'CU_ARC',
                     'DBSNMP',
                     'EXFSYS',
                     'FLOWS_FILES',
                     'MDSYS',
                     'OLAPSYS',
                     'ORDDATA',
                     'OUTLN',
                     'SCOTT',
                     'SYS',
                     'SYSMAN',
                     'SYSTEM',
                     'WMSYS',
                     'XDB')
ORDER BY OWNER, STATUS, OBJECT_NAME;

-- difference

  SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS@SPUR30
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT IN ('CBPROXYUSER',
                           'APPQOSSYS',
                           'TOAD',
                           'ORDPLUGINS',
                           'ORDSYS',
                           'PUBLIC',
                           'OWBSYS',
                           'EXPIMP',
                           'CBSYSUSER',
                           'OWBSYS_AUDIT',
                           'APEX_050000',
                           'APEX_SPUR_DEV',
                           'ARDB_USER',
                           'CTXSYS',
                           'CU_ARC',
                           'DBSNMP',
                           'EXFSYS',
                           'FLOWS_FILES',
                           'MDSYS',
                           'OLAPSYS',
                           'ORDDATA',
                           'OUTLN',
                           'SCOTT',
                           'SYS',
                           'SYSMAN',
                           'SYSTEM',
                           'WMSYS',
                           'XDB')
MINUS
   SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT LIKE '%SYS%'
         AND OWNER NOT IN ('PUBLIC',
                           'ORACLE_OCM',
                           'GSMADMIN_INTERNAL',
                           'APEX_050000',
                           'OUTLN',
                           'APEX_LISTENER',
                           'TOAD',
                           'DBSNMP',
                           'XDB')
ORDER BY OWNER, STATUS, OBJECT_NAME;

SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS@SPURTAB
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT IN ('ORACLE_OCM',
                     'CBMVUSER',
                     'JET',
                     'CBMIRROR',
                     'CBPROXYUSER',
                     'APPQOSSYS',
                     'TOAD',
                     'ORDPLUGINS',
                     'ORDSYS',
                     'PUBLIC',
                     'OWBSYS',
                     'EXPIMP',
                     'CBSYSUSER',
                     'OWBSYS_AUDIT',
                     'APEX_050000',
                     'APEX_SPUR_DEV',
                     'ARDB_USER',
                     'CTXSYS',
                     'CU_ARC',
                     'DBSNMP',
                     'EXFSYS',
                     'FLOWS_FILES',
                     'MDSYS',
                     'OLAPSYS',
                     'ORDDATA',
                     'OUTLN',
                     'SCOTT',
                     'SYS',
                     'SYSMAN',
                     'SYSTEM',
                     'WMSYS',
                     'XDB')
MINUS
   SELECT OWNER,
         OBJECT_NAME,
         OBJECT_TYPE,
         STATUS
    FROM ALL_OBJECTS
   WHERE     OBJECT_TYPE IN ('SEQUENCE',
                             'PROCEDURE',
                             'PACKAGE',
                             'PACKAGE BODY',
                             'TRIGGER',
                             'MATERIALIZED VIEW',
                             'VIEW',
                             'SYNONYM',
                             'FUNCTION',
                             'TYPE')
         AND OWNER NOT LIKE '%SYS%'
         AND OWNER NOT IN ('PUBLIC',
                           'ORACLE_OCM',
                           'GSMADMIN_INTERNAL',
                           'APEX_050000',
                           'OUTLN',
                           'APEX_LISTENER',
                           'TOAD',
                           'DBSNMP',
                           'XDB')
ORDER BY OWNER, STATUS, OBJECT_NAME;