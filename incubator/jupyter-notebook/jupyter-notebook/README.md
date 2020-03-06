# Jupyter Notebook - Scientific Python Stack

This initial release of this chart only configures a simple Jupyter notebook that you can deploy on SLATE platform for testing and evaluation purposes.

# Installation

### 
To deploy this chart, you would need to create a secret to store a username and password you'd choose to access the notebook. The secret can be created by following the below steps:

	htpasswd -c auth <username>
	
And once you choose a password, a file containing the &lt;username&gt; and password hash will be generated and named "auth".
Now you can create a secret using a command in this format: 
	
	slate secret create --group <group> --cluster <cluster> --from-file=auth <secret-name>

# Deploying
To deploy the chart after creating a secret for the app, you can run the below command to get a configuration file:  

	slate app get-conf --dev jupyter-notebook > jnb.yaml
	
Make the nessesary changes to the file and include the &lt;secret-name&gt; you created above. The last step is creating an instance of the app using the SLATE command as shown below: 

	slate app install jupyter-notebook --group <group> --cluster <cluster> --conf jnb.yaml
	
Once SLATE creates the requested resources needed for your Jupyter Notebook instance, you should be able to access it via a Web browser at a URL in this format: &lt;sub-domain&gt;.&lt;DNS-Name-of-the-Cluster&gt;, as per the values used in the configuration file. You can also view the URL of the deployed application by running the below command and passing to it the generated instance ID from the previous step.

	slate instance info <instance-ID>
