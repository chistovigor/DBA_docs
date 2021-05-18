CREATE OR REPLACE PROCEDURE ROUTER.send_mail (p_to VARCHAR2,
                                       p_from VARCHAR2,
                                       p_message VARCHAR2,
                                       p_smtp_host VARCHAR2,
                                       p_smtp_port NUMBER DEFAULT 25)
AS
  l_mail_conn   UTL_SMTP.connection;
BEGIN
  l_mail_conn := UTL_SMTP.open_connection(p_smtp_host, p_smtp_port);
  UTL_SMTP.helo(l_mail_conn, p_smtp_host);
  UTL_SMTP.mail(l_mail_conn, p_from);
  UTL_SMTP.rcpt(l_mail_conn, p_to);
  UTL_SMTP.data(l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.quit(l_mail_conn);
END;
/

Отправка почты из командной строки:

/* Formatted on 30.06.2014 17:05:35 (QP5 v5.227.12220.39754) */
DECLARE
   p_to          VARCHAR2(30):='iruacii2@raiffeisen.ru';
   p_from        VARCHAR2(20):='PRIME4';
   p_message     VARCHAR2(20):='aaa';
   p_smtp_host   VARCHAR2(20):='smtp.raiffeisen.ru';
   p_smtp_port   NUMBER:=25;
   l_mail_conn   UTL_SMTP.connection;
BEGIN
   l_mail_conn := UTL_SMTP.open_connection (p_smtp_host, p_smtp_port);
   UTL_SMTP.helo (l_mail_conn, p_smtp_host);
   UTL_SMTP.mail (l_mail_conn, p_from);
   UTL_SMTP.rcpt (l_mail_conn, p_to);
   UTL_SMTP.data (l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);
   UTL_SMTP.quit (l_mail_conn);
END;
/
