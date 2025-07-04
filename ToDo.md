1)
 - Figure out and Download locally to the storage all the needed dependancies for all the needed tools
 - Create a script to install the tools

2)
 - Create a Build script that will build a new installer

3)
 - Create a jenkings file (CI) that will syntax check the bash script, and if it fails it should notify the DevOps team and if success than package the scripts and binaries and save at the storage (wrap the installer?)

 4)
  - choose a CD, or ansible and create a playbook to copy and run installer, or a pipe line that will ssh to a machine and copy the files and run them
  - Part of CD is to check if k8s is installed and if it is, if its a worker node, update a new node, and if not k8s so install only master node
  - or study a different CD


  need to go trhew classes :
  k8s install
  jenkings CI and makeself build
  Think about a way to deploy the installer
