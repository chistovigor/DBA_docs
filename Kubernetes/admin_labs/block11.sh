# Шаг 1: Установка Metrics Server

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

#kubectl patch deployment metrics-server -n kube-system --type='json' \
#  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# Шаг 2: Установка Vertical Pod Autoscaler

  # Клонируем репозиторий (если git нет, установите: sudo apt install git)
git clone https://github.com/kubernetes/autoscaler.git
cd autoscaler/vertical-pod-autoscaler/

# Запускаем скрипт установки
./hack/vpa-up.sh

# Шаг 3: Создание деплоймента alpine-dp

# 2. Создаем чистый манифест деплоймента
cat > alpine-dp.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alpine-dp
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alpine-vpa
  template:
    metadata:
      labels:
        app: alpine-vpa
    spec:
      containers:
      - name: alpine-dp
        image: alpine
        command: ["/bin/sh", "-c", "dd if=/dev/zero of=/dev/null"]
        resources:
          requests:
            cpu: 200m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 128Mi
EOF

# 3. Создаем манифест VPA
cat > vpa-alpine.yaml <<EOF
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: vpa-alpine
  namespace: default
spec:
  targetRef:
    apiVersion: "apps/v1"
    kind: Deployment
    name: alpine-dp
  updatePolicy:
    updateMode: "Off"
EOF

# 4. Применяем всё сразу
kubectl apply -f alpine-dp.yaml
kubectl apply -f vpa-alpine.yaml

# создать ResourceQuota для дефолтного неймспейса, который ограничивает ресурсы, которые могут быть запрошены и выделены для подов в этом неймспейсе. Это поможет нам увидеть, как VPA будет рекомендовать изменения в ресурсах для нашего деплоймента alpine-dp.

cat > ns-limit.yaml <<EOF
apiVersion: v1
kind: ResourceQuota
metadata:
  name: ns-limit
  namespace: default
spec:
  hard:
    cpu: 1000m
    memory: 1Gi
    pods: "10"
EOF

kubectl apply -f ns-limit.yaml

# Шаг 5: Проверка

kubectl describe vpa vpa-alpine

kubectl get resourcequota ns-limit -o yaml -n default