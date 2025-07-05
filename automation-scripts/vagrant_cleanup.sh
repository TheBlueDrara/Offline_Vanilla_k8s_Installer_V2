#!/usr/bin/env bash
##################### Start Safe Header ########################
#Developed by Alex Umansky aka TheBlueDrara
#Porpuse to cleanup vagrant vms for next POCs and rerun vagrant
#Date 5.7.25
set -o errexit
set -o nounset
set -o pipefail
#################### End Safe Header ###########################

function main(){
    if [[ $EUID -ne 0 ]]; then
        log WARNING "Please run this script with sudo or as root user."
        exit 1
    fi

    #Check if runing debian distro
    if [[ $ID_LIKE == "debian" ]]; then
        log INFO "Running on Debian-family distro. Executing main code..."
        sleep 1
    else
        log WARNING "This script is designed to run only on Debian-family distro only!"
        exit 1
    fi

    cleanup_rerun
}

    function cleanup_rerun(){
    cd /srv/vagrant
    rm -rf .vagrant
    sudo virsh destroy vagrant_control_plane 2>/dev/null
    sudo virsh undefine vagrant_control_plane --nvram 2>/dev/null
    sudo virsh destroy vagrant_worker 2>/dev/null
    sudo virsh undefine vagrant_worker --nvram 2>/dev/null
    sudo virsh vol-delete --pool default vagrant_control_plane.img 2>/dev/null
    sudo virsh vol-delete --pool default vagrant_worker.img 2>/dev/null
    sudo find /var/lib/libvirt/images/ -name 'vagrant_*.img' -exec rm -f {} \;
    sudo systemctl restart libvirtd

    sleep 2

    vagrant up --provider=libvirt

    sleep 2

    vagrant ssh-config
}