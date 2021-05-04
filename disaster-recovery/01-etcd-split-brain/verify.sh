#!/bin/bash

export KUBECONFIG=kube_config_cluster.yml
kubectl get nodes -o wide

echo "Checking etcd on each node.."
for node in `cat cluster.yml  | grep ' address: ' | awk '{print $3}'`
do
echo "Node: $node"
ssh -q -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null root@"$node" 'echo "Member list"; docker exec etcd etcdctl member list; echo "Endpoint health"; docker exec etcd etcdctl endpoint health'
sleep 5
done

