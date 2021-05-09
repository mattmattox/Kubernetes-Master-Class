#!/bin/bash

echo "Halting all nodes.."
for node in `cat cluster.yml  | grep -v '#' | grep ' address: ' | awk '{print $3}'`
do
  echo "Node: $node"
  timeout 1 ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -x -l root $node 'poweroff'
done