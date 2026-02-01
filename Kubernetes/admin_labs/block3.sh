# find internal ips for each node

ip addr show eth0 | grep inet

# run at each node

ETCD_VER=v3.5.10
curl -L https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz -o /tmp/etcd.tar.gz
tar xzvf /tmp/etcd.tar.gz -C /tmp/ etcd-${ETCD_VER}-linux-amd64 --strip-components=1
sudo mv /tmp/etcd /usr/local/bin/
sudo mv /tmp/etcdctl /usr/local/bin/
sudo mkdir -p /var/lib/etcd

# create configuration file

# master node

cat <<EOF | sudo tee /etc/etcd.env
ETCD_NAME=kube-master
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="http://10.130.0.50:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.130.0.50:2379,http://127.0.0.1:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.130.0.50:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.130.0.50:2379"
ETCD_INITIAL_CLUSTER="kube-master=http://10.130.0.50:2380,kube-node01=http://10.130.0.44:2380,kube-node02=http://10.130.0.25:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-1"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

# node 1

cat <<EOF | sudo tee /etc/etcd.env
ETCD_NAME=kube-node01
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="http://10.130.0.44:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.130.0.44:2379,http://127.0.0.1:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.130.0.44:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.130.0.44:2379"
ETCD_INITIAL_CLUSTER="kube-master=http://10.130.0.50:2380,kube-node01=http://10.130.0.44:2380,kube-node02=http://10.130.0.25:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-1"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

# node 2

cat <<EOF | sudo tee /etc/etcd.env
ETCD_NAME=kube-node02
ETCD_DATA_DIR="/var/lib/etcd"
ETCD_LISTEN_PEER_URLS="http://10.130.0.25:2380"
ETCD_LISTEN_CLIENT_URLS="http://10.130.0.25:2379,http://127.0.0.1:2379"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://10.130.0.25:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://10.130.0.25:2379"
ETCD_INITIAL_CLUSTER="kube-master=http://10.130.0.50:2380,kube-node01=http://10.130.0.44:2380,kube-node02=http://10.130.0.25:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster-1"
ETCD_INITIAL_CLUSTER_STATE="new"
EOF

# create service for all nodes

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd key-value store
After=network.target

[Service]
Type=notify
EnvironmentFile=/etc/etcd.env
ExecStart=/usr/local/bin/etcd
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now etcd

# move to "existing" state

etcdctl endpoint health --endpoints=10.130.0.50:2379,10.130.0.44:2379,10.130.0.25:2379

sudo su -
vim /etc/etcd.env

#change ETCD_INITIAL_CLUSTER_STATE="new" with: ETCD_INITIAL_CLUSTER_STATE="existing"

systemctl restart etcd

# write some data into etcd at any node

etcdctl put key "nice job"

# run autocheck

export $(grep -v '^#' /etc/etcd.env | xargs -d '\n') && etcdctl member list

# check data in the DB at any different node

etcdctl get key

# backup etcd data

etcdctl snapshot save backup.db