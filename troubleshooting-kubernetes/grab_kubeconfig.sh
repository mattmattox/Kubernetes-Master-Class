#!/bin/bash
echo "Building cluster_recovery.yml..."
echo "Working on Nodes..."
echo 'nodes:' > cluster_recovery.yml
kubectl --kubeconfig kube_config_cluster.yml -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig.nodes | yq r - | sed 's/^/  /' | \
sed -e 's/internalAddress/internal_address/g' | \
sed -e 's/hostnameOverride/hostname_override/g' | \
sed -e 's/sshKeyPath/ssh_key_path/g' >> cluster_recovery.yml
echo "" >> cluster_recovery.yml

echo "Working on services..."
echo 'services:' >> cluster_recovery.yml
kubectl --kubeconfig kube_config_cluster.yml -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig.services | yq r - | sed 's/^/  /' >> cluster_recovery.yml
echo "" >> cluster_recovery.yml

echo "Working on network..."
echo 'network:' >> cluster_recovery.yml
kubectl --kubeconfig kube_config_cluster.yml -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig.network | yq r - | sed 's/^/  /' >> cluster_recovery.yml
echo "" >> cluster_recovery.yml

echo "Working on authentication..."
echo 'authentication:' >> cluster_recovery.yml
kubectl --kubeconfig kube_config_cluster.yml -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig.authentication | yq r - | sed 's/^/  /' >> cluster_recovery.yml
echo "" >> cluster_recovery.yml

echo "Working on systemImages..."
echo 'system_images:' >> cluster_recovery.yml
kubectl --kubeconfig kube_config_cluster.yml -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r .desiredState.rkeConfig.systemImages | yq r - | sed 's/^/  /' >> cluster_recovery.yml
echo "" >> cluster_recovery.yml

echo "Building cluster_recovery.rkestate..."
kubectl --kubeconfig kube_config_cluster.yml -n kube-system get configmap full-cluster-state -o json | jq -r .data.\"full-cluster-state\" | jq -r . > cluster_recovery.rkestate

echo "Running rke up..."
rke up --config cluster_recovery.yml
