# Rebuilding from scratch

## Reproducing in a lab
- Prerequisites
  - [Latest RKE](https://github.com/rancher/rke/releases/tag/v1.2.7)
  - [Latest kubectl](https://github.com/kubernetes/kubectl/releases/tag/v0.20.6)
  - 6 VMs (2 core, 4GB of RAM, 20GB root)
  - SSH access to root on all nodes
  - Internet access to github and docker hub.
  - S3 bucket.
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
- Edit the cluster.yml to comment out the 3 orginal nodes and uncomment the 3 new nodes.
  ```
  vi ./cluster.yml
  ```
- NOTE: If S3 is not an option, you can use local etcd backups but you'll need to rsync /opt/rke/etcd-snapshots from the old nodes to the new nodes.
- Using the following script to restore the etcd data from S3 into 3 new nodes.
  ```
  bash ./restore.sh SnapshotNameHere
  ```

## Documention
- [Restoring from Backup](https://rancher.com/docs/rke/latest/en/etcd-snapshots/restoring-from-backup/)
- [Recurring Snapshots](https://rancher.com/docs/rke/latest/en/etcd-snapshots/recurring-snapshots/)
