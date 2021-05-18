/* Formatted on 24/06/2014 15:56:39 (QP5 v5.227.12220.39754) */
CREATE OR REPLACE PROCEDURE TCTDBS.chbk_mc_1 (chbk_days NUMBER DEFAULT 1, v_cursor out sys_refcursor)
IS

BEGIN
   INSERT INTO ttt_chbk_mc (rr_serno,
                            i002_number,
                            i031_arn,
                            i042_merch_id,
                            i041_pos_id,
                            i018_merch_type,
                            i043a_merch_name,
                            i043b_merch_city,
                            i005_amt_settle,
                            i050_cur_settle,
                            i007_load_date,
                            i044_reason_code,
                            i048_text_data,
                            i024_funct_code,
                            i003_proc_code,
                            de72a)
      SELECT t.serno,
             i002_number,
             i031_arn,
             i042_merch_id,
             i041_pos_id,
             i018_merch_type,
             i043a_merch_name,
             i043b_merch_city,
             ROUND (i005_amt_settle, 2),
             i050_cur_settle,
             TO_CHAR (i007_load_date, 'DD/MM/YYYY'),
             i044_reason_code,
             i048_text_data,
             i024_funct_code,
             i003_proc_code,
             m.de72
        FROM mtransactions t, misotrxns i, iso8583 m
       WHERE     inbatchserno IN
                    (SELECT SERNO
                       FROM batches
                      WHERE     batchdate =
                                   TRUNC (SYSDATE - NVL (chbk_days, 0))
                            AND filesource LIKE '%IPM%'
                            AND direction = 'I')
             AND (    t.orig_msg_type = '1442'
                  AND i.i024_funct_code IN ('450', '453', '451', '454'))
             AND t.stgeneral IN ('NOME', 'TXIN', 'REJC')
             AND t.serno = i.serno
             AND t.serno = m.trxnserno
             AND m.direction = '1';

   UPDATE ttt_chbk_mc
      SET doc_ind =
             (SELECT VALUE
                FROM pdselements
               WHERE trxnserno = ttt_chbk_mc.rr_serno AND pdsid = '0262');

   UPDATE ttt_chbk_mc
      SET cpd_date =
             (SELECT SUBSTR (VALUE, 13, 6)
                FROM pdselements
               WHERE     trxnserno = ttt_chbk_mc.rr_serno
                     AND pdsid = '0158'
                     AND direction = 1);

   UPDATE ttt_chbk_mc
      SET reversal_ind =
             (SELECT VALUE
                FROM pdselements
               WHERE     trxnserno = ttt_chbk_mc.rr_serno
                     AND deid = '48'
                     AND pdsid = '0025'
                     AND direction = 1);

   UPDATE ttt_chbk_mc
      SET o_serno =
             (SELECT MIN (t.serno)
                FROM mtransactions t, misotrxns i
               WHERE     t.serno = i.serno
                     AND t.i000_msg_type = '0220'
                     AND SUBSTR (t.i003_proc_code, 1, 2) IN ('00', '01')
                     AND i.i031_arn = ttt_chbk_mc.i031_arn
                     AND t.i002_number = ttt_chbk_mc.i002_number);

   UPDATE ttt_chbk_mc
      SET o_i038_auth_id =
             (SELECT i038_auth_id
                FROM mtransactions t, misotrxns i
               WHERE t.serno = ttt_chbk_mc.o_serno AND t.serno = i.serno),
          o_i013_trxn_date =
             (SELECT TO_CHAR (i013_trxn_date, 'DD/MM/YYYY')
                FROM mtransactions t, misotrxns i
               WHERE t.serno = ttt_chbk_mc.o_serno AND t.serno = i.serno),
          o_i012_trxn_time =
             (SELECT TO_CHAR (i012_trxn_time, 'HH24:MI')
                FROM mtransactions t, misotrxns i
               WHERE t.serno = ttt_chbk_mc.o_serno AND t.serno = i.serno),
          o_i004_amt_trxn =
             (SELECT ROUND (i004_amt_trxn, 2)
                FROM mtransactions t, misotrxns i
               WHERE t.serno = ttt_chbk_mc.o_serno AND t.serno = i.serno),
          o_i049_cur_trxn =
             (SELECT i049_cur_trxn
                FROM mtransactions t, misotrxns i
               WHERE t.serno = ttt_chbk_mc.o_serno AND t.serno = i.serno),
          i042_merch_id =
             (SELECT i042_merch_id
                FROM mtransactions t, misotrxns i
               WHERE t.serno = ttt_chbk_mc.o_serno AND t.serno = i.serno),
          i043a_merch_name =
             (SELECT i043a_merch_name
                FROM mtransactions t, misotrxns i
               WHERE t.serno = ttt_chbk_mc.o_serno AND t.serno = i.serno);

   UPDATE ttt_chbk_mc
      SET o_ucaf =
             (SELECT SUBSTR (o.rawdata, 472, 3)
                FROM mtransactions t, misotrxns i, originalpos o
               WHERE     t.serno = ttt_chbk_mc.o_serno
                     AND t.serno = i.serno
                     AND t.serno = o.trxnserno
                     AND seqno = 1
                     AND fieldno = 0)
    WHERE i042_merch_id LIKE '168%';

   UPDATE ttt_chbk_mc
      SET orig_de4842 =
             (SELECT SUBSTR (t1.i048_text_data, 10, 2)
                FROM acquirerlog@onlinedblink t1
               WHERE     t1.i002_number = ttt_chbk_mc.i002_number
                     AND ttt_chbk_mc.o_i038_auth_id = t1.i038_auth_id
                     AND (   t1.i022_pos_entry NOT LIKE ('9%')
                          OR t1.i022_pos_entry NOT LIKE ('%5%'))
                     AND t1.i042_merch_id LIKE '168%'
                     AND t1.i000_msg_type = '0110');
                     
DBMS_OUTPUT.ENABLE(100000);

open v_cursor for SELECT    rr_serno
          || '|'
          || TRUNC (i002_number)
          || '|'
          || TRUNC (i031_arn)
          || '|'
          || TRUNC (i042_merch_id)
          || '|'
          || TRUNC (i041_pos_id)
          || '|'
          || i018_merch_type
          || '|'
          || i043a_merch_name
          || '|'
          || i043b_merch_city
          || '|'
          || i005_amt_settle
          || '|'
          || i050_cur_settle
          || '|'
          || i007_load_date
          || '|'
          || o_serno
          || '|'
          || o_i013_trxn_date
          || '|'
          || o_i012_trxn_time
          || '|'
          || o_i038_auth_id
          || '|'
          || o_i004_amt_trxn
          || '|'
          || o_i049_cur_trxn
          || '|'
          || o_ucaf
          || '|'
          || i044_reason_code
          || '|'
          || doc_ind
          || '|'
          || i048_text_data
          || '|'
          || cpd_date
          || '|'
          || i024_funct_code
          || '|'
          || reversal_ind
          || '|'
          || i003_proc_code
          || '|'
          || de72a
          || '|'
          || orig_de4842
          || '|' as chbk_mc             
    FROM ttt_chbk_mc
    WHERE   SUBSTR (i002_number, 1, 6) NOT IN
                 (SELECT bin FROM rbt_onus_bins)
          AND SUBSTR (i002_number, 1, 6) NOT IN
                 (SELECT bin FROM rbt_migr_bins);
END chbk_mc_1;