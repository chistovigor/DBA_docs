# setup kubernetes cluster with kubespray

# 1. Убеждаемся, что IP подменен
sudo sed -i 's/158.160.139.255/127.0.0.1/g' /etc/kubernetes/admin.conf
sudo iptables -t nat -A OUTPUT -d 158.160.139.255 -p tcp --dport 6443 -j DNAT --to-destination 127.0.0.1:6443
curl -k https://158.160.139.255:6443

# run setup script
ansible-playbook -i inventory/mycluster/inventory.ini -b cluster.yml

# 2. Проверяем статус кластера
kubectl get nodes
kubectl get pods -n kube-system
