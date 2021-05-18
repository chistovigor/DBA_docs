-- размер лога

select bytes/1024/1024 mb from v$log;

-- динамика по приросту логов/скорости сети за последнее время

alter session set nls_date_format = 'DD/MM/YYYY';

select to_char(first_time,'DD/MM/YYYY') day,
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0))*(512/1024),'999') "00",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0))*(512/1024),'999') "01",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0))*(512/1024),'999') "02",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0))*(512/1024),'999') "03",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0))*(512/1024),'999') "04",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0))*(512/1024),'999') "05",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0))*(512/1024),'999') "06",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0))*(512/1024),'999') "07",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0))*(512/1024),'999') "08",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0))*(512/1024),'999') "09",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0))*(512/1024),'999') "10",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0))*(512/1024),'999') "11",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0))*(512/1024),'999') "12",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0))*(512/1024),'999') "13",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0))*(512/1024),'999') "14",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0))*(512/1024),'999') "15",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0))*(512/1024),'999') "16",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0))*(512/1024),'999') "17",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0))*(512/1024),'999') "18",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0))*(512/1024),'999') "19",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0))*(512/1024),'999') "20",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0))*(512/1024),'999') "21",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0))*(512/1024),'999') "22",
   to_char(sum(decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0))*(512/1024),'999') "23",
   SUM(1)*(512/1024) ||' / '||ROUND(SUM(1)*(512*8)/(24*60*60)) "TOTAL_GB / AVG_MBPS IN_DAY"    
   from v$log_history
   group by to_char(first_time,'DD/MM/YYYY')
   order by SUM(1) desc--to_date(day)
   ;