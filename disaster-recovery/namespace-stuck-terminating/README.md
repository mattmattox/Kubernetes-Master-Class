# Namespace stuck in terminating

## Reproducing in a lab
- Prerequisites
  - [Latest RKE](https://github.com/rancher/rke/releases/tag/v1.2.7)
  - [Latest kubectl](https://github.com/kubernetes/kubectl/releases/tag/v0.20.6)
  - 3 VMs (2 core, 4GB of RAM, 20GB root)
  - SSH access to root on all nodes
  - Internet access to github and docker hub.
  - Running Docker [Install Script](https://github.com/rancher/install-docker)
- Edit the cluster.yml to include your node IPs and S3 settings
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
- The namespace wil have a status of Terminating.
  ```
  kubectl get ns test-ns
  ```
  ```
  NAME      STATUS        AGE
  test-ns   Terminating   6m25s
  ```
- Unhealthy members in etcd cluster
  ```
  kubectl get ns test-ns -o yaml
  ```
  ```
  ...
  metadata:
    finalizers:
    - customresourcedefinition.apiextensions.k8s.io
  ...
  ```

## Troubleshooting
- See if there is any stuck resources inside the namespace.
  ```
  kubectl get -n <namespace> all
  ```
- Try seeing if there is a crd in the namespace. (Prometheus likes to leave stuff behind)
  ```
  kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -l <label>=<value> -n <namespace>
  ```

## Restoring/Recovering
NOTE: finalizers are a safety mechanism built-in Kubernetes to make sure all objects are cleanup before deleting the namespace.
- Patch the namespace to remove the finialzer
  ```
  kubectl patch namespace <namespace> -p '{"metadata":{"finalizers":[]}}' --type=merge
  ```

## Documention
- [Resource deletetion](https://kubernetes.io/docs/reference/using-api/api-concepts/#resource-deletion)
- [More Documention on finalizers](https://book.kubebuilder.io/reference/using-finalizers.html)