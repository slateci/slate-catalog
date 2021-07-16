
# Using SLATE to deploy Open OnDemand

## About

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

It is assumed that you already have access to a SLATE-registered Kubernetes
cluster, and that you have installed and configured the SLATE command
line interface.  If not, instructions can be found at 
[SLATE Quickstart](https://slateci.io/docs/quickstart/).  

Additionally, this application requires that `cert-manager` and a volume provisioner be present on the cluster you are installing on.
Contact your cluster administrator for more information about this.
More information about `cert-manager` can be found [here](https://cert-manager.io/docs/installation/kubernetes/),
and more information about persistent volume types can be found [here](https://kubernetes.io/docs/concepts/storage/storage-classes/).

To enable more advanced features, NFS sharing and host-level trust must be permitted between front and backend resources.


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

### Cert-Manager Setup

If cert-manager is not already present, contact your cluster administrator. To install cert-manager, the administrator must either set up the SLATE cluster using Ansible and Kubespray, or have access to `kubectl` on the command line.

When using the Ansible playbook the option for cert-manager must be changed from:
```yaml
cert_manager_enabled: false
```
to
```yaml
cert_manager_enabled: true
```
More information on using Ansible playbooks can be found [here](https://slateci.io/docs/cluster/install-kubernetes-with-kubespray.html).
If the administrator has access to `kubectl` then cert-manager can be installed using a regular manifest or with helm. Instructions can be found at the official [cert-manager docs](https://cert-manager.io/docs/installation/kubernetes/).

When all of the manifest components are installed, create an `Issuer` or `ClusterIssuer` .yaml file so that cert-manager can issue certificates on request by the OnDemand Helm chart. Here is a simple example of a `ClusterIssuer` .yaml configuration:
```yaml
metadata:
  name: letsencrypt-prod
spec:
  acme:
    # The ACME server URL
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: admin@example.com
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: lets-encrypt-key
```
Make sure that the name of the issuer is `letsencrypt-prod`.

Note: The difference between a `ClusterIssuer` and an `Issuer` is that the latter is namespace specific.


### Modifying Default Values

At the top of the configuration file is a value called `Instance`.
Set this to a unique string you wish to identify your application with.
Take note of this value, as it will eventually form part of the URL you will access your OnDemand instance with.

Next, configure the persistent volume that will store authentication data.
Under `volume`, set the `storageClass` value to a storage class that is supported by your cluster.

To determine the storage classes supported by each cluster, consult individual
cluster documentation (`slate cluster info <cluster_name>`). If this does not
yield helpful output, contact your cluster administrator.

Leave the `size` value at its default `50M`.

Then, configure the LDAP and Kerberos sections according to your institution's setup.


**Shell Access**

To set up shell access to backend compute resources, edit the `clusters` section
of the configuration file. Add a `cluster` element for each cluster you wish to
connect to, and fill out the `name` and `host` sections. The cluster name should
be whatever you want the OnDemand web portal to display that cluster as, and the
`host` value should be the DNS name of that cluster.

```yaml
  - cluster:
      name: "Notchpeak"
      host: "notchpeak.chpc.utah.edu"
      enableHostAdapter: false
```

**Remote Desktop Access**

To set up remote desktop access, set the `enableHostAdapter` value to true,
then configure the LinuxHost Adapter. This is a simplified resource manager
built from various components such as TurboVNC, Singularity and tmux. By
enabling resource management, you can set up more interactive apps and 
easily manage remote sessions from the OnDemand portal.

```yaml
  - cluster:
      name: "node1"
      host: "example-node1.net"
      enableHostAdapter: true
      job:
        ssh_hosts: "example-node1.net"
        singularity_bin: /bin/singularity
        singularity_bindpath: /etc,/media,/mnt,/opt,/run,/srv,/usr,/var,/home
        singularity_image: /opt/centos7.sif 
        tmux_bin: /bin/tmux
      basic_script: 
        - "#!/bin/bash"
        - "module purge"
        - "export XDG_RUNTIME_DIR=$(mktemp -d)"
        - "%s"
      vnc_script: 
        - "#!/bin/bash"
        - "module purge"
        - "export PATH='/opt/TurboVNC/bin:$PATH'"
        - "export WEBSOCKIFY_CMD='/usr/bin/websockify'"
        - "export XDG_RUNTIME_DIR=$(mktemp -d)"
        - "%s"
      set_host: "$(hostname -A)"
```

**Test User Setup**

This Open OnDemand chart supports the creation of temporary test users, for
validating application functionality without the complexity of connecting to
external LDAP and Kerberos servers. To add a test user(s), navigate to the
`testUsers` section of the configuration file. Add the following yaml to this
section for each user you would like to add:
```yaml
- user:
    name: <username_here>
    tempPassword: <temporary_password_here>
```

## Interactive Apps and Remote Desktop (Optional)

### Authentication

The LinuxHost Adapter requires passwordless SSH for all users which is 
most easily configured by establishing host-level trust. To enable hostBased 
Authentication, first go to each backend resources and add public host keys 
from the OnDemand server to a file called `/etc/ssh/ssh_known_hosts` using 
the`ssh-keyscan` command.

```bash
ssh-keyscan [IP_ADDR] >> /etc/ssh/ssh_known_hosts
```

Add an entry to `/etc/ssh/shosts.equiv` with the IP address of the
OnDemand server. Then in the `/etc/ssh/sshd_config` file, change the
following lines from:

```bash
#HostbasedAuthentication no
#IgnoreRhosts yes
```
to
```bash
HostbasedAuthentication yes
IgnoreRhosts no
```

Next, ensure that you have the correct permissions for host keys at `/etc/ssh`

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

Since pods are ephemeral, keys from the host system should be passed 
into the container using a secret. This will ensure that trust is not broken
when pods are replaced. This script will generate a secret containing host 
keys on the OnDemand server.

Note: must be consistent with the values.yaml file

```bash
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
$command ; printf "\n"
```

### Filesystem Distribution

Resource management for Open OnDemand also requires a distributed filesystem
between front and backend resources. This can be set up using NFS, autoFS, or some 
other DFS protocol. 

To do this using NFS, first install `nfs-utils` and then modify the `/etc/exports`
file with an entry for localhost, and then for any backend clusters.
By default, if `enableHostAdapter` is set to true, this chart will attempt to mount 
an NFS volume into the OnDemand container using the `nfs_path` value. 

```bash
/uufs/chpc.utah.edu/common/home  127.0.0.1(rw,sync,no_subtree_check,root_squash)
/uufs/chpc.utah.edu/common/home  192.168.1.1(rw,sync,no_subtree_check,root_squash)
...
...
```

### NodeSelector

Finally, in order for these environmental changes to have effect, the chart must
be installed on a properly configured node. On a multi-node system it is necessary
to set a `nodeSelectorLabel` called disktype, and match that label in the
`values.yaml` file.

```bash
kubectl label nodes <node-name> disktype=ssd
```

## Installation

Now that Open OnDemand has been properly configured, we can install the application with the following SLATE command:

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


## Configurable Parameters:

The following table lists the configurable parameters of the Open OnDemand application and their default values.

|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`Instance`| String to differentiate SLATE experiment instances. |`global`|
|`replicaCount`| The number of replicas to create. |`1`|
|`setupKeycloak`| Runs Keycloak setup script if enabled. |`true`|
|`volume.storageClass`| The volume provisioner from which to request the Keycloak backing volume |`local-path`|
|`volume.size`| The amount of storage to request for the volume |`50M`|
|`setupLDAP`| Set up LDAP automatically based on following values. |`true`|
|`ldap.connectionURL`| URL to access LDAP at. |`ldap://your-ldap-here`|
|`ldap.importUsers`| Import LDAP users to Keycloak. |`true`|
|`ldap.rdnLDAPAttribute`| LDAP configuration |`uid`|
|`ldap.uuidLDAPAttribute`| LDAP configuration |`uidNumber`|
|`ldap.userObjectClasses`| LDAP configuration |`inetOrgPerson, organizationalPerson`|
|`ldap.usersDN`| LDAP configuration |`ou=People,dc=chpc,dc=utah,dc=edu`|
|`kerberos.realm`| Kerberos realm to connect to. |`AD.UTAH.EDU`|
|`kerberos.serverPrincipal`| Kerberos server principal |`HTTP/utah-dev.chpc.utah.edu@AD.UTAH.EDU`|
|`kerberos.keyTab`| Kerberos configuration |`/etc/krb5.keytab`|
|`kerberos.kerberosPasswordAuth`| Use Kerberos for password authentication. |`true`|
|`kerberos.debug`| Writes additional debug logs if enabled. |`true`|
|`clusters.cluster.name`| Name of cluster to connect to. |`Kingspeak`|
|`clusters.cluster.host`| Hostname of cluster to connect to. |`kingspeak.chpc.utah.edu`|
|`desktopEnable` | Configure remote desktop functionality. |`true`|
|`ssh_hosts` | Full hostname of the login node. |`kingspeak.chpc.utah.edu`|
|`singularity_bin` | Location of singularity binary. |`/bin/singularity`|
|`singularity_bindpath` | Directories accessible during VNC sessions. |`/etc,/media,/mnt,/opt,/run,/srv,/usr,/var,/home`|
|`singularity_image` | Location of singularity image. |`/opt/centos7.sif`|
|`tmux_bin` | Location of tmux binary. |`/bin/tmux`|
|`basic_script` | Basic desktop startup script. |`#!/bin/bash \ ... \ %s`|
|`vnc_script` | VNC session startup script. |`#!/bin/bash \ ... \ %s`|
|`set_host` | Hostname passed from the remote node back to OnDemand. |`$(hostname -A)`|
|`host_regex` | Regular expression to capture hostnames. |`[\w.-]+\.(peaks\|arches\|int).chpc.utah.edu`|
|`desktop` | Desktop environment (mate,xfce,gnome) |`mate`|
|`node_selector_label` | Matching node label for a preferred node |`ssd`|
|`ip_addr` | Public IP address of the preferred node. |`127.0.0.1`|
|`ssh_keys_GID` | Group ID value of ssh_keys group. |`993`|
|`nfs_path` | Path to distributed filesystem. |`/uufs/chpc.utah.edu/common/home`|
|`secret_name` | Name of secret holding host_keys. |`ssh-key-secret`|
|`host_keys` | Names of stored keys. |`ssh_host_ecdsa_key`|
|`testUsers` | Unprivileged users for testing login to OnDemand. |`test`|
