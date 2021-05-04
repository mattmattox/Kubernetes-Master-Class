# Recovering from an etcd split-brain
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

## Identifying the issue
- Error messages in etcd logs.
  ```
  docker logs --tail 100 -f etcd
  ```
  ```
  2021-05-04 21:27:11.856471 E | rafthttp: request sent was ignored (cluster ID mismatch: peer[bc5babcd42042800]=a8977fad6ef90f15, local=38cf28018b4788e7)
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
- If hosted in a cloud provider like AWS use differnet availability zones for each. Example: etcd1 in us-west-2a, etcd2 in us-west-2b, etc.
- Only apply patching in a rolling fashion. Example [script](rolling_reboot.sh)
