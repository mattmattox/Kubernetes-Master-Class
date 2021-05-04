#!/bin/bash

for i in $(docker exec -it kube-apiserver sh -c 'ps aux | grep kube-apiserver' | awk -F'--etcd-servers' '{print $2}' | awk -F ' ' '{print $1}' | tr -d '=' | tr , "\n" | sed '/^$/d' | awk -F '/' '{print $3}' | awk -F ':' '{print $1}')
do
  echo -n "Checking $i "
  curl -k -X GET --cacert /etc/kubernetes/ssl/kube-ca.pem --cert /etc/kubernetes/ssl/kube-node.pem --key /etc/kubernetes/ssl/kube-node-key.pem https://"$i":2379/health
  echo ""
done
