# Rotating kube-ca breaks pods

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
- See if the file kube-ca.pem is newer then the cert files.
  ```
  ls -l /etc/kubernetes/ssl/
  ```
- If kube-ca have been rotated and/or been re-created all the rest of the certificates that it based on are going to be broken. This also breaks k8s tokens because they are based off these certificates.


## Restoring/Recovering
- Try forcing a cert rotate using RKE.
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
- Changing the failure policy to fail open. [Doc](https://open-policy-agent.github.io/gatekeeper/website/docs/failing-closed)
- [Offical OPA Gatekeeper Emergency Recovery](https://open-policy-agent.github.io/gatekeeper/website/docs/emergency)
