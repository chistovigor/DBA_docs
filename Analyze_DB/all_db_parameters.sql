col Parameter for a20
col Session for a10
col Instance for a42
col S for a1
col I for a1
col D for a1
col Description for a60 
SELECT A.KSPPINM  "Parameter", 
       DECODE( P.ISSES_MODIFIABLE,'FALSE',NULL,NULL,NULL,B.KSPPSTVL ) "Session", 
       C.KSPPSTVL "Instance",
       DECODE( P.ISSES_MODIFIABLE,'FALSE','F','TRUE','T' ) "S",
       DECODE( P.ISSYS_MODIFIABLE,'FALSE','F','TRUE','T','IMMEDIATE','I','DEFERRED','D' ) "I",
       DECODE( P.ISDEFAULT,'FALSE','F','TRUE','T' ) "D",
       A.KSPPDESC "Description"
FROM  X$KSPPI A, X$KSPPCV B, X$KSPPSV C, V$PARAMETER P
WHERE A.INDX = B.INDX AND A.INDX = C.INDX
  AND P.NAME( + ) = A.KSPPINM
  AND UPPER( A.KSPPINM ) LIKE UPPER( '%&1%' )
ORDER BY A.KSPPINM;