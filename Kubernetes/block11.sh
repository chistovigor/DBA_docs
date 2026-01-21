kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.30/deploy/local-path-storage.yaml

kubectl edit cm local-path-config -n local-path-storage

#В открывшемся редакторе найдите строку в секции config.json:
 "paths":["/opt/local-path-provisioner"] 
#и замените её на: 
 "paths":["/opt/kube-volumes"]

 kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

 kubectl get sc

 cat pvc.yaml

 apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-storage
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi

kubectl apply -f pvc.yaml

cat deployment.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-persistent-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: persistent-test
  template:
    metadata:
      labels:
        app: persistent-test
    spec:
      containers:
      - name: persistent-container
        image: alpine:3.19
        command: ["/bin/sh", "-c", "sleep infinity"]
        volumeMounts:
        - name: data
          mountPath: /mnt/my-storage
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: my-storage

kubectl apply -f deployment.yaml

kubectl exec deployment/my-persistent-deployment -- sh -c "echo 'persistent-content' > /mnt/my-storage/pvc.txt"

# check content

kubectl exec deployment/my-persistent-deployment -- cat /mnt/my-storage/pvc.txt

# delete and recreate

kubectl delete -f deployment.yaml
kubectl apply -f deployment.yaml

# final check file existence after pod recreation

kubectl exec deployment/my-persistent-deployment -- cat /mnt/my-storage/pvc.txt