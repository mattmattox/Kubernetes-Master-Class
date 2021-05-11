# Namespace stuck in terminating

## Why is my namespace stuck in termination?
When you run `kubectl delete ns <namespace>` the namespace object, the `status.phase` will be set to `Terminating,` at which point the kube-controller will wait for the finalizers to be removed. What should happen at this point to the different controllers will detect that they need to clean up their resources inside the namespace. Example: If you delete a namespace that has a PVC inside it. We'll want to call the volume controller to unmap the volume, and at which it will remove the finalizer.

NOTE: finalizers are a safety mechanism built-in Kubernetes to ensure all objects are cleanup before deleting the namespace and should only be removed if the controller is no longer available.

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
- The namespace will have a status of Terminating.
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
- See if there are any stuck resources inside the namespace.
  ```
  kubectl get -n <namespace> all
  ```
- Try seeing if there is a crd in the namespace. (Prometheus likes to leave stuff behind)
  ```
  kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -l <label>=<value> -n <namespace>
  ```

## Restoring/Recovering
- Patch the namespace to remove the finalizer
  ```
  kubectl patch namespace <namespace> -p '{"metadata":{"finalizers":[]}}' --type=merge
  ```

## Documention
- [Resource deletetion](https://kubernetes.io/docs/reference/using-api/api-concepts/#resource-deletion)
- [More Documention on finalizers](https://book.kubebuilder.io/reference/using-finalizers.html)