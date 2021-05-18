CREATE PUBLIC DATABASE LINK bcd_ro
 CONNECT TO bcd_ro
 IDENTIFIED BY bcd_ro123
 USING 'PRIMEV_1';
 
 select * from dual@bcd_ro;
 
 CREATE PUBLIC DATABASE LINK bcd
 CONNECT TO bcd
 IDENTIFIED BY bcd123bcd
 USING 'PRIMEV_1';
 
 select * from dual@bcd;