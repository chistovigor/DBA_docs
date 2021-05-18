select * from V$ENCRYPTION_WALLET;

select * from DBA_ENCRYPTED_COLUMNS order by 1,2,3;
select * from V$ENCRYPTED_TABLESPACES e,V$TABLESPACE t where t.TS# = e.TS# order by 1;
SELECT
    *
FROM
    dba_tab_columns
WHERE
    (( column_name LIKE 'CVC%' )
    OR ( column_name LIKE 'PIN%' )
	OR ( column_name LIKE 'CVV%' )
    OR ( column_name LIKE 'TRACK%' )
    OR ( column_name LIKE 'CARD%' ))
    AND table_name NOT LIKE 'BIN$%'
    AND owner <> 'SYS'
    AND LAST_ANALYZED IS NOT NULL
    AND NUM_DISTINCT > 100
ORDER BY
    owner,
    table_name;
	
select * from V$DATABASE_KEY_INFO;