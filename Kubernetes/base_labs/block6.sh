# do from master

kubectl get nodes

cat my-app.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      nodeName: kube-node02-xmmfd  # Ваше точное имя ноды
      containers:
      - name: nginx
        image: nginx:alpine
        resources:
          requests:
            cpu: "100m"
            memory: "128Mi"
          limits:
            cpu: "100m"
          # Чтобы класс был Guaranteed, limits должны строго равняться requests
            memory: "128Mi"

kubectl apply -f my-app.yaml

kubectl uncordon kube-node02-xmmfd

kubectl describe node kube-node02-xmmfd | grep Taints

kubectl taint nodes kube-node02-xmmfd dedicated=special:NoSchedule-

kubectl get pods -o custom-columns=NAME:.metadata.name,NODE:.spec.nodeName,STATUS:.status.phase,QOS:.status.qosClass