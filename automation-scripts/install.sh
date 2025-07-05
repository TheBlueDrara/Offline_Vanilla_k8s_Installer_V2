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
NULL=/dev/null
MANIFESTS_PATH=/etc/kubernetes/manifests
BIN=/home/$USER/Offline_Vanilla_k8s_Installer/binaries
#REAL_USER=${SUDO_USER:-$(logname)}
#REAL_HOME=$(eval echo "~$REAL_USER")


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
    #Check of k8s is installed or what kind of node is this
    Check_node

}

#Check if k8s is installed
function Check_node(){

    if ! command -v kubeadm &>$NULL && ! command -v kubelet &>$NULL; then
        echo "k8s is not installed, Preparing to install k8s and init a control plane..."
        Install_k8s
    else
        if ! systemctl is-active --quiet kubelet &>$NULL; then
            Install_k8s
        else
            if ! [[ -f "$MANIFESTS_PATH/kube-apiserver.yaml" || -f "$MANIFESTS_PATH/kube-scheduler.yaml" || -f "$MANIFESTS_PATH/kube-controller-manager.yaml" ]]; then
                echo "This Node is a worker node, Preparing to update..."
                Update_node
            else
                echo "This is a Control Plane node, exiting..."
                return 1
            fi
        fi
    fi
}




function Install_k8s(){
    

    if ! command -v sudo &>$NULL; then
        tar -xzf $BIN/sudo_bin_and_dependencies.tar.gz .

}





function Update_node(){}