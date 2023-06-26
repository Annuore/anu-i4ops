# Kata Container Runtime Ansible Playbook

This playbook deploys kata container runtime into the k3s cluster as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/) on your k3s control plane node.

> **Note**: installation through DaemonSets successfully installs `katacontainers.io/kata-runtime`
> on a node only if it uses either containerd or CRI-O CRI-shims. To get the container runtime that your cluster is using, run `kubectl get nodes -o wide`. 

## Included Playbooks
[`run.yaml`](run.yaml)
```ShellSession
ansible-playbook run.yaml -i hosts.ini -K -k
``` 
This playbook deploys kata container runtime and its classes into your k3s cluster. It inlcudes an roles that installs the kata container runtime as a daemonset and applies the container runtime classes. 

[`cleanup.yaml`](cleanup.yaml)
```ShellSession
ansible-playbook cleanup.yaml -i hosts
```
This playbook removes kata container runtime daemonset and its classes from your k3s cluster.

- This repo branch also includes an example deployment manifest to test the fuctionality of kata.

### Resources
- [Kata](https://katacontainers.io/docs/)
  - [Installation Guide](https://github.com/kata-containers/kata-containers/tree/main/docs/install)
  - [How to use Kata Containers and containerd with Kubernetes](https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/how-to-use-k8s-with-containerd-and-kata.md)
  - [Run Kata COntainers eith Kubernetes](https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/run-kata-with-k8s.md)
  - [How to use Kata Containers and Containerd](https://github.com/kata-containers/kata-containers/blob/main/docs/how-to/containerd-kata.md)
