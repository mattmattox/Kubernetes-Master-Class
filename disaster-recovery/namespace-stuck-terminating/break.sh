#!/bin/bash
export KUBECONFIG=kube_config_cluster.yml
kubectl create namespace test-ns
kubectl patch namespace test-ns -p '{"metadata":{"finalizers":["example.io/test"]}}' --type=merge
timeout 1 kubectl delete ns test-ns
kubectl get ns test-ns -o yaml
