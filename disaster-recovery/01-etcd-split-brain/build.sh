#!/bin/bash

echo "rke up..."
rke up --config cluster.yml

export KUBECONFIG=kube_config_cluster.yml
kubectl get nodes -o wide
