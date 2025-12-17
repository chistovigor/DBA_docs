https://kubernetes.io/ru/docs/setup/learning-environment/minikube/

https://minikube.sigs.k8s.io/docs/handbook/deploying/

https://earthly.dev/blog/managing-k8s-with-kubeadm/

# useful for read !

https://selectel.ru/blog/kubernetes-review/

# practical tasks for block

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

sudo install minikube-linux-amd64 /usr/local/bin/minikube

minikube version

sudo apt-get update

sudo apt-get install ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -aG docker $USER && newgrp docker

docker run hello-world

minikube start --driver docker

minikube addons list

minikube addons enable ingress && minikube addons enable metrics-server

# check

minikube kubectl -- get pods -A

alias kubectl="minikube kubectl --"

# Проверка потребления ресурсов узлом
kubectl top node

# исправление ошибки с запуском вне контейнера

minikube delete
minikube start --container-runtime=containerd

minikube addons enable ingress && minikube addons enable metrics-server

kubectl get pods -A