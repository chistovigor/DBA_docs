# setup kubernetes cluster with kubespray

ansible-playbook -i inventory/mycluster/inventory.ini -b cluster.yml \
  -e ignore_assert_errors=yes \
  --flush-cache