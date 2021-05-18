PACKAGE BODY dbms_workload_repository AS

  TOPNSQL_DEFAULT CONSTANT NUMBER := 2000000000; 
  TOPNSQL_MAXIMUM CONSTANT NUMBER := 2000000001; 

  
  BL_TEMPLATE_SINGLE    CONSTANT VARCHAR2(10) := 'SINGLE';
  BL_TEMPLATE_REPEATING CONSTANT VARCHAR2(10) := 'REPEATING';

  



  INST_LIST_PATTERN     CONSTANT VARCHAR2(200) :=
     '^[1-9][0-9]*(,[1-9][0-9]*)*$';





PROCEDURE VALIDATE_INSTANCE_LIST(INLIST  IN VARCHAR2,
                                 OUTLIST IN OUT NOCOPY AWRRPT_INSTANCE_LIST_TYPE)
IS
 BUF     VARCHAR2(4096);
 INSTNUM NUMBER;
 COMMA   NUMBER;
 POS     NUMBER := 1;
BEGIN
  IF LENGTH(INLIST) < 1024 THEN                              

    BUF := REPLACE(INLIST,' ');                              

    
    IF REGEXP_LIKE(BUF, INST_LIST_PATTERN, 'x') THEN
              
      LOOP
        
        COMMA := INSTR(SUBSTR(BUF, POS),',');
    
        IF COMMA <> 0 THEN
          
          INSTNUM := TO_NUMBER(SUBSTR(BUF, POS, COMMA - 1));
        ELSE
          
          INSTNUM := TO_NUMBER(SUBSTR(BUF, POS));
        END IF;

        
        IF INSTNUM > 1000000 THEN
           RAISE_APPLICATION_ERROR(-20112,'Instance number '|| INSTNUM ||
                                           ' is invalid');
        END IF;

        
        IF POS = 1 THEN
          OUTLIST := AWRRPT_INSTANCE_LIST_TYPE(INSTNUM);
        ELSE
          OUTLIST := OUTLIST MULTISET UNION AWRRPT_INSTANCE_LIST_TYPE(INSTNUM);
        END IF;

        EXIT WHEN COMMA = 0;           

        
        POS := POS + COMMA;
        IF POS > LENGTH(BUF) THEN
          
          RAISE_APPLICATION_ERROR(-20112,
                                  'Unexpected '','' at end of instance list');
        END IF;
      END LOOP;

    ELSE
      
      RAISE_APPLICATION_ERROR(-20112,'Invalid instance list format');
    END IF;
  ELSE
    
    RAISE_APPLICATION_ERROR(-20112, 'Instance list too long (' 
                                 || LENGTH(INLIST)
                                 || 'characters, limit is 1024 characters)');
  END IF;

  RETURN;
EXCEPTION
  WHEN OTHERS THEN 
    IF SQLCODE <> -20112 THEN
      RAISE_APPLICATION_ERROR(-20112, 'Invalid instance list format:' ||
                                      SQLERRM);
    ELSE
      RAISE;
    END IF;
END;






FUNCTION CREATE_SNAPSHOT_CALLOUT(
            DBID        IN  NUMBER DEFAULT NULL,
            SOURCE_NAME IN  VARCHAR2 DEFAULT NULL, 
            FLUSH_LEVEL IN  VARCHAR2
            )
RETURN NUMBER IS
EXTERNAL
LANGUAGE C
NAME "kewrpcs_create_snapshot"
WITH CONTEXT
PARAMETERS(CONTEXT,
           DBID          OCINUMBER,
           DBID          INDICATOR SB4,
           SOURCE_NAME   OCISTRING,
           SOURCE_NAME   INDICATOR SB4,
           FLUSH_LEVEL   OCISTRING,
           FLUSH_LEVEL   INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;





PROCEDURE CREATE_SNAPSHOT(
            FLUSH_LEVEL IN  VARCHAR2 DEFAULT 'BESTFIT',
            DBID        IN  NUMBER DEFAULT NULL,
            SOURCE_NAME IN  VARCHAR2 DEFAULT NULL
            ) IS
  SNAP_ID NUMBER;

BEGIN
  IF ((DBID != NULL) AND (SOURCE_NAME != NULL)) THEN
    RAISE_APPLICATION_ERROR(-20100, 'Invalid parameter combination: ' ||
                       'Source Name cannot be specified if DBID is specified');
  END IF;

  IF ((FLUSH_LEVEL = 'BESTFIT') OR (FLUSH_LEVEL = 'LITE')
      OR (FLUSH_LEVEL = 'TYPICAL') OR (FLUSH_LEVEL = 'ALL')) THEN
    SNAP_ID := CREATE_SNAPSHOT_CALLOUT(DBID, SOURCE_NAME, FLUSH_LEVEL);
  ELSE
    RAISE_APPLICATION_ERROR(-20100, 'Invalid flush level. ' ||
          'Level must be ''BESTFIT'', ''LITE'', ''TYPICAL'' or ''ALL''.');
  END IF;

END;






FUNCTION CREATE_SNAPSHOT(
            FLUSH_LEVEL IN  VARCHAR2 DEFAULT 'BESTFIT',
            DBID        IN  NUMBER DEFAULT NULL,
            SOURCE_NAME IN  VARCHAR2 DEFAULT NULL
                         )  RETURN NUMBER IS
  SNAP_ID NUMBER;

BEGIN
  IF ((DBID != NULL) AND (SOURCE_NAME != NULL)) THEN
    RAISE_APPLICATION_ERROR(-20100, 'Invalid parameter combination: ' ||
                       'Source Name cannot be specified if DBID is specified');
  END IF;

  IF ((FLUSH_LEVEL = 'BESTFIT') OR (FLUSH_LEVEL = 'LITE')
      OR (FLUSH_LEVEL = 'TYPICAL') OR (FLUSH_LEVEL = 'ALL')) THEN
    SNAP_ID := CREATE_SNAPSHOT_CALLOUT(DBID, SOURCE_NAME, FLUSH_LEVEL);
  ELSE
    RAISE_APPLICATION_ERROR(-20100, 'Invalid flush level. ' ||
          'Level must be ''BESTFIT'', ''LITE'', ''TYPICAL'' or ''ALL''.');
  END IF;

  RETURN SNAP_ID;
END;





PROCEDURE DROP_SNAPSHOT_RANGE(
            LOW_SNAP_ID             IN NUMBER,
            HIGH_SNAP_ID            IN NUMBER,
            DBID                    IN NUMBER DEFAULT NULL
            ) IS
EXTERNAL
NAME "kewrpdsr_drop_snapshot_range"
WITH CONTEXT
PARAMETERS(CONTEXT,
           LOW_SNAP_ID   OCINUMBER,
           HIGH_SNAP_ID  OCINUMBER,
           DBID          OCINUMBER,
           DBID          INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;






PROCEDURE MODIFY_SNAPSETTINGS_CALLOUT(
            RETENTION IN NUMBER,
            INTERVAL  IN NUMBER,
            TOPNSQL   IN NUMBER,
            DBID      IN NUMBER
            ) IS
EXTERNAL
NAME "kewrpms_modify_settings"
WITH CONTEXT
PARAMETERS(CONTEXT,
           RETENTION OCINUMBER,
           RETENTION INDICATOR SB4,
           INTERVAL  OCINUMBER,
           INTERVAL  INDICATOR SB4,
           TOPNSQL   OCINUMBER,
           TOPNSQL   INDICATOR SB4,
           DBID      OCINUMBER,
           DBID      INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;







PROCEDURE MODIFY_SNAPSHOT_SETTINGS(
            RETENTION IN NUMBER DEFAULT NULL,
            INTERVAL  IN NUMBER DEFAULT NULL,
            TOPNSQL   IN NUMBER DEFAULT NULL,
            DBID      IN NUMBER DEFAULT NULL) IS
BEGIN

  



  IF (TOPNSQL = TOPNSQL_DEFAULT) OR (TOPNSQL = TOPNSQL_MAXIMUM) THEN

    
    RAISE_APPLICATION_ERROR(-20110,
                            'invalid Top N SQL value. ' ||
                            'not allowed to specify ' ||
                            TOPNSQL_DEFAULT || ' or ' ||
                            TOPNSQL_MAXIMUM || '.');
  ELSE

    
    MODIFY_SNAPSETTINGS_CALLOUT(RETENTION, INTERVAL, TOPNSQL, DBID);

  END IF;

END MODIFY_SNAPSHOT_SETTINGS;






PROCEDURE MODIFY_SNAPSHOT_SETTINGS(
            RETENTION IN NUMBER   DEFAULT NULL,
            INTERVAL  IN NUMBER   DEFAULT NULL,
            TOPNSQL   IN VARCHAR2,
            DBID      IN NUMBER   DEFAULT NULL) IS

  
  TOPNSQL_NUM NUMBER;

BEGIN

  
  IF (TOPNSQL = 'DEFAULT') THEN

    
    MODIFY_SNAPSETTINGS_CALLOUT(RETENTION, INTERVAL, TOPNSQL_DEFAULT, DBID);

  ELSIF (TOPNSQL = 'MAXIMUM') THEN

    
    MODIFY_SNAPSETTINGS_CALLOUT(RETENTION, INTERVAL, TOPNSQL_MAXIMUM, DBID);

  ELSE

    BEGIN
      
      TOPNSQL_NUM := TO_NUMBER(TOPNSQL);

    EXCEPTION
      WHEN OTHERS THEN

        
        RAISE_APPLICATION_ERROR(-20111,
                                'invalid Top N SQL string: ' || TOPNSQL);
    END;

    
    MODIFY_SNAPSHOT_SETTINGS(RETENTION, INTERVAL, TOPNSQL_NUM, DBID);

  END IF;

END MODIFY_SNAPSHOT_SETTINGS;






FUNCTION CREATE_BASELINE_CALLOUT(
            START_SNAP_ID  IN NUMBER,
            END_SNAP_ID    IN NUMBER,
            BASELINE_NAME  IN VARCHAR2,
            DBID           IN NUMBER DEFAULT NULL,
            EXPIRATION     IN NUMBER DEFAULT NULL
            )
RETURN NUMBER IS
EXTERNAL
LANGUAGE C
NAME "kewrpcb_create_baseline"
WITH CONTEXT
PARAMETERS(CONTEXT,
           START_SNAP_ID    OCINUMBER,
           START_SNAP_ID    INDICATOR SB4,
           END_SNAP_ID      OCINUMBER,
           END_SNAP_ID      INDICATOR SB4,
           BASELINE_NAME    OCISTRING,
           BASELINE_NAME    INDICATOR SB4,
           DBID             OCINUMBER,
           DBID             INDICATOR SB4,
           EXPIRATION       OCINUMBER,
           EXPIRATION       INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;





PROCEDURE CREATE_BASELINE(START_SNAP_ID IN NUMBER,
                          END_SNAP_ID   IN NUMBER,
                          BASELINE_NAME IN VARCHAR2,
                          DBID          IN NUMBER DEFAULT NULL,
                          EXPIRATION    IN NUMBER DEFAULT NULL
                          ) IS
  BASELINE_ID NUMBER;

BEGIN
  BASELINE_ID := CREATE_BASELINE_CALLOUT(START_SNAP_ID, END_SNAP_ID,
                                         BASELINE_NAME, DBID, EXPIRATION);
END CREATE_BASELINE;





FUNCTION CREATE_BASELINE(START_SNAP_ID IN NUMBER,
                         END_SNAP_ID   IN NUMBER,
                         BASELINE_NAME IN VARCHAR2,
                         DBID          IN NUMBER DEFAULT NULL,
                         EXPIRATION    IN NUMBER DEFAULT NULL
                         )  RETURN NUMBER IS
  BASELINE_ID NUMBER;

BEGIN
  BASELINE_ID := CREATE_BASELINE_CALLOUT(START_SNAP_ID, END_SNAP_ID,
                                         BASELINE_NAME, DBID, EXPIRATION);

  RETURN BASELINE_ID;
END CREATE_BASELINE;





FUNCTION CREATE_BL_TIMERANGE_CALLOUT(
            START_TIME     IN DATE,
            END_TIME       IN DATE,
            BASELINE_NAME  IN VARCHAR2,
            DBID           IN NUMBER DEFAULT NULL,
            EXPIRATION     IN NUMBER DEFAULT NULL
            )
RETURN NUMBER IS
EXTERNAL
LANGUAGE C
NAME "kewrpcbt_create_bl_timerange"
WITH CONTEXT
PARAMETERS(CONTEXT,
           START_TIME       OCIDATE,
           START_TIME       INDICATOR SB4,
           END_TIME         OCIDATE,
           END_TIME         INDICATOR SB4,
           BASELINE_NAME    OCISTRING,
           BASELINE_NAME    INDICATOR SB4,
           DBID             OCINUMBER,
           DBID             INDICATOR SB4,
           EXPIRATION       OCINUMBER,
           EXPIRATION       INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;





PROCEDURE CREATE_BASELINE(START_TIME     IN DATE,
                          END_TIME       IN DATE,
                          BASELINE_NAME  IN VARCHAR2,
                          DBID           IN NUMBER DEFAULT NULL,
                          EXPIRATION     IN NUMBER DEFAULT NULL
                          ) IS
  BASELINE_ID NUMBER;
BEGIN
  BASELINE_ID := CREATE_BL_TIMERANGE_CALLOUT(START_TIME, END_TIME, 
                                             BASELINE_NAME, DBID, EXPIRATION);
END CREATE_BASELINE;





FUNCTION CREATE_BASELINE(START_TIME     IN DATE,
                         END_TIME       IN DATE,
                         BASELINE_NAME  IN VARCHAR2,
                         DBID           IN NUMBER DEFAULT NULL,
                         EXPIRATION     IN NUMBER DEFAULT NULL
                         )  RETURN NUMBER IS
  BASELINE_ID NUMBER;
BEGIN
  BASELINE_ID := CREATE_BL_TIMERANGE_CALLOUT(START_TIME, END_TIME, 
                                             BASELINE_NAME, DBID, EXPIRATION);
  RETURN BASELINE_ID;
END CREATE_BASELINE;























FUNCTION SELECT_BASELINE_DETAILS(L_BASELINE_ID   IN NUMBER,
                                 L_BEG_SNAP      IN NUMBER DEFAULT NULL,
                                 L_END_SNAP      IN NUMBER DEFAULT NULL,
                                 L_DBID          IN NUMBER DEFAULT NULL
                                )
 RETURN AWRBL_DETAILS_TYPE_TABLE PIPELINED
IS
  P_BEG_SNAP     NUMBER;
  P_END_SNAP     NUMBER;
  P_BASELINE_ID  NUMBER;
  P_DBID         NUMBER;

  
  MVWIN_SIZE     NUMBER;

  
  CURSOR BLSTATS_CUR IS
     SELECT DBID             DBID,
            P_BASELINE_ID    BASELINE_ID,
            INSTANCE_NUMBER  INSTANCE_NUMBER,
            MIN_SID          START_SNAP_ID,
            MIN_ETIME        START_SNAP_TIME,
            MAX_SID          END_SNAP_ID,
            MAX_ETIME        END_SNAP_TIME,
            CASE WHEN DSTART > 1 THEN 'YES'
              ELSE 'NO' END AS SHUTDOWN,
            ECOUNT           ERROR_COUNT,
            DECODE(MAX_ETIME, MIN_ETIME, NULL,
               ROUND(100 *
                     (TOTAL_TIME -
                       (EXTRACT(DAY FROM TIME_ADJ) * 1440 +
                        EXTRACT(HOUR FROM TIME_ADJ) * 60  +
                        EXTRACT(MINUTE FROM TIME_ADJ)     +
                        EXTRACT(SECOND FROM TIME_ADJ) / 60)) /
                     (EXTRACT (DAY FROM WALL_TIME) * 1440 +
                      EXTRACT(HOUR FROM WALL_TIME) * 60 +
                      EXTRACT(MINUTE FROM WALL_TIME) +
                      EXTRACT(SECOND FROM WALL_TIME) / 60), 2)) PCT_TOTAL_TIME
     FROM
     (SELECT
        DBID, INSTANCE_NUMBER, MIN(SNAP_ID) MIN_SID, MAX(SNAP_ID) MAX_SID,
        MIN(END_INTERVAL_TIME) MIN_ETIME, MAX(END_INTERVAL_TIME) MAX_ETIME,
        (MAX(END_INTERVAL_TIME) - MIN(END_INTERVAL_TIME))   WALL_TIME,
        (MIN(END_INTERVAL_TIME) - MIN(BEGIN_INTERVAL_TIME)) TIME_ADJ,
        COUNT(DISTINCT STARTUP_TIME) DSTART, SUM(ERROR_COUNT) ECOUNT,
        SUM(EXTRACT(DAY FROM END_INTERVAL_TIME - BEGIN_INTERVAL_TIME) * 1440
          + EXTRACT(HOUR FROM END_INTERVAL_TIME - BEGIN_INTERVAL_TIME) * 60
          + EXTRACT(MINUTE FROM END_INTERVAL_TIME - BEGIN_INTERVAL_TIME)
          + EXTRACT(SECOND FROM END_INTERVAL_TIME - BEGIN_INTERVAL_TIME) / 60)
         AS TOTAL_TIME
      FROM DBA_HIST_SNAPSHOT
      WHERE DBID = P_DBID
        AND SNAP_ID BETWEEN P_BEG_SNAP AND P_END_SNAP
      GROUP BY DBID, INSTANCE_NUMBER);

  CUROUT BLSTATS_CUR%ROWTYPE;                         

BEGIN

  
  IF (L_DBID IS NULL) THEN
    SELECT DBID INTO P_DBID FROM V$DATABASE;
  ELSE
    P_DBID := L_DBID;
  END IF;

  
  P_BASELINE_ID := L_BASELINE_ID;

  


  IF (P_BASELINE_ID = 0) THEN

    
    SELECT MOVING_WINDOW_SIZE INTO MVWIN_SIZE
      FROM DBA_HIST_BASELINE_METADATA
     WHERE BASELINE_ID = P_BASELINE_ID
       AND DBID        = P_DBID;

    
    SELECT NVL(MIN(SNAP_ID), 0), NVL(MAX(SNAP_ID), 0)
      INTO P_BEG_SNAP, P_END_SNAP
      FROM DBA_HIST_SNAPSHOT
     WHERE END_INTERVAL_TIME >= (SYSDATE - MVWIN_SIZE)
       AND DBID               = P_DBID;

  ELSE
    
    SELECT START_SNAP_ID, END_SNAP_ID INTO P_BEG_SNAP, P_END_SNAP
      FROM  DBA_HIST_BASELINE_METADATA
      WHERE BASELINE_ID = P_BASELINE_ID
        AND DBID        = P_DBID;

    
    IF (L_BEG_SNAP IS NOT NULL) THEN
      P_BEG_SNAP := L_BEG_SNAP;
    END IF;

    IF (L_END_SNAP IS NOT NULL) THEN
      P_END_SNAP := L_END_SNAP;
    END IF;

  END IF;

  
  OPEN BLSTATS_CUR;

  LOOP
    
    FETCH BLSTATS_CUR INTO CUROUT;

    EXIT WHEN BLSTATS_CUR%NOTFOUND;

    
    PIPE ROW(AWRBL_DETAILS_TYPE(CUROUT.DBID, CUROUT.BASELINE_ID,
                                CUROUT.INSTANCE_NUMBER,
                                CUROUT.START_SNAP_ID,  CUROUT.START_SNAP_TIME,
                                CUROUT.END_SNAP_ID,    CUROUT.END_SNAP_TIME,
                                CUROUT.SHUTDOWN,       CUROUT.ERROR_COUNT,
                                CUROUT.PCT_TOTAL_TIME));
  END LOOP;

  CLOSE BLSTATS_CUR;

END SELECT_BASELINE_DETAILS;















FUNCTION SELECT_BASELINE_METRIC(L_BASELINE_NAME  IN VARCHAR2,
                                L_DBID           IN NUMBER DEFAULT NULL,
                                L_INSTANCE_NUM   IN NUMBER DEFAULT NULL)
RETURN AWRBL_METRIC_TYPE_TABLE PIPELINED
IS
  P_BEG_SNAP     NUMBER;
  P_END_SNAP     NUMBER;
  P_DBID         NUMBER;
  P_INSTANCE_NUM NUMBER;

  MVWIN_SIZE     NUMBER;

  CURSOR BLMETRIC_CUR IS
    SELECT METRIC_NAME, METRIC_UNIT,
           MIN(BEGIN_TIME) BEG_TIME, MAX(END_TIME) END_TIME,
           MAX(INTSIZE) INTERVAL_SIZE,
           SUM(NUM_INTERVAL) NUM_INTERVAL,
           MIN(MINVAL) MINIMUM, MAX(MAXVAL) MAXIMUM,
           SUM(AVERAGE * NUM_INTERVAL) / SUM(NUM_INTERVAL) AVERAGE
      FROM DBA_HIST_SYSMETRIC_SUMMARY
     WHERE DBID            = P_DBID
       AND INSTANCE_NUMBER = P_INSTANCE_NUM
       AND SNAP_ID         >= P_BEG_SNAP
       AND SNAP_ID         <= P_END_SNAP
     GROUP BY METRIC_NAME, METRIC_UNIT;

  CUROUT BLMETRIC_CUR%ROWTYPE;                        

BEGIN

  
  IF (L_DBID IS NULL) THEN
    SELECT DBID INTO P_DBID FROM V$DATABASE;
  ELSE
    P_DBID := L_DBID;
  END IF;

  
  IF (L_INSTANCE_NUM IS NULL) THEN
    SELECT INSTANCE_NUMBER INTO P_INSTANCE_NUM FROM V$INSTANCE;
  ELSE
    P_INSTANCE_NUM := L_INSTANCE_NUM;
  END IF;

  


  IF (L_BASELINE_NAME = 'SYSTEM_MOVING_WINDOW') THEN

    
    SELECT MOVING_WINDOW_SIZE INTO MVWIN_SIZE
      FROM DBA_HIST_BASELINE_METADATA
     WHERE BASELINE_ID = 0
       AND DBID        = P_DBID;

    
    SELECT NVL(MIN(SNAP_ID), 0), NVL(MAX(SNAP_ID), 0)
      INTO P_BEG_SNAP, P_END_SNAP
      FROM DBA_HIST_SNAPSHOT
     WHERE END_INTERVAL_TIME >= (SYSDATE - MVWIN_SIZE)
       AND DBID               = P_DBID
       AND INSTANCE_NUMBER    = P_INSTANCE_NUM;

  ELSE

    
    SELECT START_SNAP_ID, END_SNAP_ID INTO P_BEG_SNAP, P_END_SNAP
      FROM  DBA_HIST_BASELINE_METADATA
      WHERE BASELINE_NAME   = L_BASELINE_NAME
        AND DBID            = P_DBID;

  END IF;

  
  OPEN BLMETRIC_CUR;

  LOOP
    
    FETCH BLMETRIC_CUR INTO CUROUT;

    EXIT WHEN BLMETRIC_CUR%NOTFOUND;

    
    PIPE ROW(AWRBL_METRIC_TYPE(L_BASELINE_NAME, P_DBID, P_INSTANCE_NUM,
                               CUROUT.BEG_TIME,     CUROUT.END_TIME,
                               CUROUT.METRIC_NAME,  CUROUT.METRIC_UNIT,
                               CUROUT.NUM_INTERVAL, CUROUT.INTERVAL_SIZE,
                               CUROUT.AVERAGE,      CUROUT.MINIMUM,
                               CUROUT.MAXIMUM));
  END LOOP;

  CLOSE BLMETRIC_CUR;

END SELECT_BASELINE_METRIC;





PROCEDURE RENAME_BASELINE(OLD_BASELINE_NAME IN VARCHAR2,
                          NEW_BASELINE_NAME IN VARCHAR2,
                          DBID              IN NUMBER DEFAULT NULL
                          ) IS
EXTERNAL
NAME "kewrprb_rename_baseline"
WITH CONTEXT
PARAMETERS(CONTEXT,
           OLD_BASELINE_NAME OCISTRING,
           OLD_BASELINE_NAME INDICATOR SB4,
           NEW_BASELINE_NAME OCISTRING,
           NEW_BASELINE_NAME INDICATOR SB4,
           DBID              OCINUMBER,
           DBID              INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;





PROCEDURE MODIFY_BASELINE_WINDOW_SIZE(WINDOW_SIZE IN NUMBER,
                                      DBID        IN NUMBER DEFAULT NULL
                                      ) IS
EXTERNAL
NAME "kewrpmws_modbl_window_size"
WITH CONTEXT
PARAMETERS(CONTEXT,
           WINDOW_SIZE  OCINUMBER,
           WINDOW_SIZE  INDICATOR SB4,
           DBID         OCINUMBER,
           DBID         INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;






PROCEDURE DROP_BASELINE(
            BASELINE_NAME  IN VARCHAR2,
            CASCADE        IN BOOLEAN DEFAULT FALSE,
            DBID           IN NUMBER DEFAULT NULL
            ) IS
EXTERNAL
NAME "kewrpdbn_dropbl_byname"
WITH CONTEXT
PARAMETERS(CONTEXT,
           BASELINE_NAME  OCISTRING,
           BASELINE_NAME  INDICATOR SB4,
           CASCADE        INT,
           CASCADE        INDICATOR SB4,
           DBID           OCINUMBER,
           DBID           INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;







PROCEDURE ADD_COLORED_SQL(
            SQL_ID         IN VARCHAR2,
            DBID           IN NUMBER DEFAULT NULL
            ) IS
EXTERNAL
NAME "kewrpacs_add_colored_sql"
WITH CONTEXT
PARAMETERS(CONTEXT,
           SQL_ID         OCISTRING,
           SQL_ID         INDICATOR SB4,
           DBID           OCINUMBER,
           DBID           INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;







PROCEDURE REMOVE_COLORED_SQL(
            SQL_ID         IN VARCHAR2,
            DBID           IN NUMBER DEFAULT NULL
            ) IS
EXTERNAL
NAME "kewrprcs_remove_colored_sql"
WITH CONTEXT
PARAMETERS(CONTEXT,
           SQL_ID         OCISTRING,
           SQL_ID         INDICATOR SB4,
           DBID           OCINUMBER,
           DBID           INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;








PROCEDURE CREATE_BL_TEMPLATE_CALLOUT(TEMPLATE_TYPE  IN VARCHAR2,
                                     DAY_OF_WEEK    IN VARCHAR2,
                                     HOUR_IN_DAY    IN NUMBER,
                                     DURATION       IN NUMBER,
                                     START_TIME     IN DATE,
                                     END_TIME       IN DATE,
                                     BLNAME         IN VARCHAR2,
                                     BLNAME_PREFIX  IN VARCHAR2,
                                     TEMPLATE_NAME  IN VARCHAR2,
                                     EXPIRATION     IN NUMBER,
                                     DBID           IN NUMBER DEFAULT NULL
                                     ) IS
EXTERNAL
NAME "kewrpcbt_create_bl_template"
WITH CONTEXT
PARAMETERS(CONTEXT,
           TEMPLATE_TYPE  OCISTRING,
           TEMPLATE_TYPE  INDICATOR SB4,
           DAY_OF_WEEK    OCISTRING,
           DAY_OF_WEEK    INDICATOR SB4,
           HOUR_IN_DAY    OCINUMBER,
           HOUR_IN_DAY    INDICATOR SB4,
           DURATION       OCINUMBER,
           DURATION       INDICATOR SB4,
           START_TIME     OCIDATE,
           START_TIME     INDICATOR SB4,
           END_TIME       OCIDATE,
           END_TIME       INDICATOR SB4,
           BLNAME         OCISTRING,
           BLNAME         INDICATOR SB4,
           BLNAME_PREFIX  OCISTRING,
           BLNAME_PREFIX  INDICATOR SB4,
           TEMPLATE_NAME  OCISTRING,
           TEMPLATE_NAME  INDICATOR SB4,
           EXPIRATION     OCINUMBER,
           EXPIRATION     INDICATOR SB4,
           DBID           OCINUMBER,
           DBID           INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;





PROCEDURE CREATE_BASELINE_TEMPLATE(START_TIME     IN DATE,
                                   END_TIME       IN DATE,
                                   BASELINE_NAME  IN VARCHAR2,
                                   TEMPLATE_NAME  IN VARCHAR2,
                                   EXPIRATION     IN NUMBER DEFAULT NULL,
                                   DBID           IN NUMBER DEFAULT NULL
                                   ) IS
BEGIN
  
  CREATE_BL_TEMPLATE_CALLOUT(BL_TEMPLATE_SINGLE,
                             NULL,
                             NULL,
                             NULL,
                             START_TIME,
                             END_TIME,
                             BASELINE_NAME,
                             NULL,
                             TEMPLATE_NAME,
                             EXPIRATION,
                             DBID);
END CREATE_BASELINE_TEMPLATE;





PROCEDURE CREATE_BASELINE_TEMPLATE(DAY_OF_WEEK          IN VARCHAR2,
                                   HOUR_IN_DAY          IN NUMBER,
                                   DURATION             IN NUMBER,
                                   START_TIME           IN DATE,
                                   END_TIME             IN DATE,
                                   BASELINE_NAME_PREFIX IN VARCHAR2,
                                   TEMPLATE_NAME        IN VARCHAR2,
                                   EXPIRATION           IN NUMBER DEFAULT 35,
                                   DBID                 IN NUMBER DEFAULT NULL
                                   ) IS
BEGIN
  
  CREATE_BL_TEMPLATE_CALLOUT(BL_TEMPLATE_REPEATING,
                             UPPER(DAY_OF_WEEK),
                             HOUR_IN_DAY,
                             DURATION,
                             START_TIME,
                             END_TIME,
                             NULL,
                             BASELINE_NAME_PREFIX,
                             TEMPLATE_NAME,
                             EXPIRATION,
                             DBID);
END CREATE_BASELINE_TEMPLATE;





PROCEDURE DROP_BASELINE_TEMPLATE(TEMPLATE_NAME  IN VARCHAR2,
                                 DBID           IN NUMBER DEFAULT NULL
                                 ) IS
EXTERNAL
NAME "kewrpdbt_drop_bl_template"
WITH CONTEXT
PARAMETERS(CONTEXT,
           TEMPLATE_NAME  OCISTRING,
           TEMPLATE_NAME  INDICATOR SB4,
           DBID           OCINUMBER,
           DBID           INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;


 


  FUNCTION AWR_REPORT_TEXT(L_DBID     IN NUMBER,
                       L_INST_NUM IN NUMBER,
                       L_BID      IN NUMBER,
                       L_EID      IN NUMBER,
                       L_OPTIONS  IN NUMBER DEFAULT 0)
  RETURN AWRRPT_TEXT_TYPE_TABLE PIPELINED
  IS
    I NUMBER;
    ARR DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
  BEGIN
    ARR := DBMS_SWRF_REPORT_INTERNAL.AWR_REPORT_MAIN
                (L_DBID, L_INST_NUM, L_BID, L_EID,
                 L_OPTIONS, FALSE);

    FOR I IN ARR.FIRST..ARR.LAST LOOP
        PIPE ROW(AWRRPT_TEXT_TYPE(SUBSTR(ARR(I), 1,
                 DBMS_SWRF_REPORT_INTERNAL.TEXT_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_REPORT_TEXT;

 


  FUNCTION AWR_REPORT_HTML(L_DBID     IN NUMBER,
                       L_INST_NUM IN NUMBER,
                       L_BID      IN NUMBER,
                       L_EID      IN NUMBER,
                       L_OPTIONS  IN NUMBER DEFAULT 0)
  RETURN AWRRPT_HTML_TYPE_TABLE PIPELINED
  IS
    I NUMBER;
    ARR DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
  BEGIN
    ARR := DBMS_SWRF_REPORT_INTERNAL.AWR_REPORT_MAIN(L_DBID, L_INST_NUM, L_BID,
                                                     L_EID, L_OPTIONS, TRUE);

    FOR I IN ARR.FIRST..ARR.LAST LOOP
        PIPE ROW(AWRRPT_HTML_TYPE(SUBSTR(ARR(I), 1,
                 DBMS_SWRF_REPORT_INTERNAL.HTML_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_REPORT_HTML;

 


  FUNCTION AWR_GLOBAL_REPORT_TEXT(L_DBID     IN NUMBER,
                                  L_INST_NUM IN AWRRPT_INSTANCE_LIST_TYPE,
                                  L_BID      IN NUMBER,
                                  L_EID      IN NUMBER,
                                  L_OPTIONS  IN NUMBER DEFAULT 0)
  RETURN AWRDRPT_TEXT_TYPE_TABLE PIPELINED
  IS
    I NUMBER;
    ARR DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
  BEGIN
    ARR := DBMS_SWRF_REPORT_INTERNAL.AWR_GLOBAL_REPORT_MAIN
                (L_DBID, L_INST_NUM, L_BID, L_EID,
                 L_OPTIONS, FALSE);

    FOR I IN ARR.FIRST..ARR.LAST LOOP
        PIPE ROW(AWRDRPT_TEXT_TYPE(SUBSTR(ARR(I), 1,
                 DBMS_SWRF_REPORT_INTERNAL.DD_TEXT_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_GLOBAL_REPORT_TEXT;

  FUNCTION AWR_GLOBAL_REPORT_TEXT(L_DBID     IN NUMBER,
                                  L_INST_NUM IN VARCHAR2,
                                  L_BID      IN NUMBER,
                                  L_EID      IN NUMBER,
                                  L_OPTIONS  IN NUMBER DEFAULT 0)
  RETURN AWRDRPT_TEXT_TYPE_TABLE PIPELINED
  IS
    I         NUMBER;
    ARR       DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
    INST_LIST AWRRPT_INSTANCE_LIST_TYPE := NULL;
  BEGIN
    
    
    
    IF L_INST_NUM IS NOT NULL THEN
      VALIDATE_INSTANCE_LIST(L_INST_NUM, INST_LIST);
    END IF;

    ARR := DBMS_SWRF_REPORT_INTERNAL.AWR_GLOBAL_REPORT_MAIN
                (L_DBID, INST_LIST, L_BID, L_EID,
                 L_OPTIONS, FALSE);

    FOR I IN ARR.FIRST..ARR.LAST LOOP
        PIPE ROW(AWRDRPT_TEXT_TYPE(SUBSTR(ARR(I), 1,
                 DBMS_SWRF_REPORT_INTERNAL.DD_TEXT_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_GLOBAL_REPORT_TEXT;

 


  FUNCTION AWR_GLOBAL_REPORT_HTML(L_DBID     IN NUMBER,
                                  L_INST_NUM IN AWRRPT_INSTANCE_LIST_TYPE,
                                  L_BID      IN NUMBER,
                                  L_EID      IN NUMBER,
                                  L_OPTIONS  IN NUMBER DEFAULT 0)
  RETURN AWRRPT_HTML_TYPE_TABLE PIPELINED
  IS
    I         NUMBER;
    ARR       DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
  BEGIN

    ARR := DBMS_SWRF_REPORT_INTERNAL.AWR_GLOBAL_REPORT_MAIN(L_DBID, L_INST_NUM,
                                                L_BID, L_EID, L_OPTIONS, TRUE);

    FOR I IN ARR.FIRST..ARR.LAST LOOP
        PIPE ROW(AWRRPT_HTML_TYPE(SUBSTR(ARR(I), 1,
                 DBMS_SWRF_REPORT_INTERNAL.HTML_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_GLOBAL_REPORT_HTML;


  FUNCTION AWR_GLOBAL_REPORT_HTML(L_DBID     IN NUMBER,
                                  L_INST_NUM IN VARCHAR2,
                                  L_BID      IN NUMBER,
                                  L_EID      IN NUMBER,
                                  L_OPTIONS  IN NUMBER DEFAULT 0)
  RETURN AWRRPT_HTML_TYPE_TABLE PIPELINED
  IS
    I         NUMBER;
    ARR       DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
    INST_LIST AWRRPT_INSTANCE_LIST_TYPE := NULL;
  BEGIN
    
    
    
    IF L_INST_NUM IS NOT NULL THEN
      VALIDATE_INSTANCE_LIST(L_INST_NUM, INST_LIST);
    END IF;

    ARR := DBMS_SWRF_REPORT_INTERNAL.AWR_GLOBAL_REPORT_MAIN(L_DBID, INST_LIST,
                                                L_BID, L_EID, L_OPTIONS, TRUE);

    FOR I IN ARR.FIRST..ARR.LAST LOOP
        PIPE ROW(AWRRPT_HTML_TYPE(SUBSTR(ARR(I), 1,
                 DBMS_SWRF_REPORT_INTERNAL.HTML_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_GLOBAL_REPORT_HTML;

  
  
  
  
  
  
  
  
  
  
  
  
  
  FUNCTION AWR_SQL_REPORT_TEXT(L_DBID     IN NUMBER,
                               L_INST_NUM IN NUMBER,
                               L_BID      IN NUMBER,
                               L_EID      IN NUMBER,
                               L_SQLID    IN VARCHAR2,
                               L_OPTIONS  IN NUMBER DEFAULT 0)
  RETURN AWRSQRPT_TEXT_TYPE_TABLE PIPELINED
  IS
    I NUMBER;
    ARR DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
  BEGIN
    ARR := DBMS_SWRF_REPORT_INTERNAL.SQL_REPORT_MAIN
                (L_DBID, L_INST_NUM, L_BID, L_EID,L_SQLID,
                 L_OPTIONS, FALSE);

    FOR I IN ARR.FIRST..ARR.LAST LOOP
        PIPE ROW(AWRSQRPT_TEXT_TYPE(SUBSTR(ARR(I), 1,
                 DBMS_SWRF_REPORT_INTERNAL.SQ_TEXT_REPORT_LINESIZE)));
    END LOOP;


    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_SQL_REPORT_TEXT;


  
  
  
  
  
  
  
  
  
  
  
  
  
  FUNCTION AWR_SQL_REPORT_HTML(L_DBID     IN NUMBER,
                               L_INST_NUM IN NUMBER,
                               L_BID      IN NUMBER,
                               L_EID      IN NUMBER,
                               L_SQLID    IN VARCHAR2,
                               L_OPTIONS  IN NUMBER DEFAULT 0)
  RETURN AWRRPT_HTML_TYPE_TABLE PIPELINED
  IS
    I NUMBER;
    ARR DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
  BEGIN
    ARR := DBMS_SWRF_REPORT_INTERNAL.SQL_REPORT_MAIN(L_DBID, L_INST_NUM, L_BID,
                 L_EID, L_SQLID,L_OPTIONS, TRUE);

    FOR I IN ARR.FIRST..ARR.LAST LOOP
        PIPE ROW(AWRRPT_HTML_TYPE(SUBSTR(ARR(I), 1,
                 DBMS_SWRF_REPORT_INTERNAL.HTML_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_SQL_REPORT_HTML;


  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  FUNCTION AWR_DIFF_REPORT_TEXT(DBID1     IN NUMBER,
                                INST_NUM1 IN NUMBER,
                                BID1      IN NUMBER,
                                EID1      IN NUMBER,
                                DBID2     IN NUMBER,
                                INST_NUM2 IN NUMBER,
                                BID2      IN NUMBER,
                                EID2      IN NUMBER)
  RETURN AWRDRPT_TEXT_TYPE_TABLE PIPELINED
  IS

    RPT_OUT DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
    IDX     NUMBER;

  BEGIN

    RPT_OUT := DBMS_SWRF_REPORT_INTERNAL.DIFF_REPORT_MAIN(DBID1, INST_NUM1,
                   BID1, EID1, DBID2, INST_NUM2, BID2, EID2, FALSE);

    FOR IDX IN RPT_OUT.FIRST .. RPT_OUT.LAST LOOP
      PIPE ROW(AWRDRPT_TEXT_TYPE(SUBSTR(RPT_OUT(IDX), 1,
                 DBMS_SWRF_REPORT_INTERNAL.DD_TEXT_REPORT_LINESIZE )));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_DIFF_REPORT_TEXT;

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  FUNCTION AWR_GLOBAL_DIFF_REPORT_TEXT(DBID1     IN NUMBER,
                                INST_NUM1 IN AWRRPT_INSTANCE_LIST_TYPE,
                                BID1      IN NUMBER,
                                EID1      IN NUMBER,
                                DBID2     IN NUMBER,
                                INST_NUM2 IN AWRRPT_INSTANCE_LIST_TYPE,
                                BID2      IN NUMBER,
                                EID2      IN NUMBER)
  RETURN AWRDRPT_TEXT_TYPE_TABLE PIPELINED
  IS

    RPT_OUT DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
    IDX     NUMBER;

  BEGIN

    RPT_OUT := 
      DBMS_SWRF_REPORT_INTERNAL.DIFF_GLOBAL_REPORT_MAIN(DBID1, INST_NUM1,
                        BID1, EID1, DBID2, INST_NUM2, BID2, EID2, FALSE);

    FOR IDX IN RPT_OUT.FIRST .. RPT_OUT.LAST LOOP
      PIPE ROW(AWRDRPT_TEXT_TYPE(SUBSTR(RPT_OUT(IDX), 1,
                 DBMS_SWRF_REPORT_INTERNAL.DD_TEXT_REPORT_LINESIZE )));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_GLOBAL_DIFF_REPORT_TEXT;

  FUNCTION AWR_GLOBAL_DIFF_REPORT_TEXT(DBID1     IN NUMBER,
                                       INST_NUM1 IN VARCHAR2,
                                       BID1      IN NUMBER,
                                       EID1      IN NUMBER,
                                       DBID2     IN NUMBER,
                                       INST_NUM2 IN VARCHAR2,
                                       BID2      IN NUMBER,
                                       EID2      IN NUMBER)
  RETURN AWRDRPT_TEXT_TYPE_TABLE PIPELINED
  IS

    RPT_OUT   DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
    IDX       NUMBER;
    INST_LIST AWRRPT_INSTANCE_LIST_TYPE := NULL;
    INST_LIST2 AWRRPT_INSTANCE_LIST_TYPE := NULL;
  BEGIN
    
    
    
    IF INST_NUM1 IS NOT NULL THEN
      VALIDATE_INSTANCE_LIST(INST_NUM1, INST_LIST);
    END IF;
    
    
    
    IF INST_NUM2 IS NOT NULL THEN
      VALIDATE_INSTANCE_LIST(INST_NUM2, INST_LIST2);
    END IF;
    
    
    
    RPT_OUT :=
      DBMS_SWRF_REPORT_INTERNAL.DIFF_GLOBAL_REPORT_MAIN(DBID1, INST_LIST,
                        BID1, EID1, DBID2, INST_LIST2, BID2, EID2, FALSE);

    FOR IDX IN RPT_OUT.FIRST .. RPT_OUT.LAST LOOP
      PIPE ROW(AWRDRPT_TEXT_TYPE(SUBSTR(RPT_OUT(IDX), 1,
                 DBMS_SWRF_REPORT_INTERNAL.DD_TEXT_REPORT_LINESIZE )));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_GLOBAL_DIFF_REPORT_TEXT;


  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  FUNCTION AWR_DIFF_REPORT_HTML(DBID1     IN NUMBER,
                                INST_NUM1 IN NUMBER,
                                BID1      IN NUMBER,
                                EID1      IN NUMBER,
                                DBID2     IN NUMBER,
                                INST_NUM2 IN NUMBER,
                                BID2      IN NUMBER,
                                EID2      IN NUMBER)
  RETURN AWRRPT_HTML_TYPE_TABLE PIPELINED
  IS

    RPT_OUT DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
    IDX     NUMBER;

  BEGIN

    RPT_OUT := DBMS_SWRF_REPORT_INTERNAL.DIFF_REPORT_MAIN(DBID1, INST_NUM1,
                   BID1, EID1, DBID2, INST_NUM2, BID2, EID2, TRUE);

    FOR IDX IN RPT_OUT.FIRST .. RPT_OUT.LAST LOOP
      PIPE ROW(AWRRPT_HTML_TYPE(SUBSTR(RPT_OUT(IDX), 1,
                 DBMS_SWRF_REPORT_INTERNAL.HTML_REPORT_LINESIZE )));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_DIFF_REPORT_HTML;


  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  FUNCTION AWR_GLOBAL_DIFF_REPORT_HTML(DBID1     IN NUMBER,
                                INST_NUM1 IN AWRRPT_INSTANCE_LIST_TYPE,
                                BID1      IN NUMBER,
                                EID1      IN NUMBER,
                                DBID2     IN NUMBER,
                                INST_NUM2 IN AWRRPT_INSTANCE_LIST_TYPE,
                                BID2      IN NUMBER,
                                EID2      IN NUMBER)
  RETURN AWRRPT_HTML_TYPE_TABLE PIPELINED
  IS

    RPT_OUT DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
    IDX     NUMBER;

  BEGIN

    RPT_OUT :=
       DBMS_SWRF_REPORT_INTERNAL.DIFF_GLOBAL_REPORT_MAIN(DBID1, INST_NUM1,
                   BID1, EID1, DBID2, INST_NUM2, BID2, EID2, TRUE);

    FOR IDX IN RPT_OUT.FIRST .. RPT_OUT.LAST LOOP
      PIPE ROW(AWRRPT_HTML_TYPE(SUBSTR(RPT_OUT(IDX), 1,
                 DBMS_SWRF_REPORT_INTERNAL.HTML_REPORT_LINESIZE )));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_GLOBAL_DIFF_REPORT_HTML;

  FUNCTION AWR_GLOBAL_DIFF_REPORT_HTML(DBID1     IN NUMBER,
                                       INST_NUM1 IN VARCHAR2,
                                       BID1      IN NUMBER,
                                       EID1      IN NUMBER,
                                       DBID2     IN NUMBER,
                                       INST_NUM2 IN VARCHAR2,
                                       BID2      IN NUMBER,
                                       EID2      IN NUMBER)
  RETURN AWRRPT_HTML_TYPE_TABLE PIPELINED
  IS

    RPT_OUT   DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
    IDX       NUMBER;
    INST_LIST AWRRPT_INSTANCE_LIST_TYPE := NULL;
    INST_LIST2 AWRRPT_INSTANCE_LIST_TYPE := NULL;
  BEGIN
    
    
    
    IF INST_NUM1 IS NOT NULL THEN
      VALIDATE_INSTANCE_LIST(INST_NUM1, INST_LIST);
    END IF;
    
    
    
    IF INST_NUM2 IS NOT NULL THEN
      VALIDATE_INSTANCE_LIST(INST_NUM2, INST_LIST2);
    END IF;
    
    
    
    RPT_OUT :=
       DBMS_SWRF_REPORT_INTERNAL.DIFF_GLOBAL_REPORT_MAIN(DBID1, INST_LIST,
                   BID1, EID1, DBID2, INST_LIST2, BID2, EID2, TRUE);

    FOR IDX IN RPT_OUT.FIRST .. RPT_OUT.LAST LOOP
      PIPE ROW(AWRRPT_HTML_TYPE(SUBSTR(RPT_OUT(IDX), 1,
                 DBMS_SWRF_REPORT_INTERNAL.HTML_REPORT_LINESIZE )));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

  END AWR_GLOBAL_DIFF_REPORT_HTML;


 


  FUNCTION ASH_GLOBAL_REPORT_TEXT(L_DBID          IN NUMBER,
                                  L_INST_NUM      IN VARCHAR2,
                                  L_BTIME         IN DATE,
                                  L_ETIME         IN DATE,
                                  L_OPTIONS       IN NUMBER    DEFAULT 0,
                                  L_SLOT_WIDTH    IN NUMBER    DEFAULT 0,
                                  L_SID           IN NUMBER    DEFAULT NULL,
                                  L_SQL_ID        IN VARCHAR2  DEFAULT NULL,
                                  L_WAIT_CLASS    IN VARCHAR2  DEFAULT NULL,
                                  L_SERVICE_HASH  IN NUMBER    DEFAULT NULL,
                                  L_MODULE        IN VARCHAR2  DEFAULT NULL,
                                  L_ACTION        IN VARCHAR2  DEFAULT NULL,
                                  L_CLIENT_ID     IN VARCHAR2  DEFAULT NULL,
                                  L_PLSQL_ENTRY   IN VARCHAR2  DEFAULT NULL,
                                  L_DATA_SRC      IN NUMBER    DEFAULT 0,
                                  L_CONTAINER     IN VARCHAR2  DEFAULT NULL
                                 )
  RETURN AWRDRPT_TEXT_TYPE_TABLE PIPELINED
  IS
    I   NUMBER;
    ARR DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
    INST_OUT AWRRPT_INSTANCE_LIST_TYPE := NULL;
  BEGIN
    
    
    
    IF L_INST_NUM IS NOT NULL THEN
      VALIDATE_INSTANCE_LIST(L_INST_NUM, INST_OUT);
    END IF;

    ARR := DBMS_SWRF_REPORT_INTERNAL.ASH_GLOBAL_REPORT_MAIN
                ( L_DBID, INST_OUT, L_BTIME, L_ETIME,
                  L_OPTIONS, L_SLOT_WIDTH, FALSE,
                  L_SID, L_SQL_ID, L_WAIT_CLASS,
                  L_SERVICE_HASH, L_MODULE, L_ACTION, L_CLIENT_ID,
                  L_PLSQL_ENTRY,  
                  0, 
                  L_CONTAINER);

    FOR I IN ARR.FIRST..ARR.LAST LOOP
      PIPE ROW(AWRDRPT_TEXT_TYPE(SUBSTR(ARR(I), 1,
               DBMS_SWRF_REPORT_INTERNAL.DD_TEXT_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

    RETURN;

  END ASH_GLOBAL_REPORT_TEXT;

 


  FUNCTION ASH_GLOBAL_REPORT_HTML(L_DBID          IN NUMBER,
                                  L_INST_NUM      IN VARCHAR2,
                                  L_BTIME         IN DATE,
                                  L_ETIME         IN DATE,
                                  L_OPTIONS       IN NUMBER    DEFAULT 0,
                                  L_SLOT_WIDTH    IN NUMBER    DEFAULT 0,
                                  L_SID           IN NUMBER    DEFAULT NULL,
                                  L_SQL_ID        IN VARCHAR2  DEFAULT NULL,
                                  L_WAIT_CLASS    IN VARCHAR2  DEFAULT NULL,
                                  L_SERVICE_HASH  IN NUMBER    DEFAULT NULL,
                                  L_MODULE        IN VARCHAR2  DEFAULT NULL,
                                  L_ACTION        IN VARCHAR2  DEFAULT NULL,
                                  L_CLIENT_ID     IN VARCHAR2  DEFAULT NULL,
                                  L_PLSQL_ENTRY   IN VARCHAR2  DEFAULT NULL,
                                  L_DATA_SRC      IN NUMBER    DEFAULT 0,
                                  L_CONTAINER     IN VARCHAR2  DEFAULT NULL
                                 )
  RETURN AWRRPT_HTML_TYPE_TABLE PIPELINED
  IS
    I   NUMBER;
    ARR DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
    INST_OUT AWRRPT_INSTANCE_LIST_TYPE := NULL;
  BEGIN
    
    
    
    IF L_INST_NUM IS NOT NULL THEN
      VALIDATE_INSTANCE_LIST(L_INST_NUM, INST_OUT);
    END IF;

    ARR := DBMS_SWRF_REPORT_INTERNAL.ASH_GLOBAL_REPORT_MAIN
                ( L_DBID, INST_OUT, L_BTIME, L_ETIME,
                  L_OPTIONS, L_SLOT_WIDTH, TRUE,
                  L_SID, L_SQL_ID, L_WAIT_CLASS,
                  L_SERVICE_HASH, L_MODULE, L_ACTION, L_CLIENT_ID,
                  L_PLSQL_ENTRY,  
                  0, 
                  L_CONTAINER);

    FOR I IN ARR.FIRST..ARR.LAST LOOP
      PIPE ROW(AWRRPT_HTML_TYPE(SUBSTR(ARR(I), 1,
                 DBMS_SWRF_REPORT_INTERNAL.HTML_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

    RETURN;

  END ASH_GLOBAL_REPORT_HTML;

 


  FUNCTION ASH_REPORT_TEXT(L_DBID          IN NUMBER,
                           L_INST_NUM      IN NUMBER,
                           L_BTIME         IN DATE,
                           L_ETIME         IN DATE,
                           L_OPTIONS       IN NUMBER    DEFAULT 0,
                           L_SLOT_WIDTH    IN NUMBER    DEFAULT 0,
                           L_SID           IN NUMBER    DEFAULT NULL,
                           L_SQL_ID        IN VARCHAR2  DEFAULT NULL,
                           L_WAIT_CLASS    IN VARCHAR2  DEFAULT NULL,
                           L_SERVICE_HASH  IN NUMBER    DEFAULT NULL,
                           L_MODULE        IN VARCHAR2  DEFAULT NULL,
                           L_ACTION        IN VARCHAR2  DEFAULT NULL,
                           L_CLIENT_ID     IN VARCHAR2  DEFAULT NULL,
                           L_PLSQL_ENTRY   IN VARCHAR2  DEFAULT NULL,
                           L_DATA_SRC      IN NUMBER    DEFAULT 0,
                           L_CONTAINER     IN VARCHAR2  DEFAULT NULL
                          )
  RETURN AWRRPT_TEXT_TYPE_TABLE PIPELINED
  IS
    I   NUMBER;
    ARR DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
  BEGIN
    ARR := DBMS_SWRF_REPORT_INTERNAL.ASH_REPORT_MAIN
                ( L_DBID, L_INST_NUM, L_BTIME, L_ETIME,
                  L_OPTIONS, L_SLOT_WIDTH, FALSE,
                  L_SID, L_SQL_ID, L_WAIT_CLASS,
                  L_SERVICE_HASH, L_MODULE, L_ACTION, L_CLIENT_ID,
                  L_PLSQL_ENTRY, L_DATA_SRC, L_CONTAINER );

    FOR I IN ARR.FIRST..ARR.LAST LOOP
      PIPE ROW(AWRRPT_TEXT_TYPE(SUBSTR(ARR(I), 1,
               DBMS_SWRF_REPORT_INTERNAL.TEXT_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

    RETURN;

  END ASH_REPORT_TEXT;

 


  FUNCTION ASH_REPORT_HTML(L_DBID          IN NUMBER,
                           L_INST_NUM      IN NUMBER,
                           L_BTIME         IN DATE,
                           L_ETIME         IN DATE,
                           L_OPTIONS       IN NUMBER    DEFAULT 0,
                           L_SLOT_WIDTH    IN NUMBER    DEFAULT 0,
                           L_SID           IN NUMBER    DEFAULT NULL,
                           L_SQL_ID        IN VARCHAR2  DEFAULT NULL,
                           L_WAIT_CLASS    IN VARCHAR2  DEFAULT NULL,
                           L_SERVICE_HASH  IN NUMBER    DEFAULT NULL,
                           L_MODULE        IN VARCHAR2  DEFAULT NULL,
                           L_ACTION        IN VARCHAR2  DEFAULT NULL,
                           L_CLIENT_ID     IN VARCHAR2  DEFAULT NULL,
                           L_PLSQL_ENTRY   IN VARCHAR2  DEFAULT NULL,
                           L_DATA_SRC      IN NUMBER    DEFAULT 0,
                           L_CONTAINER     IN VARCHAR2  DEFAULT NULL
                          )
  RETURN AWRRPT_HTML_TYPE_TABLE PIPELINED
  IS
    I   NUMBER;
    ARR DBMS_SWRF_REPORT_INTERNAL.OUTPUT_TABLE;
  BEGIN
    ARR := DBMS_SWRF_REPORT_INTERNAL.ASH_REPORT_MAIN
                ( L_DBID, L_INST_NUM, L_BTIME, L_ETIME,
                  L_OPTIONS, L_SLOT_WIDTH, TRUE,
                  L_SID, L_SQL_ID, L_WAIT_CLASS,
                  L_SERVICE_HASH, L_MODULE, L_ACTION, L_CLIENT_ID,
                  L_PLSQL_ENTRY, L_DATA_SRC, L_CONTAINER );

    FOR I IN ARR.FIRST..ARR.LAST LOOP
      PIPE ROW(AWRRPT_HTML_TYPE(SUBSTR(ARR(I), 1,
                 DBMS_SWRF_REPORT_INTERNAL.HTML_REPORT_LINESIZE)));
    END LOOP;

    DBMS_SWRF_REPORT_INTERNAL.REPORT_CLEANUP();

    RETURN;

  END ASH_REPORT_HTML;

  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  FUNCTION ASH_REPORT_ANALYTICS(DBID         IN  NUMBER   := NULL, 
                                INST_ID      IN  NUMBER   := NULL, 
                                BEGIN_TIME   IN  DATE,
                                END_TIME     IN  DATE,
                                REPORT_LEVEL IN  VARCHAR2 := NULL, 
                                FILTER_LIST  IN  VARCHAR2 := NULL)
  RETURN CLOB
  IS 
    REPORT_XML  XMLTYPE;
    REPORT_CLOB CLOB;
  BEGIN 

    
    REPORT_XML := DBMS_ASH_INTERNAL.REPORT_ASHVIEWER_XML(
                    DBID => DBID, 
                    INST_ID => INST_ID, 
                    BEGIN_TIME => TO_CHAR(BEGIN_TIME, 'HH24:MI:SS MM/DD/YYYY'), 
                    END_TIME => TO_CHAR(END_TIME, 'HH24:MI:SS MM/DD/YYYY'), 
                    REPORT_LEVEL => REPORT_LEVEL, 
                    FILTER_LIST => FILTER_LIST);

    
    IF (REPORT_XML IS NULL) THEN
      RETURN NULL;
    END IF;

    
    REPORT_CLOB := DBMS_REPORT.FORMAT_REPORT(REPORT_XML, 'ACTIVE');

    
    RETURN REPORT_CLOB;

  END ASH_REPORT_ANALYTICS; 




PROCEDURE CONTROL_RESTRICTED_SNAPSHOT(ALLOW IN BOOLEAN) IS
EXTERNAL
NAME "kewrpcrs_ctl_restricted_snap"
WITH CONTEXT
PARAMETERS(CONTEXT,
           ALLOW        INT,
           ALLOW        INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;




PROCEDURE PURGE_SQL_DETAILS(NUMROWS IN NUMBER DEFAULT NULL,
                            DBID    IN NUMBER DEFAULT NULL) IS
EXTERNAL
NAME "kewrpsd_purge_sql_details"
WITH CONTEXT
PARAMETERS(CONTEXT,
           NUMROWS      OCINUMBER,
           NUMROWS      INDICATOR SB4,
           DBID         OCINUMBER,
           DBID         INDICATOR SB4)
LIBRARY DBMS_SWRF_LIB;

PROCEDURE AWR_SET_REPORT_THRESHOLDS(TOP_N_EVENTS       IN NUMBER DEFAULT NULL,
                                    TOP_N_FILES        IN NUMBER DEFAULT NULL,
                                    TOP_N_SEGMENTS     IN NUMBER DEFAULT NULL,
                                    TOP_N_SERVICES     IN NUMBER DEFAULT NULL,
                                    TOP_N_SQL          IN NUMBER DEFAULT NULL, 
                                    TOP_N_SQL_MAX      IN NUMBER DEFAULT NULL,
                                    TOP_SQL_PCT        IN NUMBER DEFAULT NULL,
                                    SHMEM_THRESHOLD    IN NUMBER DEFAULT NULL,
                                    VERSIONS_THRESHOLD IN NUMBER DEFAULT NULL,
                                    TOP_N_DISKS        IN NUMBER DEFAULT NULL,
                                    OUTLIER_PCT        IN NUMBER DEFAULT NULL,
                                    OUTLIER_CPU_PCT    IN NUMBER DEFAULT NULL)
IS
BEGIN
   DBMS_SWRF_REPORT_INTERNAL.SET_REPORT_THRESHOLDS(
     EVENTS=>TOP_N_EVENTS,
     FILES=>TOP_N_FILES,
     SEGMENTS=>TOP_N_SEGMENTS,
     SERVICES=>TOP_N_SERVICES,
     TSQLMIN=>TOP_N_SQL,
     TSQLMAX=>TOP_N_SQL_MAX,
     SQLPCT=>TOP_SQL_PCT,
     SHMEM=>SHMEM_THRESHOLD,
     VERSIONS=>VERSIONS_THRESHOLD,
     TDISKS=>TOP_N_DISKS,
     OUTLIER_PCT=>OUTLIER_PCT,
     OUTLIER_CPU_PCT=>OUTLIER_CPU_PCT);
END AWR_SET_REPORT_THRESHOLDS;




PROCEDURE UPDATE_OBJECT_INFO( MAXROWS    NUMBER  DEFAULT  0)
 IS
BEGIN
   DBMS_SWRF_INTERNAL.UPDATE_OBJECT_INFO(MAXROWS);
EXCEPTION 
   WHEN OTHERS THEN RAISE;
  
END UPDATE_OBJECT_INFO;
    
  
  
  
  PROCEDURE UPDATE_DATAFILE_INFO
  IS
  BEGIN
    DBMS_SWRF_INTERNAL.UPDATE_DATAFILE_INFO;
  EXCEPTION
    WHEN OTHERS THEN RAISE;

  END UPDATE_DATAFILE_INFO;   

END;                   