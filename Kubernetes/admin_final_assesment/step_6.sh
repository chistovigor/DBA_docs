# Шаг 1: Установка Helm (если еще нет)

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Шаг 2: Создание хранилища (Local Path Provisioner)

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

# Сделаем его стандартным
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Шаг 3: Установка Prometheus (Namespace: prometheus)

kubectl create namespace prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack -n prometheus

# Шаг 4: Установка ELK/EFK (Namespace: logging/elasticsearch)

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

# Делаем его основным
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

kubectl create namespace elasticsearch

cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch
  namespace: elasticsearch
spec:
  serviceName: elasticsearch
  replicas: 1
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:7.17.10
        env:
        - name: discovery.type
          value: single-node
        - name: ES_JAVA_OPTS
          value: "-Xms512m -Xmx512m"
        ports:
        - containerPort: 9200
        resources:
          limits:
            memory: 1Gi
---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: elasticsearch
spec:
  selector:
    app: elasticsearch
  ports:
  - port: 9200
EOF

# 3. Разворачиваем Prometheus (Namespace: prometheus)

helm uninstall prometheus -n prometheus
helm uninstall fluent-bit -n logging

kubectl create namespace prometheus
helm install prometheus prometheus-community/prometheus -n prometheus \
  --set server.persistentVolume.storageClass=local-path \
  --set alertmanager.enabled=false \
  --set pushgateway.enabled=false

  # 2. Установка Logging (Fluent-bit)

  kubectl create namespace logging || true
helm install fluent-bit prometheus-community/fluent-bit -n logging \
  --set backend.type=es \
  --set backend.es.host=elasticsearch.elasticsearch.svc.cluster.local