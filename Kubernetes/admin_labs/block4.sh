# === 1. Подготовка всех узлов (Master, Node01, Node02) ===

# 1. Отключаем swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# 2. Модули ядра
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay
sudo modprobe br_netfilter

# 3. Сетевые параметры
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# 4. Установка containerd
sudo apt-get update
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
# Важно: включаем SystemdCgroup для стабильности v1.28
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
sudo systemctl restart containerd

# 5. Установка компонентов K8s (v1.28)
sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# === 2. Инициализация Мастера (kube-master) ===

sudo kubeadm init \
  --apiserver-advertise-address=10.130.0.32 \
  --pod-network-cidr=192.168.0.0/16 \
  --node-name kube-master

# Настройка конфига для пользователя root
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# === Оживляем сеть (Calico) ===

# 1. Устанавливаем Calico через единый манифест (без оператора)
# Это гарантирует, что поды будут в kube-system
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# 2. Принудительно указываем интерфейс eth0
# Это лечит статус NotReady в облачных лабах
kubectl set env daemonset/calico-node -n kube-system IP_AUTODETECTION_METHOD=interface=eth0

# === 3. Присоединение узлов (Node01 и Node02) ===
# Выполните join-команду, полученную на этапе init, на воркерах.

# 4. Проверка состояния кластера (kube-master)

kubectl get nodes -o wide