# Kubevirt Ansible Playbook 

## On this Page 
- [**Instructions**](#instr)
- [**Resources**](#res)
- [**Build Kubevirt Containerdisk Image**](#build)

## Overview 
This playbook installs [kubevirt](https://kubevirt.io/user-guide/) into our k3s cluster. Kubevirt is a virtual machine management add-on for kubernetes. It allows teams with a reliance on existing vm-based workloads to rapidly containerize applications. It also installs virtctl and libguestfs-tools(for virt-builder and virt-customize).

Included in this repo is the [kube-files](kube-files) directory that contains examples of vm, vmi and container disk manifest files. The [dockerfile](dockerfile) builds a docker image that can be mounted on a vmi as a containerdisk image

**NOTE: Run commands on the remote host(on which the cluster is to be deployed) as a regular user not as root**

### Quick Steps
- Install kubevirt operator as described [here](https://kubevirt.io/user-guide/operations/installation/) or enable the kubevirt [addon](https://kubevirt.io/quickstart_minikube/) on [minikube](https://minikube.sigs.k8s.io/docs/start/). 

 #### Step by step instructions
 **This playbook assumes that a kubernetes cluster is already installed. It also assumes that you have git installed.** 
- clone the repo 
```ShellSession
git clone https://github.com/hubbertsmith/anu-i4ops.git
``` 
- change directory into anu-i4ops
```ShellSession
cd anu-i4ops
```
- Change the `ansible_user` and `ansible_host` in the hosts.ini file to your user and ip. 
- add ssh keys to remote systems using
```ShellSession
ssh-copy-id -i /path/to/public/key user@ip
``` 
- run the playbook using
```ShellSession
ansible-playbook -i hosts.ini -k -K install.yaml 
```  
**NOTE:** make sure that hostkey-checking is disabled in the default section of your /etc/ansible/ansible.cfg file.

## To use create a new vm in the cluster(on the remote host) after running the kubevirt install playbook, 
- first, create a pvc
```ShellSession
cd ~/longhorn
kubectl apply -f longhorn-vm-pvc.yaml
``` 
- create a testvm 
```ShellSession
cd ~/kubevirt
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

## Instructions<a id='instr'></a>
- Change the `ansible_user` and `ansible_host` to your user and ip. 
- add ssh keys to remote systems using
```ShellSession
ssh-copy-id -i /path/to/public/key user@ip
``` 
- Run the run-playbook.yaml to install kubevirt operator in your cluster 
- Run a `kubectl apply` on vm.yaml in the user's home directory. 
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
# Build Kubevirt Containerdisk Image<a id='build'></a> 
### Assumptions
*This playbook makes the following assumptions*
- That docker is install and configured locally (i.e the machine that runs the ansible playbook). [Click here](https://docs.docker.com/engine/install/ubuntu/) to install docker.
- That a user is logged into docker locally. Else, run `docker login`
- That docker python dependecy has been installed locally. Run `pip install docker.py` locally. Do not run within a virtual environment. 
- That the i4 module and i4ctl are in a local directory named i4.

### Before running the playbook
- in [main.yaml](./build_kubevirt_image/roles/create-vm/defaults/main.yaml) file, change the *build_and_push_image_name* to your docker hub repository name in the format *username/repo*, the *build_and_push_image_version*, and *build_docker_file_path* to the absolute path to the dockerfile.
- Note that the *disk_image_dest* path needs to end with a trailing slash '/' to avoid errors. Also, the *build_docker_file_path* and *disk_image_dest* paths MUST be the same.
- in [all.yaml](./build_kubevirt_image/group_vars/all.yaml) file, change the *i4_src_dir* to the directory that contains the i4kmod and i4ctl on your local machine. 
- change ssh key (public key of your remote host, i.e. either master or worker nodes) in [vm.yaml](./roles/install/templates/vm.yaml.j2) or comment out that line if you do not want to add ssh keys.

### Steps
- cd into [build_kubevirt_image](./build_kubevirt_image/) directory.
- run the playbook `ansible-playbook -i hosts.ini -k -K build_containerdisk.yaml`

### Accessing the Virtual Machines
The remote/ansible user's public ssh key is injected into the vm dynamically via the qemu-guest-agent. Utilizing the qemuGuestAgent propagation method, configured `Secrets` are attached to a VirtualMachine when the VM is started.

The `Secret` containing the SSH public key is attached to the virtual machine via the access credentials API with the qemuGuestAgent propagation method. This allows updating the contents of the Secret at any time, which will result in the changes getting applied to the running virtual machine immediately. 

The `Secret` is created while the playbook runs. Get the created secret using `kubectl get secret` or add additional public keys by editing the secret.

**NOTE**
- if you get an ouput similar to `"changed": false, "skip_reason": "Conditional result was False"`, change the *build_and_push_image_version*, the playbook will not build an image version if it's previously built, else, remove the image from your computer.
- The playbook takes between 12 to 16 minutes to run, if any of the tasks is taking time, it's running. The long build time is due to the image file size.
- New Secrets cannot be attached to a running VM. You must restart the VM to attach the new Secret.


## Cloning a Virtual Machine
The `clone.kubevirt.io` API Group defines resources for cloning KubeVirt objects. Under the hood, the clone API relies upon Snapshot & Restore APIs.
Kubevirt requires that a `virtual machine` uses `DataVolumes` or `PersistentVolumeClaims` backed by a `StorageClass` in order to get `VolumeSnapshot`. 
It also requires the Snapshot feature gate. 
This section makes the following assumption
- That a kubernetes cluster is running
- That kubevirt and virtctl are installed 
- That a kubevirt vm exists
- That the snapshot controller has been installed/deployed into the cluster.

### Steps
- change dir into longhorn. `cd ~/longhorn` 
- Apply [volume_snapshot_sc.yaml](../longhorn/roles/install/templates/volume_snapshot_sc.yaml.j2) to create the snapshot class object. `kubectl apply -f volume_snapshot_sc.yaml`
- change dir into kubevirt directory. `cd ../kubevirt`
- Display the contents of [vm_clone.yaml](roles/install/templates/vm_clone.yaml.j2) and confirm that spec.source.name is consistent with the vm name(vm that is to be cloned).
- Apply the vm_clone.yaml file to create the clone. 
- Wait for a clone to complete. `kubectl wait vmclone testclone --for condition=Ready`

## Resources<a id='res'></a>
- [Kubevirt Installation](https://kubevirt.io/user-guide/operations/installation/)
- [Kubevirt Updating and deletion](https://kubevirt.io/user-guide/operations/updating_and_deletion/)
- [Kubevirt VM creation](https://kubevirt.io/user-guide/virtual_machines/virtual_machine_instances/)
- [Virtctl]( https://github.com/kubevirt/kubevirt.github.io/blob/main/_includes/quickstarts/virtctl.md)
- [Kubevirt Image Generator](https://github.com/Tedezed/kubevirt-images-generator)
- [Ubuntu Cloud Images](https://cloud-images.ubuntu.com/)

