

# small note, check if this trhee tools need any kind of dependancies

install helm: 
    - place the helm_bin => /usr/local/bin/helm
    - to check if installed run: helm help
install kubectl:
    - sudo install -o root -g root -m 0755 <path to kubectl> /usr/local/bin/kubectl
    - to check if instaleld run: "kubectl version --client"
install kustomize:
    - sudo mv kustomize /usr/local/bin/
    - to check if installed run: kustomize version
install k8s vanilla:

- i need this requiremnts for all nodes : containerd iptables apt-transport-https gnupg2 curl sudo
- i also need to install kubelet and kubeadm

 install containerd:
for the binary part: 
    tar -xvzf containerd.tar.gz
    chmod +x containerd/install.sh
    bash containerd/install.sh

for the config part:
    overwrite the config file run: "echo configs/containerd_config_files/containerd_config.tomal > /etc/containerd/config.toml"
    dont forget to restart service : "systemctl restart containerd.service"
    check if service is runnign run: systemcrl status containerd.service"