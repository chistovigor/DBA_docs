# application deployment

cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: team-one-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/chistovigor/DBA_docs.git'
    targetRevision: master
    path: Kubernetes/admin_final_assesment
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: team-one
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF



ssh -L 443:127.0.0.1:443 user@158.160.139.255

# checks

kubectl get nodes -o wide
kubectl get all -n elasticsearch
kubectl get all -n prometheus
kubectl get all -n logging
kubectl get pv
kubectl get pvc -A