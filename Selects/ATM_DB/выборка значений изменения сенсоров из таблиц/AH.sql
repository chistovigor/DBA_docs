with a1 as (SELECT *
          FROM router.AH201308
         WHERE     robj = 4101
               AND szdtime > '2013-08-14 13:20:00'
               AND szdtime < '2013-08-14 13:40:00')
               select * from a1 where exists (SELECT 1 FROM router.AH201308 a, router.AH201308 b
             WHERE a.ratm = b.ratm AND a.szdtime < b.szdtime AND a.rvalue = 1);