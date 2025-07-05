# Script flow

run the installer with 2 parameters: control plane and worker node ip

run main function
    check if installer is ran as a logged in root user, if no, exit #ADD MORE VALIDATION FOR ROOT
    check if os is Debian based, if no, exit
    check if docker is installed, if yes, exit
    use case to accept parameters
    validate the ip address, if failed, exit
    check if recived parameters, if not, exit # ADD CHECK

    run the Check_node function
    run the Connect_vm function after setting up a control panel node

run Check_node
    if kubeadm and kubelet are not present => run Install_k8s function, that will run install process and will install control panel node \
    and loopback to Check_node, and if everything is ok and its a master node it will exit the function \
    and run the Connect_vm function + it will create a join command for the worker node and the process will run again \
    on the second vm, it will check again for dependencies, install what is needed, but now it will join the worker node \
    and not init a control panel

        if tools are present => check what kind of node is that
            if control panel node, and the kubelet is inactive, exit and call dev team
            if control panel node, and the kubelet is active, install optional tools and run connect_vm function

            if worker node, and the kubelet in inactive run the join_node function
                if the join was successful, run update_node function
                    if update_node was successful exit
                    if update_node was not successful exit
                if join was not successful exit
            if worker node, and the kubelet is active, run the update_node function
                if it is successful exit
                if it is not successful exit
            

            if kubelet is not active => run Install_k8s function, that will run install process and will install control panel node, and loopback to Check_node, and if everything is ok and its a master node it will exit the function and run the Connect_vm function
            if kubelet is running => Check what kind of node is that
                if control plane node => run Install_optional_tools function, exit function at the end and run the Connect_vm function
                if worker node => run Update_node function and run Connect_vm function to connect to the next machine


# There is a loop, that always chekcs the environment, and will install a control panel node if k8s is not present in the beginning \
# and if it is present, check what kind of node, if master node, and everything works, hop to the next machine \
# if worker node, update the worker node and hop to the next machine



























