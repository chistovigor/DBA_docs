----------------------------------------
-- 10g --
-- Displays feature usage statistics
----------------------------------------

COLUMN name  FORMAT A50
COLUMN detected_usages FORMAT 999999999999
COLUMN highwater FORMAT 999999999999
COLUMN last_value FORMAT 999999999999

SELECT u1.name,
       u1.detected_usages,
       u1.last_usage_date
FROM   dba_feature_usage_statistics u1
WHERE  u1.version = (SELECT MAX(u2.version)
                     FROM   dba_feature_usage_statistics u2
                     WHERE  u2.name = u1.name)
   AND u1.detected_usages>0
ORDER BY u1.name
/


SELECT hwm1.name,
       hwm1.highwater,
       hwm1.last_value
FROM   dba_high_water_mark_statistics hwm1
WHERE  hwm1.version = (SELECT MAX(hwm2.version)
                       FROM   dba_high_water_mark_statistics hwm2
                       WHERE  hwm2.name = hwm1.name)
ORDER BY hwm1.name
/

COLUMN FORMAT DEFAULT


