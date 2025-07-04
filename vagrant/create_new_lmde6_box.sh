#!/usr/bin/env bash
##################### Start Safe Header ########################
#Developed by Alex Umansky aka TheBlueDrara
#Porpuse to config a new VirtualBox VM to be exported to a .box file for Vagrant
#Date 4.7.25
set -o errexit
set -o nounset
set -o pipefail
#################### End Safe Header ###########################


# Must run as root or sudo to work!
if [[ $EUID -ne 0 ]]; then
    echo "Please run this script with sudo or as root user."
    exit 1
fi

sudo apt-get update
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo useradd -m vagrant
echo "vagrant:vagrant" | sudo chpasswd
echo "vagrant ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/vagrant
mkdir -p /home/vagrant/.ssh
curl -fsSL https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod 600 /home/vagrant/.ssh/authorized_keys

