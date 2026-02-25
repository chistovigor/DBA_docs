# Шаг 1. Установка kube-prometheus-stack

# Добавляем репозиторий
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Создаем namespace и устанавливаем стек
# Имя релиза: kube-prometheus-stack
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace

kubectl get pods -n monitoring

# Шаг 2. Запуск Pod с Redis и Redis Exporter

vim redis-pod.yaml 

apiVersion: v1
kind: Pod
metadata:
  name: redis-pod
  namespace: default
  labels:
    app: redis # Этот лейбл понадобится для PodMonitor
spec:
  containers:
  - name: redis
    image: redis:alpine
    ports:
    - containerPort: 6379
      name: redis
  - name: redis-exporter
    image: oliver006/redis_exporter:alpine
    ports:
    - containerPort: 9121
      name: metrics # Именованный порт для метрик

kubectl apply -f redis-pod.yaml

# Шаг 3. Создание PodMonitor

vim redis-monitor.yaml

apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: redis-monitor
  namespace: default
  labels:
    release: kube-prometheus-stack # Критически важный лейбл для автообнаружения!
spec:
  selector:
    matchLabels:
      app: redis # Ищем поды с этим лейблом
  podMetricsEndpoints:
  - port: metrics # Имя порта из манифеста пода

kubectl apply -f redis-monitor.yaml

# Проверить, что метрики собираются

# Пробрасываем порты 3000 (Grafana) и 9090 (Prometheus) - на локальной машине
ssh -L 3000:localhost:3000 -L 9090:localhost:9090 user@158.160.134.233

# port-forward на мастере для доступа к Grafana и Prometheus из браузера ноутбука

# Для Grafana (в фоне)
kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80 &

# Для Prometheus (в фоне)
kubectl port-forward svc/kube-prometheus-stack-prometheus -n monitoring 9090:9090 &

3. Проверка в браузере ноутбука
Теперь просто открывай на ноутбуке:

Grafana: http://localhost:3000 

#логин: admin, пароль получаем так:
kubectl get secret -n monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

Prometheus: http://localhost:9090