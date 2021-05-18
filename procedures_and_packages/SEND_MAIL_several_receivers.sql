CREATE OR REPLACE PACKAGE          raiff.MAIL_PKG
AS
   TYPE ARRAY IS TABLE OF VARCHAR2 (255);

   PROCEDURE Send (p_sender_email   IN VARCHAR2,
                   p_from           IN VARCHAR2,
                   p_to             IN ARRAY DEFAULT ARRAY (),
                   p_cc             IN ARRAY DEFAULT ARRAY (),
                   p_bcc            IN ARRAY DEFAULT ARRAY (),
                   p_subject        IN VARCHAR2 DEFAULT NULL,
                   p_body           IN LONG DEFAULT NULL,
                   p_ContentType    IN VARCHAR2 DEFAULT 'text/plain',
                   p_Rcpt_Name      IN VARCHAR2 DEFAULT NULL);
END;
/

SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY          raiff.MAIL_PKG
AS
g_crlf CHAR (2) DEFAULT CHR (13) || CHR (10);
g_mail_conn UTL_SMTP.connection;
g_mailhost VARCHAR2 (255) := 'smtp.raiffeisen.ru';

--------------------------------------------------------------------------------------
FUNCTION address_email (p_string IN VARCHAR2, p_recipients IN ARRAY) RETURN VARCHAR2
IS
   l_recipients   LONG;
BEGIN
  FOR i IN 1 .. p_recipients.COUNT
  LOOP
    IF trim(p_recipients(i)) IS NOT NULL THEN
      UTL_SMTP.rcpt (g_mail_conn, p_recipients (i));

      IF (l_recipients IS NULL) THEN  l_recipients := p_string     || p_recipients (i);
                                ELSE  l_recipients := l_recipients ||', '|| p_recipients (i);
      END IF;
    END IF;
  END LOOP;
  RETURN l_recipients;
END;

--------------------------------------------------------------------------------------
PROCEDURE writedata (p_text IN VARCHAR2)
AS
BEGIN
  IF (p_text IS NOT NULL) THEN
    UTL_SMTP.write_data (g_mail_conn, p_text || g_crlf);
  END IF;
END;

--------------------------------------------------------------------------------------
PROCEDURE writedataasraw (p_text IN VARCHAR2)
AS
BEGIN
  IF (p_text IS NOT NULL)THEN
    UTL_SMTP.write_raw_data (g_mail_conn, UTL_RAW.cast_to_raw (p_text || g_crlf));
  END IF;
END;


--------------------------------------------------------------------------------------
PROCEDURE Send (p_sender_email   IN   VARCHAR2,
                p_from           IN   VARCHAR2,
                p_to             IN   ARRAY DEFAULT ARRAY (),
                p_cc             IN   ARRAY DEFAULT ARRAY (),
                p_bcc            IN   ARRAY DEFAULT ARRAY (),
                p_subject        IN   VARCHAR2 DEFAULT NULL,
                p_body           IN   LONG DEFAULT NULL,
                p_ContentType    IN   VARCHAR2 DEFAULT 'text/plain',
                p_Rcpt_Name      IN   VARCHAR2 DEFAULT NULL
               )
IS
  l_to_list    LONG;
  l_cc_list    LONG;
  l_bcc_list   LONG;
  l_date       VARCHAR2 (255) DEFAULT TO_CHAR (SYSDATE, 'dd Mon yy hh24:mi:ss');
BEGIN
  g_mail_conn  := UTL_SMTP.open_connection (g_mailhost, 25);

  UTL_SMTP.helo (g_mail_conn, g_mailhost);
  UTL_SMTP.mail (g_mail_conn, p_sender_email);

  l_to_list  := address_email ('To: ', p_to);
  l_cc_list  := address_email ('Cc: ', p_cc);
  l_bcc_list := address_email ('Bcc: ',p_bcc);

  UTL_SMTP.open_data (g_mail_conn);
  writedata ('Date: ' || l_date);
  writedata ('From: ' || NVL (p_from, p_sender_email));
  writedataasraw ('Subject: ' || NVL (p_subject, '(no subject)'));

  writedata('MIME-Version: 1.0');
  writedata('Content-Type: '|| p_ContentType ||'; charset="windows-1251"');
  writedata('Content-Transfer-Encoding: 8bit');

  -- substitution value for field "To"
  IF p_Rcpt_Name IS NOT NULL THEN
    l_to_list := 'To: '||p_Rcpt_Name;
  END IF;

  writedata(l_to_list);
  writedata(l_cc_list);
  writedata(l_bcc_list);

  writedataasraw(g_crlf || p_body); --

  UTL_SMTP.close_data (g_mail_conn);
  UTL_SMTP.quit (g_mail_conn);
EXCEPTION
  WHEN UTL_SMTP.transient_error OR UTL_SMTP.permanent_error THEN
    BEGIN
      UTL_SMTP.QUIT(g_mail_conn);
    EXCEPTION
      WHEN UTL_SMTP.TRANSIENT_ERROR OR UTL_SMTP.PERMANENT_ERROR THEN
        NULL; -- If SMTP isn't available or not connected to server,
              -- then execution command "QUIT" - raise exception.
              -- You may ignore this Error.
    END;
    raise_application_error(-20000, 'Sending message is''t successfuly. Error: ' || sqlerrm);
END Send;

END;
/

SHOW ERRORS;



Выполнение отправки нескольким респондентам:

DECLARE
   Arr_to   raiff.Mail_Pkg.ARRAY;
BEGIN
   Arr_to := raiff.Mail_Pkg.ARRAY ('Igor.CHISTOV@raiffeisen.ru', 'iruacii2');
   raiff.Mail_Pkg.send (
      p_sender_email   => 'PRIME4',
      p_from           => 'PRIME4',
      p_to             => Arr_to,
      p_subject        =>    'message subject '
                          || TO_CHAR (TRUNC (SYSDATE, 'HH24'),
                                      'YYYY-MM-DD HH24:MI:SS'),
      p_body           => 'aaaa',
      p_ContentType    => 'text/html');
END;
/

или

DECLARE
   Arr_to   raiff.Mail_Pkg.ARRAY;
BEGIN
   Arr_to := raiff.Mail_Pkg.ARRAY ('Igor.CHISTOV@raiffeisen.ru', 'iruacii2');
   raiff.Mail_Pkg.send (
      p_sender_email   => 'ONLINE4',
      p_from           => 'ONLINE4',
      p_to             => Arr_to,
      p_subject        =>    'message subject ',
      p_body           => 'message was sent at '||TO_CHAR (SYSDATE,'YYYY-MM-DD HH24:MI:SS'),
      p_ContentType    => 'text/html');
END;