# Шаг 1: Установка Nginx Ingress-контроллера

# Добавляем репозиторий
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Устанавливаем чарт с нужными портами
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.nodePorts.http=32080 \
  --set controller.service.nodePorts.https=32443

  # Проверяем установку

sleep 60 && kubectl -n ingress-nginx get svc

# Шаг 2: Выполняем "работу облака" (Патчинг сервиса)

# 1. Прописываем externalIP
kubectl -n ingress-nginx patch svc ingress-nginx-controller -p '{"spec":{"externalIPs":["158.160.223.147"]}}'

# 2. Фиксируем loadBalancerIP
kubectl -n ingress-nginx patch svc ingress-nginx-controller -p '{"spec":{"loadBalancerIP":"158.160.223.147"}}'

# 3. Проверяем результат
kubectl -n ingress-nginx get svc

# Шаг 3: Настройка Basic-аутентификации

# Устанавливаем утилиту htpasswd (если её нет)
sudo apt-get update && sudo apt-get install -y apache2-utils

# Создаем файл auth с учетными данными
htpasswd -bc auth user password

# Создаем Secret в namespace default
kubectl create secret generic basic-auth --from-file=auth --namespace=default

# Шаг 4: Развертывание тестового приложения nginx-dp

# Создаем Deployment
kubectl create deployment nginx-dp --image=nginx --namespace=default

# Создаем сервис ClusterIP
kubectl expose deployment nginx-dp --name=svc-internal --port=80 --namespace=default

# Шаг 5: Создание Ingress ресурса

cat > ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-nginx
  namespace: default
  annotations:
    # Указываем Ingress-контроллеру использовать basic auth
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
spec:
  ingressClassName: nginx
  rules:
  - host: dp.158.160.223.147.sslip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: svc-internal
            port:
              number: 80
EOF

# Применяем манифест
kubectl apply -f ingress.yaml

# Шаг 6: Проверка работоспособности

# Пробуем зайти без пароля (должен быть отказ - 401 Unauthorized)
curl -I http://dp.158.160.223.147.sslip.io

# Пробуем зайти с логином и паролем (должен быть 200 OK)
curl -I -u user:password http://dp.158.160.223.147.sslip.io