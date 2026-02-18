# initial environment setup for kubespray

# Если папка уже есть, лучше начать с чистого листа
rm -rf kubespray

# Клонируем репозиторий
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray

# Переключаемся на стабильную ветку (используем ту же версию v2.29.1)
git checkout v2.29.1

# Установка venv и зависимостей
sudo apt update && sudo apt install -y python3-venv sshpass
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Копируем шаблон инвентаря
cp -rfp inventory/sample inventory/ha-cluster

# keys setup

# Генерируем ключ (без парольной фразы)
ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_rsa

# Копируем ключи (вводите password при запросе)
# Master
ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.6
# Node 1
ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.5
# Node 2
ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.39

# inventory setup

cat > inventory/ha-cluster/inventory.ini <<EOF
[all]
kube-master ansible_host=10.130.0.6 ip=10.130.0.6 etcd_member_name=etcd1
kube-node01 ansible_host=10.130.0.5 ip=10.130.0.5 etcd_member_name=etcd2
kube-node02 ansible_host=10.130.0.39 ip=10.130.0.39 etcd_member_name=etcd3

[kube_control_plane]
kube-master
kube-node01
kube-node02

[etcd]
kube-master
kube-node01
kube-node02

[kube_node]
kube-master
kube-node01
kube-node02

[k8s_cluster:children]
kube_control_plane
kube_node
EOF

# load balancer setup

cat > inventory/ha-cluster/group_vars/all/custom_lb.yml <<EOF
## Отключаем локальный балансировщик (требование поддержки)
loadbalancer_apiserver_localhost: false

## Указываем внешний балансировщик
loadbalancer_apiserver:
  address: 84.252.134.62
  port: 6443
EOF

cat inventory/ha-cluster/group_vars/all/custom_lb.yml

# check all

ansible -i inventory/ha-cluster/inventory.ini all -m ping -u user -b

# run setup

ansible-playbook -i inventory/ha-cluster/inventory.ini -u user -b --become-user=root cluster.yml -e ignore_assert_errors=yes