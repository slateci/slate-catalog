# Condor-Worker - High Throughput Computing Worker Node for HTCondor


HTCondor is a distributed computing framework for High Throughput Computing (HTC). This chart will install an HTCondor execute node (startd) that uses a shared pool password or token to connect back to an existing HTCondor central manager.

---
# Installation

### Dependency Notes
This SLATE application requires a pool password or token secret to be installed on the target cluster in order to successfully deploy. Click [here](https://portal.slateci.io/secrets) to add a secret in the SLATE portal.

### Deployment
```console
$ slate app get-conf condor-worker > condor-worker.yaml
$ slate secret create condor-password --group <group-name> --cluster <cluster-name> --from-literal 'condor_password=<pool password>'
#  OR, if your pool password is stored in a file
$ slate secret create condor-password --group <group-name> --cluster <cluster-name> --from-file 'condor_password=<password file>'
$ slate app install --group <group-name> --cluster <cluster-name> --conf condor-worker.yaml condor-worker
```
---
# Configuration and usage
### Central manager configuration
Your central manager will need configuration equivalent to one of the two following examples in order for execute
nodes to successfully connect back and begin accepting jobs. 

Password-based configuration:

```
ALLOW_DAEMON = $(ALLOW_DAEMON), condor_pool@*
SEC_DEFAULT_AUTHENTICATION = PREFERRED
SEC_DEFAULT_AUTHENTICATION_METHODS = $(SEC_DEFAULT_AUTHENTICATION_METHODS) PASSWORD
SEC_DEFAULT_ENCRYPTION = OPTIONAL
SEC_DEFAULT_INTEGRITY = OPTIONAL
SEC_ENABLE_MATCH_PASSWORD_AUTHENTICATION = TRUE
SEC_PASSWORD_FILE = /etc/condor/condor_password
```

where /etc/condor/condor_password contains the password that is also stored in your PasswordFileSecret. 

Token-based configuration:

```
ALLOW_DAEMON = $(ALLOW_DAEMON), condor_pool@*
SEC_DEFAULT_AUTHENTICATION = PREFERRED
SEC_DEFAULT_AUTHENTICATION_METHODS = $(SEC_DEFAULT_AUTHENTICATION_METHODS) TOKEN
CREDD_OAUTH_MODE = True
TOKENS = True
SEC_DEFAULT_ENCRYPTION = OPTIONAL
SEC_DEFAULT_INTEGRITY = OPTIONAL
SEC_PASSWORD_FILE = /etc/condor/condor_password

# deny all requests by unidentified users
DENY_WRITE         = anonymous@*
DENY_ADMINISTRATOR = anonymous@*
DENY_DAEMON        = anonymous@*
DENY_NEGOTIATOR    = anonymous@*
DENY_CLIENT        = anonymous@*
# hosts are irrelevant with suitable token authentication
HOSTALLOW_WRITE = *
ALLOW_WRITE = $(HOSTALLOW_WRITE)
ALLOW_DAEMON = *
```


### Configuration options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| Instances | Number of HTCondor worker nodes | `1` |
| CollectorHost | The HTCondor central manager | `localhost` |
| PasswordFileSecret | The SLATE secret that contains the HTCondor pool password, which should be stored under the key `condor_password` | `null` |
| AuthTokenSecret | The SLATE secret that contains the HTCondor token issued by the central manager, which should be stored under the key `condor_token` | `null` |
| MemoryLimit | The total amount of memory that is requested by the HTCondor pod - **NOTE** the HTcondor slots are configured to be partitionable by default | `512` |
| NumberCPUs | The total number of CPUs requested by the HTCondor pod. **NOTE** The HTCondor slots are configured to be partitionable by default. | `1` | 
| UseGPUs | If enabled, will attempt to create expose request GPUs via the nvidia-docker plugin and expose them as a GPU classad. The image currently uses CUDA driver v9.1.85 which likely needs to match the driver version on the host  | `false` |  
| NumberGPUs | The number of GPUs requested via the nvidia-docker plugin | `2` | 
| ExecuteDir | An external hostPath mounted into the container for scratch | Container default storage location |
| CondorConfigFile | Any HTCondor-specific configuration macros may be set here. | - | 

### Usage
For more instructions on using HTCondor please read this [documentation](https://research.cs.wisc.edu/htcondor/manual/)

