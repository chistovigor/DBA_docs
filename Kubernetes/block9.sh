kubectl create secret docker-registry regcred \
  --docker-server=registry.rebrainme.com \
  --docker-username=pull-creds \
  --docker-password=gldt-HtG_JHBMXyzCCiJAgpzh

  kubectl run tmp --image=nginx --restart=Never

  # wait until pod is in Running state

kubectl exec tmp -- cat /etc/nginx/nginx.conf > nginx.conf

kubectl delete pod tmp

vim nginx.conf

#change in the file:
# worker_processes  4;

kubectl create configmap nginx-config --from-file=nginx.conf


kubectl create secret generic creds \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=rebrain \
  --from-literal=password=secret

  cat nginx-pod.yaml


  apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  # Используем созданный секрет для скачивания образа
  imagePullSecrets:
    - name: regcred
  containers:
    - name: nginx
      image: registry.rebrainme.com/workshops/middle/kubernetes-local/newplatform_autochecks/nginx:latest
      env:
        # Переменные из секрета
        - name: COOL_USER
          valueFrom:
            secretKeyRef:
              name: creds
              key: username
        - name: COOL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: creds
              key: password
        # Переменная через Downward API
        - name: MY_NODE
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
      volumeMounts:
        # Монтируем файл конфига
        - name: config-volume
          mountPath: /etc/nginx/nginx.conf
          subPath: nginx.conf # Важно: заменяет только файл, а не всю папку
      ports:
        - containerPort: 80
  volumes:
    - name: config-volume
      configMap:
        name: nginx-config


kubectl apply -f nginx-pod.yaml

#check variables

kubectl exec nginx -- env | grep -E "COOL|MY_NODE"

# check nginx config

kubectl exec nginx -- cat /etc/nginx/nginx.conf | grep worker_processes

kubectl get pod nginx