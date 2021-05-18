-- connected locked users

SELECT SID,
       SERIAL#,
       USERNAME,
       STATUS,
       LOGON_TIME
  FROM V$SESSION
 WHERE USERNAME IN (SELECT USERNAME
                      FROM DBA_USERS
                     WHERE ACCOUNT_STATUS <> 'OPEN');

-- запуск после выдачи прав в STIMKIT

DECLARE 
V_RESULT VARCHAR2(3000);
BEGIN
V_RESULT:=IDM_AUTH_PR.SYNC_USERS;
DBMS_OUTPUT.PUT_LINE(V_RESULT);
COMMIT;
END;

-- доступ к группам данных

--CREATE ROLE R_SELECT_ON_VTD_GR_4_5; --анонимные данные ВТД
select 'grant select on '||VIEW_OWNER||'.'||INTERNALDM||' TO &GRANTEE_NAME;' from INTERNALDM_ADMIN.internaldm_views where infosec_group_id in (4,5) ORDER BY VIEW_OWNER,INTERNALDM;

-- GRANT ACCESS TO SCHEMA OBJECTS

CREATE ROLE R_INTERNALDM_URZH;

  SELECT 'grant select on ' || OWNER || '.' || OBJECT_NAME || ' to R_INTERNALDM_URZH;'
    FROM ALL_OBJECTS D
   WHERE     D.OBJECT_TYPE IN ('TABLE', 'VIEW', 'MATERIALIZED VIEW')
         AND D.OBJECT_NAME LIKE 'V_URZH%'
         AND D.OWNER IN ('INTERNALDM')
ORDER BY OWNER, OBJECT_TYPE, OBJECT_NAME;

GRANT R_INTERNALDM_URZH TO ANALITIC;

-- ACL

-- просмотр существующих листов:
SELECT * FROM dba_network_acls order by 1,4;

--для конкретного пользователя:
SELECT * FROM dba_network_acl_privileges WHERE principal = 'MONITOR_PROD';
 
--2) создание листа

BEGIN
   DBMS_NETWORK_ACL_ADMIN.create_acl (acl           => 'monitor_prod_permissions.xml', -- or any other file name
                                      description   => 'network access',
                                      principal     => 'BPEL', -- the user name trying to access the network resource
                                      is_grant      => TRUE,
                                      privilege     => 'connect',
                                      start_date    => NULL,
                                      end_date      => NULL);
END;
/
commit;

--3) Добавление разрешений для пользователя в лист

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'monitor_prod_permissions.xml',
                                         principal   => 'BPEL',
                                         is_grant    => TRUE,
                                         privilege   => 'connect');
END;
/

COMMIT;

BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (acl         => 'monitor_permissions.xml',
                                         principal   => 'BPEL',
                                         is_grant    => TRUE,
                                         privilege   => 'resolve');
END;
/

COMMIT;

--4) Добавление сервера в лист (Only one ACL can be assigned to a specific host and port-range combination)

BEGIN
   DBMS_NETWORK_ACL_ADMIN.assign_acl (acl          => 'monitor_prod_permissions.xml',
                                      HOST         => '172.20.195.152',
                                      lower_port   => 15555,
                                      upper_port   => 15555);
END;
/

COMMIT;

--5) Добавление разрешений пользователю (можно не запускать):

grant execute on UTL_SMTP  to BPEL;
grant execute on UTL_TCP   to BPEL;
grant execute on UTL_INADDR   to BPEL;
grant execute on UTL_HTTP   to BPEL;

-- USERS ACCESS

--Вывод всех несистемных пользователей и их привелегий для всех объектов

  SELECT *
    FROM (SELECT U.USERNAME,
                 UP.OWNER    OBJECT_OWNER,
                 UP.TABLE_NAME OBJECT_NAME,
                 'DIRECT'    GRANT_DIRECT_OR_WITH_ROLE,
                 UP.GRANTABLE
            FROM DBA_USERS U, DBA_TAB_PRIVS UP
           WHERE     U.USERNAME = UP.GRANTEE
                 AND UP.PRIVILEGE IN ('SELECT',
                                      'UPDATE',
                                      'INSERT',
                                      'DELETE')
                 AND UP.OWNER NOT LIKE '%SYS%'
                 AND U.ACCOUNT_STATUS = 'OPEN'
                 AND U.USERNAME NOT IN ('SYS', 'SYSTEM')
          UNION
          SELECT U.USERNAME,
                 UP.OWNER    OBJECT_OWNER,
                 UP.TABLE_NAME OBJECT_NAME,
                 UP.GRANTEE,
                 UP.GRANTABLE
            FROM DBA_USERS U, DBA_ROLE_PRIVS R, DBA_TAB_PRIVS UP
           WHERE     U.USERNAME = R.GRANTEE
                 AND R.GRANTED_ROLE = UP.GRANTEE
                 AND UP.PRIVILEGE IN ('SELECT',
                                      'UPDATE',
                                      'INSERT',
                                      'DELETE')
                 AND UP.OWNER NOT LIKE '%SYS%'
                 AND U.ACCOUNT_STATUS = 'OPEN'
                 AND U.USERNAME NOT IN ('SYS', 'SYSTEM')) A
   WHERE     A.USERNAME NOT IN ('ARDB_USER',
                                'BL',
                                'CBSYSUSER',
                                'CURR',
                                'EQ',
                                'DAKR',
                                'DDL_MONITORING',
                                'FINDATA',
                                'ICDB',
                                'KBDUSER')
         AND A.USERNAME NOT LIKE 'INTERNAL%'
         AND A.USERNAME NOT LIKE 'LOADER%'
         AND A.USERNAME NOT LIKE 'MOSCOW_EXCHANGE%'
         AND A.USERNAME NOT LIKE 'FINANCE_INT%'
         AND A.OBJECT_OWNER || '.' || A.OBJECT_NAME IN --объекты с неагрегированными сделками для согласования с безопасностью
                ('BL.TRADES_BASE',
                 'EQ.EXTTRADES_BASE',
                 'CURR.TRADES_BASE',
                 'EQ.REFUND_BASE',
                 'FORTS_AR.FUT_AR_REPOTRADE_BASE',
                 'FORTS_CLEARING.DEAL_BASE',
                 'FORTS_JAVA.ADJUSTED_FEE_BASE',
                 'EQ.TRADES_BASE',
                 'FORTS_JAVA.OTC_DEALS_REPL_LOG_BASE',
                 'FORTS_JAVA.FUTDEAL_BASE',
                 'SPUR_DAY.EXTTRADES',
                 'SPUR_DAY.TRADES',
                 'SPUR_DAY_CU.TRADES',
                 'EQ.RPT40_BASE',
                 'EQ.REP40_BASE',
                 'EQ.REPOTRADEHIST_BASE''EQ.V_TRADES_BASE',
                 'SPUR.V_EQ_PARTICIPANT_VAL',
                 'CURR.V_TRADES_BASE',
                 'SPUR.V_MM_EURUSDSTATS01',
                 'EQ.V_TRADES_BASE',
                 'EQ.V_TRADES_BASE_EXA',
                 'SPUR_DAY.MONITOR_ONLINE',
                 'CURR.V_TRADES_BASE',
                 'SPUR_DAY.MONITOR_ONLINE',
                 'CURR.V_TRADES_BASE_EXA',
                 'INTERNALREP.V_FOAR_FUT_REPOTRADE',
                 'DMV.MULTILEG_DEAL_874866',
                 'FORTS_JAVA.V_FORTS_ADJUSTED_FEE',
                 'INTERNALREP.V_FORTS_ADJUSTED_FEE',
                 'TLDWH.TRADE',
                 'INTERNALDM.V_BL_TRADES',
                 'INTERNALDM.V_EQ_REFUND',
                 'INTERNALDM.V_EQ_EXTTRADES',
                 'INTERNALDM.V_EQ_RPT40',
                 'EQ.V_EQ_REP40',
                 'INTERNALDM.V_EQ_REP40',
                 'INTERNALDM.V_EQ_REPOTRADEHIST',
                 'INTERNALREP.V_FORTS_FUT_DEAL',
                 'INTERNALDM.V_FORTS_TRADES_FU',
                 'FORTS_JAVA.V_FORTS_FUT_DEAL',
                 'INTERNALREP.V_FORTS_OTC_DEALS_REPL_LOG',
                 'INTERNALDM.V_EX_RTS_TRADES',
                 'FORTS_JAVA.V_FORTS_OTC_DEALS_REPL_LOG',
                 'DMV.OPTDEAL_BASE_729535_1M',
                 'DMV.OPTDEAL_BASE_729535',
                 'INTERNALREP.V_FRPA_DEALS_FU',
                 'INTERNALREP.V_FCLR_DEAL',
                 'INTERNALREP.V_FRPA_DEALS_OP',
                 'TLDWH.TRADE',
                 'SPUR.V_FO_TRADES',
                 'DMV.FUTDEAL_BASE_310684',
                 'DMV.FUT_AR_DEAL_BASE_38084_1M',
                 'DMV.OPT_AR_DEAL_BASE_516634',
                 'DMV.FUT_AR_DEAL_BASE_38084',
                 'DMV.OPT_AR_DEAL_BASE_516634_1M',
                 'DMV.FUTDEAL_BASE_310684_1M')
ORDER BY 1, 2, 3;

select ''''||OWNER||'.'||NAME||''',' from all_dependencies where REFERENCED_OWNER||'.'||REFERENCED_NAME in ('BL.TRADES_BASE',
             'EQ.EXTTRADES_BASE',
             'CURR.TRADES_BASE',
             'EQ.REFUND_BASE',
             'FORTS_AR.FUT_AR_REPOTRADE_BASE',
             'FORTS_CLEARING.DEAL_BASE',
             'FORTS_JAVA.ADJUSTED_FEE_BASE',
             'EQ.TRADES_BASE',
             'FORTS_JAVA.OTC_DEALS_REPL_LOG_BASE',
             'FORTS_JAVA.FUTDEAL_BASE',
             'SPUR_DAY.EXTTRADES',
             'SPUR_DAY.TRADES',
             'SPUR_DAY_CU.TRADES',
             'EQ.RPT40_BASE',
             'EQ.REP40_BASE',
             'EQ.REPOTRADEHIST_BASE') AND TYPE = 'VIEW';

SELECT * FROM DBA_USERS;
SELECT * FROM DBA_ROLE_PRIVS order by 1,2;
SELECT * FROM DBA_TAB_PRIVS where GRANTEE LIKE 'R%';
SELECT * FROM ROLE_TAB_PRIVS;

