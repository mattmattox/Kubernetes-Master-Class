# Kubernetes-Master-Class

---

## Kubernetes Master Class: Recovering from a disaster with Rancher and Kubernetes
Recover, Restore and Rebuild:​ Disaster Recovery with Rancher and Kubernetes​

Everything breaks at some point; whether it is infrastructure (DNS, network, storage, etc.) or Kubernetes itself, something will fail eventually. In this session, we will walk through some common failure scenarios, including identifying failures and how to respond to them in the fastest way possible using the same troubleshooting steps, scripts, and tools Rancher Support uses when supporting our Enterprise customers. Then finally, to recover from these types of failures in place or scratch. This session includes documentation and scripts for reproducing all of these failures (based on actual events) in a lab environment.

[Link](./disaster-recovery)

---

## Kubernetes Master Class: A Seamless Approach to Rancher and Kubernetes Upgrades

In this master class Matt Mattox, Principal Support Engineer at Rancher (now a part of SUSE), will address the high-level steps required to plan and perform a Rancher and Kubernetes upgrade. We will go over planning the upgrade and selecting versions. Then we’ll plan out the change controls needed for the upgrade, including the required maintenance windows. We will also walk through different upgrades, including rolling back from a failed upgrade. Finally, We will cover how to automate upgrades.

Agenda:
- Planning your Rancher / k8s versions
- Creating your change controls
- Pre-upgrade data collection and prep work
- Rancher upgrade demos
- Upgrade rollback and recovery
- Post-upgrade steps
- Automating your upgrade process

[Link](./rancher-k8s-upgrades)

---


## Kubernetes Master Class: Addressing the Amount of Pull Requests in Rancher

In this master class Support Engineer Matthew Mattox will address the new Docker Hub limits and how to reduce the number of pull requests made against Docker Hub. We will go over different options including building a full registry mirror, and using the standard registry, including the required maintenance tasks, to use a pull-through-cache registry. We will also cover some Enterprise solutions (e.g. JFrog) along with how to reduce the number of pulls while using Docker Hub.

Agenda:

- What is the impact of the new Docker Hub pull limits, and how will it impact Rancher and Rancher managed cluster
- What solutions are available to solve this issue?
- Designing and implementing a full registry mirror.
- Designing and implementing a pull-through-cache registry.

[Link](./docker-hub-limits)

---

## Kubernetes Master Class: How to Run Databases in Production on Kubernetes
Databases are business-critical entities and data loss leads to major operational risk scenarios in any organization. A single operational or architectural failure can lead to significant loss of time and resources. This class will provide a real-world view into the challenges of maintaining state and running databases in production and show solutions managed by Rancher.

In this session, Rancher Engineer Matt Mattox will discuss and demo:
- How to architect and setup a stateful, distributed database on Kubernetes managed by Rancher
- How to respond to common operational scenarios like node failure, disk out of space, and restore from snapshots

[Link](./databases)

---

## Kubernetes Master Class: Troubleshooting Kubernetes
Everything breaks at some point, wether it is infrastructure (DNS, network etc) or Kubernetes itself, something will break eventually. In this session we will walk through the master components of Kubernetes, how they interact and how to troubleshoot the most common issues with Kubernetes. What parameters to use, what commands to run, how to interpret output from logging or commands are things that we will show you.

Attend this session if you want to learn:
- What the Kubernetes master components are and how they interact
- How to troubleshoot the Kubernetes master components
- How to remediate some of the most common issues with Kubernetes

[Link](./troubleshooting-kubernetes)
