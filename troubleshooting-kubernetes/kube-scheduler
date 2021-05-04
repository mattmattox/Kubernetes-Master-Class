#!/bin/bash
NODE="$(kubectl -n kube-system get endpoints kube-scheduler -o jsonpath='{.metadata.annotations.control-plane\.alpha\.kubernetes\.io/leader}' | jq . 2>/dev/null | grep 'holderIdentity' | awk '{print $2}' | tr -d ",\"" | awk -F '_' '{print $1}')"
echo "kube-scheduler is the leader on node $NODE"
