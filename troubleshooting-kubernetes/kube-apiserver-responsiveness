#!/bin/bash
for cip in $(kubectl get nodes -l "node-role.kubernetes.io/controlplane=true" -o jsonpath='{range.items[*].status.addresses[?(@.type=="InternalIP")]}{.address}{"\n"}{end}');
do
  kubectl --server https://${cip}:6443 get nodes -v6 2>&1| grep round_trippers;
done
