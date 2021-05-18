1) add smtp server into /etc/hosts

2) service sendmail status

3) sudo service sendmail restart

4) send test message
 mailx -s "`uname -n` test" iruacii2@raiffeisen.ru  <<message
aaa
message

5) log in /var/log/maillog