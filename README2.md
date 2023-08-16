# K3s Single-Node Cluster Ansible Playbook 

## Overview
This playbook installs k3s on a single-node. A single-node server installation is a fully-functional Kubernetes cluster, including all the datastore, control-plane, kubelet, and container runtime components necessary to host workload pods.
It'll also install kubevip for load balancing and virtual ip.

## Basic Workflow
- install the cluster
- install longhorn
- install kubevirt

## setup accounts
on host server
```ShellSession
adduser --home/i4 i4    # password = Wilde6666!
usermod -aG sudo i4
``` 

## software
on master server
```ShellSession
sudo apt update
sudo apt upgrade -y
apt install ansible-core -y

apt install cowsay
``` 

## create ansible.cfg
on master server
```ShellSession
mkdir /etc/ansible
chmod 777 /etc/ansible
ansible-config init > /etc/ansible/ansible.cfg

micro /etc/ansible/ansible.cfg
cowpath=/usr/games/cowsay
``` 

## edit hosts.ini file
micro hosts.ini should look like
```ShellSession
[master]
u9 ansible_host=192.168.1.187 ansible_user=i4 ansible_python_interpreter=/usr/bin/python3

[workers]
u8 ansible_host=172.26.241.60 ansible_user=anu ansible_python_interpreter=/usr/bin/python3

[all:children]
master
workers

; for one node quickstart ... the only node used is [master]

``` 

## set up ssh public key password

```ShellSession
su i4    #password=Wilde6666!
sudo -s  #password=Wilde6666!

ssh-keygen -t rsa -b 4096
eval "$(ssh-agent -s)"
apt-get install sshpass
ssh-add /root/.ssh/id_rsa
ssh-copy-id -i /root/.ssh/id_rsa i4@u9  #password=Wilde6666!
ssh-agent bash

ssh-keyscan u9
``` 


# Kubeconfig path setup
in /etc/environment or .profile
```ShellSession
export KUBECONFIG=$HOME/.kube/config
``` 

## Run ansible playbook

```ShellSession
ansible-playbook install.yaml -i hosts.ini
```

## Check ansible playbook for quickstart, single node

```ShellSession
ansible-all -m ping -v
``` 



## Files and Directories
- **roles:** contains two roles, install (which has the tasks that installs k3s) and delete (deletes the cluster)
- **hosts.ini:** host file to specify hosts ip and user
- **single-cluster.yaml:** playbook to install k3s
- **delete-sn-cluster.yaml:** deletes k3s 