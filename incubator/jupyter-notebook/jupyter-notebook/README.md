# Jupyter Notebook - Scientific Python Stack

This initial release of this chart only configures a simple Jupyter notebook that you can deploy on SLATE platform for testing and evaluation purposes.

# Installation

### Dependancy note:
To deploy this chart, you would need to create a secret to store the username and password you'd choose to access the notebook. The secret can be created by following the below steps:

	htpasswd -c <filename> <username>
	
And once you choose a password, a file containing the <username> and password hash will be generated and named <filename>.
Now you can create a secret using this command: 
	
	slate secret create <secret-name> --group <group> --cluster <cluster> --from-env-file creds

# Deploying
To deploy the chart after creating a secret for the app, you can just run the below command: 

	slate app get-conf --dev jupyter-notebook > jnb.yaml
	
Make the nessesary changes to the config file and include the name of the secret you created above. The last step is to creating an instance of the app using the SLATE command as shown below: 

	slate app install jupyter-notebook --group <group> --cluster <cluster> --conf jnb.yaml
