#!/usr/bin/env bash
##################### Start Safe Header ########################
#Developed by Alex Umansky aka TheBlueDrara
#Porpuse to install k8s vanilla localy in offline, init a control_plane,
#and join the second vm, deploy, config a worker node and join to the cluster
#Date 4.7.25
set -o errexit
set -o nounset
set -o pipefail
#################### End Safe Header ###########################
. /etc/os-release
# This makes the pathing work and does not depend on root or user pathings, as the root directory will be walys depending on where the script was ran
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NULL=/dev/null
BIN_PATH=$PROJECT_ROOT/binaries
CONFIG_PATH=$PROJECT_ROOT/congifs
MANIFESTS_PATH=/etc/kubernetes/manifests
REAL_USER=${SUDO_USER:-$(logname)}
REAL_HOME=$(eval echo "~$REAL_USER")
NODE_NAME=$(hostname)
CONTROL_PANEL_IP_ADDRESS=0.0.0.0
WORKER_IP_ADDRESS=0.0.0.0

function main(){

    #Check if ran as root user
    if [[ $EUID -ne 0 ]]; then
        echo "Please run this script with sudo"
        exit 1
    fi

    #Check if OS is Debain based distro
    if [[ $ID_LIKE == "debian" ]]; then
        echo "Running on Debian-family distro. Executing main code..."
    else
        echo "This script is designed to run only on Debian-family distro only!"
        exit 1
    fi
    #Check if Docker is installed
    if command -v docker &>$NULL; then
        echo "Docker is installed, Please remove Docker and rerun the installer"
        exit 1
    fi

    while [[ $# != 0 ]] ; do
        case $1 in
            -m|--master)
                read -p "Enter Control Plane (master) IP address: " CONTROL_PANEL_IP_ADDRESS
                if ! validate_ip "$CONTROL_PANEL_IP_ADDRESS"; then
                    echo "Exiting due to invalid master IP."
                    exit 1
                fi
                ;;
            -w|--worker)
                read -p "Enter Worker node IP address: " WORKER_IP_ADDRESS
                if ! validate_ip "$WORKER_IP_ADDRESS"; then
                    echo "Exiting due to invalid worker IP."
                    exit 1
                fi
                ;;
        esac
    done

    check_node
    #connect_vm

}

# Checks if given ip address are valid
validate_ip() {

    local ip=$1
    if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if ((octet < 0 || octet > 255)); then
                echo " Invalid IP: $ip"
                exit 1
            fi
        done
        return 0
    else
        echo "Invalid IP format: $ip"
        exit 1
    fi
}

#Check if k8s is installed
function check_node(){

    if ! command -v kubeadm &>$NULL && ! command -v kubelet &>$NULL; then
        echo "k8s is not installed, Preparing to install k8s and init a control plane..."
        install_k8s
    else
        if ! systemctl is-active --quiet kubelet &>$NULL; then
            install_k8s
        else
            if ! [[ -f "$MANIFESTS_PATH/kube-apiserver.yaml" || -f "$MANIFESTS_PATH/kube-scheduler.yaml" || -f "$MANIFESTS_PATH/kube-controller-manager.yaml" ]]; then
                echo "This Node is a worker node, Preparing to update..."
                if update_node; then
                    echo "Update was successful"
                    return 0
                else
                    echo "Update failed, Please contact dev team"
                    exit 1
                fi
            else
                install_optional_tools
                echo "This is a Control Plane node"
                return 0
            fi
        fi
    fi
}

# Start the k8s install process
function install_k8s(){

    install_dependencies
    install_iptables
    install_containerd
    kernal_modules
    install_kube
    disable_swap
    install_calico
    init_control_plane
    check_node
}

# Install different dependencies (may add in future if something is missing)
function install_dependencies(){

    if ! command -v sudo &>$NULL; then
        tar -xzf $BIN_PATH/sudo/*.tar.gz
        if ! dpkg -i install *.deb &>$NULL; then
            echo "Something went wrong with sudo installetion, Contact the dev team"
            return 1
        fi
    fi
}

# Install iptables linux fire wall, and config the kernal network parameters
function install_iptables(){

    if ! iptables --version &>$NULL; then
        tar -xzf $BIN_PATH/iptables/*.tar.gz
        if ! dpkg -i install *.deb &>$NULL; then
            echo "Something went wrong with iptables installetion, Contact the dev team"
            exit 1
        fi
    fi

    mv $CONFIG_PATH/iptables_conf/network.conf /etc/sysctl.d/99-k8s-cri.conf

    if ! sysctl --system &>$NULL; then
        echo "Something went wrong with applying new kernel parameter settings in /etc/sysctl.d/99-k8s-cri.conf"
    fi

    local legacy="/usr/sbin/iptables-legacy"
    if [ "$current" != "$legacy" ] && [ -e "$legacy" ]; then
        sudo update-alternatives --set iptables "$legacy"
    else
        echo "Failed to chnage iptables to legacy mode, Please contact dev team"
    fi
}

# Install docker runtime, aka containderd, and rewrite the conf file
function install_containerd(){

    if ! command -v containerd &>$NULL; then
        tar -xzf $BIN_PATH/containerd/*.tar.gz
        if ! dpkg -i install *.deb &>$NULL; then
            echo "Something went wrong with containerd installetion, Contact the dev team"
            return 1
        fi
    fi

    echo $CONFIG_PATH/containerd_conf/config.toml > /etc/containerd/config.toml
    systemctl restart containerd.service
    sleep 1

    if ! systemctl is-active --quiet containerd &>$NULL; then
        echo "Containderd did not start proporly, Please contact the dev team."
        exit 1
    fi
}

# Loads kernal modules
function kernal_modules(){

    modprobe overlay 
    modprobe br_netfilter

    if ! lsmod | grep overlay && lsmod | grep br_netfilter; then
        echo "Kernal modules did not load proporly, Please contact the dev team"
    fi

    echo -e overlay\\nbr_netfilter > /etc/modules-load.d/k8s.conf
}

# Install kubectl, kubeadm and kubelet
function install_kube(){

    if ! kubelet --version; then
        echo "Kubelet is not installed, preparing to install now..."
        tar -xzf $BIN_PATH/kube/kublet_bin.tar.gz
        if ! dpkg -i install kubelet/*.deb &>$NULL; then
            echo "There was a problem installing kubelet, Please contact dev team"
        fi
    else
        echo "kubelet already present"
    fi

    if ! kubeadm version; then
        echo "Kubeadm is not installed, preparing to install now..."
        tar -xzf $BIN_PATH/kube/kubadm_bin.tar.gz
        if ! dpkg -i install kubeadm/*.deb &>$NULL; then
            echo "There was a problem installing kubeadm, Please contact dev team"
        fi
    else
        echo "kubeadm already present"
    fi

    if ! kubectl version --client; then
        echo "Kubectl is not installed, preparing to install now..."
        tar -xzf $BIN_PATH/kube/kubectl_bin.tar.gz
        install -o root -g root -m 0755 $BIN_PATH/kube/kubectl /usr/local/bin/kubectl
    else
        echo "kubectl already present"
    fi
}

# Disable Swap files
function disable_swap(){

    swapoff -a
    sed -i.bak '/\sswap\s/s/^/#/' /etc/fstab
    if ! swapon --summary; then
        echo "Swap is disabled at runtime."
    else
        echo "Failed to disable swap, Please contact dev team"
        exit 1
    fi
}

# Install and configure calico
function install_calico(){

    if ! kubectl get daemonset calico-node -n kube-system -o jsonpath='{.status.numberReady}' || /
    [[ kubectl get daemonset calico-node -n kube-system -o jsonpath='{.status.numberReady}' -eq 0 ]]; then
        echo "Calico is not installed or having issuies, preparing to install..." 
        ln -s /opt/cni/bin /usr/lib/cni

        cat $BIN_PATH/binaries/calico_images/calico-node.tar.part-* > binaries/calico_images/calico-node.tar
        cat $BIN_PATH/binaries/calico_images/calico-cni.tar.part-* > binaries/calico_images/calico-cni.tar
        rm -rf $BIN_PATH/binaries/calico_images/*part-*

        for image in $BIN_PATH/calico_images/*; do
            ctr -n k8s.io images import $image

        if ! kubectl apply -f $CONFIG_PATH/configs/calico_conf/calico.yaml; then
            echo "There was a problem installing calico, Please contact dev team"
            exit 1
        fi
    else
        echo "Calico is present and running"
    fi
}

# Install optional tools like helm and kustomize on control plane only 
function install_optional_tools(){

    if ! helm help; then
        tar -xzf $BIN_PATH/optional_tools/helm_bin.tar.gz
        mv $BIN_PATH/optional_tools/helm /usr/local/bin/helm
        if ! helm help; then
            echo "There was a problem installing helm, Please contact dev team"
        fi
    else
        echo "Helm is already present"
    fi

    if ! kustomize version; then
        tar -xzf $BIN_PATH/optional_tools/kustomize_bin.tar.gz
        mv $BIN_PATH/optional_tools/kustomize /usr/local/bin/kustomize
        if ! kustomize version; then
            echo "There was a problem installing kustomize, Please contact dev team"
        fi
    else
        echo "kustomize is already present"
    fi
}

# Init the node a control plane
function init_control_plane(){

    for image in $BIN_PATH/control_panel_images/*; do
        sudo ctr -n k8s.io images import "$image"
    done


    if ! kubeadm init \
        --kubernetes-version=v1.30.14 \
        --control-plane-endpoint=$CONTROL_PANEL_IP_ADDRESS \
        --pod-network-cidr=192.168.0.0/16 \
        --cri-socket=unix:///run/containerd/containerd.sock \
        --v=5; then

        echo "Control Plane init failed, starting clean up, Please contant your dev team"
        kubeadm reset -f \
        rm -rf /etc/kubernetes/ \
        rm -rf /var/lib/etcd \
        rm -rf /etc/cni/net.d/ \
        rm $REAL_HOME/.kube/config
        exit 1

    else
        echo "Control Plane init was succsesful"
        mkdir -p $REAL_HOME/.kube
        ln -s /etc/kubernetes/admin.conf $REAL_HOME/.kube/config
        chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.kube/config"
        sleep 1

        echo "The setup for a Control Plane node has finished, Please wait a few mintues so the setup can take place \
        if you notice that it takes too long, Please contact the dev team \
        Please run this command - 'kubectl get pods -A' to check if all neccery pods are up \
        Please run this command - 'kubectl get nodes' to see if Node is READY"
        sleep 3
        exit 1
    fi
}

# Update the existing node
function update_node(){

    if ! kubectl cordon "$NODE_NAME"; then
        echo "Failed to cordon node, Please contact dev team"
    else
        tar -xzf $BIN_PATH/kube/kubeadm_bin.tar.gz
        if ! dpkg -i "$BIN_PATH/kube/kubeadm/*.deb"; then
            echo "Failed it install new kubeadm packages, Please contact dev team"
            return 1
        else
            echo "Installed new kubeadm version: $(kubeadm version), Prepering to update node..."
        fi
    fi

    if ! kubeadm upgrade node; then
        return 0
    fi

    tar -xzf $BIN_PATH/kube/kubelet_bin.tar.gz
    if ! dpkg -i "$BIN_PATH/kube/kubelet/*.deb"
        echo "Failed to install new version of kubelet, Please contact dev team"
        return 1
    fi

    if command -v kubectl &>$NULL; then
        tar -xzf $BIN_PATH/kube/kubectl_bin.tar.gz -C /usr/local/bin/
        chmod +x /usr/local/bin/kubectl
        echo "Kubectl was updated to: $(kubectl version --client --short)"
    else
        echo "Kubectl not found on this node. Skipping kubectl upgrade"
    fi

    if ! systemctl daemon-reexec; then
        echo "Deamon-reexec failed to restart, Please contact dev team"
        return 1
    fi

    if ! systemctl restart kubelet; then
        echo "Kubelet failed to restart, Please contact dev team"
        return 1
    fi

    if ! systemctl is-active --quiet kubelet &>$NULL; then
        echo "Kubelet failed to activate after upgrade, Please contact dev team"
        return 1
    else
        kubectl uncordon "$NODE_NAME"
        return 0
    fi
}

main "$@"