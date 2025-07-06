# Offline Vanilla Kubernetes Installer

## Overview

Dear user, here you will find an offline vanilla Kubernetes installer, wrapped using Makeself.
You will also find a CI Jenkins pipeline to syntax-check the committed code into your GitHub repository,
and a Vagrantfile to help you set up the environment.

## Features

- Wrapping script that creates your Makeself offline Kubernetes installer.
- CI pipeline that syntax-checks and builds a new updated installer upon success.
- Vagrantfile you can use to quickly provision 2 VMs for the control plane and worker nodes.
- Modular installer: if run on an empty machine, it will create a control plane node; if a worker node already exists, it will update it.

## Prerequisites

- Vagrant, Libvirt plugin, and KVM provider installed
- Logged in as root user
- Debian-based distribution
- Makeself installed

## Dev Notes

### How-To Guide

You can follow this [Guide](GUIDE.md) to set everything up.

### Tool Versions

- Calico v3.27.2
- Kubernetes v1.30.14

### Task

You can find the full task [here](TASK.md).

### Contributors

You can find the project contributors [here](CONTRIBUTORS.md).

### Project Tree

_(To be completed)_

### My To-Do

Each time I stumble across a new project that I'm unfamiliar with, I create a To-Do list.
I try to break the big project into small main pieces.

I start by doing everything manually and document the process along the way.
This helps me come to the coding part more prepared and saves me time.

You can find my To-Do list [here](TODO.md). It's unrefined and honest at the moment thinking.

You can find my script code flow [here](FLOW.md)

### Daily Warhammer 40K Quote
```
I have slept for centuries...
But now I have awoken, and I remember everything.
I remember the heretics.
I remember the traitors.
And I remember...
vengeance.

— Unknown Venerable Dreadnought
```