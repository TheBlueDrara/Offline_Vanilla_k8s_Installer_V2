# Offline Vanilla Kubernetes Installer


# Please Note!

This Repo is under construction, i will be ypdating the project so it will be easily deployed via ansible in the near future!









## Overview
Dear user, here you will find an offline vanilla Kubernetes installer, wrapped using Makeself.
You will also find a CI Jenkins pipeline to syntax-check the committed code into your GitHub repository,
and a Vagrantfile to help you set up the environment.

## Features
- Wrapping script that creates your Makeself offline Kubernetes installer.
- CI pipeline that syntax-checks and builds a new updated installer upon success.
- Vagrantfile you can use to quickly provision 2 VMs for the control plane and worker nodes.
- Modular installer: if run on an empty machine, it will create a control plane node; if a worker node already exists, it will update it.

## Prerequisites
- Vagrant, Libvirt plugin, and KVM provider installed
- Logged in as root user
- Debian-based distribution
- Makeself installed

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
<pre>```
.
├── automation-scripts
│   ├── install.sh
│   └── .placeholder
├── binaries
│   ├── calico_images
│   │   ├── calico-cni.tar.part-aa
│   │   ├── calico-cni.tar.part-ab
│   │   ├── calico-controllers.tar
│   │   ├── calico-node.tar.part-aa
│   │   ├── calico-node.tar.part-ab
│   │   ├── calico-node.tar.part-ac
│   │   └── calico-node.tar.part-ad
│   ├── containerd
│   │   └── containerd_bin.tar.gz
│   ├── control_panel_images
│   │   ├── registry.k8s.io_coredns_coredns_v1.11.3.tar
│   │   ├── registry.k8s.io_etcd_3.5.15-0.tar
│   │   ├── registry.k8s.io_kube-apiserver_v1.30.14.tar
│   │   ├── registry.k8s.io_kube-controller-manager_v1.30.14.tar
│   │   ├── registry.k8s.io_kube-proxy_v1.30.14.tar
│   │   ├── registry.k8s.io_kube-scheduler_v1.30.14.tar
│   │   └── registry.k8s.io_pause_3.9.tar
│   ├── iptables
│   │   └── iptables_bin.tar.gz
│   ├── kube
│   │   ├── crictl-v1.30.0-linux-amd64.tar.gz
│   │   ├── kubeadm_bin.tar.gz
│   │   ├── kubectl_bin.tar.gz
│   │   └── kubelet_bin.tar.gz
│   ├── optional_tools
│   │   ├── helm_bin.tar.gz
│   │   └── kustomize_bin.tar.gz
│   ├── .placeholder
│   ├── sudo
│   │   └── sudo_bin.tar.gz
│   └── worker_images
│       ├── registry.k8s.io_kube-proxy_v1.30.14.tar
│       └── registry.k8s.io_pause_3.9.tar
├── build-script
│   ├── makeself.sh
│   └── .placeholder
├── cd
│   └── .placeholder
├── ci
│   ├── Jenkinsfile
│   └── .placeholder
├── configs
│   ├── calico_conf
│   │   └── calico.yaml
│   ├── containerd_conf
│   │   └── config.toml
│   ├── iptables_conf
│   │   └── network.conf
│   ├── join_command.txt
│   └── .placeholder
├── CONTRIBUTORS.md
├── FLOW.md
├── .git
│   ├── branches
│   ├── config
│   ├── description
│   ├── HEAD
│   ├── hooks
│   │   ├── applypatch-msg.sample
│   │   ├── commit-msg.sample
│   │   ├── fsmonitor-watchman.sample
│   │   ├── post-update.sample
│   │   ├── pre-applypatch.sample
│   │   ├── pre-commit.sample
│   │   ├── pre-merge-commit.sample
│   │   ├── prepare-commit-msg.sample
│   │   ├── pre-push.sample
│   │   ├── pre-rebase.sample
│   │   ├── pre-receive.sample
│   │   ├── push-to-checkout.sample
│   │   └── update.sample
│   ├── index
│   ├── info
│   │   └── exclude
│   ├── logs
│   │   ├── HEAD
│   │   └── refs
│   │       ├── heads
│   │       │   └── main
│   │       └── remotes
│   │           └── origin
│   │               └── HEAD
│   ├── objects
│   │   ├── info
│   │   └── pack
│   │       ├── pack-36fd71097bdf2cd3e8cd1f8ff1e50cd5a889d0f6.idx
│   │       └── pack-36fd71097bdf2cd3e8cd1f8ff1e50cd5a889d0f6.pack
│   ├── packed-refs
│   └── refs
│       ├── heads
│       │   └── main
│       ├── remotes
│       │   └── origin
│       │       └── HEAD
│       └── tags
├── .gitignore
├── GUIDE.md
├── logs
│   └── .placeholder
├── README.md
├── TASK.md
├── TODO.txt
└── vagrant
    ├── shared_folder_control_plane
    │   └── .placeholder
    ├── shared_folder_worker
    │   └── .placeholder
    └── Vagrantfile

```</pre>


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




#########################
# More requirements
ansible, sshpass


ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook main.yaml -i ../inventory/hosts.ini


fix that .kube/conf does not show up for the regular user (as the ssh is a root)

another problem is that join command txt file is empty, why it does not rewrite it