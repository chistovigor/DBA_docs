# --- Шаг 1. Установка Helm и Ingress-Nginx ---
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.nodePorts.http=32080 \
  --set controller.service.nodePorts.https=32443

# --- Шаг 2. Патчинг адреса балансировщика ---
# Используем IP, который выдало облако (158.160.227.164), так как 84.201.169.7 не принимал трафик на 80 порт
kubectl -n ingress-nginx patch svc ingress-nginx-controller -p '{"spec":{"externalIPs":["158.160.227.164"]}}'

# --- Шаг 3. Создание приложения (Deployment + Service) ---
kubectl create deployment nginx-dp --image=nginx --namespace=default
kubectl expose deployment nginx-dp --name=svc-internal --port=80 --namespace=default

# --- Шаг 4. Установка Cert-Manager ---
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager --create-namespace \
  --set installCRDs=true

# --- Шаг 5. Настройка ClusterIssuer (Staging) ---
# Используем staging, чтобы избежать ошибок 429 Rate Limit на доменах nip.io/sslip.io
cat > cluster-issuer.yaml <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: student-k8s-work-84@gmail.com
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

kubectl apply -f cluster-issuer.yaml

# --- Шаг 6. Создание Ingress и получение сертификата ---
# Используем nip.io и отключаем ssl-redirect для прохождения проверки HTTP-01
cat > nginx-ingress.yaml <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: default
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - dp.158.160.227.164.nip.io
    secretName: tls-cert
  rules:
  - host: dp.158.160.227.164.nip.io
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

kubectl apply -f nginx-ingress.yaml

# --- Шаг 7. Проверка ---
# Ожидаем статус READY: True
sleep 60 && kubectl get certificate tls-cert