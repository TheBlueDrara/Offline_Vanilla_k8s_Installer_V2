# Offline Vanilla Kubernetes Installer

<div align="center">
  <img src="images/k8s.webp" alt="Kubernetes" width="120" style="display:inline-block; margin-right: 20px;"/>
  <img src="images/ansible.png" alt="Ansible" width="120" style="display:inline-block; margin-right: 20px;"/>
  <img src="images/vagrant.png" alt="Vagrant" width="120" style="display:inline-block;"/>
</div>


## Overview
Dear user, here you will find an offline vanilla Kubernetes installer, wrapped using Makeself.
A Vagrantfile to help you set up the environment.
Ansible playbooks to deploy the installer.
And lastly a CI Jenkins pipeline to syntax-check the committed code into your GitHub repository.


## Features
- Wrapping script that creates your Makeself offline Kubernetes installer.
- Vagrantfile you can use to quickly provision 2 VMs for the control plane and worker nodes.
- Ansible Playbook that connects to the VMs and deploys the installer.
- CI pipeline that syntax-checks and builds a new updated installer upon success.
- The installation process is logged in a text file in /tmp/installer.log
- Modular installer:
    - If control_plane role passed, it will install k8s and init a control plane node
    - If worker role passed, it will install k8s and join the worker to the cluster
    - If control plane already exists, will do nothing
    - If worker already exists, it will update the worker


## Prerequisites
- Vagrant, Libvirt plugin, and KVM provider installed
    - VM image - "generic/debian12" 
- Makeself installed
- Ansible server or installed locally
- Logged in as root user
- Debian-based distribution


# Dev Notes


### How-To Guide
You can follow this [Guide](GUIDE.md) to set everything up.


### Tool Versions
- Calico v3.27.2
- Kubernetes v1.30.14


### Task
You can find the full task [here](TASK.md).


### Contributors
You can find the project contributors [here](CONTRIBUTORS.md).


### My To-Do
Each time I stumble across a new project that I'm unfamiliar with, I create a To-Do list.
I try to break the big project into small main pieces.

I start by doing everything manually and document the process along the way.
This helps me come to the coding part more prepared and saves me time.

You can find my To-Do list [here](TODO.txt). It's unrefined and honest at the moment thinking.

You can find my script code flow [here](FLOW.md)


### Project Tree
<pre>
.
├── automation-scripts
│   └── install.sh
├── binaries
│   ├── calico_images
│   │   ├── calico-cni.tar.part-aa
│   │   ├── calico-cni.tar.part-ab
│   │   ├── calico-controllers.tar
│   │   ├── calico-node.tar.part-aa
│   │   ├── calico-node.tar.part-ab
│   │   ├── calico-node.tar.part-ac
│   │   └── calico-node.tar.part-ad
│   ├── containerd
│   │   └── containerd_bin.tar.gz
│   ├── control_panel_images
│   │   ├── registry.k8s.io_coredns_coredns_v1.11.3.tar
│   │   ├── registry.k8s.io_etcd_3.5.15-0.tar
│   │   ├── registry.k8s.io_kube-apiserver_v1.30.14.tar
│   │   ├── registry.k8s.io_kube-controller-manager_v1.30.14.tar
│   │   ├── registry.k8s.io_kube-proxy_v1.30.14.tar
│   │   ├── registry.k8s.io_kube-scheduler_v1.30.14.tar
│   │   └── registry.k8s.io_pause_3.9.tar
│   ├── iptables
│   │   └── iptables_bin.tar.gz
│   ├── kube
│   │   ├── crictl-v1.30.0-linux-amd64.tar.gz
│   │   ├── cri-tools_1.30.1-1.1_amd64.deb
│   │   ├── kubeadm_bin.tar.gz
│   │   ├── kubectl_bin.tar.gz
│   │   └── kubelet_bin.tar.gz
│   ├── optional_tools
│   │   ├── helm_bin.tar.gz
│   │   └── kustomize_bin.tar.gz
│   ├── sudo
│   │   └── sudo_bin.tar.gz
│   └── worker_images
│       ├── registry.k8s.io_kube-proxy_v1.30.14.tar
│       └── registry.k8s.io_pause_3.9.tar
├── build-script
│   └── makeself.sh
├── cd
│   ├── inventory
│   │   └── hosts.ini
│   ├── playbooks
│   │   └── main.yaml
│   ├── roles
│   │   ├── control_plane
│   │   │   └── tasks
│   │   │       └── main.yaml
│   │   └── worker
│   │       └── tasks
│   │           └── main.yaml
│   └── ansible.cfg
├── ci
│   └── Jenkinsfile
├── configs
│   ├── calico_conf
│   │   └── calico.yaml
│   ├── containerd_conf
│   │   └── config.toml
│   ├── iptables_conf
│   │   └── network.conf
│   └── join_command.txt
├── images
│   ├── ansible.gif
│   ├── ansible_logo.webp
│   ├── k8s.png
│   ├── kube.gif
│   ├── makeself.gif
│   ├── vagrant.gif
│   └── vagrant_logo.jpg
├── vagrant
│   └── Vagrantfile
├── CONTRIBUTORS.md
├── FLOW.md
├── GUIDE.md
├── README.md
├── TASK.md
└── TODO.txt
</pre>


# Known Issues
- "join_command.txt" might be empty if the control plane installer does not complete correctly. Make sure the file is generated before proceeding.


#### Daily Warhammer 40K Quote
```
I have slept for centuries...
But now I have awoken, and I remember everything.
I remember the heretics.
I remember the traitors.
And I remember...
vengeance.

— Unknown Venerable Dreadnought
```


