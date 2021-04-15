# Open OnDemand

Application Name (in catalog): `open-ondemand`

Application Version: `0.6.0`


## Description

This application launches an instance of the [Open OnDemand](https://openondemand.org) web portal, as well as [Keycloak](https://www.keycloak.org) for user management.


## Installation

To install, first retrieve and locally store the default configuration file with this command: 

```bash
slate app get-conf open-ondemand > ood.yaml
```

Next, modify the configuration file with your preferred editor to configure the application for your site.
A guide to this can be found [here](https://slateci.io/blog/slate-open-ondemand.html).

Then, install the app with your configuration onto a SLATE cluster.
Use a command that looks something like this: 

```bash
slate app install open-ondemand --group <group_name> --cluster <cluster> --conf ood.yaml
```


## System Requirements

No special compute resources are required for this application.


## Network Requirements

This application serves two secure HTTPS web portals (port 443).
It does not require its own IP, but it does require that the SLATE ingress controller be installed.


## Storage Requirements

Open OnDemand on SLATE requires one volume to persist authentication data.
The storage class of this volume must be declared in the `values.yaml` file, under `volume.storageClass`.
Thus, the SLATE cluster Open OnDemand is installed on must also support volumes of this storage class.
Supported storage classes on a cluster can be viewed by running `slate cluster info <cluster_name>`.
Volume size is also configured through the `values.yaml`, under `volume.size`.


## Statefulness

This application operates two containers in one pod that are dependent on each other.
The main OnDemand container serves the Open OnDemand portal, and connects to a Keycloak container for identity and authentication management.
This Keycloak container has state, as it stores its data on a persistent volume.


## Privilege Requirements

This application obtains certificates from Let's Encrypt, using Kubernetes `cert-manager`.
Thus, `cert-manager` must be installed and configured on the cluster that Open OnDemand is running on.


## Monitoring and Logging

There are no special monitoring considerations.


## Multiple Versions

It is not necessary to support multiple versions.


## Testing

More information about testing can be found in [this post](https://slateci.io/blog/slate-open-ondemand.html).


## Configurable Parameters

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

