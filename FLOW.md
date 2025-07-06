# Script flow

Run the script with 2 parameters, control plane and worker node ip address

Run main function
    Check if installer is ran as a logged in root user, if no, exit 
    Check if OS is Debian based, if no, exit
    Check if docker is installed, if yes, exit
    Check if recived parameters, if not, exit 
    validate the ip address, if failed, exit

    Run Check_node function
        Check if kubeadm and kubelet are installed, if not, depending on the parameter, will init or join node by running install_k8s function

        install_k8s
            Run install_dependencies - Installs minor packages
            Run install_iptables - Installs and configures iptables
            Run install_containerd - Installs and configures containerd
            Run kernel_modules - Loads kernel modules
            Run install_kube - Installs kubectl, kubeadm and kubelet
            Run disable_swap - Disables swap files

            Depending on what ip address was passed,
                Run init_control_plane 
                    Run install_calico
            
                Run join_worker_node
            Run check_node
    
    If they are installed, Check presence of manifest files,
    If unpresent,
        Check if kubelet is active
            If not, Run join_worker
            If yes, Run update_node
    If present,
        Run install_optional_tools

























