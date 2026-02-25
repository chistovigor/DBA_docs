# подготовка и применение манифестов на мастере

# подготовка и применение манифестов на мастере

#!/bin/bash
set -e

echo "=== 1. Установка Metrics Server ==="
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ || true
helm repo update
helm upgrade --install metrics-server metrics-server/metrics-server \
  --namespace kube-system \
  --set args={--kubelet-insecure-tls}

echo "=== 2. Установка Prometheus Stack ==="
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set prometheus.prometheusSpec.scrapeProtocols='{PrometheusProto,OpenMetricsText1.0.0,OpenMetricsText0.0.1,PrometheusText1.0.0}'

echo "=== 3. Создание Deployment autoscale-dp ==="
# Используем совместимый образ и добавляем ресурсы
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: autoscale-dp
  namespace: default
  labels:
    app: autoscale
spec:
  replicas: 1
  selector:
    matchLabels:
      app: autoscale
  template:
    metadata:
      labels:
        app: autoscale
    spec:
      containers:
      - name: autoscale
        image: registry.k8s.io/hpa-example
        ports:
        - containerPort: 80
          name: metrics
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
EOF

echo "=== 4. Создание Service и ServiceMonitor ==="
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: autoscale-svc
  namespace: default
  labels:
    app: autoscale
spec:
  ports:
  - port: 80
    targetPort: 80
    name: metrics
  selector:
    app: autoscale
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: autoscale-sm
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
spec:
  namespaceSelector:
    matchNames: ["default"]
  selector:
    matchLabels:
      app: autoscale
  endpoints:
  - port: metrics
    interval: 10s
    path: /
    enableHttp2: false
EOF

echo "=== 5. Установка Prometheus Adapter ==="
cat <<EOF > adapter-values.yaml
prometheus:
  url: http://kube-prometheus-stack-prometheus.monitoring.svc
  port: 9090
rules:
  default: true
  custom:
  - seriesQuery: 'http_requests_total{kubernetes_namespace!="",kubernetes_pod_name!=""}'
    resources:
      overrides:
        kubernetes_namespace: {resource: "namespace"}
        kubernetes_pod_name: {resource: "pod"}
    name:
      matches: "^(.*)_total$"
      as: "\${1}"
    metricsQuery: 'sum(rate(<<.Series>>{<<.LabelMatchers>>}[1m])) by (<<.GroupBy>>)'
EOF

helm upgrade --install prometheus-adapter prometheus-community/prometheus-adapter \
  --namespace monitoring \
  -f adapter-values.yaml

echo "=== 6. Создание HPA (чистка старых и создание нового) ==="
kubectl delete hpa --all || true

cat <<EOF | kubectl apply -f -
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: hpa-autoscale
  namespace: default
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: autoscale-dp
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests
      target:
        type: AverageValue
        averageValue: 10
EOF

echo "=== Готово! Ожидание инициализации таргетов (30-60 сек) ==="

# 1. Проверь статус HPA:

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests" | jq .

# 2. Сымитируй нагрузку

# В отдельном терминале (без port-forward, прямо внутри кластера)
kubectl run load-gen --image=busybox:1.28 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://autoscale-svc.default.svc.cluster.local; sleep 0.01; done"

# 1. Проверь статус HPA:

kubectl get --raw "/apis/custom.metrics.k8s.io/v1beta1/namespaces/default/pods/*/http_requests" | jq .

# 2. Сымитируй нагрузку

# В отдельном терминале (без port-forward, прямо внутри кластера)
kubectl run load-gen --image=busybox:1.28 --restart=Never -- /bin/sh -c "while true; do wget -q -O- http://autoscale-svc.default.svc.cluster.local; sleep 0.01; done"