CREATE OR REPLACE PROCEDURE ROUTER.SUB_FRAUD_ALERT
IS
   vC_PROCEDURE    VARCHAR2 (32000);
   vC_TABLE_NAME   VARCHAR2 (8) := 'AB';
BEGIN
   vC_TABLE_NAME := vC_TABLE_NAME || TO_CHAR (SYSDATE, 'YYYYMM');

   /* -- add comment here to disable procedure
   */

   vC_PROCEDURE :=
         'DECLARE
   vC_REPORT VARCHAR2(32000);
   vN_COLOR NUMBER(1) := 1;
   vC_COLOR VARCHAR2(10) := ''"#FFFFFF"'';
   Arr_to     Mail_Pkg.ARRAY;
 BEGIN
 vC_REPORT := ''<HTML>''
            ||''<HEAD>''
            ||   ''<TITLE>ATM Controller Suspicious Transactions</TITLE>''
            ||   ''<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=windows-1251">''
            || ''</HEAD>''
            || ''<BODY>''
            ||   ''<TABLE border="0" width="950">''
            ||   ''<TR><TD width="100%">''
            ||       ''<CENTER><h3 align="center">ATM Controller Suspicious Transactions</CENTER>'' ||
                     ''<CENTER><h5 align="center"> Period: '' ||
                         to_char(trunc(SYSDATE,''HH24'')-1/24,''YYYY-MM-DD HH24:MI:SS'') || '' - '' ||
                         to_char(trunc(SYSDATE,''HH24''),''YYYY-MM-DD HH24:MI:SS'') || ''</CENTER><BR><BR>''
            ||       ''<TABLE border="1" cellspacing="0" cellpadding="1" width="100%">'' ||

               ''<TR>'' ||
                 ''<TD bgColor="#FBD7D7"><font size=-1><B>'' || ''Date/Time''  || ''</B></font></TD>'' ||
                 ''<TD bgColor="#FBD7D7"><font size=-1><B>'' || ''ATM''        || ''</B></font></TD>'' ||
                 ''<TD bgColor="#FBD7D7"><font size=-1><B>'' || ''Transaction''|| ''</B></font></TD>'' ||
                 ''<TD bgColor="#FBD7D7"><font size=-1><B>'' || ''Card Number''|| ''</B></font></TD>'' ||
                 ''<TD bgColor="#FBD7D7"><font size=-1><B>'' || ''Amount''     || ''</B></font></TD>'' ||
                 ''<TD bgColor="#FBD7D7"><font size=-1><B>'' || ''Cur''        || ''</B></font></TD>'' ||
                 ''<TD bgColor="#FBD7D7"><font size=-1><B>'' || ''RC''         || ''</B></font></TD>'' ||
               ''</TR>'';

  FOR TRXN IN (SELECT a.szdevin,o1.szname atm,o2.szname op,a.szpan,a.lamount/100 amt,a.lcurr,lpad(a.lresult,2,''0'') rc
                 FROM '
      || vC_TABLE_NAME
      || ' a, objlist o1, objlist o2 -- ONLY FOR THIS F*CKING TABLE DYNAMIC SQL USED
                WHERE o1.robj = a.ratm
                  AND o2.robj = a.rrequest
                  AND a.lresult IN (7,15)
                  AND a.szdevin
              BETWEEN to_char(trunc(SYSDATE,''HH24'')-1/24,''YYYY-MM-DD HH24:MI:SS'')
                  AND to_char(trunc(SYSDATE,''HH24''),''YYYY-MM-DD HH24:MI:SS'')
             ORDER BY a.szdevin)
  LOOP

  IF vN_COLOR > 0 THEN
    vC_COLOR := ''"#DAF4E2"'';
  ELSE
    vC_COLOR := ''"#FFFFFF"'';
  END IF;

  vC_REPORT := vC_REPORT ||
               ''<TR>'' ||
                 ''<TD bgColor='' || vC_COLOR || ''><font size=-1>'' || TRXN.SZDEVIN || ''</font></TD>''  ||
                 ''<TD bgColor='' || vC_COLOR || ''><font size=-1>'' || trim(TRXN.ATM)|| ''</font></TD>'' ||
                 ''<TD bgColor='' || vC_COLOR || ''><font size=-1>'' || trim(TRXN.OP) || ''</font></TD>'' ||
                 ''<TD bgColor='' || vC_COLOR || ''><font size=-1>'' || TRXN.SZPAN   || ''</font></TD>''  ||
                 ''<TD bgColor='' || vC_COLOR || '' align="right"><font size=-1>'' || TRXN.AMT     || ''</font></TD>'' ||
                 ''<TD bgColor='' || vC_COLOR || ''><font size=-1>'' || TRXN.LCURR   || ''</font></TD>''  ||
                 ''<TD bgColor='' || vC_COLOR || ''><font size=-1>'' || TRXN.RC      || ''</font></TD>''  ||
                ''</TR>'';
  vN_COLOR := -1*vN_COLOR;
  END LOOP;
 vC_REPORT := vC_REPORT || ''</TABLE>'';
 vC_REPORT := vC_REPORT
            ||    ''</TD></TR>''
            ||    ''</TABLE>''
            || ''</BODY>''
            || ''</HTML>'';

 Arr_to := Mail_Pkg.ARRAY(''valexandrova@raiffeisen.ru'',
                          ''INIKOLAEV@raiffeisen.ru'',
                          ''cardcentre_alerts@raiffeisen.ru'',
                          ''Teymur.DADASHEV@raiffeisen.ru'',
                          ''VRADVANSKAYA@raiffeisen.ru'',
                          ''Olga.ELISTRATOVA@raiffeisen.ru''
                          --''iruacii2''
                          );

 Mail_Pkg.send( p_sender_email => ''CTRLDB'',
                          p_from         => ''CTRLDB'',
                          p_to           => Arr_to,
                          p_subject      => ''ATM Controller Suspicious Transactions '' || to_char(trunc(SYSDATE,''HH24''),''YYYY-MM-DD HH24:MI:SS''),
                          p_body         => vC_REPORT,
                          p_ContentType  => ''text/html''
                         );
END;';

   EXECUTE IMMEDIATE vC_PROCEDURE;

   /* to check resulting text of procedure

   Mail_Pkg.send (p_sender_email   => 'CTRLDB',
                  p_from           => 'CTRLDB',
                  p_to             => Mail_Pkg.ARRAY ('iruacii2'),
                  p_subject        => 'vC_PROCEDURE',
                  p_body           => vC_PROCEDURE,
                  p_ContentType    => 'plain/html');
                  */
                     
END;
/
