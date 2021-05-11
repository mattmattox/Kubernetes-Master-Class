
## How to install a standalone MySQL server with Longhorn

### Create Namespace
`kubectl apply -f 00-namespace.yml`

### Create secret
`kubectl -n single-node-mysql create secret generic mysql-pass --from-literal=password=password`

### Create PVC
`kubectl apply -f 01-pvc.yml`

### Create Deployment
`kubectl apply -f 02-deployment.yml`

### Create Service
`kubectl apply -f 03-service.yml`

## Verify Deployment
`kubectl -n single-node-mysql get pods -l app=single-node-mysql`

## Access to MySQL
`kubectl -n single-node-mysql exec -it "$(kubectl -n single-node-mysql get pods -l app=single-node-mysql -o name)" -- mysql -u root -ppassword
`

or

`kubectl -n single-node-mysql port-forward "$(kubectl -n single-node-mysql get pods -l app=single-node-mysql -o name)" 3307:3306 &`

`mysql -h 127.0.0.1 --port=3307 -u root -ppassword`
