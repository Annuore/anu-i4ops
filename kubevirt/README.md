# Kubevirt Ansible Playbook 

## On this Page 
- [**Instructions**](#inst)
- [**Resources**](#res)

## Overview 
This playbook installs [kubevirt](https://kubevirt.io/user-guide/) into our k3s cluster. Kubevirt is a virtual machine management add-on for kubernetes. It allows temas with a reliance on existing vm-based workloads to rapidly containerize applications. It also installs virtctl and libguestfs-tools(for virt-builder and virt-customize).

Included in this repo is the [kube-files](kube-files) directory that container examples of vm, vmi and container disk manifest files. The [dockerfile](dockerfile) builds a docker image that can be mounted on a vmi as a containerdisk image

### Quick Steps
- Install kubevirt operator as described [here](https://kubevirt.io/user-guide/operations/installation/) or enable the kubevirt [addon](https://kubevirt.io/quickstart_minikube/) on [minikube](https://minikube.sigs.k8s.io/docs/start/). 

#### Step by step instructions
- Change the `ansible_user` and `ansible_host` to your user and ip. 
- add ssh keys to remote systems using
```ShellSession
ssh-copy-id -i /path/to/public/key user@ip
``` 
- run `sudo mv virtctl /usr/local/bin` to add virtcl to the users's bin.
- run the playbook using
```ShellSession
ansible-playbook -i hosts.ini -k -K run-playbook.yaml 
```  
* **NOTE** make sure that hostkey-checking is disabled i  the default section of your /etc/ansible/ansible.cfg file.
- create a testvm 
```ShellSession
kubectl apply -f vm.yaml
``` 
- start a virtual machine instance 
```ShellSession
virtctl start testvm
``` 
- get the vm and the vm instance. Optionally you can add a `-w` to watch the status or progress of the started vm
```ShellSession
kubectl get vm,vmi
``` 
- connect to the running vmi
```ShellSession
virtctl console testvm
``` 

## Instructions <a id='instr'></a>
**This playbook assumes that a kubernetes cluster is already installed.** 
- Change the `ansible_user` and `ansible_host` to your user and ip. 
- add ssh keys to remote systems using
```ShellSession
ssh-copy-id -i /path/to/public/key user@ip
``` 
- Run the run-playbook.yaml to install kubevirt perator in your cluster 
- Run a `kubectl apply` on vm.yaml in the [kube-files](kube-files) directory. 
- Start a vm instance from the created vm using `virtcl start <name-of-vm>` 
- To get access into the virtual machine run, `virtctl console <name-of-vm>`

### Note for deletion. 
It is important to know that you need to delete the apiservices before deleteing the operator. Run, 
```ShellSession
kubectl delete apiservices v1.subresources.kubevirt.io
``` 
This is to avoid stuck terminating namespaces. If by mistake you deleted the operator first, the kubevirt custom resource will get stuck in the `Terminating` state. To fix it, delete manually finalizer from the resource.
```ShellSession
kubectl -n kubevirt patch kv kubevirt --type=json -p '[{ "op": "remove", "path": "/metadata/finalizers" }]'
``` 

## Resources <a id='res'></a>
- [Kubevirt Installation](https://kubevirt.io/user-guide/operations/installation/)
- [Kubevirt Updating and deletion](https://kubevirt.io/user-guide/operations/updating_and_deletion/)
- [Kubevirt VM creation](https://kubevirt.io/user-guide/virtual_machines/virtual_machine_instances/)
- [Virtctl]( https://github.com/kubevirt/kubevirt.github.io/blob/main/_includes/quickstarts/virtctl.md)
- [Kubevirt Image Generator](https://github.com/Tedezed/kubevirt-images-generator)
- [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)
