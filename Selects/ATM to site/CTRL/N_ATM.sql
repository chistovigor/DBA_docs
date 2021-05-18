-- выборка только банкоматов, онлайн, в сервисе, не в супервизоре

  SELECT DISTINCT TO_NUMBER (SUBSTR (szname,
                                     1,
                                       INSTR (szname,
                                              ' ',
                                              1,
                                              1)
                                     - 1))
                     AS C_NATM_CTRL
    FROM (SELECT DISTINCT robj, szname
            FROM objlist
           WHERE ltag = 100
          MINUS
          SELECT DISTINCT robj, szname
            FROM objlist
           WHERE robj IN
                    (SELECT ratm
                       FROM amattr
                      WHERE    (robj = 4113 AND lindex = 26 AND rvalue = 0)
                            OR (robj = 4102 AND rvalue = 1))
          INTERSECT
          SELECT DISTINCT b.ROBJ, b.szname
            FROM obj2ip a, objlist b
           WHERE     a.lstatus = 1
                 AND a.ROBJ = b.ROBJ
                 AND LOWER (b.szname) NOT LIKE '%блокирован%'
                 AND b.szname NOT IN ('NDC', 'DDC'))
ORDER BY 1;

-- выборка только банкоматов онлайн

  SELECT DISTINCT TO_NUMBER(SUBSTR (b.szname,
                          1,
                            INSTR (b.szname,
                                   ' ',
                                   1,
                                   1)
                          - 1))
                     AS C_NATM_CTRL
    FROM obj2ip a, objlist b
   WHERE     a.lstatus = 1
         AND a.ROBJ = b.ROBJ
         AND LOWER (b.szname) NOT LIKE '%блокирован%'
         AND b.szname NOT IN ('NDC', 'DDC')
ORDER BY 1;

-- выборка всех с текущим статусом 0 - недоступен для клиентов ,1 - доступен для клиентов

SELECT 0 AS status, C_NATM_CTRL
  FROM (SELECT DISTINCT TO_NUMBER (SUBSTR (szname,
                                           1,
                                           INSTR (szname,
                                                  ' ',
                                                  1,
                                                  1)
                                           - 1))
                           AS C_NATM_CTRL
          FROM (SELECT robj, szname
                  FROM objlist
                 WHERE ltag = 100
                       AND LOWER (szname) NOT LIKE '%блокирован%'
                       AND szname NOT IN
                              ('NDC',
                               'DDC',
                               '0000 (ХАБ) Город, Адрес, Компания Cash-in                                                                                       '))
        MINUS
        SELECT DISTINCT TO_NUMBER (SUBSTR (szname,
                                           1,
                                           INSTR (szname,
                                                  ' ',
                                                  1,
                                                  1)
                                           - 1))
                           AS C_NATM_CTRL
          FROM (SELECT DISTINCT robj, szname
                  FROM objlist
                 WHERE ltag = 100
                MINUS
                SELECT DISTINCT robj, szname
                  FROM objlist
                 WHERE robj IN
                          (SELECT ratm
                             FROM amattr
                            WHERE (robj = 4113 AND lindex = 26 AND rvalue = 0)
                                  OR (robj = 4102 AND rvalue = 1))
                INTERSECT
                SELECT DISTINCT b.ROBJ, b.szname
                  FROM obj2ip a, objlist b
                 WHERE     a.lstatus = 1
                       AND a.ROBJ = b.ROBJ
                       AND LOWER (b.szname) NOT LIKE '%блокирован%'
                       AND b.szname NOT IN
                              ('NDC',
                               'DDC',
                               '0000 (ХАБ) Город, Адрес, Компания Cash-in                                                                                       ')))
UNION ALL
SELECT 1 AS status, C_NATM_CTRL
  FROM (SELECT DISTINCT TO_NUMBER (SUBSTR (szname,
                                           1,
                                           INSTR (szname,
                                                  ' ',
                                                  1,
                                                  1)
                                           - 1))
                           AS C_NATM_CTRL
          FROM (SELECT DISTINCT robj, szname
                  FROM objlist
                 WHERE ltag = 100
                MINUS
                SELECT DISTINCT robj, szname
                  FROM objlist
                 WHERE robj IN
                          (SELECT ratm
                             FROM amattr
                            WHERE (robj = 4113 AND lindex = 26 AND rvalue = 0)
                                  OR (robj = 4102 AND rvalue = 1))
                INTERSECT
                SELECT DISTINCT b.ROBJ, b.szname
                  FROM obj2ip a, objlist b
                 WHERE     a.lstatus = 1
                       AND a.ROBJ = b.ROBJ
                       AND LOWER (b.szname) NOT LIKE '%блокирован%'
                       AND b.szname NOT IN
                              ('NDC',
                               'DDC',
                               '0000 (ХАБ) Город, Адрес, Компания Cash-in                                                                                       ')))
ORDER BY 1, 2;



/* Formatted on 04.03.2014 13:03:56 (QP5 v5.227.12220.39754) */
  SELECT DISTINCT a.ROBJ,
                  b.SZNAME,
                  SUBSTR (b.szname,
                          1,
                            INSTR (b.szname,
                                   ' ',
                                   1,
                                   1)
                          - 1)
                     AS C_NATM_CTRL
    FROM obj2ip a, objlist b
   WHERE     a.lstatus = 1
         AND a.ROBJ = b.ROBJ
         AND LOWER (b.szname) NOT LIKE '%блокирован%'
         AND b.szname NOT IN ('NDC', 'DDC')
ORDER BY 3;

