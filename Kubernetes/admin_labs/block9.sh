# initial environment setup for kubespray

# Клонируем репозиторий
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray

# Переключаемся на нужную версию
git checkout v2.29.1

# Установка venv, если его нет (для Ubuntu)
sudo apt update && sudo apt install -y python3-venv

# Создаем и активируем окружение
python3 -m venv venv
source venv/bin/activate

# Обновляем pip и ставим зависимости
pip install --upgrade pip
pip install -r requirements.txt

# Копируем шаблон в папку ha-cluster
cp -rfp inventory/sample inventory/ha-cluster

# keys setup

ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_rsa
# Для самого себя (мастера)
ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.27

# Для первой ноды
ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.31

# Для второй ноды
ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.29

# inventory setup

vim inventory/ha-cluster/inventory.ini

[all]
kube-master ansible_host=10.130.0.27 ip=10.130.0.27 etcd_member_name=etcd1
kube-node01 ansible_host=10.130.0.31 ip=10.130.0.31 etcd_member_name=etcd2
kube-node02 ansible_host=10.130.0.29 ip=10.130.0.29 etcd_member_name=etcd3

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

# add name resolution

echo "158.160.177.85 lb-apiserver.kubernetes.local" | sudo tee -a /etc/hosts

# load balancer add

vim inventory/ha-cluster/group_vars/all/all.yml

loadbalancer_apiserver_localhost: true
loadbalancer_apiserver:
  address: 158.160.177.85
  port: 6443

# check all

ansible -i inventory/ha-cluster/inventory.ini all -m ping -u user -b

# run setup

ansible-playbook -i inventory/ha-cluster/inventory.ini -u user -b --become-user=root cluster.yml -e ignore_assert_errors=yes