# Настройка Ingress (Nginx) под порты 8080/8443

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/baremetal/deploy.yaml

kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type='json' -p='[
  {"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
    "/nginx-ingress-controller",
    "--election-id=ingress-nginx-leader",
    "--controller-class=k8s.io/ingress-nginx",
    "--ingress-class=nginx",
    "--configmap=$(POD_NAMESPACE)/ingress-nginx-controller",
    "--validating-webhook=:8443",
    "--validating-webhook-certificate=/usr/local/certificates/cert",
    "--validating-webhook-key=/usr/local/certificates/key",
    "--http-port=8080",
    "--https-port=8443"
  ]},
  {"op": "add", "path": "/spec/template/spec/hostNetwork", "value": true}
]'
