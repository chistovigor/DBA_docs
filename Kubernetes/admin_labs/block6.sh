# upgrade cluster from 1.34.0 to 1.35.X

# Шаг 0: Подготовка (на Мастере)

apt-cache policy kubeadm | grep -A 5 "1.34"
apt-cache policy kubeadm | grep -A 5 "1.35"

# Шаг 1: Обновление Мастера (kube-master-teiff)
# 1. Обновляем kubeadm до 1.35.0

sudo apt-mark unhold kubeadm
sudo apt-get update && sudo apt-get install -y kubeadm=1.35.0-1.1
sudo apt-mark hold kubeadm

# 2. Проверяем план обновления

sudo kubeadm upgrade plan

sudo kubeadm upgrade apply v1.35.0

# Завершение на Мастере

# Снимаем защиту с пакетов
sudo apt-mark unhold kubelet kubectl

# Устанавливаем версию 1.35.0
sudo apt-get update && sudo apt-get install -y kubelet=1.35.0-1.1 kubectl=1.35.0-1.1

# Возвращаем защиту и перезапускаем
sudo apt-mark hold kubelet kubectl
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Шаг 2: Обновление Воркер-нод (node01 и node02) - строго по очереди

# На Мастере подготовьте ноду:

kubectl drain kube-node01-teiff  --ignore-daemonsets

# На Воркер-ноде (node01) обновите ПО:

sudo apt-mark unhold kubeadm kubelet kubectl
sudo apt-get update && sudo apt-get install -y kubeadm=1.35.0-1.1 kubelet=1.35.0-1.1 kubectl=1.35.0-1.1

# Выполняем апгрейд самой ноды
sudo kubeadm upgrade node

sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo apt-mark hold kubeadm kubelet kubectl

# На Мастере верните ноду в строй:

kubectl uncordon kube-node01-teiff

# следующая нода

# На Мастере подготовьте ноду:

kubectl drain kube-node02-teiff --ignore-daemonsets

# На Воркер-ноде (node02) обновите ПО:

sudo apt-mark unhold kubeadm kubelet kubectl
sudo apt-get update && sudo apt-get install -y kubeadm=1.35.0-1.1 kubelet=1.35.0-1.1 kubectl=1.35.0-1.1

# Выполняем апгрейд самой ноды
sudo kubeadm upgrade node

sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo apt-mark hold kubeadm kubelet kubectl

# На Мастере верните ноду в строй:

kubectl uncordon kube-node02-teiff

# Шаг 3: Финальная проверка (на Мастере)

kubectl get nodes