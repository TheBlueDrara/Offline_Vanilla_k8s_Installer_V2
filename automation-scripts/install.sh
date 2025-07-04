

My Work Flow
#Install only on Master Node
install helm: 
    - place the helm_bin => /usr/local/bin/helm
    - to check if installed run: helm help

install kustomize:
    - sudo mv kustomize /usr/local/bin/
    - to check if installed run: kustomize version

# Do this steps on each node no matter if control plane or worker node
install k8s vanilla:

- i need this requiremnts for all nodes : containerd iptables sudo kubelet kubectl kubeadm

for to install k8s dependancies:
    - used rdepends utlity to download locally the needed tools and thier dependencies

#Importent note, this is the order of installetion of tools! keep it that way!

install sudo:
    - first check if sudo is already installed run: "dpkg -l | grep sudo"
    - if not use the bin files and install sudo

install containerd:
for the binary part: 
    tar -xvzf containerd_bin.tar.gz
    chmod +x containerd/install.sh
    bash containerd/install.sh

for the config part:
    overwrite the config file run: "echo configs/containerd_config_files/containerd_config.tomal > /etc/containerd/config.toml"
    dont forget to restart service run : "systemctl restart containerd.service"
    check if service is runnign run: "systemcrl status containerd.service"

Load required kernel modules
    #Requires containderd runtime!
    #Requires to run as root user!
    modprobe overlay; modprobe br_netfilter
    echo -e overlay\\nbr_netfilter > /etc/modules-load.d/k8s.conf

install and config iptables (linux fire_wall)
for the binary part: 
    - first check if iptables is already installed run: "iptables --version"
    - if not use the bin files and install iptables
for the config part #sysctl.d config:
    - Must be done as root user!
    place the config file at: "mv configs/iptables_config_files/network.conf /etc/sysctl.d/99-k8s-cri.conf"
    apply the change run: "sysctl --system"

install kubelet:
    tar -xvzf kublet_bin.tar.gz
    chmod +x kubelet/install.sh
    bash kubelet/install.sh

    - Check if installed, run: "kubelet --version"

install kubeadm:
    tar -xvzf kubeadm_bin.tar.gz
    sudo dpkg -i kubeadm_1.30.14-1.1_amd64.deb

    - Check if installed, run: "kubeadm version"

install kubectl:
    - sudo install -o root -g root -m 0755 <path_to_kubectl_bin_file> /usr/local/bin/kubectl
    - to check if instaleld run: "kubectl version --client"

Change to iptables config to legacy:
    - First check if the legacy binary exists, and if yes run this to change config
    legacy="/usr/sbin/iptables-legacy"
    current=$(readlink -f /etc/alternatives/iptables)

   # if [ "$current" != "$legacy" ] && [ -e "$legacy" ]; then
   # sudo update-alternatives --set iptables "$legacy"
   # fi

disable swap:
    sudo swapoff -a
    - Check if worked, run: "sudo swapon --show"
    Comment out the swap in fstab file, run: "sudo sed -i.bak '/\sswap\s/s/^/#/' /etc/fstab"

Create CNI soft link:
    run: "sudo ln -s /opt/cni/bin /usr/lib/cni"


