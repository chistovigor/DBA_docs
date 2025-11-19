import secrets
import string

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
    "grafana": [{"role": "clusterMonitor", "db": "admin"}],

    "admin": [
        {"role": "clusterMonitor", "db": "admin"},
        {"role": "readWriteAnyDatabase", "db": "admin"},
        {"role": "dbAdminAnyDatabase", "db": "admin"}
    ]
}

#logic dialog
users_and_passwords = []

generate_pwd = input('Generate passwords for all users? (yes/no): ')
if generate_pwd.lower() == 'yes':
    for user in roles_for_users:
        password = generate_password()
        roles = roles_for_users[user]
        users_and_passwords.append({"user": user, "pwd": password, "roles": roles})
else:
    password_list = input('Enter passwords for all users (user:pwd format, separated by commas): ')
    for password_item in password_list.split(','):
        user, password = map(str.strip, password_item.split(':'))
        roles = roles_for_users.get(user, [])
        users_and_passwords.append({"user": user, "pwd": password, "roles": roles})

output_file_path = 'mongo-users.js'
with open(output_file_path, 'w') as output_file:
    for entry in users_and_passwords:
        output_file.write(generate_user_entry(entry["user"], entry["pwd"], entry["roles"]))
        print(f'user: "{entry["user"]}"\npwd: "{entry["pwd"]}"')

print(f'Output saved to {output_file_path}')

