## How to Use

### Please Note: This is a work in progress; currently, some of the steps are manual.

This guide is divided into two parts. The first is slightly manual but will help you build a full cluster with a working control plane (master) and worker node. If you only want to create a control plane node, you can use the Installer path.

### The Full Cluster Path

Start by creating your Vagrant VMs:

```
cd vagrant
vagrant up --provider=libvirt
vagrant ssh-config
```

Connect via SSH to both VMs: one is the control plane, and the second is a worker.

```
ssh vagrant@192.168.56.11
ssh vagrant@192.168.56.12
```
### The password? You guessed it-it's "vagrant"!!

Copy the necessary files to the VM shared folders:

```
cp -r binaries/ configs/ automation-scripts/ vagrant/shared_folder_control_panel
cp -r binaries/ configs/ automation-scripts/ vagrant/shared_folder_worker
```

Copy everything in both VMs to the workspace:

```
cp -r shared_folder_<Node Name>/* .
```

Inside the control plane VM, run the script as the root user.
The script must receive two IP addresses: `-m` for master, `-w` for worker (in this order only).

```
sudo -i
bash /home/vagrant/automation-scripts/install.sh -m 192.168.56.11 -w 192.168.56.12
```

Check if the control plane is active:

```
kubectl get nodes
kubectl get pods -A
```

Copy the join command from the control plane VM:

```
cat /home/vagrant/config/join_command.txt
```

Now edit two things inside the worker VM:

```
# Change this variable:
vim automation-scripts/install.sh
Line 27: ENABLE_WORKER=1

# Paste the join command here:
vim /home/vagrant/config/join_command.txt
```

Now run the script:

```
sudo -i
bash /home/vagrant/automation-scripts/install.sh -m 192.168.56.11 -w 192.168.56.12
```

Now check on the control plane VM if the worker node joined:

```
kubectl get nodes
```

And you're done!


### Only the Control Plane Node via Installer

Create the Makeself installer:

```
cd build-script
bash makeself.sh
```

Copy the installer to your node. If you're using Vagrant, you can follow the steps in the previous path.

On your machine, run the installer:

```
chmod +x ./k8s_installer.run
./k8s_installer.run -- -m 192.168.56.11 -w 192.168.56.12
```

And you're done!