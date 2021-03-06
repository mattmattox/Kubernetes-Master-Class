# Recovering from an etcd split-brain
<p align="center">
  <img src="banner.png">
</p>

## What is an etcd split-brain?
Etcd is a leader-based distributed system. Ensure that the leader periodically sends heartbeats on time to all followers to keep the cluster stable. Etcd requires a majority of nodes to up and healthy to accept writes. If the cluster ever lost a quorum, it will go into read-only mode until a quorum is restored.

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
- Error messages in etcd logs.
  ```
  docker logs --tail 100 -f etcd
  ```
  ```
  2021-05-04 07:50:10.140405 E | rafthttp: request cluster ID mismatch (got ecdd18d533c7bdc3 want a0b4701215acdc84)
  2021-05-04 07:50:10.142212 E | rafthttp: request sent was ignored (cluster ID mismatch: peer[fa573fde1c0b9eb9]=ecdd18d533c7bdc3, local=a0b4701215acdc84)
  2021-05-04 07:50:10.155090 E | rafthttp: request sent was ignored (cluster ID mismatch: peer[fa573fde1c0b9eb9]=ecdd18d533c7bdc3, local=a0b4701215acdc84)
  ```
- Unhealthy members in etcd cluster
  ```
  docker exec -e ETCDCTL_ENDPOINTS=$(docker exec etcd /bin/sh -c "etcdctl member list | cut -d, -f5 | sed -e 's/ //g' | paste -sd ','") etcd etcdctl member list
  ```
  ```
  15de45eddfe271bb, started, etcd-a1ublabat03, https://172.27.5.33:2380, https://172.27.5.33:2379, false
  1d6ed2e3fa3a12e1, started, etcd-a1ublabat02, https://172.27.5.32:2380, https://172.27.5.32:2379, false
  68d49b1389cdfca0, started, etcd-a1ublabat01, https://172.27.5.31:2380, https://172.27.5.31:2379, false
  ```
- Endpoint health
  ```
  docker exec -e ETCDCTL_ENDPOINTS=$(docker exec etcd /bin/sh -c "etcdctl member list | cut -d, -f5 | sed -e 's/ //g' | paste -sd ','") etcd etcdctl endpoint health
  ```
  ```
  https://172.27.5.31:2379 is healthy: successfully committed proposal: took = 66.729472ms
  https://172.27.5.32:2379 is healthy: successfully committed proposal: took = 70.804719ms
  https://172.27.5.33:2379 is healthy: successfully committed proposal: took = 71.457556ms
  ```

## Troubleshooting
- Try resyncing the cluster using RKE.
```
rke up --config cluster.yml
```

## Restoring/Recovering
- If the `rke up` fails, use [etcd-tools](https://github.com/rancherlabs/support-tools/tree/master/etcd-tools) to force a new cluster.

## Preventive tasks
- If hosted in VMware, use VM Anti-Affinity rules to make sure etcd nodes are hosted on different ESXi hosts. [VMware KB](https://docs.vmware.com/en/VMware-vSphere/7.0/com.vmware.vsphere.resmgmt.doc/GUID-FBE46165-065C-48C2-B775-7ADA87FF9A20.html)
- If hosted in a cloud provider like AWS, use different availability zones for each. Example: etcd1 in us-west-2a, etcd2 in us-west-2b, etc.
- Only apply patching in a rolling fashion. Example [script](rolling_reboot.sh)

## Documention
- [etcd offical doc](https://etcd.io/docs/v3.4/op-guide/failures/)
