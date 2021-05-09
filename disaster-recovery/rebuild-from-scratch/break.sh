#!/bin/bash

SnapshotName=$(echo test-`date '+%Y%m%d%H%M%S'`)
echo "Taking an etcd backup..."
rke etcd snapshot-save --config cluster.yml --name ${SnapshotName}

echo "Stopping docker.."
for node in `cat cluster.yml  | grep -v '#' | grep ' address: ' | awk '{print $3}'`
do
echo "Node: $node"
ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -x -l root $node '
systemctl stop docker
'
done

echo "Snapshot: ${SnapshotName}"