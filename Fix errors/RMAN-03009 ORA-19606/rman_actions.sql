rman target /

CONFIGURE SNAPSHOT CONTROLFILE NAME clear;

crosscheck backup;

delete force noprompt contriolfilecopy '/mnt/data1/backup/snapcf_ULTRALB.f';

CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/mnt/data1/backup/snapcf_ULTRALB.f';

crosscheck backup;