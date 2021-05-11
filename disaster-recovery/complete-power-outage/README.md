# Restoring service after power outage

## What happens to an RKE cluster after a power outage?
RKE/Kubernetes is good about recovering from a cluster shutdown and requires little intervention, though there is a specific order in which things should be powered back on to minimize errors. Etcd is our primary concern because the rest of the services are stateless. Etcd uses a write-ahead log (WAL) to store certain updates before applying them.  If a member crashes and restarts between snapshots, it can locally recover transactions done since the last snapshot by looking at the content of the WAL.
NOTE: Etcd uses [fdatasync](https://linux.die.net/man/2/fdatasync) to flush writes from cache to disk.

## Reproducing in a lab
- Prerequisites
  - [RKE v0.3.2](https://github.com/rancher/rke/releases/tag/v0.3.2)
  - [Latest kubectl](https://github.com/kubernetes/kubectl/releases/tag/v0.20.6)
  - 7 VMs (2 core, 4GB of RAM, 20GB root)
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

## Restoring/Recovering
- Power on any storage devices if applicable.
  Check with your storage vendor to properly power on your storage devices and verify that they are ready.

- For each etcd node:
  - Power on the system/start the instance.
  - Log into the system via ssh.
  - Ensure docker has started sudo service docker status or sudo systemctl status docker
  - Ensure etcd and kubelet’s status shows Up in Docker sudo docker ps
- For each control plane node:
  - Power on the system/start the instance.
  - Log into the system via ssh.
  - Ensure docker has started sudo service docker status or sudo systemctl status docker
  - Ensure kube-apiserver, kube-scheduler, kube-controller-manager, and kubelet’s status shows Up in Docker sudo docker ps
- For each worker node:
  - Power on the system/start the instance.
  - Log into the system via ssh.
  - Ensure docker has started sudo service docker status or sudo systemctl status docker
  - Ensure kubelet’s status shows Up in Docker sudo docker ps
  - Log into the Rancher UI (or use kubectl) and check your various projects to ensure workloads have started as expected. This may take a few minutes, depending on the number of workloads and your server capacity.

## Preventive tasks
- [How to shutdown a Kubernetes cluster](https://support.rancher.com/hc/en-us/articles/360054671192-How-to-shutdown-a-Kubernetes-cluster-Rancher-Kubernetes-Engine-RKE-CLI-provisioned-or-Rancher-v2-x-Custom-clusters-#shutting-down-storage-0-7)
- You should make sure async is enabled on your storage subsystem.
