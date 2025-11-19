// Select the admin DB
db = db.getSiblingDB("admin");

// Fetch current user info
var user = db.getUser("zabbix");

if (!user) {
    print("User 'zabbix' does not exist.");
    quit(1);
}

print("Current roles:");
printjson(user.roles);

// Filter out exporterCollStatsRole
var updatedRoles = user.roles.filter(function(r) {
    return r.role !== "exporterCollStatsRole";
});

// Check if the role is present
var removed = user.roles.length !== updatedRoles.length;

if (!removed) {
    print("Role 'exporterCollStatsRole' is not assigned to user 'zabbix'. Nothing to do.");
    quit(0);
}

// Update user with new roles
db.updateUser("zabbix", { roles: updatedRoles });

print("Updated roles:");
printjson(updatedRoles);

print("Successfully removed exporterCollStatsRole from user 'zabbix'.");