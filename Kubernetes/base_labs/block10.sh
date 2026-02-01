kubectl create deployment dep-main --image=nginx --replicas=1
kubectl create deployment dep-canary --image=nginx --replicas=1

# проверяем нужные лейблы 
kubectl get deployments --show-labels
kubectl label deployment dep-canary app=dep-canary --overwrite

cat services.yaml

apiVersion: v1
kind: Service
metadata:
  name: svc-dep-main
spec:
  selector:
    app: dep-main
  ports:
    - name: http
      port: 8080
      targetPort: 80
    - name: https
      port: 8443
      targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: svc-dep-canary
spec:
  selector:
    app: dep-canary
  ports:
    - name: http
      port: 9090
      targetPort: 80
    - name: https
      port: 9443
      targetPort: 80

kubectl apply -f services.yaml

kubectl run test-curl --image=curlimages/curl -i --tty --rm -- \
  curl -s http://svc-dep-main:8080 && curl -s http://svc-dep-canary:9090

cat ingresses.yaml

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingr-main
spec:
  ingressClassName: nginx
  rules:
  - host: main-158.160.210.235.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: svc-dep-main
            port:
              number: 8080
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingr-canary
spec:
  ingressClassName: nginx
  rules:
  - host: canary-158.160.210.235.nip.io
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: svc-dep-canary
            port:
              number: 9090

kubectl apply -f ingresses.yaml

curl -I http://main-158.160.210.235.nip.io
curl -I http://canary-158.160.210.235.nip.io

sudo apt update && sudo apt install -y apache2-utils

htpasswd -bc auth user password

kubectl create secret generic basic-auth-secret --from-file=auth

kubectl annotate ingress ingr-main \
  nginx.ingress.kubernetes.io/auth-type=basic \
  nginx.ingress.kubernetes.io/auth-secret=basic-auth-secret \
  nginx.ingress.kubernetes.io/auth-realm='Authentication Required'

# Должно вернуть 401 Unauthorized
curl -I http://main-158.160.210.235.nip.io

# Должно вернуть 200 OK
curl -I -u user:password http://main-158.160.210.235.nip.io

# final step

kubectl patch ingress ingr-canary --patch '{
  "metadata": {
    "annotations": {
      "nginx.ingress.kubernetes.io/canary": "true",
      "nginx.ingress.kubernetes.io/canary-weight": "70"
    }
  },
  "spec": {
    "rules": [{
      "host": "main-158.160.210.235.nip.io",
      "http": {
        "paths": [{
          "path": "/",
          "pathType": "Prefix",
          "backend": {
            "service": { "name": "svc-dep-canary", "port": { "number": 9090 } }
          }
        }]
      }
    }]
  }
}'

# check after patch

for i in {1..10}; do curl -u user:password -s -o /dev/null -w "%{http_code}\n" http://main-158.160.210.235.nip.io; done

# switch to canary 100%

kubectl annotate ingress ingr-canary nginx.ingress.kubernetes.io/canary-weight="100" --overwrite