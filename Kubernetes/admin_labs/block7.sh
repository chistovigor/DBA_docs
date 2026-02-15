1. Подготовка Master-ноды (SSH и зависимости)
Bash
# Установка системных пакетов
sudo apt-get update
sudo apt-get install -y git python3 python3-pip python3-venv sshpass

# Генерация ключа (если еще нет) и копирование на все ноды
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
ssh-copy-id user@10.130.0.41
ssh-copy-id user@10.130.0.38
ssh-copy-id user@10.130.0.19
# 2. Подготовка Kubespray (ветка 2.29 — самая стабильная для v1.33)
Bash
cd /home/user
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
git checkout release-2.29

# Создание виртуального окружения и установка зависимостей
python3 -m venv venv
source venv/bin/activate
pip install -U pip
pip install -r requirements.txt
# 3. Настройка конфигурации (Inventory)

mkdir -p inventory/mycluster
cp -rfp inventory/sample/group_vars inventory/mycluster/

cat <<EOF > inventory/mycluster/inventory.ini
[all]
kube-master ansible_host=10.130.0.41 ip=10.130.0.41 etcd_member_name=etcd1
kube-node01 ansible_host=10.130.0.38 ip=10.130.0.38 etcd_member_name=etcd2
kube-node02 ansible_host=10.130.0.19 ip=10.130.0.19 etcd_member_name=etcd3

[kube_control_plane]
kube-master

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
# 4. Тонкая настройка параметров (v1.33, Безопасность, Аддоны)

# Версия (без 'v') и параметры безопасности в k8s-cluster.yml
sed -i 's/^kube_version: .*/kube_version: 1.33.0/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's/^# kubernetes_audit: .*/kubernetes_audit: true/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's/^# kube_encrypt_secret_data: .*/kube_encrypt_secret_data: true/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's/^kube_proxy_strict_arp: .*/kube_proxy_strict_arp: true/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# ВАЖНО: Установка etcd на все узлы группы [etcd] как системную службу
sed -i 's/^etcd_deployment_type: .*/etcd_deployment_type: host/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# Включение аддонов в addons.yml
sed -i 's/metrics_server_enabled: .*/metrics_server_enabled: true/' inventory/mycluster/group_vars/k8s_cluster/addons.yml
sed -i 's/local_path_provisioner_enabled: .*/local_path_provisioner_enabled: true/' inventory/mycluster/group_vars/k8s_cluster/addons.yml
# 5. Запуск установки

# Проверка связи
ansible -i inventory/mycluster/inventory.ini all -m ping -u user --become

# Деплой кластера
ansible-playbook -i inventory/mycluster/inventory.ini -u user -b --become-user=root cluster.yml
# 6. Настройка доступа и финальная проверка

# Настройка kubectl для root
sudo mkdir -p /root/.kube
sudo cp /etc/kubernetes/admin.conf /root/.kube/config
sudo chown root:root /root/.kube/config

# Проверка нод
kubectl get nodes

# Проверка etcd (теперь это системная служба, проверяем через etcdctl)
sudo ETCDCTL_API=3 etcdctl \
--endpoints=https://10.130.0.41:2379 \
--cacert=/etc/ssl/etcd/ssl/ca.pem \
--cert=/etc/ssl/etcd/ssl/admin-kube-master.pem \
--key=/etc/ssl/etcd/ssl/admin-kube-master-key.pem \
member list -w table

# reset before setup (if needed)

ansible-playbook -i inventory/mycluster/inventory.ini -u user -b --become-user=root reset.yml -e reset_confirmation=yes