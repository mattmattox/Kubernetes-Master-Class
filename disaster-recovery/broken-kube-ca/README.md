# Rotating kube-ca breaks pods

## What is kube-ca, and how can it break my cluster?
Kubernetes uses SSL certificates are all of its services. TLS certificates need certificate authorities' "CAs" work. In this case, kube-ca is a root certificate authority created as part of building the cluster. RKE then creates key pairs for kube-apiserver, etcd, kube-scheduler, etc., and signs them uses kube-ca. This also includes service accounts tokens which are signed by kube-service-account-token. This means that if that chain is broken. kubectl and related services will do the safest option and block the connection.

## Reproducing in a lab
- Prerequisites
  - [Latest RKE](https://github.com/rancher/rke/releases/tag/v1.2.7)
  - [Latest kubectl](https://github.com/kubernetes/kubectl/releases/tag/v0.20.6)
  - 3 VMs (2 core, 4GB of RAM, 20GB root)
  - SSH access to root on all nodes
  - Internet access to github and docker hub.
  - Running Docker [Install Script](https://github.com/rancher/install-docker)
- Edit the cluster.yml to include your node IPs
  ```
  vi ./cluster.yml
  ```
- Stand up the cluster
  ```
  bash ./build.sh
  ```
- Verify the cluster is up and healthy
  ```
  bash ./verify.sh
  ```
- Break the cluster
  ```
  bash ./break.sh
  ```

## Identifying the issue
- Error messages in ingress-nginx-controllers logs.
  ```
  kubectl -n ingress-nginx logs --timestamps=true -l app=ingress-nginx
  ```
  ```
  2021-05-08T06:06:42.278352968Z E0508 06:06:42.278206       6 reflector.go:138] k8s.io/client-go@v0.20.0/tools/cache/reflector.go:167: Failed to watch *v1.Service: failed to list *v1.Service: Get "https://10.43.0.1:443/api/v1/services?resourceVersion=898": x509: certificate signed by unknown authority (possibly because of "crypto/rsa: verification error" while trying to verify candidate authority certificate "kube-ca")
  2021-05-08T06:06:50.856116235Z E0508 06:06:50.855895       6 leaderelection.go:325] error retrieving resource lock ingress-nginx/ingress-controller-leader-nginx: Get "https://10.43.0.1:443/api/v1/namespaces/ingress-nginx/configmaps/ingress-controller-leader-nginx": x509: certificate signed by unknown authority (possibly because of "crypto/rsa: verification error" while trying to verify candidate authority certificate "kube-ca")
  ```

## Troubleshooting
- Does adding `--insecure-skip-tls-verify` to `kubectl` from inside a pod work?
- See if the file kube-ca.pem is newer than the cert files.
  ```
  ls -l /etc/kubernetes/ssl/
  ```
- If kube-ca has been rotated or been re-created, all the rest of the certificates that it is based on will be broken. This also breaks k8s tokens because they are based on these certificates.


## Restoring/Recovering
- Try forcing a cert rotation using RKE.
  ```
  rke cert rotate --rotate-ca --config cluster.yml
  ```
- Try resetting the service account tokens.
  ```
  for namespace in $(kubectl get ns -o NAME | awk -F '/' '{print $2}'); do for secret in $(kubectl -n $namespace get secret --field-selector type=kubernetes.io/service-account-token -o NAME | awk -F '/' '{print $2}'); do  kubectl -n $namespace delete secret $secret; done; done
  ```
- Try running an etcd restore. [Doc](https://rancher.com/docs/rke/latest/en/etcd-snapshots/restoring-from-backup/)
  ```
  rke etcd snapshot-restore --config cluster.yml --name mysnapshot
  ```

## Preventive tasks
- [How Kubernetes certificates work](https://jvns.ca/blog/2017/08/05/how-kubernetes-certificates-work/)