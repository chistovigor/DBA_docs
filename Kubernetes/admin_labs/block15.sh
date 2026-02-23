#!/bin/bash
set -e

# ==========================================
# Этап 1: Подготовка и Базовая Инфраструктура
# ==========================================

# 1. Создаем необходимые namespaces
kubectl create namespace logging --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace cert-manager --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace elastic-system --dry-run=client -o yaml | kubectl apply -f -

# 2. Настройка NFS-сервера (на master-ноде)
sudo apt-get update && sudo apt-get install -y nfs-kernel-server apache2-utils
sudo mkdir -p /srv/nfs/kubedata
sudo chown nobody:nogroup /srv/nfs/kubedata
sudo chmod 777 /srv/nfs/kubedata
# Замени 10.130.0.0/24 на свою подсеть, если она отличается
echo "/srv/nfs/kubedata 10.130.0.0/24(rw,sync,no_subtree_check,no_root_squash)" | sudo tee -a /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-kernel-server

# 3. Установка NFS-провижионера (в kube-system)
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update

# Замени 10.130.0.14 на IP своего NFS-сервера
helm upgrade --install nfs-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
  --namespace kube-system \
  --set nfs.server=10.130.0.14 \
  --set nfs.path=/srv/nfs/kubedata \
  --set storageClass.name=nfs-client \
  --set storageClass.defaultClass=true

# 4. Установка Cert-Manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --set installCRDs=true

# Ожидание готовности Cert-Manager
echo "Ожидание запуска Cert-Manager..."
kubectl wait --for=condition=Ready pods --all -n cert-manager --timeout=300s

# Создание ClusterIssuer (Staging для тестов, замени на Prod URL если требуется)
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: student-k8s@example.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

# ==========================================
# Этап 2: Развертывание Elastic Stack
# ==========================================

# 1. Установка ECK Operator
helm upgrade --install -n elastic-system elastic-operator \
  --set config.containerRegistry=docker.io \
  --set config.containerRepository=elastic \
  --set image.repository=docker.io/elastic/eck-operator \
  --set image.tag=2.14.0 \
  https://download.elastic.co/downloads/eck/2.14.0/elastic-operator-2.14.0.tgz

# 2. Создание Elasticsearch
cat <<EOF | kubectl apply -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: elasticsearch
  namespace: logging
spec:
  version: 8.14.0
  nodeSets:
  - name: default
    count: 1
    config:
      node.store.allow_mmap: false
    podTemplate:
      spec:
        containers:
        - name: elasticsearch
          resources:
            requests:
              memory: 1.5Gi
              cpu: 0.5
            limits:
              memory: 2Gi
              cpu: 1
    volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 5Gi
        storageClassName: nfs-client
EOF

# 3. Создание Kibana
cat <<EOF | kubectl apply -f -
apiVersion: kibana.k8s.elastic.co/v1
kind: Kibana
metadata:
  name: kibana
  namespace: logging
spec:
  version: 8.14.0
  count: 1
  elasticsearchRef:
    name: elasticsearch
EOF

# Ожидание генерации пароля (Elasticsearch должен начать запуск)
echo "Ожидание генерации пароля Elasticsearch..."
sleep 60
export ELASTIC_PASSWORD=$(kubectl get secret elasticsearch-es-elastic-user -n logging -o go-template='{{.data.elastic | base64decode}}')
echo "Пароль пользователя elastic: $ELASTIC_PASSWORD"

# 4. Установка Fluent-bit
helm repo add fluent https://fluent.github.io/helm-charts
helm repo update

cat <<EOF > fluent-bit-values.yaml
config:
  outputs: |
    [OUTPUT]
        Name            es
        Match           *
        Host            elasticsearch-es-http.logging.svc.cluster.local
        Port            9200
        HTTP_User       elastic
        HTTP_Passwd     ${ELASTIC_PASSWORD}
        tls             On
        tls.verify      Off
        Replace_Dots    On
EOF

helm upgrade --install fluent-bit fluent/fluent-bit -n logging -f fluent-bit-values.yaml

# ==========================================
# Этап 3: Настройка Доступа (Ingress)
# ==========================================

# 1. Генерация Basic Auth (логин: admin, пароль: xpujedbgtp)
htpasswd -c -b auth admin xpujedbgtp
kubectl create secret generic kibana-basic-auth --from-file=auth -n logging --dry-run=client -o yaml | kubectl apply -f -
rm auth

# 2. Создание Ingress
# ВНИМАНИЕ: Замени kibana.158.160.228.79.nip.io на свой актуальный домен
DOMAIN="kibana.158.160.228.79.nip.io"

cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kibana-ingress
  namespace: logging
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: kibana-basic-auth
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - ${DOMAIN}
    secretName: kibana-tls-cert
  rules:
  - host: ${DOMAIN}
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kibana-kb-http
            port:
              number: 5601
EOF

echo "Развертывание запущено! Проверьте статус сертификата командой: kubectl get certificate -n logging"