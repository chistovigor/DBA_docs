1. Правильно замонтировать сетевой диск

vim /etc/fstab

//10.242.254.227/s-msk-p-atm-arch       /mnt/oracle/backup cifs uid=502,gid=58995,auto,user,username=srv-processing,password=sfcvKi87sd 0 0

2. Включить асанхронный/прямой вывод RMAN (ТРЕБУЕТ ПЕРЕЗАПУСКА БД)

alter system set filesystemio_options=SETALL scope=spfile;

3. Если не работает, включить асанхронный вывод RMAN

alter system set filesystemio_options=ASYNCH scope=spfile;