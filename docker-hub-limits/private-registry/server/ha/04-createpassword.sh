
#!/bin/bash

htpasswd -c auth admin
kubectl -n private-registry create secret generic private-registry --from-file=auth
