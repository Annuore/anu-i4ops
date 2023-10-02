# K3s Single-Node Cluster Ansible Playbook 

## Overview
This playbook installs k3s on a single-node. A single-node server installation is a fully-functional Kubernetes cluster, including all the datastore, control-plane, kubelet, and container runtime components necessary to host workload pods.
It'll also install kubevip for load balancing and virtual ip, rancher for cluster management, and nginx ingress controller.

## Basic Workflow
- install the cluster
- install [longhorn](https://github.com/Annuore/anu-i4ops/tree/k3s/longhorn)
- install [kubevirt](https://github.com/Annuore/anu-i4ops/tree/k3s/kubevirt)


## Files and Directories
- **roles:** contains two roles, install (which has the tasks that installs k3s) and delete (deletes the cluster)
- **hosts.ini:** host file to specify hosts ip and user
- **single-cluster.yaml:** playbook to install k3s
- **delete-sn-cluster.yaml:** deletes k3s 

## Sample deployment
On the user's home directory, find a [deploy.yaml](#roles/install/templates/deploy.yaml.j2) file
- Change the image reference under spec.template.spec.containers to your image. 
- Run `kubectl apply -f deploy.yaml`. This will create two replicas of nginx deployment and a service.