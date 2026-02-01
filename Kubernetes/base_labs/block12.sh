ssh to master node

# Шаг 1: Подготовка меток (Labels)

kubectl get nodes  --show-labels

kubectl label node kube-master-ldaiu ingress=true
kubectl label node kube-node02-ldaiu ingress=true


# Шаг 1.2: Установка Local Path Provisioner

kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml
kubectl get sc

# Шаг 2: Развертывание Kafka (StatefulSet)

cat kafka.yaml

apiVersion: v1
kind: Service
metadata:
  name: kafka-svc
spec:
  clusterIP: None
  selector:
    app: kafka
  ports:
  - port: 9092
    name: broker
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: kafka-sts
spec:
  serviceName: "kafka-svc"
  replicas: 3
  selector:
    matchLabels:
      app: kafka
  template:
    metadata:
      labels:
        app: kafka
    spec:
      containers:
      - name: kafka # Имя контейнера по заданию
        image: alpine:3.19
        command: ["/bin/sh", "-c", "sleep infinity"]
        volumeMounts:
        - name: kafka-pvc
          mountPath: /bitnami/kafka # Путь монтирования
  volumeClaimTemplates:
  - metadata:
      name: kafka-pvc # Имя PVC по заданию
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: "local-path" # Наш рабочий провижионер
      resources:
        requests:
          storage: 1Gi


kubectl apply -f kafka.yaml

# Шаг 3: Развертывание DaemonSet (my-special-service)

cat ds.yaml

apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: my-special-service
spec:
  selector:
    matchLabels:
      app: special-worker
  template:
    metadata:
      labels:
        app: special-worker
    spec:
      nodeSelector:
        ingress: "true"
      # Эти допуски позволяют игнорировать статус "control-plane" на мастере
      tolerations:
      - key: node-role.kubernetes.io/master
        operator: Exists
        effect: NoSchedule
      - key: node-role.kubernetes.io/control-plane
        operator: Exists
        effect: NoSchedule
      containers:
      - name: alpine
        image: alpine:3.19
        command: ["sh", "-c", "sleep infinity"]


kubectl apply -f ds.yaml

# Шаг 4: Проверка результатов

#Проверка Kafka: 
kubectl get pods -l app=kafka -o wide 
#Вы должны увидеть три пода (0, 1, 2), распределенные по вашим нодам.

#Проверка DaemonSet: 
kubectl get pods -l app=special-worker -o wide 
kubectl get pods -o wide
#Проверьте колонку NODE: поды должны быть запущены только на kube-master-ldaiu и kube-node02-ldaiu.

#Проверка дисков: 
kubectl get pvc
# Должно быть 3 PVC с именами kafka-pvc-kafka-sts-0/1/2 в статусе Bound.