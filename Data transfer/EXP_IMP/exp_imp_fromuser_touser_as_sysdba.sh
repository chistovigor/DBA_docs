exp \'/ AS SYSDBA\' FILE=exp_bpel.dmp LOG=exp_bpel.log OWNER=bpel
imp \'/ AS SYSDBA\' FILE=exp_bpel.dmp LOG=imp_bpel.log FROMUSER=bpel touser=bpel_test1
expdp \'/ AS SYSDBA\'