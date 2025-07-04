1)
 - Download locally to the storage all the needed dependancies for all the needed tools (k8s vanilla, kubectl, kustomize, helm)
 - Create a script for the installer, the script should do the following:
    - Check if the machine has k8s installed if not install k8s master
    - if is installed, check if master or slave node, if master do nothing, if slave update the slave
    - have the option to install on the same machine both slave master node via a parameter pass 
  - Create a script that wrappers the binaries and script with Makeself tool 

2)
 - Create a Jenkings CI pipeline that will check the syntax of the script
    - if syntax is ok, run the wrapping script and build a new updated installer, save it in storage for later use

3)
  - Create a CD pipeline that will connect to a machine and run the installer