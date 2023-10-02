# K3s Cluster Ansible Playbook

## In this repo
There are additional projects in this repo, they include:
- [K3s single node cluster](k3s_quickstart) which installs a single node cluster
- [Kubevirt](kubevirt) which deploys kubevirt into the cluster
-[Longhorn](longhorn) which deploys longhorn for storage and persistence


## On this Page
- [**Project Overview**](#project)
- [**Project Workflow or Sequence**](#flow)
- [**Included Playbooks**](#ip)
- [**Roles**](#roles)
- [**Instructions**](#instructions)
- [**Network Overview**](#net)
- [**Resources**](#res)


## Project Overview <a id='project'></a>
This repo creates a [k3s](https://docs.k3s.io/) kubernetes cluster with [kube-vip](https://kube-vip.io/docs/installation/). It includes [Argocd](https://argo-cd.readthedocs.io/en/stable/) for gitops and [Rancher management server](https://ranchermanager.docs.rancher.com/v2.5/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster) for container or cluster management(UI). It also includes a [Kubevirt](./kubevirt) playbook that deploys kubevirt into the cluster. For each additional projects like the [singlenode k3s cluster](https://github.com/Annuore/anu-i4ops/blob/k3s/k3s_quickstart/README.md), [kubevirt](https://github.com/Annuore/anu-i4ops/blob/k3s/kubevirt/README.md), and [longhorn](https://github.com/Annuore/anu-i4ops/blob/k3s/longhorn/README.md), there's an available readme which will walk you through each project.

## Project Workflow or Sequence <a id='flow'></a>
- First you install the k3s cluster (follow instructions below on how to install) or cd into k3s_quickstart to create a single-node k3s cluster.
- Install kubevirt
- Then install longhorn for persistence

## Included Playbooks <a id='ip'></a>
[`install_k3s_cluster.yaml`](install_k3s_cluster.yaml):
```ShellSession
ansible-playbook run.yaml -i hosts.ini
``` 
Optionally, you can add `-K` to ask for priviledge esclation password, `--ask-pass` to ask for ssh password, and `-vv` for detailed verbose or output.
Your inventory must include at least one `master` and one `worker` node. To get a highly available control plane, more `controller` nodes can be added to the cluster. To add more nodes to the exsiting cluster, visit the k3s [HA embedded etcd](https://docs.k3s.io/datastore/ha-embedded) for details.

[`delete_k3s_cluster.yaml`](delete_k3s_cluster.yaml):
```ShellSession
ansible-playbook reset.yaml -i hosts
```
This playbook deletes k3s all its files, directories and services from all hosts.

## Roles <a id='roles'></a>
* [**K3s-download**](roles/k3s_download)
This role installs the K3s binary. 
* [**K3s-prereq**](roles/k3s_prereq)
This role installs all softwares and dependencies required for K3s to run.
* [**K3s_cluster**](roles/k3s_cluster)
This role deploys the K3s cluster. It starts the k3s service on the master node, generates a join token for the workers and then adds the workers to the cluster. It also generates the kube-vip RBAC manifest and adds the daemonset manifest to the auto-deploy directory.
* [**Cluster_addons**](roles/cluster_addons)
This role install argocd and rancher management server via helm. 
* [**Reset**](roles/reset)
This role deletes the cluster, directories, and stops K3s service on all nodes.

## Instructions <a id='instructions'></a>
- Edit the [hosts.ini](hosts.ini) file to add your hosts. Change the `ansible_user` and `ansible_host` to fit your environment. This file must include at least one `master` and one `worker` node.

- Generate your ssh key . To add your private key to ssh agent, run, 
```ShellSession
ssh-agent bash
sudo ssh-add <path/to/private/key>
ssh-copy-id -i <path/to/public/key> hostname@remote-server-ip
``` 
Alternatively, you can add the path using `private_key_file` to ansible config file `/etc/ansible/ansible.cfg` under `[defaults]`.
- Run the [Playbook!](https://github.com/Annuore/anu-i4ops/tree/k3s#included-playbooks-)
- To access the cluster run 
``` ShellSession
export KUBECONFIG=$HOME/.kube/config
``` 

- Rancher requires a `hostname` variable. You can use a domain name or use any name and add it to your `/etc/hosts` file.
- To get argocd's initial password for admin user. 
```ShellSession
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
``` 

- To get rancher's initial password for admin user. 
```ShellSession
kubectl get secret --namespace cattle-system bootstrap-secret -o go-template='{{.data.bootstrapPassword|base64decode}}{{ "\n" }}
``` 

### Optional
- You can patch the argocd service to use the load balancer service type.
```ShellSession
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
``` 
[Click here](https://argo-cd.readthedocs.io/en/stable/getting_started/) for more info about the argocd configuration and how to access the UI.  

[Click here](https://docs.k3s.io/advanced) for k3s advanced configuration.

## Network Overview <a id='net'></a>
The k3s cluster automatically comes with traefik for ingress and cluster network which is disabled during this cluster installation (check server arguments passed to install command). The traefik ingress is still functional but nginx ingress controller is bootstrapped with the cluster and should be used by specifying the value `nginx` under spec.ingressClassName in your ingress yaml definition.
- [**Kubevip**](https://kube-vip.io/docs/usage/k3s/) for virtual IP and load balancing. Kubevip assigns an external IP to a loadbalancer type of service which allows external traffic into the cluster. 
- [**Nginx**](https://docs.nginx.com/nginx-ingress-controller/) for ingress 
- **Traefik** is disabled.


## Resources <a id='res'></a>
- [**K3s**](https://docs.K3sproject.io/v1.23.6+K3s.2/)
- [**Kube-Vip**](https://kube-vip.io/docs/usage/k3s/)
- [**ArgoCD**](https://argo-cd.readthedocs.io/en/stable/)
-  [**Rancher**](https://ranchermanager.docs.rancher.com/v2.5/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster)
