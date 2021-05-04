#!/bin/bash

echo "Breaking etcd.."
node=`cat cluster.yml  | grep ' address: ' | awk '{print $3}' | head -n1`
echo "Node: $node"
ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null root@"$node" 'curl -LO https://github.com/rancherlabs/support-tools/raw/master/etcd-tools/restore-etcd-single.sh; bash ./restore-etcd-single.sh FORCE_NEW_CLUSTER'
