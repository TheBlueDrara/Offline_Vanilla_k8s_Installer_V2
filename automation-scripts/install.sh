set -x
#!/usr/bin/env bash
##################### Start Safe Header ########################
# Developed by Alex Umansky aka TheBlueDrara
# Purpose: Install k8s vanilla locally in offline mode, initialize a control plane,
# and join a second VM as a worker node to the cluster
# Date: 4.7.25
set -o errexit
set -o nounset
set -o pipefail
#################### End Safe Header ###########################

. /etc/os-release

# This makes the pathing work and does not depend on root or user paths,
# as the root directory will always depend on where the script was run
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
NULL=/dev/null
BIN_PATH=$PROJECT_ROOT/binaries
CONFIG_PATH=$PROJECT_ROOT/configs
MANIFESTS_PATH=/etc/kubernetes/manifests
REAL_USER=${SUDO_USER:-$(logname)}
REAL_HOME=$(eval echo "~$REAL_USER")
NODE_NAME=$(hostname)
CONTROL_PANEL_IP_ADDRESS=0.0.0.0
WORKER_IP_ADDRESS=0.0.0.0
. $CONFIG_PATH/join_command.txt
ENABLE_WORKER=0

function main() {
    # Check if ran as root user
    if [[ $EUID -ne 0 ]]; then
        echo "Please run this script with sudo"
        exit 1
    fi

    # Check if OS is Debian-based
    if [[ $ID == "debian" ]]; then
        echo "Running on Debian-family distro. Executing main code..."
    else
        echo "This script is designed to run only on Debian-family distros!"
        exit 1
    fi

    # Check if Docker is installed
    if command -v docker &>$NULL; then
        echo "Docker is installed. Please remove Docker and rerun the installer."
        exit 1
    fi

    # Make sure both -m and -w parameters are provided
    if [[ $# -lt 2 ]]; then
        echo "You must provide both -m (master) and -w (worker) parameters"
        exit 1
    fi
    #Catch parameters from user running installetion
    while [[ $# != 0 ]]; do
        case $1 in
            -m|--master)
                CONTROL_PANEL_IP_ADDRESS="$2"
                if ! validate_ip "$CONTROL_PANEL_IP_ADDRESS"; then
                    echo "Exiting due to invalid master IP."
                    exit 1
                fi
                shift 2
                ;;
            -w|--worker)
                WORKER_IP_ADDRESS="$2"
                if ! validate_ip "$WORKER_IP_ADDRESS"; then
                    echo "Exiting due to invalid worker IP."
                    exit 1
                fi
                shift 2
                ;;
        esac
    done

    check_node
    #connect_vm
}

function validate_ip() {
    local ip=$1
    if [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        IFS='.' read -r -a octets <<< "$ip"
        for octet in "${octets[@]}"; do
            if ((octet < 0 || octet > 255)); then
                echo "Invalid IP: $ip"
                exit 1
            fi
        done
        return 0
    else
        echo "Invalid IP format: $ip"
        exit 1
    fi
}
# Checking what kind of node and if k8s is installed
function check_node() {
    if ! command -v kubeadm &> "$NULL" && ! command -v kubelet &> "$NULL" && [[ $ENABLE_WORKER -eq 0 ]]; then
        echo "K8s is not installed. Preparing to install and initialize control plane..."
        install_k8s "$CONTROL_PANEL_IP_ADDRESS"

    elif ! command -v kubeadm &> "$NULL" && ! command -v kubelet &> "$NULL" && [[ $ENABLE_WORKER -eq 1 ]]; then
        echo "K8s is not installed. Preparing to install and join to cluster a worker node..."
        install_k8s "$WORKER_IP_ADDRESS"

    else  # If first run failed at the end and the kube binaries present, but manifest files are missing as it never inited
        if ! [[ -f "$MANIFESTS_PATH/kube-apiserver.yaml" || -f "$MANIFESTS_PATH/kube-scheduler.yaml" || -f "$MANIFESTS_PATH/kube-controller-manager.yaml" ]]; then
            echo "This Node is a worker node"
            if ! command -v kubeadm &> "$NULL" && ! command -v kubelet &> "$NULL"; then
                echo "K8s is not installed. Preparing to install and join worker node..."
                install_k8s "$WORKER_IP_ADDRESS"
            fi
            if ! systemctl is-active --quiet kubelet &> "$NULL"; then
                if ! join_worker_node "$WORKER_IP_ADDRESS"; then
                    exit 1
                fi
                if update_node; then
                    echo "Update was successful"
                    exit 0
                else
                    echo "Update failed. Please contact the dev team."
                    exit 1
                fi
            else
                if update_node; then
                    echo "Update was successful"
                    exit 0
                else
                    echo "Update failed. Please contact the dev team."
                    exit 1
                fi
            fi

        else
            echo "This is a Control Plane node"
            if ! systemctl is-active --quiet kubelet &> "$NULL"; then
                echo "The kubelet service on the master node is inactive. Please contact the dev team."
                exit 1
            fi 
            install_optional_tools
            return 0
        fi
    fi
}
# The installetion process
function install_k8s() {
    local ip=$1
    install_dependencies
    install_iptables
    install_containerd
    kernel_modules
    install_kube
    disable_swap
    
    if [[ "$ip" == "$CONTROL_PANEL_IP_ADDRESS" ]]; then
        init_control_plane "$ip"
    else
        join_worker_node "$ip"
    fi

    install_calico
    check_node
}
# Install different dependencies, may scale for future use
function install_dependencies() {
    if ! command -v sudo &>$NULL; then
        tar -xzf $BIN_PATH/sudo/*.tar.gz -C $BIN_PATH/sudo/
        if ! dpkg -i $BIN_PATH/sudo/*.deb &>$NULL; then
            echo "Something went wrong with sudo installation. Contact the dev team."
            exit 1
        fi
    fi
}
# Install and config iptables
function install_iptables() {
    if ! iptables --version &>$NULL; then
        tar -xzvf $BIN_PATH/iptables/*.tar.gz -C $BIN_PATH/iptables/
        if ! dpkg -i $BIN_PATH/iptables/*.deb &>$NULL; then
            echo "Something went wrong with iptables installation. Contact the dev team."
            exit 1
        fi
    fi

    cp $CONFIG_PATH/iptables_conf/network.conf /etc/sysctl.d/99-k8s-cri.conf

    if ! sysctl --system &>$NULL; then
        echo "Error applying kernel parameters from /etc/sysctl.d/99-k8s-cri.conf"
    fi

    local legacy="/usr/sbin/iptables-legacy"
    local current=$(which iptables)
    if [ "$current" != "$legacy" ] && [ -e "$legacy" ]; then
        sudo update-alternatives --set iptables "$legacy"
    else
        echo "Failed to change iptables to legacy mode. Please contact the dev team."
    fi
}
# Install and config docker run time aka containerd
function install_containerd() {
    if ! command -v containerd &>$NULL; then
        tar -xzf $BIN_PATH/containerd/*.tar.gz -C $BIN_PATH/containerd/
        if ! dpkg -i $BIN_PATH/containerd/*.deb &>$NULL; then
            echo "Something went wrong with containerd installation. Contact the dev team."
            return 1
        fi
    fi

    cp $CONFIG_PATH/containerd_conf/config.toml /etc/containerd/config.toml
    systemctl restart containerd.service
    sleep 1

    if ! systemctl is-active --quiet containerd &>$NULL; then
        echo "containerd did not start properly. Please contact the dev team."
        exit 1
    fi
}
# Load kernal modules
function kernel_modules() {
    modprobe overlay 
    modprobe br_netfilter

    if ! lsmod | grep overlay || ! lsmod | grep br_netfilter; then
        echo "Kernel modules did not load properly. Please contact the dev team."
    fi

    echo -e "overlay\nbr_netfilter" > /etc/modules-load.d/k8s.conf
}
# Install kubectl, kubeadm and kubelet
function install_kube() {
    if ! kubelet --version &>$NULL; then
        echo "Installing kubelet..."
        tar -xzf $BIN_PATH/kube/kubelet_bin.tar.gz -C $BIN_PATH/kube/
        systemctl daemon-reload
        if ! dpkg -i $BIN_PATH/kube/kubelet/*.deb &>$NULL; then
            echo "Failed to install kubelet. Please contact the dev team."
        fi
    fi

    if ! kubeadm version &>$NULL; then
        echo "Installing kubeadm..."
        tar -xzf $BIN_PATH/kube/kubeadm_bin.tar.gz -C $BIN_PATH/kube/
        if ! dpkg -i $BIN_PATH/kube/kubeadm/*.deb &>$NULL; then
            echo "Failed to install kubeadm. Please contact the dev team."
        fi
    fi

    if ! kubectl version --client &>$NULL; then
        echo "Installing kubectl..."
        tar -xzf $BIN_PATH/kube/kubectl_bin.tar.gz -C $BIN_PATH/kube/
        install -o root -g root -m 0755 $BIN_PATH/kube/kubectl /usr/local/bin/kubectl
    fi
}
# Disable swap
function disable_swap() {
    swapoff -a
    sed -i.bak '/\sswap\s/s/^/#/' /etc/fstab
    if swapon --summary | grep -q '^'; then
        echo "Failed to disable swap. Please contact the dev team."
        exit 1
    fi
}
# Install and config calico
function install_calico() {
    if ! kubectl get daemonset calico-node -n kube-system -o jsonpath='{.status.numberReady}' &> $NULL || \
       [[ $(kubectl get daemonset calico-node -n kube-system -o jsonpath='{.status.numberReady}') -eq 0 ]]; then
        echo "Installing Calico..."
        ln -s /opt/cni/bin /usr/lib/cni

        cat $BIN_PATH/calico_images/calico-node.tar.part-* > $BIN_PATH/calico_images/calico-node.tar
        cat $BIN_PATH/calico_images/calico-cni.tar.part-* > $BIN_PATH/calico_images/calico-cni.tar
        rm -f $BIN_PATH/calico_images/*part-*

        for image in $BIN_PATH/calico_images/*; do
            ctr -n k8s.io images import "$image"
        done

        if ! kubectl apply -f $CONFIG_PATH/calico_conf/calico.yaml; then
            echo "Failed to apply Calico YAML. Please contact the dev team."
            exit 1
        fi
    else
        echo "Calico is already installed and running."
    fi
}
# Install optional tools only on control panel node
function install_optional_tools() {
    if ! helm help &>$NULL; then
        tar -xzf $BIN_PATH/optional_tools/helm_bin.tar.gz -C $BIN_PATH/optional_tools/
        mv $BIN_PATH/optional_tools/helm /usr/local/bin/helm
    fi

    if ! kustomize version &>$NULL; then
        tar -xzf $BIN_PATH/optional_tools/kustomize_bin.tar.gz -C $BIN_PATH/optional_tools/
        mv $BIN_PATH/optional_tools/kustomize /usr/local/bin/kustomize
    fi
}
# Init control panel
function init_control_plane() {
    for image in $BIN_PATH/control_panel_images/*; do
        sudo ctr -n k8s.io images import "$image"
    done

    local master_ip=$1
    if ! kubeadm init \
        --kubernetes-version=v1.30.14 \
        --control-plane-endpoint=$master_ip \
        --pod-network-cidr=192.168.0.0/16 \
        --cri-socket=unix:///run/containerd/containerd.sock \
        --v=5; then

        echo "Control Plane init failed. Starting cleanup..."
        kubeadm reset -f
        rm -rf /etc/kubernetes/ /var/lib/etcd /etc/cni/net.d/
        rm -f $REAL_HOME/.kube/config
        exit 1
    else
        echo "Control Plane init was successful"
        mkdir -p $REAL_HOME/.kube
        ln -s /etc/kubernetes/admin.conf $REAL_HOME/.kube/config
        chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.kube/config"

        join_command=$(kubeadm token create --print-join-command)
        echo "$join_command" > $CONFIG_PATH/join_command.txt

        echo "Control Plane setup completed. Run 'kubectl get pods -A' and 'kubectl get nodes' after a few minutes."
        sleep 20
        return 0
    fi
}
# Update an existing node
function update_node() {
    if ! kubectl cordon "$NODE_NAME"; then
        echo "Failed to cordon node. Please contact the dev team."
        return 1
    fi

    tar -xzf $BIN_PATH/kube/kubeadm_bin.tar.gz -C $BIN_PATH/kube/
    if ! dpkg -i $BIN_PATH/kube/kubeadm/*.deb; then
        echo "Failed to install new kubeadm. Please contact the dev team."
        return 1
    fi

    if ! kubeadm upgrade node; then
        return 1
    fi

    tar -xzf $BIN_PATH/kube/kubelet_bin.tar.gz -C $BIN_PATH/kube/
    if ! dpkg -i $BIN_PATH/kube/kubelet/*.deb; then
        echo "Failed to install new kubelet. Please contact the dev team."
        return 1
    fi

    if command -v kubectl &>$NULL; then
        tar -xzf $BIN_PATH/kube/kubectl_bin.tar.gz -C /usr/local/bin/
        chmod +x /usr/local/bin/kubectl
    fi

    systemctl daemon-reexec
    systemctl restart kubelet
    systemctl daemon-reload

    if ! systemctl is-active --quiet kubelet &>$NULL; then
        echo "Kubelet failed to activate after upgrade. Please contact the dev team."
        return 1
    else
        kubectl uncordon "$NODE_NAME"
        return 0
    fi
}
# Join a worker node to the cluster
function join_worker_node() {
    echo "Running join command: $join_command"
    if ! $join_command; then
        exit 1
    else
        return 0
    fi
}

#function connect_vm(){}
# connect to the second machine, pass the ip address to the installer, run and install k8s and config a worker node
# after connection to a vagrant machine run sudo -i to login as root before the install
# in the function, rewrite the $ENABLE_WORKER to =1, to signal that this time if k8s is not installed, run installetion and join a worker node
main "$@"
set +x