# Шаг 1: Установка Metrics Server

wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# add --kubelet-insecure-tls to the args of metrics-server container

containers:
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
        - --kubelet-use-node-status-port
        - --metric-resolution=15s
        - --kubelet-insecure-tls # <--- Добавить эту строку
        image: registry.k8s.io/metrics-server/metrics-server:v0.7.1

kubectl apply -f components.yaml

# wait 2-3 minutes and check

kubectl top nodes

# Шаг 2: Создание Deployment my-service

cat deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-service
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: my-service
  template:
    metadata:
      labels:
        app: my-service
    spec:
      containers:
      - name: busybox
        image: busybox:1.36
        # Команда dd загружает одно ядро CPU на 100%
        command: ["sh", "-c", "dd if=/dev/zero of=/dev/null bs=500M"]
        resources:
          requests:
            cpu: "200m"  # Запрашиваем 0.2 ядра. 20% от этого = 40m
          limits:
            cpu: "500m"

kubectl apply -f deployment.yaml

# Шаг 3: Создание HorizontalPodAutoscaler

cat hpa.yaml

apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-my-service
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-service
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 20 # Порог срабатывания — 20% от requests

kubectl apply -f hpa.yaml

# Шаг 4: Мониторинг масштабирования

kubectl get hpa -w

kubectl get pods -l app=my-service -w