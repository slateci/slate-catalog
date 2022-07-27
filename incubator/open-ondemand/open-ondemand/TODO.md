# Overview

Open OnDemand is a single-access point for operating remote computing resources. It allows a user to log in easily using their organization credentials without the need to connect to a virtual private network or opening traffic to untrusted networks.

The portal enables a user to establish secure shell access, remote desktop access using TurboVNC, and use GUI-enabled interactive applications all through the comfort of their web browser. This makes for a much more intuitive general user experience and encourages new programmers to get comfortable using a command-line-interface, without the irritation or confusion that often accompanies many users first experience with remote access and programming in general.

This document will clarify some of the future additions to the Open OnDemand application for SLATE and some of the less understood components of the existing application.

If you have not already done so it may be prudent to read over the SLATE Open OnDemand blog posts for [deploying OnDemand](https://slateci.io/blog/slate-open-ondemand.html) and [enabling Remote Desktop](https://slateci.io/blog/slate-open-ondemand-desktop.html).

The official Open OnDemand docs can be found [here](https://openondemand.org/), and any additional questions you have can be answered on the OSC discussion board [here](https://discourse.osc.edu/c/open-ondemand/5).

## TO-DO

At the time of writing this, the SLATE application for Open OnDemand supports a Shell application, a Filesystem browsing application, and a Remote Desktop application. In the future it will be necessary to add other interactive apps to the OnDemand container.

Currently the most requested applications are Jupyter Notebook and MATLAB, which can be added as interactive apps to the OnDemand container and any desired backend compute nodes.

For OnDemand version 2.0, `Jupyter Notebook 4.2.3+` requiring `OpenSSL 1.0.1+` can be installed following [this documentation](https://osc.github.io/ood-documentation/latest/app-development/tutorials-interactive-apps/add-jupyter.html?highlight=jupyter). To configure all interactive applications `LMOD 6.0.1+` is required for module operation.

MATLAB will require `OpenJDK runtime` and `VirtualGL 2.5+` and can be installed following [this documentation](https://osc.github.io/ood-documentation/latest/app-development/tutorials-interactive-apps/add-matlab.html). 

All newly added Open OnDemand applications will require their own app directory under `/var/www/ood/apps/sys/<app>` containing the application files and executables. Additional configuration will be required in the `submit.yml.erb` file for job submission, which is stored in the `ood-desktop-app-cfg.yaml` file in the OOD Helm chart.

**IMPORTANT**: Open OnDemand for SLATE is currently a complete service and can be deployed on any SLATE cluster that meets the necessary criteria. It is important to note, though, that it will take time to set up and requires elevated permissions to configure backend resources. Before offering Open OnDemand as a service, ensure that there will be sufficient time to set it up and that there are no approaching deadlines that may require a functioning OnDemand server.

**University of Utah**: Before the commencement of the Fall 2021 semester at the University of Utah, some administrators were contacted about setting Open OnDemand up for the Physics department. Before deploying the application, it was requested that Jupyter Notebook and MATLAB be added to the helm chart, and that any instantiation of Open OnDemand must occur well in advance of the first day of classes. Please feel free to reach out to the Physics department or any other departments whom you think the application may prove useful.

## LinuxHost Adapter

First it may be necessary to discuss the so-called LinuxHost Adapter, as termed by the administrators at OSC, the creators of Open OnDemand.

The LinuxHost Adapter is a custom resource manager, designed by the team at OSC. It enables all the necessary functions of a typical resource manager (ie Torque, Slurm, LSF), without the added complexity and configuration.

While Open OnDemand does support many of these resource managers, for the SLATE application it was decided to use the LinuxHost Adapter instead, as its simple and light-weight design is ideal for a containerized environment.

It is essentially a collection of different processes and protocols that all work in tandem to achieve behavior similar to that of other job schedulers (AKA resource managers). These processes are run on backend compute resources, **not** on the server running Open OnDemand.

The LinuxHost Adapter is comprised of:

- NoVNC: an open source VNC client that allows for websocket remote VNC connection, includes the following apps
  - TurboVNC (2.1+)
    - A Virtual Network Computing software, designed with speed and efficiency in mind
  - Websockify (0.8.0+)
    - A proxy for websocket traffic, translating websocket traffic to normal traffic
    - Forwards to the client and target in both directions
- Singularity
  - A containerization software for managing and organizing user processes
  - Provides isolation  between user processes and the host system, de-escalates privileges on backend resources, and allows for pick-and-choose filesystem mounting
  - Essentially works like a namespace for interactive app sessions
- SSHD
  - Maintains a connection between the OnDemand web node to backend resources
- Tmux
  - Offers persistence for running jobs
- Timeout
  - Sets a time until a process is killed
- Pstree
  - Used to detect a jobs parent `sinit` so that it can be killed when necessary
- nmap-ncat
  - A general purpose CLI tool for reading, writing, and encrypting data across a network
- Desktop application
  - A desktop application of the users choice
    - mate 1+
    - xfce 4+
    - gnome 2 

## Container Design Choices

In order to adapt Open OnDemand to Kubernetes and the containerized environment, some necessary design choices were made.

### Host-Based Authentication

`HostBasedAuthentication` is an uncommonly used feature of the SSH Daemon, enabling host-level trust between specified domains/IP addresses.

It allows for all users of a trusted host IP or domain to have passwordless SSH to the host running SSHD with `HostBasedAuthenticaiton` enabled. This does open up certain vulnerabilities, but when properly managed it's not much of a concern.

For example, if an unprivileged user who is not supposed to have access to a node that has established host-level trust, they can still SSH in if an identical user exists on both systems. This can be remedied by simply deleting the user on the secure system, and then host-level trust will not apply to that user, or simply denying them access.

If an intruder gains access to the system, then if their user exists on both hosts, and they know the domain or IP of each trusted host, they would have passwordless SSH access between them.

This is assuming, however, that the security of one host has already been compromised, so its not so much of a concern if security is already tight on both hosts.

But to prevent this some precautions may be taken, for example denying all users or groups except those specified in the `sshd_config` file should ensure that only trusted users will have access between hosts.

For Open OnDemand, `HostBasedAuthentication` ensures that all users that exist in the Keycloak database (populated by the LDAP configuration provided by the server admin) can use the `Interactive Apps` functionality in the web-portal.

Without `HostBasedAuthentication`, then all users must have an SSH key-pair stored on each host enabling passwordless SSH on a user-by-user basis. A very time-consuming option to do manually, and also an inefficient way to automate host-level trust.

### Filesystem Distribution

In order for the LinuxHost Adapter to work, it needs to be able to share files between hosts. When the Open OnDemand portal initializes an interactive app, it generates an interactive session directory with scripts, logging information, and configuration files. If these files cannot be accessed by the backend compute node, then the application will not work.

To distribute files, NFS protocol was configured so that home directories are persistent between hosts. By mounting `/home` on remote, the compute nodes have an identical home directory to the one stored on the OnDemand node. In addition, the default path for session data is `/home/user/ondemand`, so session data is stored automatically.

Since NFS protocol is less efficient and can waste resources, `autofs` is the optional and preferred configuration.

### SSSD

SSSD is used in the Open OnDemand container to ensure that users are added to the system with all relevant information.

Initially this was avoided as to reduce complexity, and not use two methods of authentication (Keycloak and SSSD). To add users to the OnDemand filesystem their information was first collected from the Keycloak database using an HTTP request, then their information was stored in a file in `/etc/passwd` format on the Keycloak container. A script running in the OnDemand container would wait until it sees this file in a `/shared` directory, then it would run a `newusers foo.txt` command which would add these users to the OnDemand system.

This placated the OnDemand system into allowing users to log in with their credentials, and even use the Shell application. However, when any of the Interactive apps were used, such as the Remote Desktop app, the users did not match those on the backend compute nodes. This is because Keycloak does not store information on user IDs and group IDs in its database.

So SSSD was installed in the OnDemand container, which uses the LDAP configuration info in the `values.yaml` file to populate its userbase. This ensures continuity between front and backend users.

## Helm Chart Information

This section will provide extra background information on files stored in the Helm chart, in order to better explain their function.

### deployment.yaml

The deployment has a great deal of configmaps and volumes attached to it, and the two containers for OnDemand and Keycloak.

The volumes are all labeled with their corresponding files. Most are self explanatory, and further detail can be gleaned from reading the other configuration files. But there is a comment that states

``` yaml
##### Start of Advanced Features #####
```

This marks the point of optional configuration.

Looking below at line #126, you can once again see this comment in the `VolumeMounts` section just above a selection control statement saying

```go
{{ if eq .Values.enableHostAdapter true}}
```

This is an option set to `true` or `false` in the values.yaml file, essentially allowing users to select whether they want to configure interactive apps and remote desktop, or not.

### ingress.yaml

This file defines the ingress object that will assign domain names to both containers and expose them on ports `80` and `8080` respectively. To ensure that this resource works properly, the SLATE cluster must have an ingress-controller and cert-manager installed, so that each host can automatically have a valid certificate assigned to it.

### keycloak-pvc.yaml

A persistent volume claim assigned to store Keycloak's h2 database.

### keycloak-setup-cfg.yaml

A configmap to set up Keycloak. Creates a Keycloak realm for OnDemand data, configures LDAP user-storage, and generates test users.

### ood-autofs-cfg.yaml

Creates an automount file and enables autofs.

### ood-desktop-app-cfg.yaml

Generates and replaces files necessary for remote desktop app and other interactive apps. Contains several files which are mounted separately, but all relate to the LinuxHost Adapter and interactive apps.

### ood-linuxhost-adapter-cfg.yaml

The configmap for generating cluster configuration files and configuring the LinuxHost Adapter.

### ood-nfs-pv.yaml/ood-nfs-pvc.yaml

A persistent volume and volume claim for using NFS mounts directly from the host. Disabled if using autofs instead.

### ood-sssd-cfg.ymal

SSSD configuration file.

### ood-startup-cfg.yaml

Necessary post-startup commands, bug fixes, and optional configuration.

### service.yaml

NodePort service for exposing container ports to TCP traffic.

## Images

Open OnDemand uses a custom image built for SLATE to build containers, while Keycloak uses the official Keycloak container maintained by jboss.

Open OnDemand uses the RedHat software collections apache with its own nested filesystem, which in this case is always stored in the `/opt/rh/httpd` folder in the container. It also uses software collection versions of ruby and nodejs to support its applications.

**IMPORTANT**: It is important to note that when running executables for OnDemand apps or components, that you may get an error when not first enabling software collections and then running an executable. To do this, you can always run

```bash
scl enable ondemand [COMMAND]
```

This will ensure that all software collections are enabled before running a command.

### startup-apache.sh

This file stored in the SLATE OnDemand image configures the software collections apache to expose the OnDemand server on its domain and enable OIDC (Open ID Connect) authentication to Keycloak. If the webpage is inaccessible, it is possible that the file at `/opt/rh/httpd24/root/etc/httpd/conf.d/auth_openidc.conf` is misconfigured.