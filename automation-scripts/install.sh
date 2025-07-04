

My Work Flow

# Start with Checks
# Make sure Docker is not installed!
# This Part will be before installetion, to check what does exist currently on the machine!

Check if k8s is installed:
    - Check if the main 2 k8s tools are installed,run: "command -v kubeadm >/dev/null && command -v kubelet >/dev/null"
    #kubectl does not have to be installed on a worker node, so we must check the main two tools, kubeadm and kubelet
    -If yes continue to the next check
    -If not, Run the installetion to install only the control plane node and inform the user
    Check if kublet is running as a service, run: "systemctl is-active --quiet kubelet"
        #If the service is dead, k8s is not running
        -If not, Run the installetion to install only the control plane node and inform the user
        -If yes, check what kind of node is that, if control plane node, do nothing, if workder node, update the node

    # The Installetion process must start with this checks, and only than run the install process.
Check what kind of node is that:
    - Check this path for manifests files that exit only on control plane nodes, run: "/etc/kubernetes/manifests/" 
    - This files: kube-apiserver.yaml , kube-scheduler.yaml , kube-controller-manager.yaml
        -If this files are missing, its a worker node and needs an update.
        -If this files are present, do nothing

Update the worker node:
    # Requirement, before updating the worker node, update the control panel node
    # Or, check what version is the control panel node, and compare it to the worker node
    - Prevent scheduling new pods, run: "kubectl cordon <node-name>"
    # Optional - kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
    - install the new version,run: "sudo dpkg -i kubeadm_<new-version>_amd64.deb"
    - Confirm the new version, run: "kubeadm version"
    - Upgrade kubeadm, run: "sudo kubeadm upgrade node"
    - Upgrade kubelet, run: "sudo dpkg -i kubelet_<new-version>_amd64.deb"
    - Check if kubectl exist on node, if not do nothing, if yes update it, run: "sudo dpkg -i kubectl_<new-version>_amd64.deb"
    - Restart the services, run: "sudo systemctl daemon-reexec" , "sudo systemctl restart kubelet"
    - Return back to scheduling new pods, run: "kubectl uncordon <node-name>"


# Do this steps on each node no matter if control plane or worker node
# Start of Installetion
# Importent note, this is the order of installetion of tools! keep it that way!
# I need this requiremnts for all nodes : containerd iptables sudo kubelet kubectl kubeadm
# I used rdepends utlity to download locally the needed tools and thier dependencies

install k8s vanilla:

for to install k8s dependancies:

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

#Install only on Master Node
install helm: 
    - place the helm_bin => /usr/local/bin/helm
    - to check if installed run: helm help

install kustomize:
    - sudo mv kustomize /usr/local/bin/
    - to check if installed run: kustomize version

# End of Installetion



# init control plane
Import local control panel images, run:
    #for tar in binaries/control_panel_images/*; do
    #  echo "Importing $tar"
    #  sudo ctr -n k8s.io images import "$tar"
    #done


sudo kubeadm init \
--kubernetes-version=v1.30.14 \
--control-plane-endpoint=<IPaddress_of_VM> \
--pod-network-cidr=192.168.0.0/16 \
--cri-socket=unix:///run/containerd/containerd.sock \
--v=5

-if it fails, before exit, clean up, run:
    "sudo kubeadm reset -f; sudo rm -rf /etc/kubernetes/ ; sudo rm -rf /var/lib/etcd ; sudo rm -rf /etc/cni/net.d/ ; sudo rm -rf $HOME/.kube/config"

-If a succsseful init:
    Set cluster admin user config, run:
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

Install Calico:
# Images were too heavy, so i split them up, and on remote machine, re snip them back togther
    cat binaries/calico_images/calico-node.tar.part-* > binaries/calico_images/calico-node.tar
    cat binaries/calico_images/calico-cni.tar.part-* > binaries/calico_images/calico-cni.tar
    rm -rf *part-*
    sudo ctr -n k8s.io images import calico-node.tar
    sudo ctr -n k8s.io images import calico-controllers.tar
    sudo ctr -n k8s.io images import calico-cni.tar

Make sure Node is READY, run: "kubectl get nodes"
Make sure all pods are running, run: "kubectl get pods -A"

#DONE, Node is up!


# Another hard part, the script needs to connect to the machines and run the installer
# Now connect to another vm, and run the installer again, but this time, after the connect to a vm, if the vm is a control panel node and k8s is not installed, install the node and join it.
Connect to another VM:
