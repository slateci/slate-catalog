# GridFTP - Secure, Robust, Fast, Efficient Data Transfer 


---
# Installation

### Dependency notes
**NOTE**: This SLATE application requires Kubernetes secrets for both a user X509 certificate-key pair, as well as for a hostname IGTF server SSL cerficate-key pair. The default names for these secrets are "gridftp-user-secret" and "gridftp-host-secret", respectively.

**NOTE**: The Common Name in the server certificate used with this application must match the hostname configured on the node where it is scheduled. To coordinate this, the application will only schedule on nodes which have a `gridftp: "true"` label set by a cluster administrator. Users are recommended to contact cluster admins to arrange this. 

**NOTE**: This application currently uses host networking, so two instances configured to use the same port cannot coexist on the same node. No mechanism is currently in place to ensure that multiple instances are scheduled to different nodes even if multiple suitable nodes are available. 

### The host secret
This chart will install and configure a GridFTP front end allowing data to be sent and received. 

The host secret should contain two keys: `hostcert.pem` and `hostkey.pem`, containing the server certificate and secret key, respectively. 

The user secret should contain the 'gridmap' file under the key `grid-mapfile`. This file should contain the DNs of any clients you wish to allow, mapped to the usernames with which you want them to be associated. Additionally, under the key `etc-passwd` the secret should contain a file, in the standard /etc/passwd format, describing the mapping of usernames to user identifier numbers and groups. Details like home directory paths and login shells are allowed, but have little practical use. By using these two mappings, it is possible to configure GridFTP to read and write files according to pre-existing schemes of user and group IDs (such as whatever may be already in use on the filesystem mounted by GridFTP with `InternalPath`).

### Deployment
```console
$ slate app get-conf --dev gridftp > gridftp.yaml
$ slate app install --dev --group <group-name> --cluster <cluster-name> gridftp
```
---
# Configuration and usage

### Configuration options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| HostSecretName | The SLATE secret that contains the Host certificate and keys | `gridftp-host-pems` |
| UserSecretName | The SLATE secret that contains the grid-mapfile for GridFTP, and the /etc/passwd file for the server, named 'grid-mapfile' and 'etc-passwd' respectively | `gridftp-users` |
| GridFTPPort | The port for data & control channel access to GridFTP. These can be decoupled by advanced configuration | `2811` |
| InternalPath | A path on the host system which should be mounted into the GridFTP container as back-end storage. | `/mnt`| 
| ExternalPath | The path inside the GridFTP container at which the filesystem specified by `InternalPath` should be mounted. This is the path which will be used in GridFTP URLs to manipulate data on that filesystem. | `/export` | 

### Usage
For more instructions on how to run gridftp please see this [documentation](https://www.nics.tennessee.edu/computing-resources/data-transfer/gridftp)
