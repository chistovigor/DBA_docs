# find CA at any worker node

sudo cat /etc/kubernetes/pki/ca.crt

# find certificates at master node

ls -alth /etc/kubernetes/pki

# copy ca.crt content from worker node to master node

vim /etc/kubernetes/pki/ca.crt

# Шаг 2: Генерируем сертификаты API-сервера

sudo kubeadm init phase certs apiserver
# На всякий случай перегенерируем и остальные основные
sudo kubeadm init phase certs apiserver-kubelet-client
sudo kubeadm init phase certs front-proxy-client

# check api server config

cat /etc/kubernetes/manifests/kube-apiserver.yaml

# replace 

--tls-cert-file=/etc/kubernetes/pki/WHERE_IS_MY_CERT_DUDE.crt
# with
--tls-cert-file=/etc/kubernetes/pki/apiserver.crt

# Обновляем Kubeconfig (Финальный штрих)

# 1. Генерируем новый admin.conf
sudo kubeadm init phase kubeconfig admin

# 2. Копируем его пользователю root
mkdir -p /root/.kube
sudo cp /etc/kubernetes/admin.conf /root/.kube/config
sudo chown root:root /root/.kube/config

#Проверка
#Подождите около 30 секунд. kubelet увидит, что файл 
/etc/kubernetes/manifests/kube-apiserver.yaml 
#изменился, и автоматически перезапустит под API-сервера с правильными параметрами.

kubectl get nodes

kubectl get pods -n kube-system
