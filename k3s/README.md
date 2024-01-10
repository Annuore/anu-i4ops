## Roles <a id='roles'></a>
* [**k3s-download**](roles/k3s_download)
This role installs the K3s binary. 
* [**k3s-prereq**](roles/k3s_prereq)
This role installs all softwares and dependencies required for K3s to run.
* [**k3s_cluster**](roles/k3s_cluster)
This role deploys the K3s cluster. It starts the k3s service on the master node, generates a join token for the workers and then adds the workers to the cluster. It also generates the kube-vip RBAC manifest and adds the daemonset manifest to the auto-deploy directory.
* [**cluster_addons**](roles/cluster_addons)
This role install argocd and rancher management server via helm. 
* [**reset**](roles/reset)
This role deletes the cluster, directories, and stops K3s service on all nodes.

## Network Overview <a id='net'></a>
The k3s cluster automatically comes with traefik for ingress and cluster network which is disabled during this cluster installation (check server arguments passed to install command). The traefik ingress is still functional but nginx ingress controller is bootstrapped with the cluster and should be used by specifying the value `nginx` under spec.ingressClassName in your ingress yaml definition.
- [**Kubevip**](https://kube-vip.io/docs/usage/k3s/) for virtual IP and load balancing. Kubevip assigns an external IP to a loadbalancer type of service which allows external traffic into the cluster. 
- [**Nginx**](https://docs.nginx.com/nginx-ingress-controller/) for ingress 
- **Traefik** is disabled.