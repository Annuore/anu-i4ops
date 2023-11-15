# K3s Single-Node Cluster Ansible Playbook 

## Overview
This playbook installs k3s on a single-node. A single-node server installation is a fully-functional Kubernetes cluster, including all the datastore, control-plane, kubelet, and container runtime components necessary to host workload pods.
It'll also install kubevip for load balancing and virtual ip, rancher for cluster management, and nginx ingress controller.

## Basic Workflow
**Note that the installation doesn't follow a particular order, however, it is expected that longhorn be installed before running kubevirt vms.**
- install the [cluster](https://github.com/Annuore/anu-i4ops/tree/k3s/k3s_quickstart#instructions)
- install [longhorn](https://github.com/Annuore/anu-i4ops/tree/k3s/longhorn)
- install [kubevirt](https://github.com/Annuore/anu-i4ops/tree/k3s/kubevirt)

## Files and Directories
- **roles:** contains two roles, install (which has the tasks that installs k3s) and delete (deletes the cluster)
- **hosts.ini:** host file to specify hosts ip and user
- **run-k3s_quick.yaml:** playbook to install k3s single node
ansible-playbook run-k3s_quick.yaml -i hosts.ini -k -K

- **stop-k3s_quick.yaml:** deletes k3s single node
ansible-playbook run-k3s_quick.yaml -i hosts.ini -k -K

## Instructions
- clone the [repo](https://github.com/Annuore/anu-i4ops/tree/k3s) and cd into it.
- cd into k3s_quickstart
- edit hosts.ini file to fit your master's ip address and username
- `u5 ansible_host=10.243.16.10  ansible_user=i4demo ansible_python_interpreter=/usr/bin/python3`
- run the playbook `ansible-playbook run-k3s_quick.yaml -i hosts.ini -k -K`

## Sample deployment
On the user's home directory, find a [deploy.yaml](#roles/install/templates/deploy.yaml.j2) file
- Change the image reference under spec.template.spec.containers to your image. 
- Run `kubectl apply -f ~/deploy.yaml`. This will create two replicas of nginx deployment and a service.

- kubectl get deployments
- kubectl delete -f deploy.yaml
- 
