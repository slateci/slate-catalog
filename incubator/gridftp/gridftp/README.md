# GridFTP - Secure, Robust, Fast, Efficient Data Transfer 

**NOTE**: This SLATE application requires Kubernetes secrets for both a user X509 certificate-key pair, as well as for a hostname IGTF server SSL cerficate-key pair. The default names for these secrets are "gridftp-user-secret" and "gridftp-host-secret", respectively.

This chart will install and configure a GridFTP front end, with the option of installing and configuring a data node for back end data striping.

---
## Usage:

```console
$ slate app get-conf --dev gridftp > gridftp.yaml
$ slate app install --dev --group <group-name> --cluster <cluster-name> gridftp
```
---

## Configuration options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| Instances | Number of GridFTP servers (Increased in striping or cloud config) | `1` |
| HostNetwork | Whether to use the Kubernetes HostNetwork interface | `true` |
| HostSecretName | The SLATE secret that contains the Host certificate and keys | `gridftp-host-pems` |
| UserSecretName | The SLATE secret that contains the grid-mapfile for GridFTP, and the /etc/passwd file for the server, named 'grid-mapfile' and 'etc-passwd' respectively | `gridftp-users` |
| GridFTPPort | The port for data & control channel access to GridFTP. These can be decoupled by advanced configuration | `2811` |
| DFSPath | Where on the Kubernetes local host additional Distributed File System storage was mounted. Will become a Kubernetes volume by HostPath. | `/cephfs/test`| 
| DFSMountPoint | Where Kubernetes should mount additional storage from DFS Path. | `/scratch` | 
