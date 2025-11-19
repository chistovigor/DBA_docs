import secrets
import string
import yaml

def generate_password(length=24):
    alphabet = string.ascii_letters + string.digits
    password = ''.join(secrets.choice(alphabet) for _ in range(length))
    return password

def generate_user_entry(username, password, roles):
    entry = (
        f'db.createUser(\n'
        f' {{\n'
        f'   user: "{username}",\n'
        f'   pwd: "{password}",\n'
        f'   roles: {roles}\n'
        f' }}\n'
        f')\n\n'
    )
    return entry

roles_for_users = {
    "root": [{"role": "root", "db": "admin"}],
    "rw": [{"role": "readWriteAnyDatabase", "db": "admin"}],
    "zabbix": [{"role": "clusterMonitor", "db": "admin"}],
    "admin": [
        {"role": "clusterMonitor", "db": "admin"},
        {"role": "readWriteAnyDatabase", "db": "admin"},
        {"role": "dbAdminAnyDatabase", "db": "admin"},
        {"role": "userAdminAnyDatabase", "db": "admin"}
    ]
}

users_and_passwords = []

for user in roles_for_users:
    password = generate_password()
    roles = roles_for_users[user]
    users_and_passwords.append({"user": user, "pwd": password, "roles": roles})

#  pass  manually
# users_and_passwords = [
#     {"user": "root", "pwd": "your_root_password", "roles": roles_for_users["root"]},
#     {"user": "rw", "pwd": "your_rw_password", "roles": roles_for_users["rw"]},
#     {"user": "zabbix", "pwd": "your_zabbix_password", "roles": roles_for_users["zabbix"]},
#     {"user": "admin", "pwd": "your_admin_password", "roles": roles_for_users["admin"]}
# ]

output_autoadd_users_yml = 'mongodb-users.yml'

with open(output_autoadd_users_yml, 'w') as output_file_yml:
    passwords_dict = {f"{entry['user']}pwd": entry["pwd"] for entry in users_and_passwords}
    yaml.dump(passwords_dict, output_file_yml)

print(f'saved {output_autoadd_users_yml}')

for entry in users_and_passwords:
    print(f'user: "{entry["user"]}"\npwd: "{entry["pwd"]}"')
