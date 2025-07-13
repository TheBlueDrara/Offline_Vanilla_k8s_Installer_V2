# How to Use Guide

### Please Follow Along

Start by creating the Makeself installer:

```bash
cd build-script
chmod +x makeself.sh
./makeself.sh
```

![Demo](images/makeself.gif)

Then, create your Vagrant VMs:

```bash
cd vagrant
vagrant up --provider=libvirt
```

![Demo](images/vagrant.gif)

Finally, run the Ansible main playbook:

```bash
cd cd/playbooks/
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook main.yaml -i ../inventory/hosts.ini
```

![Demo](images/ansible.gif)

You can connect to the machines using **vagrant** as the username and password.

On the control plane node, run the following to check if nodes were created:

```bash
kubectl get nodes
kubectl get pods -A
```

![Demo](images/kube.gif)

And you're done!

---

### Notes

- You can remove `ANSIBLE_HOST_KEY_CHECKING=False` if you use SSH keys, or add it to your `.bashrc` to make it permanent.
- To add more worker nodes:
  - Edit the Vagrantfile and add more VMs.
  - Edit the `hosts.ini` file and include the new VMs' IP addresses.

---

## If Install is ran without Ansbile

You can run the installer as a standalone without the deployment process
But you will need to take in mind a few things 

1) Run the installer as loged in as root user
2) Run the installer with the correct parameters -
  - "-r" or "--role" "control_panel" or "worker"
  - If ran as control panel, add "-m" or "--master" "<IP_Address_Of_Master_Node>"
  - If ran as worker, just the role is enough
3) join_command.txt, by default this file is empty, it is genertaed while initing a control plane node, if you will run \
the installer only on worker nodes, you will have to provide this file manually.
  - The file must be in this path - /tmp
  - The file must start like this - "JOIN_COMMAND=<The_Join_Command_It_Self>"

### Examples

Place the installer in /tmp

```bash
mv ./k8s_installer.run /tmp
```

Run the installer to create a control node

```bash
sudo -i
cd /tmp
chmod +x ./k8s_installer.run
./k8s_installer.run --role control_panel --master 192.168.10.10
```

The join_command.txt will be generted in this directory.

If you already have a control panel, and only need the join command

```bash
echo $(kubeadm token create --print-join-command) > /tmp/join_command.txt

```

Now on the second VM you want to create a worker and join it to the cluster

Place the join command file in /tmp

```bash
mv join_command.txt /tmp
```

Run the installer

```bash
sudo -i
cd /tmp
chmod +x ./k8s_installer.run
./k8s_installer.run --role worker
```

And thats it.

Check if everything is working

```bash
kubectl get nodes
kubectl get pods -A
```