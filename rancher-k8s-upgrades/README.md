# Kubernetes-Master-Class-Upgrades
Kubernetes Master Class: A Seamless Approach to Rancher &amp; Kubernetes Upgrades

## [YouTube video](https://www.youtube.com/watch?v=d8kS8y8cLq4)

## Terms
- **Rancher Server** is a set of pods that run the main orchestration engine and UI for Rancher.
- **RKE** (Rancher Kubernetes Engine) is the tool Rancher uses to create and manage Kubernetes clusters
- **Local/upstream cluster** This is the cluster where the Rancher server is installed; this is usually an RKE built cluster)
- **Downstream cluster(s)** are Kubernetes cluster that Rancher is managing

## High-Level rules
The following are the high-level rules for planning a Rancher/Kubernetes/Docker upgrade.
- Do not rush an upgrade.
- Do not stack upgrades (We recommended at least 24hours between upgrades)
- Make sure you have a good backup
- The recommended order of upgrades is Rancher, Kubernetes, and then Docker.
- All upgrades should be tested in a lab or non-prod environment before being deployed to Production.
- Review all release notes [link](https://github.com/rancher/rancher/releases/tag/v2.5.5)
- Review the support matrix [link](https://rancher.com/support-maintenance-terms/all-supported-versions/rancher-v2.5.5/)
- It is not required, but we recommended pausing any CI/CD pipelines using the Rancher API during an upgrade.

## Picking a version
Please see the following recommendations when planning version upgrades.
- **Rancher**: perform one minor version jump at a time
For example: when upgrading from v2.1.x -> v2.3.x. We encourage upgrading v2.1.x -> v2.2.x -> v2.3.x but this is not required.
- **Kubernetes**: perform no more than two minor versions at a time, ideally avoid skipping minor versions entirely as this can increase the chances of an issue due to accumulated changes
For example: when upgrading from v1.13.x -> v1.19.x we encourage upgrading v1.13.x -> v1.15.x -> v1.17.x -> v1.19.x
- **RKE**: perform one major RKE versions jump at a time
For example: when upgrading from v0.1.x -> v1.1.0 instead do v0.1.x -> v0.2.x -> v.0.3.x -> v1.0.x -> v1.1.x


## Creating your change control

### Scheduled change window
- **Rancher upgrade** - 30Mins for install with 30mins for rollback
- **Kubernetes upgrade** - 60Mins for install which may be longer for larger clusters with 60Mins for troubleshooting/rollback

### Effect / Impact during the change window
- **Rancher upgrade** - Only management of Rancher and downstream clusters are impacted; applications shouldn't know that anything is being done. But any CI/CD pipelines should be paused.
- **Kubernetes upgrade of the local cluster** - The Rancher UI should disconnect and reconnect after a few mins due to the ingress-controllers being restarted.
- **Kubernetes upgrade of downstream clusters** - Applications might see a short network blip as ingress-controllers and networking is restarted. See [link](https://rancher.com/blog/2020/zero-downtime/) for more details

### Maintenance window
- **Rancher upgrade** - A maintenance window is not required, but CI/CD pipelines should be paused.
- **Kubernetes upgrade of the local cluster** - A maintenance window is not needed, but CI/CD pipelines should be paused.
- **Kubernetes upgrade of downstream clusters** - This should be done during a maintenance window or a quiet time

## Rancher Upgrade – Prep work
- Check if the Rancher UI is accessible
    - Check if all clusters in UI are in an Active state
    - Check if all pods in kube-system and cattle-system namespaces are running in both the local and downstream clusters.
        ```
        kubectl get pods -n kube-system
        kubectl get pods -n cattle-system
        ```
- Verify etcd has scheduled snapshots configured, and these are working.
    - **RKE**: if Rancher is deployed on a Kubernetes cluster built with RKE, verify etcd snapshots are enabled and working, on etcd nodes you can confirm with the following:
        ```
        ls -l /opt/rke/etcd-snapshots
        docker logs etcd-rolling-snapshots
        ```
    - **k3s**: if Rancher is deployed on a k3s Kubernetes cluster, ensure scheduled backups are configured and working. Please see the k3s [Documentation](https://rancher.com/docs/k3s/latest/en/) pages for further information on this.
- Create a one-time datastore snapshot; please see the following Documentation for RKE and k3s and the single node Docker install options for more information
    - **RKE**: check for expired/expiring Kubernetes certs
        ```
        for i in $(ls /etc/kubernetes/ssl/*.pem|grep -v key); do echo -n $i" "; openssl x509 -startdate -enddate -noout -in $i | grep 'notAfter='; done
        ```

## Rancher Upgrade - Change
- Update helm repo cache
    ```
    helm repo update
    helm fetch rancher-stable/rancher
    ```
- Verify you’re connected to the correct cluster
    ```
    kubectl get nodes -o wide
    ```
- Take an etcd snapshot
    ```
    rke etcd snapshot-save --config cluster.yaml --name pre-rancher-upgrade-`date '+%Y%m%d%H%M%S'`
    ```    
- Grab the current helm values using helm get values rancher -n cattle-system
    Example output:
    ```
    USER-SUPPLIED VALUES:
    antiAffinity: required
    auditLog:
      level: 2
    hostname: rancher.example.com
    ingress:
      tls:
        source: secret
    ```
- Use the values to build your upgrade command
    **NOTE**: The only thing you should change is the version flag.
    ```
    helm upgrade --install rancher rancher-stable/rancher \
    --namespace cattle-system \
    --set hostname=rancher.example.com \
    --set ingress.tls.source=secret \
    --set auditLog.level=2 \
    --set antiAffinity=required \
    --version 2.5.5
    ```
- Wait for the upgrade to finish
    ```
    kubectl -n cattle-system rollout status deploy/rancher
    ```
- Official Rancher upgrade [Documentation](https://rancher.com/docs/rancher/v2.x/en/installation/install-rancher-on-k8s/upgrades/)

## Rancher Upgrade – Verify
- Check if the Rancher UI is accessible
    - Check if all clusters in UI are in an Active state
    - Check if all pods in kube-system and cattle-system namespaces are running in both the local and downstream clusters.
        ```
        kubectl get pods -n kube-system
        kubectl get pods -n cattle-system
        ```
- Verify new Rancher version (Bottom Left corner)
- Verify all Rancher, cattle-cluster-agent, and cattle-node-agent is running on the new version on the local cluster
    ```
    kubectl get pods -n cattle-system -o wide
    ```
- Verify all downstream cluster are Active
- Verify all Rancher, cattle-cluster-agent, and cattle-node-agent runs on the new version on all downstream clusters.
    ```
    kubectl get pods -n cattle-system -o wide
    ```
Take a post-upgrade etcd snapshot
    ```
    rke etcd snapshot-save --config cluster.yaml --name post-rancher-upgrade-`date '+%Y%m%d%H%M%S'`
    ```

## Rancher Upgrade – Backout
- You can not downgrade Rancher; you must do an etcd restore [Documentation](https://rancher.com/docs/rke/latest/en/etcd-snapshots/restoring-from-backup/)
    ```
    rke etcd snapshot-restore --name pre-rancher-upgrade-..... --config ./cluster.yaml
    ```

## RKE Upgrade – Prep work
- Verify the correct `cluster.yaml` and `cluster.rkestate` file
- Verify SSH access to all nodes in the cluster
- Verify all nodes are Ready
    ```
    kubectl get nodes -o wide
    ```
- Verify all pods are Healthy
    ```
    kubectl get pods --all-namespaces -o wide | grep -v 'Running\|Completed'
    ```
    - We're looking for Pods crashing or stuck.
- Verify Kubernetes version is available in RKE
    ```
    rke config --list-version --all –print
    ```
    - You might need to upgrade to a newer RKE version if the recommend k8s version isn't available.

## RKE Upgrade – Change
- Take an etcd snapshot
    ```
    rke etcd snapshot-save --config cluster.yaml --name pre-k8s-upgrade-`date '+%Y%m%d%H%M%S'`
    ```
- Change `kubernetes_version` in the `cluster.yaml`
    ```
    kubernetes_version: "1.19.7-rancher1-1"
    ```
- If you have an air-gapped setup, please see [Documentation](https://rancher.com/docs/rke/latest/en/config-options/system-images/)

## RKE Upgrade - Verify
- Verify all nodes are Ready and at the new version
    ```kubectl get nodes -o wide
    ```
- Verify all pods are Healthy
    ```
    kubectl get pods --all-namespaces -o wide | grep -v 'Running\|Completed’
    ```
    - All pods should be healthy; we're looking for Pods crashing or stuck.

## RKE Upgrade – Backout
- You can not downgrade Rancher; **you must do an etcd restore**
    ```
    rke etcd snapshot-restore --name pre-k8s-upgrade-..... --config ./cluster.yaml
    ```
    - [Documentation](https://rancher.com/docs/rke/latest/en/etcd-snapshots/restoring-from-backup/)

## Common issues

### Missing `cluster.yaml` and `cluster.rkestate`

#### Setting up a lab environment
- Build a standard RKE cluster [Documentation](https://rancher.com/docs/rke/latest/en/installation/#deploying-kubernetes-with-rke)
- Delete `cluster.rkestate`
- Delete `kube_config_cluster.yml`

#### Reproducing the issue
- `rke up`
- You should see rke generating new certificates (See example output below)
```
INFO[0004] [certificates] Generating CA kubernetes certificates
INFO[0005] [certificates] Generating Kubernetes API server aggregation layer requestheader client CA certificates
INFO[0005] [certificates] GenerateServingCertificate is disabled, checking if there are unused kubelet certificates
INFO[0005] [certificates] Generating Kubernetes API server certificates
INFO[0006] [certificates] Generating Service account token key
INFO[0006] [certificates] Generating Kube Controller certificates
INFO[0006] [certificates] Generating Kube Scheduler certificates
INFO[0006] [certificates] Generating Kube Proxy certificates
INFO[0007] [certificates] Generating Node certificate
INFO[0007] [certificates] Generating admin certificates and kubeconfig
```

#### Resolution

- SSH to one of controlplane nodes
- Run the [script](https://raw.githubusercontent.com/rancherlabs/support-tools/master/how-to-retrieve-kubeconfig-from-custom-cluster/rke-node-kubeconfig.sh) and follow the instructions given to get a kubeconfig file for the cluster.
- Run the [script](https://raw.githubusercontent.com/rancherlabs/support-tools/master/how-to-retrieve-cluster-yaml-from-custom-cluster/cluster-yaml-recovery.sh) and follow the instructions given to get a cluster.yaml and cluster.rkestate file for the cluster.
- Copy the files cluster.yml, cluster.rkestate, and kube_config_cluster.yml to a safe location.

###  Upgrading from an old Helm version

#### Setting up a lab environment
- Build a standard RKE cluster [Documentation](https://rancher.com/docs/rke/latest/en/installation/#deploying-kubernetes-with-rke)
- Setup [helm2](https://github.com/helm/helm/releases/tag/v2.17.0)
    ```
    kubectl -n kube-system create serviceaccount tiller
    kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
    helm init --service-account tiller --wait
    helm repo add rancher-latest https://releases.rancher.com/server-charts/latest

    ```
- Install Rancher using helm2
    ```
    helm install rancher-latest/rancher --name rancher \
    --namespace cattle-system \
    --set hostname=rancher.example.com \
    --set ingress.tls.source=secret \
    --version 2.3.10
    ```

#### Reproducing the issue
- Setup [helm3](https://github.com/helm/helm/releases/tag/v3.5.0)
    ```
    helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
    helm repo update
    ```
- Try to upgrade Rancher
    ```
    helm upgrade --install rancher rancher-latest/rancher \
    --namespace cattle-system \
    --set hostname=rancher.example.com \
    --set ingress.tls.source=secret \
    --version 2.5.5
    ```
- Error message
    ```
    Release "rancher" does not exist. Installing it now.
    Error: rendered manifests contain a resource that already exists. Unable to continue with install: ServiceAccount "rancher" in namespace "cattle-system" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "rancher"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "cattle-system"
    ```

#### Resolution
- Take an etcd snapshot
    ```
    rke etcd snapshot-save --config cluster.yaml --name helm2-helm3-`date '+%Y%m%d%H%M%S'`
    ```
- Update annotates and labels for Rancher objects
   ```
   kubectl annotate --overwrite namespace cattle-system app.kubernetes.io/managed-by=helm
   kubectl annotate --overwrite namespace cattle-system meta.helm.sh/release-name=rancher
   kubectl annotate --overwrite namespace cattle-system meta.helm.sh/release-namespace=cattle-system
   kubectl label --overwrite namespace cattle-system app.kubernetes.io/managed-by=Helm
   kubectl -n cattle-system annotate --overwrite sa rancher app.kubernetes.io/managed=helm
   kubectl -n cattle-system annotate --overwrite sa rancher meta.helm.sh/release-name=rancher
   kubectl -n cattle-system annotate --overwrite sa rancher meta.helm.sh/release-namespace=cattle-system
   kubectl -n cattle-system label --overwrite sa rancher app.kubernetes.io/managed-by=Helm
   kubectl -n cattle-system annotate --overwrite ClusterRoleBinding rancher app.kubetes.io/managed-by=helm
   kubectl -n cattle-system annotate --overwrite ClusterRoleBinding rancher meta.helm.sh/release-name=rancher
   kubectl -n cattle-system annotate --overwrite ClusterRoleBinding rancher meta.helm.sh/release-namespace=cattle-system
   kubectl -n cattle-system label --overwrite ClusterRoleBinding rancher app.kubernetes.io/managed-by=Helm
   kubectl -n cattle-system annotate --overwrite service rancher app.kubernetes.ianaged-by=helm
   kubectl -n cattle-system annotate --overwrite service rancher meta.helm.sh/release-name=rancher
   kubectl -n cattle-system annotate --overwrite service rancher meta.helm.sh/release-namespace=cattle-system
   kubectl -n cattle-system label --overwrite service rancher app.kubernetes.io/managed-by=Helm   
   kubectl -n cattle-system annotate --overwrite Deployment rancher app.kuberne.io/managed-by=helm
   kubectl -n cattle-system annotate --overwrite Deployment rancher meta.helm.sh/release-name=rancher
   kubectl -n cattle-system annotate --overwrite Deployment rancher meta.helm.sh/release-namespace=cattle-system
   kubectl -n cattle-system label --overwrite Deployment rancher app.kubernetes.io/managed-by=Helm
   kubectl -n cattle-system annotate --overwrite Ingress rancher app.kubernetio/managed-by=helm
   kubectl -n cattle-system annotate --overwrite Ingress rancher meta.helm.sh/release-name=rancher
   kubectl -n cattle-system annotate --overwrite Ingress rancher meta.helm.sh/release-namespace=cattle-system
   kubectl -n cattle-system label --overwrite Ingress rancher app.kubernetes.io/managed-by=Helm
   ```
- Upgrade Rancher
   ```
   helm upgrade --install rancher rancher-latest/rancher \
   --namespace cattle-system \
   --set hostname=rancher.example.com \
   --set ingress.tls.source=secret \
   --version 2.5.5
   ```

###  Upgrading with a broken node

#### Setting up a lab environment
- Build a standard RKE cluster [Documentation](https://rancher.com/docs/rke/latest/en/installation/#deploying-kubernetes-with-rke)
- Install Rancher using helm3
   ```
   kubectl create namespace cattle-system
   helm upgrade --install rancher rancher-latest/rancher \
   --namespace cattle-system \
   --set hostname=rancher.example.com \
   --set ingress.tls.source=secret \
   --set antiAffinity=required \
   --version 2.5.5
   ```

#### Reproducing the issue
- `systemctl stop docker` one of the nodes in the cluster
- Error message
   ```
   NAME               STATUS     ROLES                      AGE     VERSION
   mmattox-lab-c-01   Ready      controlplane,etcd,worker   9m22s   v1.19.7
   mmattox-lab-c-02   Ready      controlplane,etcd,worker   9m22s   v1.19.7
   mmattox-lab-c-03   NotReady   controlplane,etcd,worker   9m22s   v1.19.7
   ```
- `kubectl get pods -n cattle-system -o wide | grep -ve 'Running\|Completed'`
   ```
   NAME                              READY   STATUS      RESTARTS   AGE     IP           NODE               NOMINATED NODE   READINESS GATES
   rancher-7df6ff577b-nqjfv          0/1     Pending     0          2m11s   <none>       <none>             <none>           <none>
   ```

#### Resolution
**NOTE** This should only be done if the node is unrecoverable, and a replacement should be added to the cluster ASAP.
- Upgrading Rancher
   - Change replicas to 2 for Rancher deployment
       ```
       helm upgrade --install rancher rancher-latest/rancher \
       --namespace cattle-system \
       --set hostname=rancher.example.com \
       --set ingress.tls.source=secret \
       --set replicas=2
       --version 2.5.5
       ```
- Upgrading Kubernetes
    - Edit cluster.yml
    - Comment out bad node. **NOTE** You should only remove one node at a time.
    - Run a `rke up`
    - Delete the node from the cluster if RKE left to behind
        `kubectl delete node mmattox-lab-c-03`
