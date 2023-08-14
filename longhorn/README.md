# Longhorn Ansible Playbook 
**IMPORTANT NOTE: add the label "volume: longhorn to any deployment that will consume the longhorn storage/volume** 
## Files and Directories
- **roles:** contains two roles, install (which has the tasks that installs longhorn) and delete (deletes longhorn)
- **hosts.ini:** host file to specify hosts ip and user
- **install-playbook.yaml:** playbook to install longhorn
- **delete-playbook.yaml:** deletes longhorn 
## Steps
- modify the hosts.ini file to contain the server's ip and username
- add your ssh key to the remote using 
```ShellSession
ssh-copy-id -i <path/to/public/key> hostname@remote-server-ip
```
**NOTE:** make sure that hostkey-checking is disabled in the default section of your /etc/ansible/ansible.cfg file.

- run the playbook using 
```ShellSession
ansible-playbook -i hosts.ini -k -K install-playbook.yaml
``` 
- once the playbook runs, cd into the longhorn directory and create a storage class, persistent volume claim and pod to consume the volume
```ShellSession
kubectl apply -f storageclass.yaml
kubectl apply -f longhorn/longhorn-vm-pvc.yaml
``` 
- create a vm.
```ShellSession
kubectl apply -f vm.yaml
```  
- start the vm.
```ShellSession
virtctl start testvm
```
- watch the status of the vm using `kubectl get vmi -w` and wait for the `running` status. connect to the vm using 
```ShellSession
virtctl console testvm
```
## Resources
- [Longhorn](https://longhorn.io/docs/1.5.1/what-is-longhorn/)
- [Installation](https://longhorn.io/docs/1.5.1/deploy/install/)
- [Use Longhorn](https://longhorn.io/docs/1.5.1/volumes-and-nodes/create-volumes/)