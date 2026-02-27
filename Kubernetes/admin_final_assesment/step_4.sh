# 2. Установка ArgoCD

# Создаем namespace
kubectl create namespace argocd

# Устанавливаем стабильную версию
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml --server-side --force-conflicts

# check

kubectl get pods -n argocd

# Финальный аккорд: Доступ к UI

# check password for admin user
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo