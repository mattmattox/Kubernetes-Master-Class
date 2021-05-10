# Run away App stomping all over a cluster

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
- Check pod CPU/MEM usage
  ```
  kubectl top pod -A
  ```
- Some pods will start `CrashLooping`
  ```
  kubectl get pods -A
  ```
  ```
  NAME      STATUS        AGE
  test-ns   Terminating   6m25s
  ```
- If kubelet or Docker starts timing out or crashes. The nodes will go into `NotReady`.
  ```
  kubectl get node -o wide
  ```

## Troubleshooting
- SSH into the node(s) in question and run `top`, if the node is swapping it's going to crash
  ```
  ```
  root@a1ublabgt01:~# top
  top - 21:51:01 up 1 day, 20:49,  1 user,  load average: 33.61, 16.60, 7.21
  Tasks: 285 total,  22 running, 262 sleeping,   0 stopped,   1 zombie
  %Cpu(s):  1.4 us, 93.6 sy,  0.0 ni,  0.0 id,  0.0 wa,  0.0 hi,  5.0 si,  0.0 st
  MiB Mem :   3932.3 total,     85.5 free,   3782.9 used,     63.9 buff/cache
  MiB Swap:    980.0 total,      0.0 free,    980.0 used.     30.4 avail Mem
      PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
      91 root      20   0       0      0      0 R  37.9   0.0   0:51.69 [kswapd0]
  ```
- Try running `docker stats` to find the containter that is using up all the resources.

## Restoring/Recovering
- Scale the deployment to zero
  ```
  kubectl -n <namespace> scale deployment/<deployment name> --replicas=0
  ```
- Add/Edit CPU and MEM limits to the deployment
  ```
  kubectl -n <namespace> edit deployment/<deployment name>
  ```
  Add/Update the following.
  ```
      resources:
      limits:
        cpu: "800m"
        mem: "500Mi"
      requests:
        cpu: "500m"
        mem: "250Mi"
  ```

## Preventive tasks
- Use OPA Gatekeeper to force all pods to have limits. 
[Example Constraint](https://docs.rafay.co/recipes/governance/limits_policy/)

## Documention
- [General](https://kubernetes.io/docs/tasks/administer-cluster/manage-resources/)
- [More Examples](https://github.com/open-policy-agent/gatekeeper/blob/master/demo/agilebank/constraints/containers_must_be_limited.yaml)