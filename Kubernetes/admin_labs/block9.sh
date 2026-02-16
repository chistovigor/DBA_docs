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

ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.18
ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.21
ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.6

# inventory setup

vim inventory/ha-cluster/inventory.ini

[all]
kube-master ansible_host=10.130.0.18 ip=10.130.0.18 etcd_member_name=etcd1
kube-node01 ansible_host=10.130.0.21 ip=10.130.0.21 etcd_member_name=etcd2
kube-node02 ansible_host=10.130.0.6  ip=10.130.0.6  etcd_member_name=etcd3

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

echo "84.201.180.19 lb-apiserver.kubernetes.local" | sudo tee -a /etc/hosts

ansible -i inventory/ha-cluster/inventory.ini all -m lineinfile -u user -b \
-a "path=/etc/hosts regexp='.*lb-apiserver.kubernetes.local' line='10.130.0.18 lb-apiserver.kubernetes.local'"

# load balancer add

vim inventory/ha-cluster/group_vars/all/all.yml

loadbalancer_apiserver_localhost: true
loadbalancer_apiserver:
  address: 84.201.180.19
  port: 6443

# check all

ansible -i inventory/ha-cluster/inventory.ini all -m ping -u user -b

# run setup

nohup ansible-playbook -i inventory/ha-cluster/inventory.ini -u user -b --become-user=root cluster.yml -e ignore_assert_errors=yes > install_ha.log 2>&1 &