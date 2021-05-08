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

echo "Installing OPA Gatekeeper..."
kubectl create namespace gatekeeper-system
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm upgrade --install gatekeeper gatekeeper/gatekeeper \
--namespace gatekeeper-system \
--set disableValidatingWebhook=false

echo "Waiting for OPA Gatekeeper to completely start..."
kubectl -n gatekeeper-system rollout status deploy/gatekeeper-audit
kubectl -n gatekeeper-system rollout status deploy/gatekeeper-controller-manager

echo "Deploying test workload..."
kubectl apply -f test-deployment.yaml