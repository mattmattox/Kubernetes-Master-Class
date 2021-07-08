# Recovering from a disaster with Rancher and Kubernetes

Everything breaks at some point; whether it is infrastructure (DNS, network, storage, etc.) or Kubernetes itself, something will fail eventually. In this session, we will walk through some common failure scenarios, including identifying failures and how to respond to them in the fastest way possible using the same troubleshooting steps, scripts, and tools Rancher Support uses when supporting our Enterprise customers. Then finally, to recover from these types of failures in place or scratch. This session includes documentation and scripts for reproducing all of these failures (based on actual events) in a lab environment.

## [YouTube video](https://www.youtube.com/watch?v=qD2kFA8THrY)

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
- [Recovering from an etcd split-brain](./etcd-split-brain)
- [Rebuilding from etcd backup](./rebuild-from-scratch)
- [Restoring service after power outage](./complete-power-outage)
- [Pods not being scheduled with OPA Gatekeeper](./broken-opa-gatekeeper)
- [Run away App stomping all over a cluster](./run-away-app)
- [Rotating kube-ca breaks pods](./broken-kube-ca)
- [Namespace stuck in terminating](./namespace-stuck-terminating)
