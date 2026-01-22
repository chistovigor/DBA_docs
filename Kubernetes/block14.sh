# Шаг 1: Подготовка пространства и подов

kubectl get nodes

kubectl create ns policy-test

cat pods.yaml

apiVersion: v1
kind: Pod
metadata:
  name: pod-ingress
  namespace: policy-test
  labels:
    app: pod-ingress
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 101 # UID пользователя nginx в unprivileged образе
  containers:
  - name: nginx
    image: nginxinc/nginx-unprivileged:1.25
    securityContext:
      allowPrivilegeEscalation: false
      privileged: false
    ports:
    - containerPort: 8080
---
apiVersion: v1
kind: Pod
metadata:
  name: pod-egress
  namespace: policy-test
  labels:
    app: pod-egress
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 101
  containers:
  - name: nginx
    image: nginxinc/nginx-unprivileged:1.25
    securityContext:
      allowPrivilegeEscalation: false
      privileged: false
    ports:
    - containerPort: 8080

kubectl apply -f pods.yaml

# Шаг 2: Сервисы и Ingress

cat services.yaml

apiVersion: v1
kind: Service
metadata:
  name: pod-ingress
  namespace: policy-test
spec:
  selector:
    app: pod-ingress
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: pod-egress
  namespace: policy-test
spec:
  selector:
    app: pod-egress
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-test
  namespace: policy-test
spec:
  rules:
  - host: policy.example.com # Замените на ваш домен или используйте curl с заголовком
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: pod-ingress
            port:
              number: 80

kubectl apply -f services.yaml

# Шаг 3: Политика Zero Trust

cat zero-trust.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: zero-trust
  namespace: policy-test
spec:
  podSelector: {} # Выбирает все поды в неймспейсе
  policyTypes:
  - Ingress
  - Egress

kubectl apply -f zero-trust.yaml

# Шаг 4: Восстановление доступа для Ingress-контроллера

cat allow-ingress-controller.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-controller
  namespace: policy-test
spec:
  podSelector:
    matchLabels:
      app: pod-ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          # В современных K8s у неймспейсов есть автоматическая метка с их именем
          kubernetes.io/metadata.name: ingress-nginx 
  policyTypes:
  - Ingress

kubectl apply -f allow-ingress-controller.yaml

# Шаг 5: Взаимодействие между подами (Egress -> Ingress)

cat internal-auth.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress-to-ingress
  namespace: policy-test
spec:
  podSelector:
    matchLabels:
      app: pod-egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: pod-ingress
  policyTypes:
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-from-egress
  namespace: policy-test
spec:
  podSelector:
    matchLabels:
      app: pod-ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: pod-egress
  policyTypes:
  - Ingress

kubectl apply -f internal-auth.yaml

cat internal-policies.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-internal-traffic
  namespace: policy-test
spec:
  podSelector:
    matchLabels:
      app: pod-egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: pod-ingress
  - ports: # Разрешаем DNS, чтобы найти IP пода по имени
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP
  policyTypes:
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-from-egress
  namespace: policy-test
spec:
  podSelector:
    matchLabels:
      app: pod-ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: pod-egress
  policyTypes:
  - Ingress

kubectl apply -f internal-policies.yaml

cat allow-egress.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-egress
  namespace: policy-test
spec:
  podSelector:
    matchLabels:
      app: pod-egress
  policyTypes:
  - Egress
  egress:
  # 1. Разрешаем доступ к поду pod-ingress
  - to:
    - podSelector:
        matchLabels:
          app: pod-ingress
  # 2. Разрешаем DNS (без этого curl pod-ingress не сработает)
  - ports:
    - port: 53
      protocol: UDP
    - port: 53
      protocol: TCP

kubectl apply -f allow-egress.yaml

cat allow-ingress.yaml

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress
  namespace: policy-test
spec:
  podSelector:
    matchLabels:
      app: pod-ingress
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: pod-egress

kubectl apply -f allow-ingress.yaml

# Шаг 6: Проверка работы

kubectl get pod,svc,ingress -n policy-test -o wide

kubectl exec -n policy-test pod-ingress -- id

kubectl exec -n policy-test pod-egress -- curl -s -I pod-ingress:80

