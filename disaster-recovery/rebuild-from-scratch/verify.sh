#!/bin/bash

export KUBECONFIG=kube_config_cluster.yml
kubectl get nodes -o wide
kubectl get pod -l app=swiss-army-knife -o wide
