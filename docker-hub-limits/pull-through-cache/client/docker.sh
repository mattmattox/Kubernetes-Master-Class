#!/bin/bash

ProxyServer=$1
ProxyPort=$2

if [[ -z $ProxyServer ]] || [[ -z $ProxyPort ]]
then
  echo "Missing Server and Port"
  exit 1
fi

echo "Configuring Docker..."
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
[Service]
Environment="HTTP_PROXY=http://${ProxyServer}:${ProxyPort}/"
Environment="HTTPS_PROXY=http://${ProxyServer}:${ProxyPort}/"
EOF

echo "Setting up the proxy cert..."
rm -f /usr/share/ca-certificates/docker_registry_proxy.crt
wget -O /usr/share/ca-certificates/docker_registry_proxy.crt http://${ProxyServer}:${ProxyPort}/ca.crt
echo "docker_registry_proxy.crt" >> /etc/ca-certificates.conf
update-ca-certificates --fresh

echo "Restarting docker..."
systemctl daemon-reload
systemctl restart docker.service
docker info

echo "Testing image pull..."
docker pull busybox
