

My Work Flow

install helm: 
    - place the helm_bin => /usr/local/bin/helm
    - to check if installed run: helm help
install kubectl:
    - sudo install -o root -g root -m 0755 <path to kubectl> /usr/local/bin/kubectl
    - to check if instaleld run: "kubectl version --client"
install kustomize:
    - sudo mv kustomize /usr/local/bin/
    - to check if installed run: kustomize version
install k8s vanilla:

- i need this requiremnts for all nodes : containerd iptables sudo
- i also need to install kubelet and kubeadm


for to install k8s dependancies:
    - run: "sudo dpkg -i <path to deb packages>"
    - used rdepends utlity to download locally the needed tools and thier dependencies

install containerd:
for the binary part: 
    tar -xvzf containerd_bin.tar.gz
    chmod +x containerd/install.sh
    bash containerd/install.sh

for the config part:
    overwrite the config file run: "echo configs/containerd_config_files/containerd_config.tomal > /etc/containerd/config.toml"
    dont forget to restart service run : "systemctl restart containerd.service"
    check if service is runnign run: "systemcrl status containerd.service"

install and config iptables (linux fire_wall)
for the binary part: 
    - first check if iptables is already installed run: "iptables --version"
    - if not use the bin files and install iptables
for the config part:
    - Must be done as root user!
    place the config file at: "mv configs/iptables_config_files/network.conf /etc/sysctl.d/99-k8s-cri.conf"
    apply the change run: "sysctl --system"

install sudo:
    - first check if sudo is already installed run: "dpkg -l | grep sudo"
    - if not use the bin files and install sudo

install kubelet:
    tar -xvzf kublet_bin.tar.gz
    chmod +x kubelet/install.sh
    bash kubelet/install.sh

    - Check if installed, run: "kubelet --version"

install kubeadm:
    tar -xvzf kubeadm_bin.tar.gz
    sudo dpkg -i kubeadm_1.30.14-1.1_amd64.deb

    - Check if installed, run: "kubeadm version"

# Note, at this point i understand that i dont need to install more tools, as they are need for online deployment of k8s, and i have an offline one.



