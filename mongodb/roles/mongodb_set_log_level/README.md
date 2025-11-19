📘 Role: mongodb_set_log_level

This role manages the MongoDB logging level and operation profiling settings across all nodes of a MongoDB cluster (replica set or sharded cluster).

It performs:

Enabling/disabling or checking the MongoDB log level (setParameter logLevel).

Managing profiling settings (profilingLevel, slowms_threshold).

Synchronizing the slowOpThresholdMs value in /etc/mongod.conf with the desired threshold (slowms_threshold).

Non-destructive checks (no changes mode).

⚙️ Role Variables
Variable	Default Value	Description
log_action	"enable"	Action to perform:
• enable — enable logging and profiling as defined below.
• disable — disable profiling and revert logging to default.
• check — read and display current settings without making changes.
log_level	1	MongoDB log level (0–5).
script_path	"~/log_level_manage_cluster.js"	Path on the remote node to the helper JavaScript used for log management.
ProfilingLevel	0	Profiling level:
• 0 — profiling disabled;
• 1 — log only slow operations;
• 2 — log all operations.
slowms_threshold	100	Threshold (in milliseconds) defining "slow" operations.
This value is also written to the slowOpThresholdMs parameter inside /etc/mongod.conf.
mongo_user	—	Username with root or clusterAdmin privileges.
mongo_password	—	Password for the above user.
🧩 New Functionality

When the variable slowms_threshold is defined, the role will:

Ensure the operationProfiling section in /etc/mongod.conf is set to:

operationProfiling:
  slowOpThresholdMs: <slowms_threshold>


Create a timestamped backup of the existing configuration (e.g., /etc/mongod.conf.20251112_1042.bak).

Append the section if it does not exist.

Respect existing indentation and formatting (YAML-safe).

Skip modification if other non-standard parameters exist under operationProfiling.

🚀 Usage Examples
🔍 Check current logging and profiling settings (no changes)
ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_set_log_level.yml \
  --limit some_host_from_replicaset -D \
  --extra-vars "mongo_user=db_admin_username mongo_password=*** log_action=check"

🧾 Enable full query logging (recommended for diagnostics)

Enables profiling of all operations (ProfilingLevel=2) and sets the threshold to 0 ms (all operations considered “slow”):

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_set_log_level.yml \
  --limit some_host_from_replicaset -D \
  --extra-vars "log_action=enable ProfilingLevel=2 slowms_threshold=0 mongo_user=db_admin_username mongo_password=***"

⚙️ Apply default recommended settings (used after new cluster deployment)

Disables profiling and sets the default slow operation threshold to 100 ms:

ansible-playbook -i ~/git_repos/infrastructure/mongodb mongodb_set_log_level.yml \
  --limit some_host_from_replicaset -D \
  --extra-vars "log_action=disable ProfilingLevel=0 slowms_threshold=100 mongo_user=db_admin_username mongo_password=***"

🧪 Role Workflow

Connects to MongoDB using the provided credentials.

Reads the current logging and profiling parameters (db.getProfilingStatus() and getParameter logLevel).

Depending on log_action, it:

Enables/disables profiling and logging.

Updates the operationProfiling.slowOpThresholdMs parameter in /etc/mongod.conf.

Creates a backup of the configuration file before applying any changes.

Displays the resulting configuration state for confirmation.

📄 Example of resulting mongod.conf
security:
  authorization: enabled
  keyFile: /etc/mongod.key

operationProfiling:
  slowOpThresholdMs: 100

📘 Additional Notes

Changing slowOpThresholdMs in the configuration file requires restarting the mongod service.

When log_action=check, the role only reports current values without modifying anything.

The role can be safely applied across all members of a replica set — configuration and runtime parameters are synchronized automatically.