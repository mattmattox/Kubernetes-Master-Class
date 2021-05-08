#!/bin/bash

export KUBECONFIG=kube_config_cluster.yml
kubectl get pod -l app=hello-world

echo "Scaling up deployment by one..."
CurrentReplicas=`kubectl get deployment hello-world -o 'jsonpath={.status.replicas}'`
NewReplicas=$((CurrentReplicas+1))
kubectl scale --replicas=${NewReplicas} deploy/hello-world
kubectl rollout status deploy/hello-world
kubectl get pod -l app=hello-world