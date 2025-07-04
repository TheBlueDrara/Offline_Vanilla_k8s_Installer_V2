# SDS Inject

As a DevOps team, we have cases that require single file deployment tools to be created for automation.
As such, in order to avoid production issues, we create CI to test what we are building, running and packaging.

Our task, is to create _single run file_ that will setup the kubernetes cluster, master node and worker node.
while creating the automation, we would like to use CI/CD as method of verifying our scripts and IaaC while building _single run file_ installer.
You may use any tools of your choosing.
Yet, at the end of the build the only thing that should work would be the single installer file, that has all the binaries, dependencies and configuration that will let the kubernetes cluster go up.
In addition to _additional tools_ that will be helpful to deploy application to k8s. __(kubectl, kustomize, helm)__



### Tasks simplified

- Create github/gitlab project to store scripts, configs and IaaC files
- Setup storage to save binaries for kubernetes and additional tools (__kubectl, kustomize, helm__)
- Create a script that will automate the install of the kubernetes binaries
    - In modern days of devops, scripts need to be __self-healing__ and outputs/errors need to be provided to user as well as kept in log folder.
        - __Self-healing__ is a vague term for script to try to fix its outcome, even if desired state was not achieved, or will quit with error output and suggestion to fix it. 
    - Script also needs to be modular, by enabling to install k8s master and worker nodes separately and together in cases that they were triggered to so.
    - Use any log format that you are accustomed to
- Couple the script and the binaries using self running archive tools, for example [`makeself`](https://makeself.io)
- Create CI pipeline, who's only task is to validate that script is running and it can handle errors and mis-configurations
    - If pipeline is successful, it should package the script and binaries and save it in storage.
    - If pipeline fails, devops team (your team ) should be notified
- Create CD pipeline who's task is to connect to dedicated machine and deploy the installer
    - In case the there is kubernetes installed, you need to check whether it is _master node_ or _worker node_.
     __only if the node is worker node__ it should reinstall a newer version of kubernetes on __worker node__
    - In case kubernetes is __not__ installed, it should only install the master node and notify that only master was installed


### Suggested folder structure

> Note: this is just example, structure as you know, learned or was able to understand.

```sh
/sds-inject-project/
├── automation-scripts/      # Core modular install scripts    
│   └── install-script
├── binaries/                # Kubernetes + additional tool binaries
├── cd/                      # CD deployment scripts
├── ci/                      # CI pipeline files (e.g., GitHub Actions, GitLab CI) 
├── configs/                 # YAML/config templates for K8s or tools
├── logs/                    # Auto-generated log files
├── build-script             # Wrapper to build the single-file installer
└── README.md                # Readme file that will summarize what was required and how you achieved it as well as 
```

> Notes:
    - You've got __ hours to provide repository where the installer, code for script and release of installers are kept.
    - Please try not to overly use any AI Agent/platform.
        - This task is designed to test your ability to learn, adapt, and implement — not just copy/paste from prompt.
        - There will be an additional discussion where you will be required to explain what you have done.
    - You should to consider using the CI of your choice: Jenkins, GitLab-CI, Github-Action
    - Storage can be anything, folder, service, vm, container or platform .
    - Dependencies need to be considered before creating the script.


