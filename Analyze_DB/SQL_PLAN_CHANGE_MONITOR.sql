So in this case we need monitoring schema in the DB. 
DDL for that: 
1. Create monitoring schema (I have provided DDL earlier, DON’T use DBSNMP schema)
2. Create view in that schema (please use below UPDATED DDL):
3. create table in above schema
4. create scheduled job (execution time need to decide, propose every 10 minutes) with the following code in the above schema:


CREATE OR REPLACE FORCE VIEW SQL_PLAN_CHANGE_MONITOR
(
    FLAG,
    SQL_ID,
    PLAN_HASH_VALUE,
    INST_ID,
    SID,
    USERNAME,
    PROGRAM,
    MACHINE
)
BEQUEATH DEFINER
AS
    WITH
        ACTIVE_SQL
        AS
            (  SELECT /*+ MATERIALIZE */
                      VS.SQL_ID,
                      SQ.PLAN_HASH_VALUE,
                      MAX (SQ.ELAPSED_TIME)     ELAPSED,
                      MAX (SQ.EXECUTIONS)       EXECUTIONS
                 FROM GV$SESSION VS, GV$SQL SQ
                WHERE     VS.SQL_ID = SQ.SQL_ID
                      AND VS.SQL_CHILD_NUMBER = SQ.CHILD_NUMBER
                      AND VS.STATUS = 'ACTIVE'
                      AND SQ.PLAN_HASH_VALUE <> 0
             GROUP BY VS.SQL_ID, SQ.PLAN_HASH_VALUE),
        PLAN_EXECUTIONS
        AS
            (  SELECT /*+ MATERIALIZE */
                      SS.SQL_ID,
                      SS.PLAN_HASH_VALUE,
                      SUM (SS.EXECUTIONS_DELTA)     TOTAL_EXECUTIONS
                 FROM DBA_HIST_SQLSTAT SS, ACTIVE_SQL A
                WHERE A.SQL_ID = SS.SQL_ID
             GROUP BY SS.SQL_ID, SS.PLAN_HASH_VALUE),
        MOST_FREQUENT_EXECUTIONS
        AS
            (SELECT /*+ MATERIALIZE */
                    PE1.SQL_ID, PE1.PLAN_HASH_VALUE
               FROM PLAN_EXECUTIONS PE1
              WHERE PE1.TOTAL_EXECUTIONS = (SELECT MAX (PE2.TOTAL_EXECUTIONS)
                                              FROM PLAN_EXECUTIONS PE2
                                             WHERE PE1.SQL_ID = PE2.SQL_ID)),
        MOST_FREQUENT_NODUPS
        AS
            (SELECT /*+ MATERIALIZE */
                    MFE1.SQL_ID, MFE1.PLAN_HASH_VALUE
               FROM MOST_FREQUENT_EXECUTIONS MFE1
              WHERE MFE1.PLAN_HASH_VALUE =
                    (SELECT MAX (MFE2.PLAN_HASH_VALUE)
                       FROM MOST_FREQUENT_EXECUTIONS MFE2
                      WHERE MFE1.SQL_ID = MFE2.SQL_ID)),
        NOT_MOST_FREQ
        AS
            (SELECT /*+ MATERIALIZE */
                    *
               FROM ACTIVE_SQL
              WHERE (SQL_ID, PLAN_HASH_VALUE) NOT IN
                        (SELECT SQL_ID, PLAN_HASH_VALUE
                           FROM MOST_FREQUENT_NODUPS)),
        AVG_ELAPSED_MOST_F
        AS
            (  SELECT /*+ MATERIALIZE */
                      SS.SQL_ID,
                      SS.PLAN_HASH_VALUE,
                        SUM (SS.ELAPSED_TIME_DELTA)
                      / (SUM (SS.EXECUTIONS_DELTA) + 1)    AVG_ELAPSED
                 FROM DBA_HIST_SQLSTAT SS, MOST_FREQUENT_NODUPS ND
                WHERE     SS.SQL_ID = ND.SQL_ID
                      AND SS.PLAN_HASH_VALUE = ND.PLAN_HASH_VALUE
             GROUP BY SS.SQL_ID, SS.PLAN_HASH_VALUE),
        MORE_THAN_10X
        AS
            (SELECT /*+ MATERIALIZE */
                    N.SQL_ID, N.PLAN_HASH_VALUE
               FROM NOT_MOST_FREQ N, AVG_ELAPSED_MOST_F M
              WHERE     (N.ELAPSED / (N.EXECUTIONS + 1)) > 1 * M.AVG_ELAPSED
                    AND N.SQL_ID = M.SQL_ID)
      SELECT /*+ LEADING (ACTIVE_SQL PLAN_EXECUTIONS MOST_FREQUENT_EXECUTIONS MOST_FREQUENT_NODUPS NOT_MOST_FREQ AVG_ELAPSED_MOST_F MORE_THAN_10X) */
             'CHANGED ' || 'PLAN'     FLAG,
             M.SQL_ID,
             M.PLAN_HASH_VALUE,
             S.INST_ID,
             S.SID,
             S.USERNAME,
             S.PROGRAM,
             S.MACHINE
        FROM MORE_THAN_10X M, GV$SESSION S, GV$SQL Q
       WHERE     M.SQL_ID = S.SQL_ID(+)
             AND M.PLAN_HASH_VALUE = Q.PLAN_HASH_VALUE(+)
             AND S.SQL_ID = Q.SQL_ID
             AND S.SQL_CHILD_NUMBER = Q.CHILD_NUMBER
    ORDER BY M.SQL_ID,
             M.PLAN_HASH_VALUE,
             S.SID,
             S.USERNAME;
             
 -- MONITORING table DDL

CREATE TABLE CHANGED_PLAN_TBL
(
    FLAG                   VARCHAR2 (12),
    SQL_ID                 VARCHAR2 (13),
    PLAN_HASH_VALUE        NUMBER,
    INST_ID                NUMBER,
    SID                    NUMBER,
    USERNAME               VARCHAR2 (128),
    PROGRAM                VARCHAR2 (128),
    MACHINE                VARCHAR2 (128),
    DATETIME               DATE,
    OWNER_ACTION_STATUS    VARCHAR2 (5) DEFAULT 'FALSE',
    OWNER_ACTION_USER      VARCHAR2 (10),
    OWNER_ACTION_TIME      DATE DEFAULT SYSDATE
);

-- PL SQL for insert monitoring data:

DECLARE
    V_ROWS_INSERTED   NUMBER;
BEGIN
    DBMS_OUTPUT.ENABLE;

    EXECUTE IMMEDIATE 'insert into CHANGED_PLAN_TBL
        (FLAG,
        SQL_ID,
        PLAN_HASH_VALUE,
        INST_ID,
        SID,
        USERNAME,
        PROGRAM,
        MACHINE,
        DATETIME,
        OWNER_ACTION_STATUS,
        OWNER_ACTION_USER,
        OWNER_ACTION_TIME)
        select 
  FLAG,
  SQL_ID,
  PLAN_HASH_VALUE,
  INST_ID,
  SID,
  USERNAME,
  PROGRAM,
  MACHINE,
  sysdate,
  ''FALSE'',
  '''',
  ''''
  from SQL_PLAN_CHANGE_MONITOR';

    V_ROWS_INSERTED := SQL%ROWCOUNT;
    DBMS_OUTPUT.PUT_LINE (V_ROWS_INSERTED || ' rows inserted');
END;          
             
             
--insert data from the view above into table in monitoring schema
             
select count(*) from db_adm_mon.changed_plan_tbl where owner_action_status='FALSE' and username !='SYS';

--And after fixing it , will update the table as below:

update db_adm_mon.changed_plan_tbl
set owner_action_status='TRUE',
owner_action_user='MGOMAA',
owner_action_time = sysdate
where plan_hash_value in (2872876060);
commit;

--if it will not be changed for any reason, will update the record as:

update dbsnmp.changed_plan_tbl
set owner_action_status='CLEAR',
owner_action_user='MGOMAA',
owner_action_time = sysdate
where plan_hash_value in (2872876060);
commit;