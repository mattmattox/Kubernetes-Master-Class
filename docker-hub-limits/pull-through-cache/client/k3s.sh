#!/bin/bash

ProxyServer=$1
ProxyPort=$2

if [[ -z $ProxyServer ]] || [[ -z $ProxyPort ]]
then
  echo "Missing Server and Port"
  exit 1
fi

echo "Configuring Docker..."
mkdir -p /etc/systemd/system/
cat >> /etc/systemd/system/k3s.service.env << EOF
HTTP_PROXY="http://${ProxyServer}:${ProxyPort}/"
HTTPS_PROXY="http://${ProxyServer}:${ProxyPort}/"
NO_PROXY="localhost,127.0.0.0/8,0.0.0.0,10.0.0.0/8,192.168.0.0/16,172.16.0.0/12"
EOF

echo "Setting up the proxy cert..."
rm -f /usr/share/ca-certificates/docker_registry_proxy.crt
wget -O /usr/share/ca-certificates/docker_registry_proxy.crt http://${ProxyServer}:${ProxyPort}/ca.crt
echo "docker_registry_proxy.crt" >> /etc/ca-certificates.conf
update-ca-certificates --fresh

echo "Restarting k3s..."
systemctl daemon-reload
systemctl restart k3s
k3s ctr info

echo "Testing image pull..."
k3s ctr images pull busybox
