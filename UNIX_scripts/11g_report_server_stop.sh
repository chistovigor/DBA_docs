
login with Oracle user.

1. cd /way4app/Middleware/asinst_1/bin
./opmnctl stopall

2. cd /way4app/Middleware/user_projects/domains/ClassicDomain/bin

nohup sh stopManagedWebLogic.sh WLS_REPORTS &

3. #Stop Admin Server

nohup sh stopWebLogic.sh &


cd /way4app/oracle/product/Middleware/wlserver_10.3/server/bin
./stopNodeManager.sh &

or Kill the all process running with Oracle User.


kill -9 'ps -ef | grep oracle | egrep -v "grep|pts" | awk '{print $2}''





