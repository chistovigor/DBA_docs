# Создание ResourceQuota (ns-limit)

vim ns-limit.yaml

apiVersion: v1
kind: ResourceQuota
metadata:
  name: ns-limit
  namespace: default
spec:
  hard:
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "20"

# Создание LimitRange (pod-limit)

vim pod-limit.yaml

apiVersion: v1
kind: LimitRange
metadata:
  name: pod-limit
  namespace: default
spec:
  limits:
  - type: Pod
    max:
      cpu: "1"
      memory: 1Gi
    min:
      cpu: 200m
      memory: 128Mi

# Применение манифестов

kubectl apply -f ns-limit.yaml
kubectl apply -f pod-limit.yaml

# check results

# Проверяем квоту неймспейса
kubectl get resourcequota ns-limit -n default -o yaml

# Проверяем лимиты подов
kubectl describe limitrange pod-limit -n default