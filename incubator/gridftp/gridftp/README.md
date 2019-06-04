# GridFTP - Secure, Robust, Fast, Efficient Data Transfer 

**NOTE**: This SLATE application requires Kubernetes secrets for both a user X509 certificate-key pair, as well as for a hostname IGTF server SSL cerficate-key pair. The default names for these secrets are "gridftp-user-secret" and "gridftp-host-secret", respectively.

This chart will install and configure a GridFTP front end, with the option of installing and configuring a data node for back end data striping.

---
## Usage:

```console
$ slate app get-conf gridftp > gridftp.yaml
$ slate app install --group <group-name> --cluster <cluster-name> gridftp.yaml
```
---

## Configuration options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| Instances | Number of HTCondor worker nodes | `1` |
| CollectorHost | The HTCondor central manager | `localhost` |
| PasswordFileSecret | The SLATE secret that contains the HTCondor pool password | `condor-password` |
| MemoryLimit | The total amount of memory that is requested by the HTCondor pod - **NOTE** the HTcondor slots are configured to be partitionable by default | `512` |
| NumberCPUs | The total number of CPUs requested by the HTCondor pod. **NOTE** The HTCondor slots are configured to be partitionable by default. | `1` | 
| UseGPUs | If enabled, will attempt to create expose request GPUs via the nvidia-docker plugin and expose them as a GPU classad. The image currently uses CUDA driver v9.1.85 which likely needs to match the driver version on the host  | `false` |  
| NumberGPUs | The number of GPUs requested via the nvidia-docker plugin | `2` | 
| ExecuteDir | An external hostPath mounted into the container for scratch | Container default storage location |
| CondorConfigFile | Any HTCondor-specific configuration macros may be set here. | - | 
