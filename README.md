# K0s Cluster Ansible Playbook

## On this Page
- [**Project Overview**](#project)
- [**Included Playbooks**](#ip)
- [**Roles**](#roles)
- [**Instructions**](#instructions)
- [**Resources**](#res)

## Project Overview <a id='project'></a>
This repo creates a kubernetes cluster on bare metal servers using kubernetes distro [k0s](https://github.com/k0sproject/k0s).
This playbook is partly based on the official repo of [k0s-ansible](https://github.com/movd/k0s-ansible).

## Included Playbooks <a id='ip'></a>
[`run.yaml`](run.yaml):
```ShellSession
ansible-playbook run.yaml -i hosts
``` 
Optionally, you can add `-K` to ask for priviledge esclation password, `--ask-pass` to ask for ssh password, and `-vv` for detailed verbose or output.
Your inventory must include at least one `initial_controller` and one `worker` node. To get a highly available control plane, more `controller` nodes can be added to the cluster. The `inital_controller` creates tokens that get written to the nodes when the playbook is executed.

[`reset.yaml`](reset.yaml):
```ShellSession
ansible-playbook reset.yaml -i hosts
```
This playbook deletes k0s all its files, directories and services from all hosts.

## Roles <a id='roles'></a>
* [**Env_config**](roles/env_config)
This sets the environmental variables for the k0s service based on architecture of the host
* [**K0s-download**](roles/k0s-download)
This role installs the k0s binary
* [**K0s-prereq**](roles/k0s-prereq)
This role installs all softwares and dependencies required for k0s to run.
* [**K0s_cluster**](roles/k0s_cluster)
This role installs the k0s cluster
* [**Post-cluster-config**](roles/post-cluster-config)
This role install argocd and metal-lb.
* [**Reset**](roles/reset)
This role deletes the cluster, directories, and stops k0s service on all nodes.

## Instructions <a id='instructions'></a>
You can find a user guide on how to use this playbook in the [k0s documentation](https://docs.k0sproject.io/main/examples/ansible-playbook/).
- Edit the [hosts](hosts) file to add your hosts. Change the `ansible_user` and `ansible_host` to fit your environment. This file must include at least one `initial_controller` and one `worker` node.
- Generate your ssh key . To add your private key to ssh agent, run, 
```ShellSession
ssh-agent bash
sudo ssh-add <path/to/private/key>
ssh-copy-id -i <path/to/public/key> hostname@remote-server-ip
``` 
Alternatively, you can add the path using `private_key_file` to ansible config file `/etc/ansible/ansible.cfg` under `[defaults]`.
- Run the Playbook!
- To access the cluster run 
``` ShellSession
export KUBECONFIG=$HOME/k0s-kubeconfig.yaml
``` 

- To get argocd's initial password for admin user. 
```ShellSession
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
``` 

### Optional

- You can patch the argocd service to use the load balancer service type.
```ShellSession
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
``` 
[Click here](https://argo-cd.readthedocs.io/en/stable/getting_started/) for more info about the argocd configuration and how to access the UI. 

- To force Metallb to use a specific IP, add the annotation ` metallb.universe.tf/loadBalancerIPs: <IP>` to the argocd service.

## Resources <a id='res'></a>
- [**K0s**](https://docs.k0sproject.io/v1.23.6+k0s.2/)
- [**Metal LB**](https://metallb.universe.tf/configuration/)
- [**ArgoCD**](https://argo-cd.readthedocs.io/en/stable/)




