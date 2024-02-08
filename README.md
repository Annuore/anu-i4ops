# I4ops cloud agnostic infrastructure

## About i4ops

- Briefing (21 min) https://www.youtube.com/watch?v=QrHHuFw-AHI
- Demo1 (6 min) https://youtu.be/MPvPiDJSvIo
- business brief (3 min) https://youtu.be/bsn_7L-9Nps
- https://youtu.be/RhH8ASixAqE -- Wikipedia List Data Breach (2min)

## On this Page
- [**Project Overview**](#project)
- [**Project Workflow or Sequence**](#flow)
- [**Instructions**](#instructions)
- [**Resources**](#res)

## Project Overview <a id='project'></a>
This repo contains ansible playbooks for creating a [k3s](https://docs.k3s.io/) kubernetes cluster with [kube-vip](https://kube-vip.io/docs/installation/). It includes [Argocd](https://argo-cd.readthedocs.io/en/stable/) for gitops and [Rancher management server](https://ranchermanager.docs.rancher.com/v2.5/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster) for container or cluster management(UI). It also includes a [Kubevirt](./kubevirt) playbook that deploys kubevirt into the cluster. For each additional projects like the [singlenode k3s cluster](https://github.com/hubbertsmith/anu-i4ops/blob/k3s/k3s_quickstart/README.md), [kubevirt](https://github.com/hubbertsmith/anu-i4ops/blob/k3s/kubevirt/README.md), and [longhorn](https://github.com/hubbertsmith/anu-i4ops/blob/k3s/longhorn/README.md), there's an available readme which will walk you through each project.

This repo has the following directory structure (navigate to documentation by clicking the link):

- [i4kmod](i4kmod/readme.md)
- [k3s](k3s/README.md)
- [k3s_quickstart](k3s_quickstart/README.md)
- [kubevirt](kubevirt/README.md)
- [longhorn](longhorn/README.md)

Additional documentation:
- [zerotier](docs/docs/zerotier.md) - accessing nodes via VPN
- [ansible](docs/ansible.md) - ansible installation
- [artifacts](docs/kubectl-access.md) - using artifacts after deploying k8s cluster

## Project Workflow or Sequence <a id='flow'></a>
- install required ansible collections `ansible-galaxy install -r requirements.yml`
- setup the `hosts.ini` file
- connect to the environment by using zerotier

**single node cluster:**
- to install: `ansible-playbook install-single-node.yaml -i hosts.ini -k -K`
- to uninstall: `ansible-playbook uninstall-single-node.yaml -i hosts.ini -k -K`

Note: Your inventory (`hosts.ini`) must include at the same host in `master` and in `worker` section.


**multi node cluster:**
- to install: `ansible-playbook install.yaml -i hosts.ini -k -K`
- to uninstall: `ansible-playbook uninstall.yaml -i hosts.ini -k -K`

Note: Your inventory (hosts.ini) must include at least one master and one worker node.

## Selective playbook deployment
To install:
```
ansible-playbook `<playbook-name>/install.yaml` -i hosts.ini -k -K
```

For example:
```
ansible-playbook k3s_quickstart/install.yaml -i hosts.ini -k -K
```

To uninstall:
```
ansible-playbook `<playbook-name>/uninstall.yaml` -i hosts.ini -k -K
```

For example:
```
ansible-playbook k3s_quickstart/uninstall.yaml -i hosts.ini -k -K
```

## Selective task/role deployment
If a given ansible task/role contains `tags` property then you can instruct ansible to install only those marching a given tag.
For example:
```
ansible-playbook k3s/install.yaml -i hosts.ini --tags=cluster_addons
```

## Accessing kubernetes cluster from your host
After successful deployment
```
export KUBECONFIG=artifacts/k0s-kubeconfig.yaml
```

## Setup hosts.ini and servers <a id='ip'></a>
[`setup hosts.ini. you need server/hostname/host IP /user (i4demo)/pass(i4demo) `](hosts.ini):
```ShellSession
[master]
u5 ansible_host=10.243.81.56 ansible_user=i4demo ansible_python_interpreter=/usr/bin/python3
; u6 ansible_host=10.243.170.237 ansible_user=i4demo ansible_python_interpreter=/usr/bin/python3
; u7 ansible_host=10.243.26.226 ansible_user=i4demo ansible_python_interpreter=/usr/bin/python3
[workers]
u8 ansible_host=10.243.113.123 ansible_user=i4demo ansible_python_interpreter=/usr/bin/python3
u9 ansible_host=10.243.201.10 ansible_user=i4demo ansible_python_interpreter=/usr/bin/python3
[all:children]
master

; Optional, if you want your vars in the host file
[all:vars]
ansible_python_interpreter=/usr/bin/python3
; k3s_version=v1.25.10+k3s1
; systemd_dir= /etc/systemd/system
; master_ip="{{ hostvars[groups['master'][0]]['ansible_host'] | default(groups['master'][0]) }}"
; extra_server_args=""
; extra_agent_args="
```
## Instructions <a id='instructions'></a>
- Edit the [hosts.ini](hosts.ini) file to add your hosts. Change the `ansible_user` and `ansible_host` to fit your environment. This file must include at least one `master` and one `worker` node.

- Generate your ssh key . To add your private key to ssh agent, run,
```ShellSession
ssh-agent bash
sudo ssh-add <path/to/private/key>
ssh-copy-id -i <path/to/public/key> hostname@remote-server-ip
```
Alternatively, you can add the path using `private_key_file` to ansible config file `/etc/ansible/ansible.cfg` under `[defaults]`.
- Run the [Playbook!](https://github.com/hubbertsmith/anu-i4ops/tree/k3s#included-playbooks-)
- To access the cluster run
``` ShellSession
export KUBECONFIG=/home/{{ ansible_user}}/.kube/config
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




## Resources <a id='res'></a>
- [**K3s**](https://docs.K3sproject.io/v1.23.6+K3s.2/)
- [**Kube-Vip**](https://kube-vip.io/docs/usage/k3s/)
- [**ArgoCD**](https://argo-cd.readthedocs.io/en/stable/)
-  [**Rancher**](https://ranchermanager.docs.rancher.com/v2.5/pages-for-subheaders/install-upgrade-on-a-kubernetes-cluster)
