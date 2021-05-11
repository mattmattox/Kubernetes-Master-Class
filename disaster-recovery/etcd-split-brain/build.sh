#!/bin/bash

echo "rke up..."
rke up --config cluster.yml

export KUBECONFIG=kube_config_cluster.yml
kubectl get nodes -o wide

echo "Waiting for cluster to completely start..."
while [[ $(kubectl get nodes -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}' | sed 's/ /\n/g' | sort | uniq) != "True" ]];
do
  echo "Waiting for all node to be ready"
  sleep 1
done