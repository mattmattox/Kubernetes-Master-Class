#!/bin/bash

export KUBECONFIG=kube_config_cluster.yml
kubectl get test-ns -o yaml
kubectl -n test-ns get pod -l app=swiss-army-knife -o wide
