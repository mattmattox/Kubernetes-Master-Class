#!/bin/bash

echo "Cleanup current cluster"
rke remove --force --config cluster.yml

echo "Clean nodes.."
for node in `cat cluster.yml  | grep ' address: ' | awk '{print $3}'`
do
  echo "Node: $node"
  ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null root@"$node" 'curl https://raw.githubusercontent.com/rancherlabs/support-tools/master/extended-rancher-2-cleanup/extended-cleanup-rancher2.sh | bash'
  ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null root@"$node" 'systemctl restart docker'
done