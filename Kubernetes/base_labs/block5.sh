kubectl create deployment nginx-ds --image=nginx:alpine3.17 --replicas=3
kubectl get pods

kubectl rollout pause deployment/nginx-ds

kubectl set image deployment/nginx-ds nginx=nginx:alpine3.18

kubectl describe deployment nginx-ds

kubectl rollout resume deployment/nginx-ds

kubectl rollout status deployment/nginx-ds
kubectl describe deployment nginx-ds