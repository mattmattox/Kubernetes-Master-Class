#!/bin/bash

MKTEMP_BASEDIR=""

while getopts ":d:k:" opt; do
  case $opt in
    d)
      MKTEMP_BASEDIR="-p ${OPTARG}"
      ;;
    k)
      KUBECONFIG="-k ${OPTARG}"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# Create temp directory
TMPDIR=$(mktemp -d $MKTEMP_BASEDIR)

echo "Collecting Cluster level info..."
mkdir -p $TMPDIR/cluster
kubectl cluster-info > $TMPDIR/cluster/cluster-info 2>&1
kubectl get nodes -o wide > $TMPDIR/cluster/nodes-wide 2>&1

echo "Collecting k8s components..."
mkdir -p $TMPDIR/k8s-components

echo "Working on metrics-server..."
mkdir -p $TMPDIR/k8s-components/metrics-server
kubectl -n kube-system get pods -o wide -l k8s-app=metrics-server > $TMPDIR/k8s-components/metrics-server/pods-wide 2>&1
mkdir -p $TMPDIR/k8s-components/metrics-server/describe/pod
for pod in $(kubectl -n kube-system get pods -o NAME -l k8s-app=metrics-server);
do
  kubectl -n kube-system describe $pod > $TMPDIR/k8s-components/metrics-server/describe/$pod 2>&1
done
mkdir -p $TMPDIR/k8s-components/metrics-server/logs/pod
for pod in $(kubectl -n kube-system get pods -o NAME -l k8s-app=metrics-server);
do
  kubectl -n kube-system logs $pod > $TMPDIR/k8s-components/metrics-server/logs/$pod 2>&1
done
kubectl get endpoints -n kube-system metrics-server -o wide > $TMPDIR/k8s-components/metrics-server/endpoints-wide 2>&1
kubectl describe endpoints -n kube-system metrics-server > $TMPDIR/k8s-components/metrics-server/endpoints-describe 2>&1

echo "Checking metrics health..."
kubectl -n cattle-system exec -it `kubectl -n cattle-system get pods -o NAME -l app=cattle-agent | head -n1` -- curl -k -X GET --cacert /etc/kubernetes/ssl/kube-ca.pem --cert /etc/kubernetes/ssl/kube-node.pem --key /etc/kubernetes/ssl/kube-node-key.pem https://`kubectl -n kube-system describe endpoints metrics-server | grep Addresses: | grep -v NotReadyAddresses: | awk '{print $2}'`:443/healthz > $TMPDIR/k8s-components/metrics-server/healthz 2>&1
echo "" >> $TMPDIR/k8s-components/metrics-server/healthz 2>&1
echo "Checking metrics responce..."
TOKEN="$(kubectl -n cattle-system exec -it `kubectl -n cattle-system get pods -o NAME -l app=cattle-agent | head -n1` -- cat /run/secrets/kubernetes.io/serviceaccount/token)"
kubectl -n cattle-system exec -it `kubectl -n cattle-system get pods -o NAME -l app=cattle-agent | head -n1` -- curl -k -H "Authorization: Bearer $TOKEN" https://`kubectl -n kube-system describe endpoints metrics-server | grep Addresses: | grep -v NotReadyAddresses: | awk '{print $2}'`:443/metrics > $TMPDIR/k8s-components/metrics-server/responce 2>&1

FILEDIR=$(dirname $TMPDIR)
FILENAME="$(hostname)-$(date +'%Y-%m-%d_%H_%M_%S').tar"
tar cf $FILEDIR/$FILENAME -C ${TMPDIR}/ .

if $(command -v gzip >/dev/null 2>&1); then
  echo "Compressing archive to ${FILEDIR}/${FILENAME}.gz"
  gzip ${FILEDIR}/${FILENAME}
  FILENAME="${FILENAME}.gz"
fi

echo "Created ${FILEDIR}/${FILENAME}"
echo "You can now remove ${TMPDIR}"
