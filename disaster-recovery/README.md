# Recovering from a disaster with Rancher and Kubernetes

Everything breaks at some point; whether it is infrastructure (DNS, network, storage, etc.) or Kubernetes itself, something will fail eventually. In this session, we will walk through some common failure scenarios, including identifying failures and how to respond to them in the fastest way possible using the same troubleshooting steps, scripts, and tools Rancher Support uses when supporting our Enterprise customers. Then finally, to recover from these types of failures in place or scratch. This session includes documentation and scripts for reproducing all of these failures (based on actual events) in a lab environment.

## Overview
- Terms
- Common scenarios with lab examples
  - Identifying the issue
  - Troubleshooting
  - Restoring/Recovering
  - Preventive tasks
  - Reproducing in a lab
- Q&A

## Terms
- Rancher Server is a set of pods that run the main orchestration engine and UI for Rancher.
- RKE (Rancher Kubernetes Engine) is the tool Rancher uses to create and manage Kubernetes clusters
- Local/upstream cluster This is the cluster where the Rancher server is installed, this is usually an RKE built cluster)
- Downstream cluster(s) are Kubernetes cluster that Rancher is managing
- Managed clusters are created and managed by Rancher
- Imported clusters were created outside Rancher then imported.

## Common Scenarios
- Recovering from an etcd split-brain
- Rebuilding a cluster from scratch
- Restoring service after power outage
- Run away App stomping all over a cluster
- Pods not being scheduled with OPA Gatekeeper
- When all your tokens stop working
- Namespace stuck in terminating

### Recovering from an etcd split-brain
#### Reproducing in a lab
- Requirements
  - [Latest RKE](https://github.com/rancher/rke/releases/tag/v1.2.7)
  - [Latest kubectl](https://github.com/kubernetes/kubectl/releases/tag/v0.20.6)
  - 3 VMs (2 core, 4GB of RAM, 20GB root)
  - SSH access to root or an account with docker access
  - Running Docker [Install Script](https://github.com/rancher/install-docker)
- Edit the cluster.yml to include your node IPs
  ```
  cd ./01-etcd-split-brain
  ./cluster.yml
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

#### Identifying the issue

#### Troubleshooting
#### Restoring/Recovering
#### Preventive tasks
