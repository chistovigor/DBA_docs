1) Определение количества replay клиентов для проигрывания нагрузки:

wrc sys/spotlight MODE=calibrate REPLAYDIR='/u01/backup/local/database_replay/01';

2) Соединение replay клиента для проигрывания нагрузки (нужно столько сессий, сколько было указано в пред. шаге):
 
wrc system/ctrldbsystem MODE=replay REPLAYDIR='/u01/backup/local/database_replay/01';
 
wrc system/ctrldbsystem MODE=replay REPLAYDIR='/u01/backup/local/database_replay/02';