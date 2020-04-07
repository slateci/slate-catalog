# Jupyter Notebook - Scientific Python Stack

This initial release of this chart configures a simple Jupyter notebook and condor that you can deploy on SLATE platform and use to submit condor jobs for testing and evaluation purposes.

# Deploying

### 
To deploy this chart, you would need to create a token that will be used to authenticate to the notebook instance. Alternatively, if you have a Jupyter Notebook password hash you'd like to use, you can just add it later to the config file of this chart. To generate a random token, you can use one of the below commands from any Linux system:

	openssl rand -base64 32
	
or

	uuidgen

You will also need to add to the config file the following HTCondor information: collector host IP address, collector host port number, and submit-authentication-secret. The secret can be created from the submit token by pasting the token into a text file and adding one trailing newline character (\n). Then, use the slate command as follows:

	$ slate secret create submit-auth-token --group <some group> --cluster <a cluster> --from-file condor_token=submit-token
	Successfully created secret submit-auth-token with ID secret_dHiGnjAgR2A
 

To deploy the chart after creating a token for the notebook, you can run the below command to get a configuration file:  

	slate app get-conf --dev jupyter-notebook > jnb.yaml
	
Make the nessesary changes to the file and include the &lt;token&gt; and &lt;secret-name&gt; you created above and the condor access information. You can also, include a custom username and a puplic ssh key that you can use later to ssh into the pod. The last step is creating an instance of the app using the SLATE command as shown below: 

	slate app install jupyter-notebook --group <group> --cluster <cluster> --conf jnb.yaml
	
Once SLATE creates the requested resources needed for your Jupyter Notebook instance, you should be able to access it via a Web browser at a URL in this format: &lt;sub-domain&gt;.&lt;DNS-Name-of-the-Cluster&gt;, as per the values used in the configuration file. You can also view the URL of the deployed application by running the below command and passing to it the generated instance ID from the previous step.

	slate instance info <instance-ID>

The above command will also give you the IP address and port number needed for accessing the pod over ssh.

For information on how to submit a test job using condor_submit, please see our condor-manager chart at: 
https://github.com/slateci/slate-catalog/tree/master/incubator/condor-manager/condor-manager
