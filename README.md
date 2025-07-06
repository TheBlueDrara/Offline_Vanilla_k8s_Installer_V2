# Offline vanilla k8s installer

## Overview




currently its still work in progress, to join the worker node, need to manualy change variable WORKER_ENABLED=1, and copy the join_command.txt to the worker node



to run:
loog in as root user
run the installer with two parameters -m "MASTER IP" -w "WORKER IP"



verisons:
calico v3.27.2
k8s v1.30.14






prerequsits:
- LMDE6 AMD64 OS
- sudo privlages
- ran as root user

