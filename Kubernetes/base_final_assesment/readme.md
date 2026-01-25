Аргументация выбора объектов:
StatefulSet для MySQL: Даже без дисков (как разрешено в условии) этот объект гарантирует предсказуемое DNS-имя mysql-0.mysql-headless.db.svc.cluster.local, что упрощает отладку взаимодействия БД.

EnvFrom: Это требование задания. Такой подход делает манифест Deployment чище, так как десятки переменных окружения вынесены в отдельный ConfigMap.

SubPath: Использование subPath при монтировании /servers.json критично. Если примонтировать ConfigMap обычным способом в корень /, Kubernetes сотрет всё содержимое корневой директории контейнера, включая системные файлы, и приложение не запустится.

Вам осталось только создать эти 6 файлов и запустить kubectl apply -f .. После запуска подов вы сможете проверить доступ командой curl -H "Host: librespeed.example.com" http://158.160.223.3.

# create step by step with checks

kubectl apply -f 00-infra.yaml

kubectl get ns
kubectl get secret registrysecret -n final

kubectl apply -f 01-mysql-config.yaml
kubectl apply -f 02-mysql-workload.yaml

kubectl get pods -n db -w
kubectl logs -n db mysql-0 | grep "init.sql"

kubectl apply -f 03-app-config.yaml
kubectl apply -f 04-app-workload.yaml

kubectl get pods -n final -w

kubectl apply -f 05-ingress.yaml

sleep 120 && curl -I -H "Host: librespeed.example.com" http://158.160.223.3

# recreate all in one step

kubectl delete -f . && sleep 30 && kubectl apply -f .

# checks after recreate

kubectl get ns
kubectl get secret registrysecret -n final
kubectl get pods -n db -w
kubectl logs -n db mysql-0 | grep "init.sql"
kubectl get pods -n final -w
curl -I -H "Host: librespeed.example.com" http://158.160.223.3

# screenshots creation for task

# 01

kubectl get pods,svc,deploy,sts,secrets,configmaps -n db && \
echo "---" && \
kubectl get pods,svc,deploy,sts,secrets,configmaps -n final

# 02

kubectl exec -n db mysql-0 -- mysql -u speedtest -pspeedtestpassword -e "USE speedtest; DESCRIBE speedtest_users;"
kubectl exec -n db mysql-0 -- mysql -u speedtest -pspeedtestpassword -e "USE speedtest; SELECT id, timestamp, ip, dl, ul, ping FROM speedtest_users;"