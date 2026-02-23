# Шаг 1: Установка Helm

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
# Проверяем установку
helm version

# Шаг 2: Создание структуры чарта

helm create myhelmchart
cd myhelmchart

# Шаг 3: Настройка ServiceAccount (Самая важная часть)

vim values.yaml

# В файле values.yaml
serviceAccount:
  # Specifies whether a service account should be created
  create: true
  # Annotations to add to the service account
  annotations: {}
  # The name of the service account to use.
  # If not set and create is true, a name is generated using the fullname template
  name: "helm-sa"

vim templates/serviceaccount.yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ include "myhelmchart.serviceAccountName" . }}
  # ... остальное без изменений

vim templates/deployment.yaml

spec:
  # ...
  template:
    spec:
      serviceAccountName: {{ include "myhelmchart.serviceAccountName" . }}

# Шаг 4: Установка чарта

# 1. Создаем namespace
kubectl create namespace helm

# 2. Устанавливаем чарт (находясь в папке над myhelmchart или внутри неё)
# Из папки, где лежит папка myhelmchart (/home/user/myhelmchart):
helm install my-release . -n helm

# Шаг 5: Проверка

kubectl get sa -n helm

kubectl get deployment -n helm -o jsonpath='{.items[0].spec.template.spec.serviceAccountName}'