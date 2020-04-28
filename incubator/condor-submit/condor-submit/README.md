# Condor-Worker - High Throughput Computing Worker Node for HTCondor

HTCondor is a distributed computing framework for High Throughput Computing (HTC). This chart will install an HTCondor submit node (schedd) that uses a token to connect back to an existing HTCondor central manager.

---
# Installation

### Dependency Notes
This SLATE application requires a token issued by the target HTCondor central manager to be installed as a SLATE secret on the host cluster. Additionally, as an interactive resource, it requires a source for the user accounts to be provisioned, which can be either the [CI-Connect service](https://ci-connect.net) or [SSSD](https://pagure.io/SSSD/sssd) interfacing with an existing LDAP or Active Directory installation. 

### Deployment
Create a named 'submit-token' file which contains the token issued by the condor central manager to which you want this installation to submit jobs. Make sure that the file has exactly one newline character (`\n`) after the end of the token text, some versions of condor require this in order to accept the token. Then, store the token into a SLATE secret:

	$ slate secret create submit-auth-token --group <some group> --cluster <a cluster> --from-file condor_token=submit-token
	Successfully created secret submit-auth-token with ID secret_dHiGnjAgR2A

Download the configuration for this application:

	$ slate app get-conf --dev condor-submit > submit.conf

As with the worker, edit the `CondorConfig` section to set `CollectorHost` to be your central manager's address, set `CollectorPort` to be the central manager's port number, and set `AuthTokenSecret` to be "submit-auth-token":

	CondorConfig:
	  CollectorHost: 192.170.227.37
	  CollectorPort: 32541
	  AuthTokenSecret: submit-auth-token

In the `SystemConfig` section, make any customizations you need for the resources the application instance will be allowed to use. THis section also contains options for fine-tuning persistent storage either from within Kubernetes or from an external filesystem (such as a site's shared filesystem). 

If using CI-Connect to manage your user accounts, set `UserConfig.Mode` to `connectapi`, create a secret with your CI-Connect access token similar to the following:

	$ slate secret create ci-connect-token --group <some group> --cluster <a cluster> --from-file API_TOKEN=connect-token

and then set `UserConfig.ConnectToken` to the name of your secret (`ci-connect-token` if you follow the example above). 

Otherwise, if using SSSD with LDAP/AD, set `UserConfig.Mode` to `sssd`, and change `userConfig.SSSD` to your SSSD configuration. 

You can then install your instance:

	$ slate app install --dev condor-submit --group <some group> --cluster <a cluster> --conf submit.conf
	Successfully installed application condor-submit as instance some-group-condor-submit with ID instance_7Bhtyh4nHfs

You can then determine where your submit node is running:

	$ ./slate instance info instance_7Bhtyh4nHfs
	Name           Started          Group     Cluster       ID
	condor-submit  2020-Feb-01      slate-dev uchicago-prod instance_  
	               00:47:14.777454                          k0OEw6_Qbek
	               UTC                                      
	
	Services: 
	Name          Cluster IP  External IP    Ports          URL
	condor-submit 10.92.86.20 192.170.227.37 2222:32083/TCP 192.170.227.37:32083
	
	. . . 

You should be able to connect to the application interactively with SSH using your credentials configured with CI-Connect/AD/LDAP at the external IP on the external port:

	$ ssh -i ~/.ssh/<private key> -p 32083 <user name>@192.170.227.37
	Enter passphrase for key '~/.ssh/<private key>': 
	Last login: Sat Feb  1 01:00:18 2020 from 10.150.5.94
	   ______   ___ __________
	  / __/ /  / _ /_  __/ __/
	 _\ \/ /__/ __ |/ / / _/  
	/___/____/_/ |_/_/ /___/ 
	
	--------------------------
	
	 Interactive Submit Node
	
	--------------------------
	[username@machine ~]$ 

## Configuration options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| Instance | A label for your application instance | "" |
| CondorConfig.CollectorHost | The hostname or IP address of your HTCondor central manager | null |
| CondorConfig.CollectorPort | The port on which your schedd should contact the central manager daemons | 9618 |
| CondorConfig.AuthTokenSecret | The name of the SLATE secret from which contains the token your instance will use to authenticate with the central manager | null |
| CondorConfig.ConfigFile | Any additional settings you need to inject into the configuration of your schedd | null |
| SystemConfig.Cpu | The maximum amount of CPU resources the instance will be allowed to use, in units of 'millicores' | 4000m |
| SystemConfig.Memory | The maximum amount of RAM the instance will be allowed to use | 8Gi |
| SystemConfig.PVCName | The name of an existing PersistentVolumeClaim which the instance should mount as storage. Mutually exclusive with SystemConfig.HostPath | null |
| SystemConfig.HostPath | The path to a filesystem or portion thereof which the instance should mount as storage. Mutually exclusive with SystemConfig.PVCName | null |
| SystemConfig.MountLocation | The path within the contain at which any backing storage specified with SystemConfig.PVCName or SystemConfig.HostPath should be mounted. | "/data" |
| SystemConfig.NodeSelector | An expression which should be used as a Kubernetes NodeSelector to restrict on which cluster nodes this instance may be scheduled. | null |
| UserConfig.Mode | The mechanism to use for provisioning user accounts for interactive login. Must be either "connectapi" or "sssd".| "connectapi" |
| UserConfig.ConnectToken | The name of a secret which contains a CI-Connect access token, under the key `API_TOKEN`.| "connect-token-secret" |
| UserConfig.ConnectUserSourceGroup | The fully-qualified name of the CI-Connect group from which users should be selected | null |
| UserConfig.ConnectGroupSourceGroup | The fully-qualified name of the CI-Connect group from the previously-selected user's group affiliations should be drawn. This is typically the same as UserConfig.ConnectUserSourceGroup, but may also be a group which encloses it. | null |
| UserConfig.SSSD | The contents of the SSSD configuration file which should be used |  |

# Usage
For more instructions on using HTCondor please see the [official documentation](https://research.cs.wisc.edu/htcondor/manual/).