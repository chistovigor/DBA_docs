-- В БД Alpha

  SELECT C_NATM
    FROM ATM_ALPHA
   WHERE timestamp > SYSDATE - 1
ORDER BY 1;

-- номера из Альфы

  SELECT TO_NUMBER (NVL ( (SUBSTR (C_NATM,
                                   1,
                                     INSTR (C_NATM,
                                            '(',
                                            1,
                                            1)
                                   - 1)),
                         TO_CHAR (C_NATM)))
            AS C_NATM
    FROM ATM_ALPHA
   WHERE timestamp > SYSDATE - 1
ORDER BY 1;


-- номера из контроллера

  SELECT C_NATM_CTRL
    FROM ATM_CTRL
   WHERE timestamp > SYSDATE - 1 / 48
ORDER BY 1;


-- сопоставление данных 

--кол-во банкоматов там и там

SELECT 'controller' AS DB, COUNT (C_NATM_CTRL) AS ATM_NUMBER
  FROM ATM_CTRL
 WHERE timestamp > SYSDATE - 1 / 48
UNION
SELECT 'alpha', COUNT (C_NATM)
  FROM ATM_ALPHA
 WHERE timestamp > SYSDATE - 1;
 
 -- банкоматы только в Альфе 
 
 SELECT TO_NUMBER (NVL ( (SUBSTR (C_NATM,
                                 1,
                                   INSTR (C_NATM,
                                          '(',
                                          1,
                                          1)
                                 - 1)),
                       TO_CHAR (C_NATM)))
          AS ATM_ONLY_IN_ALPHA
  FROM ATM_ALPHA
MINUS
SELECT C_NATM_CTRL
  FROM ATM_CTRL
 WHERE timestamp > SYSDATE - 1 / 48;
 
  -- банкоматы только в контроллере 
 
 SELECT C_NATM_CTRL AS ATM_ONLY_IN_CTRL
  FROM ATM_CTRL
 WHERE timestamp > SYSDATE - 1 / 48
MINUS
SELECT TO_NUMBER (NVL ( (SUBSTR (C_NATM,
                                 1,
                                   INSTR (C_NATM,
                                          '(',
                                          1,
                                          1)
                                 - 1)),
                       TO_CHAR (C_NATM)))
  FROM ATM_ALPHA
 
 
  SELECT TO_NUMBER (NVL ( (SUBSTR (a.C_NATM,
                                   1,
                                     INSTR (a.C_NATM,
                                            '(',
                                            1,
                                            1)
                                   - 1)),
                         TO_CHAR (a.C_NATM)))
            AS ALPHA_ATM,
         b.C_NATM_CTRL AS CTRL_ATM
    FROM ATM_ALPHA a, ATM_CTRL b
   WHERE     a.timestamp > SYSDATE - 1
         AND b.timestamp > SYSDATE - 1 / 48
         AND TO_NUMBER (NVL ( (SUBSTR (a.C_NATM,
                                       1,
                                         INSTR (a.C_NATM,
                                                '(',
                                                1,
                                                1)
                                       - 1)),
                             TO_CHAR (a.C_NATM))) = b.C_NATM_CTRL
ORDER BY 1;


