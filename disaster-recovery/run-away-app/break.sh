#!/bin/bash
export KUBECONFIG=kube_config_cluster.yml
kubectl apply -f https://raw.githubusercontent.com/giantswarm/kube-stresscheck/master/examples/node.yaml
kubectl get pods -n kube-system
kubectl get nodes
