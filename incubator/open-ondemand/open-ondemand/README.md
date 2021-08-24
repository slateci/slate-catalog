
# Using SLATE to deploy Open OnDemand

[Open OnDemand](https://openondemand.org/) is a web application enabling easy access to high-performance computing resources.
Open OnDemand, through a plugin system, provides many different ways to interact with these resources.
Most simply, OnDemand can launch a shell to remote resources in one's web browser.
Currently, SLATE only supports this functionality, but more applications are
in development.
Additionally, OnDemand can provide several ways of submitting batch jobs and launching interactive computing sessions.
It is also able to serve as a portal to computationally expensive software running on remote HPC nodes.
For example, users can launch remote Jupyter Notebooks or Matlab instances.

The SLATE platform provides a simple way to rapidly deploy this application in
a containerized environment, complete with integration into an existing LDAP user directory.


<!--end_excerpt-->


## Prerequisites

This tutorial requires that you can install a basic OnDemand instance using SLATE as described [here](https://slateci.io/blog/slate-open-ondemand.html).

It is assumed that you already have access to a SLATE-registered Kubernetes
cluster, and that you have installed and configured the SLATE command
line interface.  If not, instructions can be found at 
[SLATE Quickstart](https://slateci.io/docs/quickstart/).  

The remote desktop application requires that autofs can be implemented
on the cluster you are installing on.
The official linux man pages provide more information [here](https://linux.die.net/man/5/autofs).

On backend resources, it is required you can install NFS/autofs, enable hostbased authentication, and can connect
to an organizational LDAP. 
More information about hostbased authentication can be found [here](https://arc.liv.ac.uk/SGE/howto/hostbased-ssh.html).

## Configuration

Initially, a configuration file for the Open OnDemand application must be
obtained. The SLATE client will do this with the following command:
```bash
slate app get-conf open-ondemand > ood.yaml
```

This will save a local copy of the OnDemand configuration, formatted as a
.yaml file. We will modify this configuration accordingly, and eventually
deploy Open OnDemand with this configuration.

With your preferred text editor, open this configuration file and follow the
instructions below.


### Cluster_Definitions

To set up remote desktop access, we must configure the `LinuxHost Adapter`. 
This is a simplified resource manager built from various component softwares. 
By enabling resource management, you can configure interactive apps and 
manage sessions remotely.

To do this set `enableHostAdapter` to true and fill in each cluster definition
file. If you're not sure what a field should be, leave it as default for now. Most
failures in connecting to backend resources are due to errors with these definition
files.

After creating an entry for each backend resource you'd like to connect to,
ensure that the `host_regex` field below captures all of the provided hostnames.

```yaml
  - cluster:
      name: "Node1"
      host: "node1.example.net"
      enableHostAdapter: true
      job:
        ssh_hosts: "node1.example.net"
        site_timeout: 14400
        singularity_bin: /bin/singularity
        singularity_bindpath: /etc,/media,/mnt,/opt,/run,/srv,/usr,/var,/home
        singularity_image: /opt/centos7.sif  # Something like centos_7.6.sif
        tmux_bin: /usr/bin/tmux
      basic_script: 
        - '#!/bin/bash'
        - 'set -x'
        - 'export XDG_RUNTIME_DIR=$(mktemp -d)'
        - '%s'
      vnc_script: 
        - '#!/bin/bash'
        - 'set -x'
        - 'export PATH="/opt/TurboVNC/bin:$PATH"'
        - 'export WEBSOCKIFY_CMD="/usr/bin/websockify"'
        - 'export XDG_RUNTIME_DIR=$(mktemp -d)'
        - '%s'
      set_host: "$(hostname)"
  - cluster:
      name: "Node2"
      ...
```

```yaml
host_regex: '[\w.-]+\.(node1|node2|example.net|example.edu)'
```

### Advanced

Here you must once again set `enableHostAdapter` equal to `true` and fill in the following entries.
To find the groupID of your ssh_keys group, simply run `cat /etc/group | grep ssh_keys`.

```yaml
enableHostAdapter: true           # Enable linuxHost Adapter
advanced:
  desktop: "mate"                 # Desktop of your choice (mate, xfce, or gnome)
  node_selector_label: "ood"      # Matching node_selector_label (See next step)
  ssh_keys_GID: 993               # ssh_keys groupID
```

### NodeSelector

The chart must be installed on a properly configured node. On a multi-node
cluster it is necessary to set a `nodeSelectorLabel` called 'application' on a desired 
node. Then match that label in the `values.yaml` file. If all nodes are properly configured
then you may leave this field blank.

```bash
kubectl label nodes <node-name> application=ood
```

### Secret_Generation

Pods are ephermeral, so keys from the host system should be passed 
into the container using a secret. This will ensure trust is not broken
when pods are replaced. This script will generate a secret containing host 
keys on the OnDemand server.

```sh
#!/bin/bash
echo -n "Please enter a name for your secret: "
read secretName
if [ "$secretName" != "" ]; then
  :
else
  echo "Please enter a non-empty secret name"
  exit
fi
command="kubectl create secret generic $secretName"
for i in /etc/ssh/ssh_host_*; do
  command=`echo "$command --from-file=$i"`
done
printf "$command\n"
$command ; echo ""
```

In the slate configuration file, ensure that the `secret_name` field and `host_key` 
names match the secret you generate. 

If you're not sure what your host_key names are, list the contents of `/etc/ssh`.

```yaml
# Provide names for each host key stored in your secret
  secret_name: "ssh-key-secret"
  host_keys:
    - host_key:
        name: "ssh_host_ecdsa_key"
    - host_key:
        name: "ssh_host_ecdsa_key.pub"
    - ...
```

**Security Precautions**

To secure your secrets when not in use or in the event of intrusion, 
you can install a secret management provider such as 
[Vault](https://www.vaultproject.io/docs/platform/k8s/helm) or 
[CyberArk](https://docs.cyberark.com/Product-Doc/OnlineHelp/AAM-DAP/11.2/en/Content/Integrations/Kubernetes_deployApplicationsConjur-k8s-Secrets.htm).

### Filesystem_Distribution

Resource management for OnDemand also requires a distributed filesystem. This chart
currently supports autofs.

```yaml
# Filesystem distribution
  autofs: true
  fileSharing:
    nfs_shares:
      - 'slate1   -rw   slate.example.net:/export/mdist/slate1'
      - 'slate2   -rw   slate.example.net:/export/mdist/slate2'
      - '...'
```

## Backend Configuration

Now that Open OnDemand is ready to be deployed using `slate app install`, we should access each
of our backend clusters and ensure that they are ready to establish a connection.

### Resource_Management

To enable resource management, you must install components of the 
`LinuxHost Adapter` on each backend cluster. 

These include 
[TurboVNC 2.1+](https://www.turbovnc.org/), [Singularity](https://sylabs.io/),
[nmap-ncat](https://nmap.org/ncat), 
[Websockify 0.8.0+](https://pypi.org/project/websockify/#description),
a [singularity image](https://sylabs.io/guides/3.5/user-guide/quick_start.html#download-pre-built-images),
and a desktop 
([mate 1+](https://mate-desktop.org/), [xfce 4+](https://www.xfce.org/), 
[gnome 2](https://www.gnome.org/)).

To get a basic centOS 7 image run the following command, and ensure it has the same
path as the `singularity_image` field in Cluster Definitions [above](###Cluster_Definitions).

```bash
singularity pull docker://centos:7
```

To establish a remote desktop connection, ports 5800(+n) 5900(+n) and 6000(+n)
need to be open for each display number n. As well as, port 22 for ssh
and ports 20000+ for websocket connections. 

To do this easily, add a global rule to iptables or a firewalld exception.

```bash
sudo iptables -A INPUT -s xxx.xxx.xxx.xxx/32 -j ACCEPT
sudo firewall-cmd --zone=trusted --add-source=xxx.xxx.xxx.xxx/32
```

### Filesystem_Distribution

Filesystem Distribution must also be configured on the backend clusters, so that user data
is persistent between the OnDemand server and backend resources.

**autofs**

To configure autofs install `nfs-utils` and `autofs`. Then configure the `auto.master` file to
mount NFS shares from an `auto.map` file. This map file should have consistent shares and mount points
with entries in the slate app configuration described [above](###Filesystem_Distribution). When everything is set up, run `systemctl enable nfs autofs` to ensure they always run at system startup.

```bash
slate1   -rw   slate.example.net:/export/mdist/slate1
slate2   -rw   slate.example.net:/export/mdist/slate2
...
```

### Authentication

The LinuxHost Adapter requires passwordless SSH for all users, which is most easily
configured by establishing host-level trust (hostBasedAuthentication). 

To do this, run the `ssh-keyscan` command below using the public IP address of the 
OnDemand host. This will automatically populate an `ssh_known_hosts` file with public
host keys.

For more detailed information, see the links in [Prerequisites](##Prerequisites).

```bash
ssh-keyscan [ONDEMAND_HOST_PUBLIC_IP] >> /etc/ssh/ssh_known_hosts
```

Next, add an entry to `/etc/ssh/shosts.equiv` with the IP address of the
OnDemand server like so

```bash
node1.example.net
node2.example.net
...
```

And in the `/etc/ssh/sshd_config` file, change the following entries from

```bash
#HostbasedAuthentication no
#IgnoreRhosts yes
```
to
```bash
HostbasedAuthentication yes
IgnoreRhosts no
```

Finally, ensure that you have the correct permissions for host keys at `/etc/ssh`

```bash
-rw-r-----.   1 root ssh_keys      227 Jan 1 2000      ssh_host_ecdsa_key
-rw-r--r--.   1 root root          162 Jan 1 2000      ssh_host_ecdsa_key.pub
-rw-r-----.   1 root ssh_keys      387 Jan 1 2000      ssh_host_ed25519_key
-rw-r--r--.   1 root root           82 Jan 1 2000      ssh_host_ed25519_key.pub
-rw-r-----.   1 root ssh_keys     1675 Jan 1 2000      ssh_host_rsa_key
-rw-r--r--.   1 root root          382 Jan 1 2000      ssh_host_rsa_key.pub
```

And for ssh-keysign at `/usr/libexec/openssh` &nbsp;&nbsp;&nbsp; 
Note: location varies with distro

```bash
---x--s--x.  1 root ssh_keys      5760 Jan 1 2000      ssh-keysign
```

## Installation

To install the application using slate, run this app install command:

```bash
slate app install open-ondemand --group <group_name> --cluster <cluster_name> --conf /path/to/ood.yaml
```

## Testing

After a short while, your SLATE OnDemand application should be live at
`<slate_instance_tag>.ondemand.<slate_cluster_name>.slateci.net`.
Note that `<slate_instance_tag>` is the `instance` parameter specified in the `values.yaml` file,
not the randomly-assigned SLATE instance ID.

Navigate to this URL with any web browser, and you will be directed to a
Keycloak login page. A successful login will then direct you to the Open OnDemand portal home page.
Navigating to the shell access menu within the portal should allow you to launch in-browser shells to the previously specified backend compute resources.

**Test User Setup**

This Open OnDemand chart supports the creation of temporary test users, for
validating application functionality without the complexity of connecting to
external LDAP and Kerberos servers. To add a test user(s), navigate to the
`testUsers` section of the configuration file. Add the following yaml to this
section for each user you would like to add:
```yaml
- user:
    name: <username_here>
    group: <test_group>
    groupID: <1000+n>
    tempPassword: <temporary_password_here>
```

## Configurable_Parameters:

The following table lists the configurable parameters of the Open OnDemand application and their default values.

|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`Instance`| String to differentiate SLATE experiment instances. |`global`|
|`replicaCount`| The number of replicas to create. |`1`|
|`volume.storageClass`| The volume provisioner from which to request the Keycloak backing volume. |`local-path`|
|`volume.size`| The amount of storage to request for the volume. |`50M`|
|`setupLDAP`| Set up LDAP automatically based on following values. |`true`|
|`ldap.connectionURL`| URL to access LDAP at. |`ldap://your-ldap-here`|
|`ldap.importUsers`| Import LDAP users to Keycloak. |`true`|
|`ldap.rdnLDAPAttribute`| LDAP configuration. |`uid`|
|`ldap.uuidLDAPAttribute`| LDAP configuration. |`uidNumber`|
|`ldap.userObjectClasses`| LDAP configuration. |`inetOrgPerson, organizationalPerson`|
|`ldap.ldapSearchBase`| LDAP configuration. |`dc=chpc,dc=utah,dc=edu`|
|`ldap.usersDN`| LDAP configuration. |`ou=People,dc=chpc,dc=utah,dc=edu`|
|`kerberos.realm`| Kerberos realm to connect to. |`AD.UTAH.EDU`|
|`kerberos.serverPrincipal`| Kerberos server principal. |`HTTP/utah-dev.chpc.utah.edu@AD.UTAH.EDU`|
|`kerberos.keyTab`| Kerberos configuration. |`/etc/krb5.keytab`|
|`kerberos.kerberosPasswordAuth`| Use Kerberos for password authentication. |`true`|
|`kerberos.debug`| Writes additional debug logs if enabled. |`true`|
|`clusters.cluster.name`| Name of cluster to appear in the portal. |`Node1`|
|`clusters.cluster.host`| Hostname of cluster to connect to. |`node1.example.net`|
|`clusters.cluster.enableHostAdapter` | Configure remote desktop functionality. |`true`|
|`clusters.cluster.job.ssh_hosts` | Full hostname of the login node. |`kingspeak.chpc.utah.edu`|
|`clusters.cluster.job.singularity_bin` | Location of singularity binary. |`/bin/singularity`|
|`clusters.cluster.job.singularity_bindpath` | Directories accessible during VNC sessions. |`/etc,/media,/mnt,/opt,/run,/srv,/usr,/var,/home`|
|`clusters.cluster.job.singularity_image` | Location of singularity image. |`/opt/centos7.sif`|
|`clusters.cluster.job.tmux_bin` | Location of tmux binary. |`/usr/bin/tmux`|
|`clusters.cluster.basic_script` | Basic desktop startup script. |`#!/bin/bash \ ... \ %s`|
|`clusters.cluster.vnc_script` | VNC session startup script. |`#!/bin/bash \ ... \ %s`|
|`clusters.cluster.set_host` | Hostname passed from the remote node back to OnDemand. |`$(hostname -A)`|
|`host_regex` | Regular expression to capture hostnames. |`[\w.-]+\.(peaks\|arches\|int).chpc.utah.edu`|
|`enableHostAdapter` | Enable resource management and interactive apps. |`true`|
|`advanced.desktop` | Desktop environment (mate,xfce,gnome) |`mate`|
|`advanced.node_selector_label` | Matching node label for a preferred node. |`ssd`|
|`advanced.ssh_keys_GID` | Group ID value of ssh_keys group. |`993`|
|`advanced.secret_name` | Name of secret holding host_keys. |`ssh-key-secret`|
|`advanced.host_keys` | Names of stored keys. |`ssh_host_ecdsa_key`|
|`advanced.autofs` | Mount home directories using autofs. |`true`|
|`advanced.filesharing.nfs_shares` | A mapfile with shares to be mounted by autofs. |`* -nolock,hard,...`|
|`testUsers` | Unprivileged users for testing login to OnDemand. |`test`|
