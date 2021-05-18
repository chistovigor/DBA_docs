LOAD DATA 
INFILE 'isslog_13.bad'
BADFILE 'isslog_13_2.bad'
DISCARDFILE 'isslog_13.dsc'
APPEND INTO TABLE AUTHORIZATIONS
TRAILING NULLCOLS
(field boundfiller CHAR(300),
i002_number EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,1)",
LTIMESTAMP EXPRESSION "TO_TIMESTAMP(REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,2),'YYYY-MM-DD HH24:MI:SS')",
i043b_merch_city EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,3)",
i043a_merch_name EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,4)",
i043c_merch_cnt EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,5)",
i004_amt_trxn EXPRESSION " REGEXP_REPLACE (REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,6),' ',NULL)",
i018_merch_type EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,7)",
i019_acq_country EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,8)",
i022_pos_entry EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,9)",
i041_pos_id EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,10)",
i042_merch_id EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,11)",
i032_acquirer_id EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,12)",
i033_forwarder_id EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,13)",
i038_auth_id EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,14)",
i049_cur_trxn EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,15)",
i060_pos_cap EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,16)",
i000_msg_type EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,17)",
i003_proc_code EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,18)",
i039_rsp_cd EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,19)",
i014_exp_date EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,20)",
i035_trk_2 EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,21)",
i044_addtnl_rsp EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,22)",
i048_text_data EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,23)",
i053_sec_cntrl EXPRESSION " REGEXP_SUBSTR (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (REPLACE (:field,'||','| |'),'||','| |'),'\\\\|','%$%$'),'\\|',' '),'\\\\','\\'),'%$%$','\\|'),'[^|]+',1,24)")
