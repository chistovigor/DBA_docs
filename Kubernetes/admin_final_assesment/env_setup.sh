# 1. Генерация ключа (нажимайте Enter на все вопросы)
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# 2. Копирование ключа на все ноды (потребуется ввести пароль)
ssh-copy-id user@10.130.0.45
ssh-copy-id user@10.130.0.7
ssh-copy-id user@10.130.0.18

# 3. Установка зависимостей и скачивание Kubespray
sudo apt update && sudo apt install -y python3-pip git
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
git checkout release-2.24 # Переключаемся на стабильную ветку (опционально)

# 1. Устанавливаем пакет для создания виртуальных окружений
sudo apt install -y python3-venv

# 2. Создаем виртуальное окружение с именем 'venv' внутри папки kubespray
python3 -m venv venv

# 3. Активируем его (после этого слева в терминале появится префикс (venv))
source venv/bin/activate

# 4. Теперь установка зависимостей пройдет успешно
pip3 install -r requirements.txt

# 4. Копирование дефолтного инвентаря
cp -rfp inventory/sample inventory/mycluster

# 1. Инвентарный файл (inventory/mycluster/inventory.ini):

cat <<EOF > inventory/mycluster/inventory.ini
[all]
kube-master ansible_host=10.130.0.45 ip=10.130.0.45 etcd_member_name=etcd1
kube-node01 ansible_host=10.130.0.7 ip=10.130.0.7
kube-node02 ansible_host=10.130.0.18 ip=10.130.0.18

[kube_control_plane]
kube-master

[etcd]
kube-master

[kube_node]
kube-node01
kube-node02

[k8s_cluster:children]
kube_control_plane
kube_node
EOF

# 2. Настройка LoadBalancer для API (HA-режим):

cat <<EOF >> inventory/mycluster/group_vars/all/all.yml
apiserver_loadbalancer_domain_name: "158.160.139.255"
loadbalancer_apiserver:
  address: 158.160.139.255
  port: 6443
supplementary_addresses_in_ssl_keys: [158.160.139.255]
EOF

# 3. Включение Cert-Manager и Local Path Provisioner:

sed -i 's/cert_manager_enabled: false/cert_manager_enabled: true/' inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i 's/local_path_provisioner_enabled: false/local_path_provisioner_enabled: true/' inventory/mycluster/group_vars/k8s_cluster/addons.yml

# проверка перед запуском setup

ansible-playbook -i inventory/mycluster/inventory.ini --syntax-check cluster.yml

ansible -i inventory/mycluster/inventory.ini all -m ping -b

ansible-inventory -i inventory/mycluster/inventory.ini --host kube-master

ansible-inventory -i inventory/mycluster/inventory.ini --graph