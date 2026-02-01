kubectl create namespace test-rbac
kubectl create serviceaccount test-user -n test-rbac
kubectl create serviceaccount test-admin -n test-rbac

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: test-user-token
  namespace: test-rbac
  annotations:
    kubernetes.io/service-account.name: test-user
type: kubernetes.io/service-account-token
EOF

USER_TOKEN=$(kubectl get secret test-user-token -n test-rbac -o jsonpath="{.data.token}" | base64 -d)
echo "Токен для test-user:"
echo $USER_TOKEN

Токен для test-user:
eyJhbGciOiJSUzI1NiIsImtpZCI6Ii04TTQtM3lyQVFVYnlON2dSMFpsd1Y3cnFuUTd5Ylo0bVVqSVJZeE5aemcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJ0ZXN0LXJiYWMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoidGVzdC11c2VyLXRva2VuIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InRlc3QtdXNlciIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6IjM5NzliZWUwLWE2MDQtNGZlMC04MDFkLTM4YjQ0ZWZjM2I0ZCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDp0ZXN0LXJiYWM6dGVzdC11c2VyIn0.ZYfR5nbZoi-_VFgKiZn1KGQqp6R3xCMr_a2A9KVGpOVw5nW-KubiidfHfr5qC6w-L18hLV68H7rC0xjr_H8EzFeHWo3FdzHY9TYDgC62rQ7_vrOtJsVzTPRebj6dyPgNkZsTLGow_FISKIN6yq_i2Cds7Id8VBRSCs0iXwo_xcNtOqiPD1ntNqUFCIDokkgdtBdVyesmDJjMR4yB-hsRIRMBaVhpJ9AIkrV4U3KGaRH0j2xgVA5czZt0qA6xAlLsqjYwraOg9Mqw8R5_lPt7Mezb7RbGYQmpjvd3h3A67gtrWvzr2F8xWfi2A1lvZhOgLoxvG3wGFdhjMZ7N7FDzMQ

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: test-admin-token
  namespace: test-rbac
  annotations:
    kubernetes.io/service-account.name: test-admin
type: kubernetes.io/service-account-token
EOF

ADMIN_TOKEN=$(kubectl get secret test-admin-token -n test-rbac -o jsonpath="{.data.token}" | base64 -d)
echo "Токен для test-admin:"
echo $ADMIN_TOKEN

Токен для test-admin:
eyJhbGciOiJSUzI1NiIsImtpZCI6Ii04TTQtM3lyQVFVYnlON2dSMFpsd1Y3cnFuUTd5Ylo0bVVqSVJZeE5aemcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJ0ZXN0LXJiYWMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlY3JldC5uYW1lIjoidGVzdC1hZG1pbi10b2tlbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJ0ZXN0LWFkbWluIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiNDRkNjY4YzgtMTc0ZS00NjA3LWEyMzktMDM1ZjQ0YzYzNGUxIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OnRlc3QtcmJhYzp0ZXN0LWFkbWluIn0.zgfJQY0eCosASxkO9b-oucfqc1T9lDgxyLM9ihdxZG_ibmocf-TZtiHU6-Oa2O85WqmojjW6pTWLz2w3O6Fu8L9c9K60Lpi3Uhif2fWf8EAl7Qk0nhFkVI4HCi4Tu5-XMJ6MY-SEWgYBh3X7-SpaaYrhHznpWW172879dQi24-yt8J_Y4nJzW_q5cnc2aKiUwP0QPxmrn1XiXerCH8zyeN2yTlhxXNyTd50bqnNbFH7oj8RerVkJF3AeMcrYXSt7nYKiagbiybGLYXRxOuINYCEZcN6pCcB-xN4ONlsg46Ov6tBSf7Q0H9UYHs9C4tuQBbhhtvq2ruUgYyOwe5Xi2Q

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: test-rbac
  name: test-role
rules:
# Права на ServiceAccounts: все, кроме удаления
- apiGroups: [""]
  resources: ["serviceaccounts"]
  verbs: ["get", "list", "watch", "create", "update", "patch"]

# Права на Pods: только чтение
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
EOF

# do role binding

kubectl create rolebinding test-binding \
  --role=test-role \
  --serviceaccount=test-rbac:test-user \
  --namespace=test-rbac

# check grants

kubectl auth can-i create serviceaccounts --as=system:serviceaccount:test-rbac:test-user -n test-rbac
kubectl auth can-i delete serviceaccounts --as=system:serviceaccount:test-rbac:test-user -n test-rbac
kubectl auth can-i create rolebindings --as=system:serviceaccount:test-rbac:test-user -n test-rbac

# task 6

kubectl create rolebinding admin-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=test-rbac:test-admin \
  --namespace=test-rbac

# check grants

kubectl auth can-i "*" "*" --as=system:serviceaccount:test-rbac:test-admin -n test-rbac
kubectl auth can-i delete namespaces --as=system:serviceaccount:test-rbac:test-admin
kubectl auth can-i get pods --as=system:serviceaccount:test-rbac:test-admin -n default

# task 7

CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')

sudo chown -R $(id -u):$(id -g) $HOME/.kube

kubectl config set-credentials test-user --token=$USER_TOKEN

CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')

kubectl config set-context sa-context \
  --cluster=$CLUSTER_NAME \
  --user=test-user \
  --namespace=test-rbac

kubectl --context sa-context -n test-rbac get sa

# checks

kubectl --context sa-context -n test-rbac delete sa default

# Попытка создать привязку (должна вернуться ошибка Forbidden)
kubectl --context sa-context -n test-rbac create rolebinding fail-binding --role=test-role --serviceaccount=test-rbac:test-user

# add admin

kubectl config set-credentials test-admin --token=$ADMIN_TOKEN

kubectl config set-context admin-context \
  --cluster=$CLUSTER_NAME \
  --user=test-admin \
  --namespace=test-rbac

# check for admin

# Попробуем получить список секретов (test-user этого не мог)
kubectl --context admin-context -n test-rbac get secrets

# Попробуем создать тестовый ServiceAccount и тут же его удалить
kubectl --context admin-context -n test-rbac create sa temporary-sa
kubectl --context admin-context -n test-rbac delete sa temporary-sa