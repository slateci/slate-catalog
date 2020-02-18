# Condor Manager - An HTCondor Pool Central Manager

This chart installs a central manager suitable for operating an HTCondor pool. Specifically, it provides the collector and negotiator components which keep track of other components participating in the pool and match jobs to worker slots, respectively. Neither a scheduler component (required for job submission) nor any workers are included in this chart; these are expected to be installed separately (see the condor-submit and condor-worker charts for this functionality). 

---
# Installation

This guid illustrates deploying a full condor pool with the central manager, an interactive submit node, and a worker node through SLATE. If suitable submit or worker nodes exist (or will be created) outside of SLATE/Kubernetes, the steps for deploying those components should be modified appropriately. 

First, the central manager should be installed, as it will issue tokens which are needed by the other components. The manager has no particular dependencies, and so may be installed directly:

	$ slate app install --dev condor-manager --group <your group> --cluster <a cluster>
	Successfully installed application condor-manager as instance some-group-condor-manager with ID instance_1sHjOie7t34

Next, inspect your instance's information to learn its address:

	$ ./slate instance info instance_1sHjOie7t34
	Name      Started                     Group      Cluster    ID
	condor-   2020-Feb-13 20:37:20.618692 some-group a-cluster  instance_
	manager   UTC                                               1sHjOie7t34
	
	Services:
	Name           Cluster IP  External IP    Ports          URL
	condor-manager 10.97.32.64 192.170.227.37 9618:32541/TCP 192.170.227.37:32541
	# . . . 

Note the external IP address of the service, in this case `192.170.227.37` and external port (`32541` in this example). Then, check the applications logs to get the tokens it has issued for the other cluster components:

	$ ./slate instance logs instance_1sHjOie7t34
	Fetching instance logs...
	========================================
	Pod: some-group-condor-manager-db6f6cdf4-z6bzq Container: condor-manager
	. . . 
	2020-02-11 23:25:46,948 INFO supervisord started with pid 1
	2020-02-11 23:25:47,950 INFO spawned: 'generate_tokens' with pid 8
	2020-02-11 23:25:47,952 INFO spawned: 'htcondor' with pid 9
	2020-02-11 23:25:47,953 INFO spawned: 'crond' with pid 10
	generate_tokens: Waiting for condor collector to become available
	2020-02-11 23:25:47,958 INFO success: generate_tokens entered RUNNING state, process has stayed up for > than 0 seconds (startsecs)
	2020-02-11 23:25:49,155 INFO success: htcondor entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
	2020-02-11 23:25:49,155 INFO success: crond entered RUNNING state, process has stayed up for > than 1 seconds (startsecs)
	**** Condor Submit Token ****
	eyJhbGciOiJIUzI1NiIsImtpZCI6IlBPT0wifQ.eyJpYXQiOjE1ODE0NjM1NTEsImlzcyI6ImNvbmRvci1tYW5hZ2VyLWRiNmY2Y2RmNC16NmJ6cSIsInN1YiI6InN1Ym1pdEBwb29sIn0.u8pHcENWvhXsNP735yS22vVDAHwqg00XmJuB_uZDEgM
	**** Condor Worker Token ****
	eyJhbGciOiJIUzI1NiIsImtpZCI6IlBPT0wifQ.eyJpYXQiOjE1ODE0NjM1NTEsImlzcyI6ImNvbmRvci1tYW5hZ2VyLWRiNmY2Y2RmNC16NmJ6cSIsInN1YiI6IndvcmtlckBwb29sIn0.juf-VAs7RBRNGdAVaYv-39KDlmk3txa0Mj_921ukLLk
	2020-02-11 23:25:51,247 INFO exited: generate_tokens (exit status 0; expected)

Copy all of the data on the line following the `**** Condor Submit Token ****` (the `eyJpYX...`) and put it in a file named 'submit-token'. Make sure that your file has exactly one trailing newline character (`\n`), as this white space is significant to current versions of HTCondor (8.9.5). Repeat the process for the worker token, copying the similar data after the `**** Condor Worker Token ****` and putting it in a file named 'worker-token'. Now, you can create secrets from these tokens, suitable for consumption by the other SLATE applications for the other components:

	$ slate secret create submit-auth-token --group <some group> --cluster <a cluster> --from-file condor_token=submit-token
	Successfully created secret submit-auth-token with ID secret_dHiGnjAgR2A
	$ slate secret create worker-auth-token --group <some group> --cluster <a cluster> --from-file condor_token=worker-token
	Successfully created secret worker-auth-token with ID secret_Hhjy43uyNsP

You are now ready to deploy one or more workers to execute jobs for the pool. Download the base configuration for the worker application, and then edit it to use the manager external IP address obtained above as the `CollectorHost`, the manager external port as the `CollectorPort`, and the name of your worker token secret as the `AuthTokenSecret`:

	$ slate app get-conf condor-worker > worker.conf
	# Edit worker.conf
	# The resulting file contain a entries something like:
	CondorConfig:
	  Instances: 1
	  CollectorHost: 192.170.227.37
	  CollectorPort: 32541
	  AuthTokenSecret: worker-auth-token
	  . . . 

You may wish to customize the number of instances, the number of CPU cores requested for each instance, RAM requested for each instance, etc. If you are familiar with HTCondor you can configure advanced settings by changing the data for `CondorConfigFile`, but the defaults should be suitable for most users. 

After you finish customizing the worker configuration, you can proceed to install it:

	$ slate app install condor-worker --group <some group> --cluster <a cluster> --conf worker.conf
	Successfully installed application condor-worker as instance some-group-condor-worker with ID instance_nsWh3hNs2Gb

Next, download the configuration for the interactive submit node:

	$ slate app get-conf --dev condor-submit > submit.conf

TODO: Discuss how to get the CI-Connect data for the `UserConfig` section. 

As with the worker, edit the `CondorConfig` section to set `CollectorHost` to be your central manager's address, set `CollectorPort` to be the central manager's port number, and set `AuthTokenSecret` to be "submit-auth-token":

	CondorConfig:
	  CollectorHost: 192.170.227.37
	  CollectorPort: 32541
	  AuthTokenSecret: submit-auth-token

Then, install the submit node application:

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

You should be able to connect to the application interactively with SSH using your CI-Connect keypair and username at the external IP on the external port:

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

At this point, you can query condor for the available computing resources:

	[username@machine ~]$ condor_status
	Name                                          OpSys      Arch   State     Activ
	
	slot1@condor-worker-6ffb89b969-7mvc6@machine  LINUX      X86_64 Unclaimed Idle 
	
	               Machines Owner Claimed Unclaimed Matched Preempting  Drain
	
	  X86_64/LINUX        1     0       0         1       0          0      0
	
	         Total        1     0       0         1       0          0      0

Here, because one worker instance was specified, condor has one slot available. You can now run a test job. Put the following into a file 'job.sub':

	Executable   = /usr/bin/echo
	Arguments    = Hello World
	Universe     = vanilla
	Log          = job.log
	Output       = job.out
	Error        = job.err
	Queue

Then, submit the job:

	$ condor_submit job.sub
	Submitting job(s).
	1 job(s) submitted to cluster 1.

If you run `condor_q` promptly, you may be able to see you job appear in the Idle state, or transition to the Running state. However, it should complete quickly. The log, error and output files specified in the submit description should have been created, with job.out containing the "Hello World" written by echo. 

## Configuration options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| Instance | A label for your application instance | "" |

# Usage
For more instructions on using HTCondor please see the [official documentation](https://research.cs.wisc.edu/htcondor/manual/).