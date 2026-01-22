kubectl get nodes

# Шаг 1: Маркировка узлов (Node Labeling)

kubectl label node kube-node01-dlypu usecase=job-node
kubectl label node kube-node02-dlypu usecase=job-node

# Шаг 2: Создание CronJob (cron-test)

cat cron-test.yaml

apiVersion: batch/v1
kind: CronJob
metadata:
  name: cron-test
  namespace: default
spec:
  schedule: "*/10 * * * *" # Раз в 10 минут
  jobTemplate:
    spec:
      template:
        spec:
          nodeSelector:
            usecase: job-node # Ограничение запуска по метке
          containers:
          - name: busybox
            image: busybox:1.36
            command: ["sh", "-c", "ping google.com -c 5"]
          restartPolicy: OnFailure

kubectl apply -f cron-test.yaml

# Шаг 3: Создание Job с Init-контейнером (job-test)

cat job-test.yaml

apiVersion: batch/v1
kind: Job
metadata:
  name: job-test
  namespace: default
spec:
  template:
    spec:
      initContainers:
      - name: pre-ping
        image: busybox:1.36
        command: ["sh", "-c", "ping 8.8.8.8 -c 5"]
      containers:
      - name: main-ping
        image: busybox:1.36
        command: ["sh", "-c", "ping 77.88.8.8 -c 5"]
      restartPolicy: Never

kubectl apply -f job-test.yaml

# Шаг 4: Изучение и проверка (Manual Debug)

kubectl get pods

kubectl describe pod <pod_name_of_job-test>

kubectl logs <pod_name_of_job-test>

kubectl get cronjob