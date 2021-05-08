#!/bin/bash

echo "Breaking etcd.."

node1=`cat cluster.yml  | grep ' address: ' | awk '{print $3}' | sed -n '1 p'`

echo "Working on Node: $node1"
ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -x -l root $node1 '
DOCKER_RUN=$(docker run -v /var/run/docker.sock:/var/run/docker.sock assaflavie/runlike etcd | sed "s/--initial-cluster-token=.*/--initial-cluster-token=broken/g")
docker stop etcd
docker rename etcd etcd-working
$DOCKER_RUN
'
