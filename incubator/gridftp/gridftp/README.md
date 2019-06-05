# GridFTP - Secure, Robust, Fast, Efficient Data Transfer 

**NOTE**: This SLATE application requires Kubernetes secrets for both a user X509 certificate-key pair, as well as for a hostname IGTF server SSL cerficate-key pair. The default names for these secrets are "gridftp-user-secret" and "gridftp-host-secret", respectively.

This chart will install and configure a GridFTP front end, with the option of installing and configuring a data node for back end data striping.

---
## Usage:

```console
$ slate app get-conf --dev gridftp > gridftp.yaml
$ slate app install --dev --group <group-name> --cluster <cluster-name> gridftp.yaml
```
---

## Configuration options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| Instances | Number of GridFTP servers (Increased in striping or cloud config) | `1` |
| HostNetwork | Whether to use the Kubernetes HostNetwork interface | `true` |
| HostSecretName | The SLATE secret that contains the Host certificate and keys | `gridftp-host-pems` |
| UserSecretName | The SLATE secret that contains the User certificate and keys (may be a tarball if MultiUserTar) is `true` | `gridftp-test-x509` |
| MultiUserTar | If true, the Docker image will unwrap a 'user_info.tar.gz' located at UserSecretName. | `false` |
| GridFTPPort | The port for data & control channel access to GridFTP. These can be decoupled by advanced configuration | `2811` |
| DataMountPoint | Where Kubernetes should mount additional storage | `/scratch` | 
| Authentication | Authentication can be GSISSH, userpass, or anonymous | `gsissh` |
| DataNodeScaling | Autoscale data node resources | `false` |
| FrontEndScaling | Autoscaling front end resources | `false` |
