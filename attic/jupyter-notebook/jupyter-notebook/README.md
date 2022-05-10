# Jupyter Notebook - Scientific Python Stack

This release of this chart configures a JupyterLab that you can deploy on SLATE platform and also provides two additional optional features: 
##### 1- Condor Submit Environment
##### 2- SSH Access

To use the first feature, this chart assumes that the user already has access to an external HTCondor cluster and that they need to add a job submit environment to the JupyterLab instance so that they can communicate with the cluster. Similarly, the second feature can be enabled by users needing access to the JupyterLab instance over SSH. 

###### Note: Setting up a full HTCondor pool with all of its main components (e.g. collector, negotiator, and worker) is outside the scope of this chart. However, if you are interested in learning more about that, we encourage you to check the other condor charts we have in our SLATE application catalog since they cover that part in detail.

# Configuration
We will start by downloading the application's configuration file so that you can configure the chart as you need. To get the file, run the following command:  

	$ slate app get-conf --dev jupyter-notebook > jupyter.conf


Now, let's take a look at the chart's configuration which can be divided into three main categories: Jupyter, Condor and SSH. 
#### 1- Jupyter

This part covers the minimum configuration that you'd need in the above file to successfully deploy an instance of this chart. First, add an instance name for the chart. 

	Instance: 'jupyterdemo'
	
Next, choose a subdomain for the application ingress: 

	Ingress:
	  Subdomain: 'slatenotebook'
 
After that, you can work on the Jupyter specific settings by first choosing a username. This user name will be used to create your home directory and set up your account on JupyterLab. For example, the below shows that username will be set to "slate"

	Jupyter:
     NB_USER: 'slate'

Finally, you'll need to provide the authentication information. Jupyter gives you the option of using a token for authentication. So to generate a random token, you can use one of the below commands from any Linux system:

	openssl rand -base64 32
	
or

	uuidgen

Then, add the generated token to the file:

	Jupyter:
	  Token: '90246f039b03803a5276925cb6b151'
     
Alternatively, if you have a JupyterLab password hash you'd like to use, you can just add it to the config file under Jupyter>Password. This is only useful for users who have access to another Jupyter Lab as the hashed password generation needs a Jupyter function called "notebook.auth.security.passwd()". 

Once you're done with this part, the configuration would look like:

	Jupyter:
     NB_USER: 'slate'
     Password: 'sha1:94491e2a6996:90242cb6b151'
     Token: '90246f039b03803a4f0bb6b151'

 
#### 2- Condor (Optional)  
If you don't need to enable the condor submit functionality in this chart, you can skip this part. As indicated before, this part only configures the condor submit feature and assumes that the other condor components already exist. In order to submit jobs to a condor pool, a token and a password are used for authentication.
 
So, to configure this feature, you will need to create a SLATE secret from these cedentials. You can do that by pasting the token into a text file &lt;submit-token&gt;, the password into a file &lt;submit-password&gt;, ensuring that each has just one trailing newline character (\n). Then, use the slate command as follows:

	$ slate secret create submit-auth-token --group <some group> --cluster <a cluster> --from-file condor_token=submit-token --from-file reverse_password=submit-password
	Successfully created secret submit-auth-token with ID secret_dHiGnjAgR2A
 
 

Now you can add to the configuration file the following HTCondor information: *CollectorHost* IP address, *CollectorPort* number, the *submit-auth-secret*, and *ExternalCondorPort*, which must be a port number which is currently unused on the cluster where the application is being installed. A sample configuration for this part looks like:

	CondorConfig:
	  Enabled: true
	  CollectorHost: 128.214.138.10
	  CollectorPort: 30487
	  AuthTokenSecret: submit-auth-token
	  ExternalCondorPort: 31862
  
#### 3- SSH (Optional) 
If you don't need to enable SSH access on your instance, then you can skip this section. Enabling this feature requires setting the Enabled flag to true and adding your SSH public key which would start with "ssh-rsa". A sample configuration for this part looks like this:

	SSH:  
	  Enabled: true
	  SSH_Public_Key: 'ssh-rsa AAAAB3NzaC1yc2ESFGSAQABAAA.....YRFB5sdfgs1+9/1Mnf53 slate'

# Deploying
 Now that the configuration file has all the changes you need, you can deploy an instance of this application by using the SLATE command as shown below: 

	$ slate app install jupyter-notebook --dev --group <group> --cluster <cluster> --conf jupyter.conf
	
###### Note: If deployment fails due to an instance name that's already been chosen by another user, please choose a different instance name and try running the above command again 
Once SLATE creates the requested resources needed for your JupyterLab instance, you can access it via a Web browser. Run the below command to learn the URL of the deployed application: 

	$ slate instance info <instance-ID>
	Services:
	Name                               Cluster IP    External IP   Ports          URL                                     
	slate-dev-jupyter-notebook-alidemo 10.96.150.245 <a-public-ip> 8888:30712/TCP http://slatenotebook.slate-dev.slateci.net/

The URL can be found under Services, which in our example is *http://slatenotebook.slate-dev.slateci.net*.

##### Condor Hello World Test Job
If you have deployed the application with the condor submit environment enabled, and would like to submit a test job to confirm things are working, you can put the following into a file 'job.sub':

	Executable   = /bin/echo
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

A successful run will genearate a job.out file that has the text "Hello World" inside.

##### SSH Access Test
If you have deployed an instance of the application with SSH enabled, you should be able to ssh into it using the username you chose in the application configuration file. To get the IP address and port number for SSH, run the below command:
	
	$ slate instance info <instance-ID>
	
The output will list the SSH IP address and port under Services>URL and it would look like this:

	Services:
	Name                               Cluster IP    External IP   Ports          URL                                     
	slate-dev-jupyter-notebook-alidemo 10.96.150.245 <a-public-ip> 22:30033/TCP   <ip-address>:<port-number>

Multiple ports will often be listed; the one you want for SSH is the one which maps to the internal port 22. 

Now, ssh into your deployed instance using the username you've chosen in your application configuration file:

	ssh -p <port-number> <your-username>@<ip-address>


