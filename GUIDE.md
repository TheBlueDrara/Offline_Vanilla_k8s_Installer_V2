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