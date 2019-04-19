# HTCondor - High Throughput Computing 
## Worker Node Chart

**NOTE**: This SLATE application requires a pool password secret to be
installed on the target cluster in order to successfully deploy. Click [here](https://portal.slateci.io/secrets) to add a secret in the SLATE portal.

*Image source*: https://github.com/LincolnBryant/htcondor-docker/


This chart will install an HTCondor executor (startd) that uses a shared pool
password to connect back to an existing HTCondor central manager.

---
## Usage:

```console
$ slate app get-conf htcondor > htcondor.yaml
$ slate app install --group <group-name> --cluster <cluster-name> htcondor.yaml
```
---

## Central manager configuration
Your central manager will need the following configuration in order for execute
nodes to successfully connect back and begin accepting jobs:
```console
    ALLOW_DAEMON = $(ALLOW_DAEMON), condor_pool@*
    SEC_DEFAULT_AUTHENTICATION = PREFERRED
    SEC_DEFAULT_AUTHENTICATION_METHODS = $(SEC_DEFAULT_AUTHENTICATION_METHODS) PASSWORD
    SEC_DEFAULT_ENCRYPTION = OPTIONAL
    SEC_DEFAULT_INTEGRITY = OPTIONAL
    SEC_ENABLE_MATCH_PASSWORD_AUTHENTICATION = TRUE
    SEC_PASSWORD_FILE = /etc/condor/condor_password
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
