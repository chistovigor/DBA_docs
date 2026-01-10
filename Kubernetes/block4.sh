https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.30/#pod-v1-core

# what is pod ?

https://habr.com/ru/companies/flant/articles/427819/

# useful for pods issues diagnostics !

https://kubernetes.io/ru/docs/tutorials/kubernetes-basics/explore/explore-intro/

kubectl get pods - посмотреть статус всех подов в неймспейсе;
kubectl describe pod - посмотреть расширенную информацию и события/ошибки, связанные с запуском пода;
kubectl get pod -o yaml - когда хотим посмотреть, что не так с манифестом. Обычно помогает при синтаксических ошибках;
kubectl logs pod - логи пода;
kubectl logs pod -с container_name - логи конкретного контейнера в поде;
kubectl get events - посмотреть, какие события происходили в данном неймпсейсе

# practice

2. cat pod.yaml

apiVersion: v1
kind: Pod
metadata:
  name: nginx          # Имя пода
spec:
  containers:
  - name: mynginx      # Имя контейнера
    image: nginx:stable-alpine3.17 # Образ

kubectl apply -f pod.yaml

or

kubectl run nginx --image=nginx:stable-alpine3.17 --dry-run=client -o yaml > pod.yaml
# Отредактируйте имя контейнера в pod.yaml на mynginx и запустите:
kubectl apply -f pod.yaml

kubectl get pods

3-5. 

Используя утилиту kubectl, добавьте вашему поду аннотацию “iddqd=true”.
Используя утилиту kubectl, добавьте вашему поду лейбл “blacklabel=true”.
Изучите флаги команды kubectl get pods и сделайте вызов команды так, чтобы получить все метки, присвоенные вашему поду.


kubectl annotate pod nginx iddqd=true
kubectl label pod nginx blacklabel=true
kubectl get pods nginx --show-labels

6. Изучите флаг --output и получите ip-адрес пода и имя ноды, на которой он запущен.

kubectl get pod nginx -o wide

7. Используя знания из п. 6, модифицируйте команду kubectl api-resources, 
чтобы узнать, какие действия (”VERBS”), с точки зрения API, возможны над подами.

kubectl api-resources --verbs=get -o wide | grep -w pods