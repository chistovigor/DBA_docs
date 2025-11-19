(function() {
  const adminDB = db.getSiblingDB('admin');
  const roleName = 'exporterCollStatsRole';
  const userName = '{{ mongodb_exporter_user }}';
  const userPwd = '{{ mongodb_exporter_password }}';

  try {
    const role = adminDB.getRole(roleName, { showPrivileges: true });
    if (!role) {
      adminDB.createRole({
        role: roleName,
        privileges: [
          { resource: { db: "", collection: "" }, actions: [ "collStats", "dbStats", "indexStats", "listCollections", "listIndexes" ] },
          { resource: { cluster: true }, actions: [ "serverStatus", "replSetGetStatus", "listDatabases" ] }
        ],
        roles: [{ role: "clusterMonitor", db: "admin" }]
      });
      print("Role created");
    } else {
      print("Role exists");
    }
  } catch (e) {
    print("Error managing role: " + JSON.stringify(e));
    quit(1);
  }

  try {
    const user = adminDB.getUser(userName);
    if (!user) {
      adminDB.createUser({ user: userName, pwd: userPwd, roles: [ { role: roleName, db: 'admin' } ] });
      print("User created and role granted");
    } else {
      const hasRole = (user.roles || []).some(r => r.role === roleName && r.db === 'admin');
      if (!hasRole) {
        adminDB.grantRolesToUser(userName, [ { role: roleName, db: 'admin' } ]);
        print("Role granted to existing user");
      } else {
        print("User exists and already has role");
      }
    }
  } catch (e) {
    print("Error managing user: " + JSON.stringify(e));
    quit(1);
  }

  print("DONE");
  quit(0);
})();
