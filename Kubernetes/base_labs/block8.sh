kubectl create deployment httpd-dp --image=httpd --replicas=3

kubectl expose deployment httpd-dp --name=http-svc-int --port=80 --target-port=80 --type=ClusterIP

kubectl expose deployment httpd-dp --name=http-svc-nodeport --port=80 --type=NodePort --overrides='{"spec":{"ports":[{"port":80,"nodePort":9999}]}}'
# gives error because port is out of range

kubectl expose deployment httpd-dp --name=http-svc-nodeport --port=80 --type=NodePort --overrides='{"spec":{"ports":[{"port":80,"nodePort":32501}]}}'

kubectl expose deployment httpd-dp --name=http-svc-ext --port=80 --type=LoadBalancer

kubectl get pods

kubectl port-forward httpd-dp-b55799c7-27tfd 8080:80
# here pod name taken from previous command 1st line

# from another terminal run:
curl http://127.0.0.1:8080

# output:
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<title>It works! Apache httpd</title>
</head>
<body>
<p>It works!</p>
</body>
</html>