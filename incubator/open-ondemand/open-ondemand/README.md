# Open OnDemand

Sets up an instance of Open OnDemand.
Authentication is handled through Keycloak.
This application additionally requires a SLATE volume to persist authentication data/configuration.

## Installation:

`slate app get-conf open-ondemand > ood.yaml`

`slate volume create --group <group_name> --cluster <cluster> --size <volume_size> --storageClass <storage_class> volume-name

`slate app install open-ondemand --group <group_name> --cluster <cluster> --conf ood.yaml`


## Usage:

* Retrieve default configuration file. (see first command above)
* Create a SLATE volume to persist configuration. (see second command above)
* Modify configuration file to ensure appropriate setup.
	* Set the `SLATE.Cluster.DNSName` value to the DNS name of the cluster the application is being installed on
	* Set the `claimName` value to the name of the previously created SLATE volume.
* Install app with custom configuration onto a SLATE cluster. (see last command above)


## Configuration

The following table lists the configurable parameters of the Open OnDemand application and their default       values.

|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`Instance`| Optional string to differentiate SLATE experiment instances. |`global`|
|`replicaCount`| The number of replicas to create. |`1`|
|`setupKeycloak`| Runs Keycloak setup script if enabled. |`true`|
|`claimName`| The name of the SLATE volume to store configuration in. |`keycloak-db`| 
|`SLATE.Cluster.DNSName`| DNS name of the cluster the application is deployed on. |`utah-dev.slateci.net`|
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


## Configure Shell Application

To configure nodes for remote shell access, yaml files must be placed in the
`/etc/ood/config/clusters.d/` directory.
When configured correctly, any node where a user has SSH permissions can be
accessed through the Open OnDemand web portal.

v2:
  metadata:
    title: "node1"
    url: "https://www.chpc.utah.edu/documentation/guides/frisco-nodes.php"
    hidden: false
  login:
    host: "node1.example1.com"
  job:
    adapter: "linux_host"
    submit_host: "node1.example1.com"  # This is the head for a login round robin
    ssh_hosts: # These are the actual login nodes, need to have full host name for the regex to work
      - node1.example1.com
    site_timeout: 7200
    debug: true
---
