# Open OnDemand

Sets up an instance of Open OnDemand.
Authentication is handled through Keycloak.
This application additionally requires a SLATE volume to persist authentication data/configuration.

## Installation:

`slate app get-conf open-ondemand > ood.yaml`

`slate app install open-ondemand --group <group_name> --cluster <cluster> --conf ood.yaml`


## Usage:

* Retrieve default configuration file. (see first command above)
* Modify configuration file to ensure appropriate setup.
	* Set `volume.storageClass` to a value that is supported by your cluster.
	* List backend cluster names and host names.
* Install app with custom configuration onto a SLATE cluster. (see last command above)


## Configuration

The following table lists the configurable parameters of the Open OnDemand application and their default values.

|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`Instance`| Optional string to differentiate SLATE experiment instances. |`global`|
|`replicaCount`| The number of replicas to create. |`1`|
|`setupKeycloak`| Runs Keycloak setup script if enabled. |`true`|
|`volume.storageClass`| The volume provisioner from which to request the Keycloak backing volume |`local-path`| 
|`volume.size`| The amount of storage to request for the volume |`50M`| 
|`setupLDAP`| Set up LDAP automatically based on following values. |`true`| 
|`ldap.connectionURL`| URL to access LDAP at. |`ldap://your-ldap-here`| 
|`ldap.importUsers`| Import LDAP users to Keycloak. |`true`| 
|`ldap.rdnLDAPAttribute`| LDAP configuration |`uid`| 
|`ldap.uuidLDAPAttribute`| LDAP configuration |`uidNumber`| 
|`ldap.userObjectClasses`| LDAP configuration |`inetOrgPerson, organizationalPerson`| 
|`ldap.usersDN`| LDAP configuration |`ou=People,dc=chpc,dc=utah,dc=edu`| 
|`kerberos.realm`| Kerberos realm to connect to. |`AD.UTAH.EDU`| 
|`kerberos.serverPrincipal`| Kerberos server principal |`HTTP/utah-dev.chpc.utah.edu@AD.UTAH.EDU`| 
|`kerberos.keyTab`| Kerberos configuration |`/etc/krb5.keytab`| 
|`kerberos.kerberosPasswordAuth`| Use Kerberos for password authentication. |`true`| 
|`kerberos.debug`| Writes additional debug logs if enabled. |`true`| 
|`clusters.cluster.name`| Name of cluster to connect to. |`Kingspeak`| 
|`clusters.cluster.host`| Hostname of cluster to connect to. |`kingspeak.chpc.utah.edu`| 
|`testUsers.user.name`| Username of test user to add. |`test`| 
|`testUsers.user.tempPassword`| Temporary password to set for test user. |`test`| 

