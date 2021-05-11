
## How to install MariaDB Galera
[MariaDB Galera](https://mariadb.com/kb/en/library/what-is-mariadb-galera-cluster/) is a multi-master database cluster solution for synchronous replication and high availability.

### Create Namespace
`kubectl create namespace mariadb-galera`

### Install chart
`helm install mariadb-galera bitnami/mariadb-galera --namespace mariadb-galera -f values.yaml --set rootUser.password="Passw0rd" --set db.password="Passw0rd"`

## Verify Deployment
`kubectl get sts -w --namespace mariadb-galera -l app.kubernetes.io/instance=mariadb-galera`

## Obtain root password
`helm install mariadb-galera bitnami/mariadb-galera --namespace mariadb-galera -f values-production.yaml --set rootUser.password="Passw0rd" --set db.password="Passw0rd"`

## Access to MySQL
`kubectl run mariadb-galera-client --rm --tty -i --restart='Never' --namespace mariadb-galera --image docker.io/bitnami/mariadb-galera:10.4.12-debian-10-r7 --command -- mysql -h mariadb-galera -P 3306 -uroot -p$(kubectl get secret --namespace mariadb-galera mariadb-galera -o jsonpath="{.data.mariadb-root-password}" | base64 --decode) my_database`

or

`kubectl port-forward --namespace mariadb-galera svc/mariadb-galera 3308:3306 &`
`mysql -h 127.0.0.1 -P 3308 -uroot -p$(kubectl get secret --namespace mariadb-galera mariadb-galera -o jsonpath="{.data.mariadb-root-password}" | base64 --decode) my_database`
