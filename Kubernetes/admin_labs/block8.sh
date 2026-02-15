# do setup prerequisites on the master node

# 1. Установка пакетов
sudo apt-get update
sudo apt-get install -y git python3 python3-pip python3-venv sshpass

# 2. Генерация SSH ключа
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""

# 3. Копирование ключей (пароль: fgiqczrpiz)
# Master (сам на себя)
sshpass -p "fgiqczrpiz" ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.41
# Node01
sshpass -p "fgiqczrpiz" ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.16
# Node02
sshpass -p "fgiqczrpiz" ssh-copy-id -o StrictHostKeyChecking=no user@10.130.0.28

# setup kubernetes cluster 1.31 with kubespray 

# 1. Клонируем репозиторий и переходим на тег v2.28.0
cd /home/user
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
git checkout v2.28.0

# 2. Подготовка Python окружения
python3 -m venv venv
source venv/bin/activate
pip install -U pip
pip install -r requirements.txt

# 3. Создание инвентаря с НОВЫМИ IP-адресами
mkdir -p inventory/mycluster
cp -rfp inventory/sample/group_vars inventory/mycluster/

cat <<EOF > inventory/mycluster/inventory.ini
[all]
kube-master ansible_host=10.130.0.41 ip=10.130.0.41 etcd_member_name=etcd1
kube-node01 ansible_host=10.130.0.16 ip=10.130.0.16 etcd_member_name=etcd2
kube-node02 ansible_host=10.130.0.28 ip=10.130.0.28 etcd_member_name=etcd3

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

# 4. Настройка версии 1.31.0 и параметров
# Задаем версию 1.31.0
sed -i 's/^kube_version: .*/kube_version: v1.31.0/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# Включаем Containerd (стандарт для новых версий)
sed -i 's/^container_manager: .*/container_manager: containerd/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
# Включаем HA etcd режим (host) для надежности при обновлениях
sed -i 's/^etcd_deployment_type: .*/etcd_deployment_type: host/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

cat <<EOF >> inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
kube_version: 1.31.0
etcd_deployment_type: host
EOF

# Проверяем и устанавливаем версию и тип etcd
sed -i 's/^kube_version: .*/kube_version: v1.31.0/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's/^etcd_deployment_type: .*/etcd_deployment_type: host/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

grep -E "kube_version:|kubernetes_audit:|kube_encrypt_secret_data:|etcd_deployment_type:" inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# 5. Запуск развертывания
# checks before
ansible -i inventory/mycluster/inventory.ini all -m ping -u user --become
ansible-playbook -i inventory/mycluster/inventory.ini --syntax-check cluster.yml
# deploy if all is ok
ansible-playbook -i inventory/mycluster/inventory.ini -u user -b --become-user=root cluster.yml -e ignore_assert_errors=yes

# 6. Настройка доступа и проверка

mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Проверяем узлы
kubectl get nodes -o wide

# Фаза 2: Обновление до v1.32.0

# update repo

cd /home/user/kubespray
git fetch --all
git checkout v2.29.1

# Обновляем зависимости (в новой версии Kubespray могут быть новые требования к Ansible)
pip install -r requirements.txt

# Меняем целевую версию в конфиге:

sed -i 's/kube_version: 1.31.0/kube_version: 1.32.0/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# Проверяем, что замена прошла успешно
grep "kube_version:" inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# Запуск обновления до 1.32.0

ansible-playbook -i inventory/mycluster/inventory.ini -u user -b --become-user=root upgrade_cluster.yml -e ignore_assert_errors=yes

kubectl get nodes

# Фаза 3: Обновление до v1.33.0

# Меняем 1.32.0 на 1.33.7
sed -i 's/kube_version: 1.32.0/kube_version: 1.33.7/' inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# Проверяем
grep "kube_version:" inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# Запуск обновления до 1.33.7

ansible-playbook -i inventory/mycluster/inventory.ini -u user -b --become-user=root upgrade_cluster.yml -e ignore_assert_errors=yes

# checks

kubectl get nodes
kubectl top nodes
sudo ls -lh /var/log/kubernetes/audit/
kubectl create secret generic top-secret --from-literal=password=kubespray-rules
sudo etcdctl --endpoints=https://127.0.0.1:2379 --cacert=/etc/ssl/etcd/ssl/ca.pem --cert=/etc/ssl/etcd/ssl/admin-kube-master.pem --key=/etc/ssl/etcd/ssl/admin-kube-master-key.pem get /registry/secrets/default/top-secret | hexdump -C