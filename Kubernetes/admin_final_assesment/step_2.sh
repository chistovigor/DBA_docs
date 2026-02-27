# Шаг 1: Создание Namespace и квот

vim team-one-setup.yaml

apiVersion: v1
kind: Namespace
metadata:
  name: team-one
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-one-quota
  namespace: team-one
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: team-one-limits
  namespace: team-one
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 200m
      memory: 256Mi
    type: Container

kubectl apply -f team-one-setup.yaml

# Шаг 2: Проверка StorageClass

kubectl get sc

# исправление DNS

kubectl get cm coredns -n kube-system -o yaml | sed 's/forward . \/etc\/resolv.conf/forward . 8.8.8.8 1.1.1.1/g' | kubectl apply -f -

kubectl delete pod -n kube-system -l k8s-app=kube-dns

sleep 30 && kubectl get pods -n kube-system -l k8s-app=kube-dns

# 1. Настройка Namespace team-one (Квоты и Лимиты)

cat <<EOF > team-one-setup.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: team-one
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: team-one-quota
  namespace: team-one
spec:
  hard:
    pods: "10"
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
---
apiVersion: v1
kind: LimitRange
metadata:
  name: team-one-limits
  namespace: team-one
spec:
  limits:
  - default:
      cpu: 500m
      memory: 512Mi
    defaultRequest:
      cpu: 200m
      memory: 256Mi
    type: Container
EOF

kubectl apply -f team-one-setup.yaml

# проверка

kubectl get quota -n team-one && kubectl get limitrange -n team-one