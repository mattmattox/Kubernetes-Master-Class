#!/bin/bash

export KUBECONFIG=kube_config_cluster.yml
kubectl get nodes -o wide
kubectl get pod -l app=swiss-army-knife -o wide

echo "Scaling up deployment by one..."
CurrentReplicas=`kubectl get deployment swiss-army-knife -o 'jsonpath={.status.replicas}'`
NewReplicas=$((CurrentReplicas+1))
kubectl scale --replicas=${NewReplicas} deploy/swiss-army-knife
kubectl rollout status deploy/swiss-army-knife
kubectl get pod -l app=swiss-army-knife -o wide