/* Formatted on 16/10/2014 16:35:57 (QP5 v5.227.12220.39754) */
SELECT hostname,
       LOWER ('ultradb.' || key) AS key,
       timestamp,
       VALUE
  FROM (SELECT 's-msk08-ultra-la' AS hostname FROM DUAL),
       (SELECT *
          FROM (SELECT *
                  FROM (SELECT COUNT (
                                  CASE WHEN a.state = 5 THEN 1 ELSE NULL END)
                                  AS v_st_suc,
                               COUNT (
                                  CASE
                                     WHEN a.state IN (0, 6) THEN 1
                                     ELSE NULL
                                  END)
                                  AS v_st_ecom_err,
                               COUNT (
                                  CASE
                                     WHEN a.state IN (8, 9, 14) THEN 1
                                     ELSE NULL
                                  END)
                                  AS v_st_lim_err,
                               COUNT (
                                  CASE
                                     WHEN a.state IN (7, 12, 13, 15, 16)
                                     THEN
                                        1
                                     ELSE
                                        NULL
                                  END)
                                  AS v_st_rc_err
                          FROM rc_vsmc.vmt_requests a
                         WHERE     a.upd_date >=
                                      TRUNC (SYSDATE, 'MI') - 2 / 24 / 60
                               AND a.upd_date <
                                      TRUNC (SYSDATE, 'MI') - 1 / 24 / 60) vmt_trns) UNPIVOT (VALUE
                                                                                     FOR key
                                                                                     IN  (v_st_suc,
                                                                                         v_st_ecom_err,
                                                                                         v_st_lim_err,
                                                                                         v_st_rc_err)),
               (SELECT TO_NUMBER (
                            (  TRUNC (SYSDATE, 'MI')
                             - 1 / 6
                             - 1 / 24 / 60
                             - TO_DATE ('01/01/1970 00:00:00',
                                        'MM-DD-YYYY HH24:MI:SS'))
                          * 24
                          * 60
                          * 60)
                          AS timestamp
                  FROM DUAL))