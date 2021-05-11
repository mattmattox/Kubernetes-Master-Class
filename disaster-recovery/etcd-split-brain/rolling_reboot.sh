#!/bin/bash
set -e

export KUBECONFIG=./kube_config_cluster.yml

for node in `kubectl get nodes -o name | awk -F'/' '{print $2}'`
do
  echo "Node: $node"
  status=`kubectl get nodes "$node" | tail -n1 | awk '{print $2}'`
  echo "Checking if node is ready..."
  if [[ "$status" == "Ready" ]]
  then
    echo "Cordoning node..."
    kubectl cordon "$node"
    kubectl drain "$node" --ignore-daemonsets --delete-local-data --force --grace-period=900
    echo "Sleeping..."
    sleep 360
    echo "Updating..."
    ssh root@"$node" 'apt update -y && apt upgrade -y'
    echo "Rebooting..."
    ssh root@"$node" 'reboot'
    echo "Sleeping..."
    sleep 360
    echo "Waiting for ping..."
    while ! ping -c 1 $node
    do
      echo "Waiting..."
      sleep 1
    done
    echo "Waiting for SSH..."
    while ! ssh root@"$node" "uptime"
    do
      echo "Waiting..."
      sleep 1
    done
    echo "Waiting for docker..."
    while ! ssh root@"$node" "docker ps"
    do
      echo "Waiting..."
      sleep 1
    done
    echo "Sleeping..."
    sleep 360
    echo "Waiting for node ready..."
    while ! kubectl get nodes "$node" | tail -n1 | awk '{print $2}' | grep "Ready"
    do
      echo "Waiting..."
      sleep 1
    done
    echo "Sleeping..."
    sleep 360
    echo "Uncordoning node..."
    kubectl uncordon "$node"
    echo "Sleeping..."
    sleep 360
    rke up
  else
   echo "Uncordoning node..."
   kubectl uncordon "$node"
  fi
done