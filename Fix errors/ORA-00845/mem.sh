sudo su - 
df -lh
umount /dev/shm
mount /dev/shm -o size=8000m  -- size > memory_max_target

size = server RAM

Для постоянного монтирования temp после рестарта сервера:

vim /etc/fstab

tmpfs                   /dev/shm                tmpfs   size=4000       0 0
#tmpfs    /dev/shm   tmpfs   nodev,nosuid,size=8G  0 0
