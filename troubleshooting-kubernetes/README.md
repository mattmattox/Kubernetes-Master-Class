# k8s Troubleshooting

## kube-scheduler

### Finding the current leader
Command(s): `curl https://raw.githubusercontent.com/mattmattox/k8s-troubleshooting/master/kube-scheduler | bash`

**Example Output of a healthy cluster**
```bash
kube-scheduler is the leader on node a1ubk8slabl03
```

## etcd-troubleshooting

### Check etcd members
Command(s): `docker exec etcd etcdctl member list`

**Example Output of a healthy cluster**
```bash
2f080bc6ec98f39b, started, etcd-a1ubrkeat03, https://172.27.5.33:2380, https://172.27.5.33:2379,https://172.27.5.33:4001, false
9d7204f89b221ba3, started, etcd-a1ubrkeat01, https://172.27.5.31:2380, https://172.27.5.31:2379,https://172.27.5.31:4001, false
bd37bc0dc2e990b6, started, etcd-a1ubrkeat02, https://172.27.5.32:2380, https://172.27.5.32:2379,https://172.27.5.32:4001, false
```

### Check etcd endpoints
Command(s): `curl https://raw.githubusercontent.com/mattmattox/etcd-troubleshooting/master/etcd-endpoints | bash `

**Example Output of a healthy cluster**
```bash
Validating connection to https://172.27.5.33:2379/health
{"health":"true"}
Validating connection to https://172.27.5.31:2379/health
{"health":"true"}
Validating connection to https://172.27.5.32:2379/health
{"health":"true"}
```

### Common errors 

`health check for peer xxx could not connect: dial tcp IP:2380: getsockopt: connection refused`

A connection to the address shown on port 2380 cannot be established. Check if the etcd container is running on the host with the address shown.


`xxx is starting a new election at term x`

The etcd cluster has lost it’s quorum and is trying to establish a new leader. This can happen when the majority of the nodes running etcd go down/unreachable.


`connection error: desc = "transport: Error while dialing dial tcp 0.0.0.0:2379: i/o timeout"; Reconnecting to {0.0.0.0:2379 0 <nil>}`

The host firewall is preventing network communication.


`rafthttp: request cluster ID mismatch`

The node with the etcd instance logging rafthttp: request cluster ID mismatch is trying to join a cluster that has already been formed with another peer. The node should be removed from the cluster, and re-added.


`rafthttp: failed to find member`

The cluster state (/var/lib/etcd) contains wrong information to join the cluster. The node should be removed from the cluster, the state directory should be cleaned and the node should be re-added.

### Enabling debug logging
`curl -XPUT -d '{"Level":"DEBUG"}' --cacert $(docker exec etcd printenv ETCDCTL_CACERT) --cert $(docker exec etcd printenv ETCDCTL_CERT) --key $(docker exec etcd printenv ETCDCTL_KEY) https://localhost:2379/config/local/log`

### Disabling debug logging
`curl -XPUT -d '{"Level":"INFO"}' --cacert $(docker exec etcd printenv ETCDCTL_CACERT) --cert $(docker exec etcd printenv ETCDCTL_CERT) --key $(docker exec etcd printenv ETCDCTL_KEY) https://localhost:2379/config/local/log`

### Getting etcd metrics
`curl -X GET --cacert $(docker exec etcd printenv ETCDCTL_CACERT) --cert $(docker exec etcd printenv ETCDCTL_CERT) --key $(docker exec etcd printenv ETCDCTL_KEY) https://localhost:2379/metrics`


**wal_fsync_duration_seconds (99% under 10 ms)**

A wal_fsync is called when etcd persists its log entries to disk before applying them.


**backend_commit_duration_seconds (99% under 25 ms)**

A backend_commit is called when etcd commits an incremental snapshot of its most recent changes to disk.

# kube-apiserver troubleshooting

Run the following script on each controlplane node

`https://raw.githubusercontent.com/mattmattox/k8s-troubleshooting/master/kube-apiserver-check-etcd`

## kubelet troubleshooting

**Check kubelet logging**

As this is the node agent, it will contain the most information regarding operations that it is executing based on scheduling requests


**Check kubelet stats**

`https://raw.githubusercontent.com/mattmattox/k8s-troubleshooting/master/kubelet-stats`
