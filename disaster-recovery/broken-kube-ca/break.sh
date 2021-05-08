#!/bin/bash

echo "Breaking k8s tokens/certs.."

echo "Backing up old kube-service-account-token"
for node in `cat cluster.yml  | grep ' address: ' | awk '{print $3}'`
do
echo "Working on Node: $node"
ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -x -l root $node '
cp -f /etc/kubernetes/ssl/kube-service-account-token.pem /etc/kubernetes/ssl/kube-service-account-token.pem-old
cp -f /etc/kubernetes/ssl/kube-service-account-token-key.pem /etc/kubernetes/ssl/kube-service-account-token-key.pem-old
'
done

echo "rke rotate CA..."
rke cert rotate --rotate-ca  --config cluster.yml

echo "Putting old kube-service-account-token back"
for node in `cat cluster.yml  | grep ' address: ' | awk '{print $3}'`
do
echo "Working on Node: $node"
ssh -o StrictHostKeyChecking=no -o GlobalKnownHostsFile=/dev/null -o UserKnownHostsFile=/dev/null -x -l root $node '
cp -f /etc/kubernetes/ssl/kube-service-account-token.pem /etc/kubernetes/ssl/kube-service-account-token.pem-new
cp -f /etc/kubernetes/ssl/kube-service-account-token-key.pem /etc/kubernetes/ssl/kube-service-account-token-key.pem-new
cp -f /etc/kubernetes/ssl/kube-service-account-token.pem-old /etc/kubernetes/ssl/kube-service-account-token.pem
cp -f /etc/kubernetes/ssl/kube-service-account-token-key.pem-old /etc/kubernetes/ssl/kube-service-account-token-key.pem
docker restart kube-apiserver
'
done