Run the following command:

1. Login with Oracle User and to go Middleware home.

cd /way4app/oracle/product/Middleware/wlserver_10.3/server/bin
. ./setWLSEnv.sh
./startNodeManager.sh &

2.Start the Admin Server.

cd /way4app/oracle/product/Middleware/user_projects/domains/ClassicDomain/bin

./startWebLogic.sh -Dweblogic.management.username=weblogic -Dweblogic.management.password=weblogic123 &

3.Start WLS_REPORTS from the WebLogic Server Administration Console.

a.Log in to the WebLogic Server Administration Console eg. (http://10.119.5.116:7001/console).

b.From the Domain Structure section in the left navigation pane, select Environment > Servers.The Summary of Servers screen is displayed. Click the Control tab.

c.Select the WLS_REPORTS check box and click Start.

4 Starting Reports Standalone Server

cd /way4app/oracle/product/Middleware/asinst_1/bin

5.Enter the following command:
opmnctl startall
opmnctl status 
