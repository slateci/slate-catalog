# Open OnDemand

Sets up an instance of Open OnDemand.
Authentication is handled through Keycloak.

## Installation:

`slate app get-conf open-ondemand > ood.yaml`

`slate app install open-ondemand --group <group_name> --cluster <cluster> --conf ood.yaml`


## Usage:

* Retrieve default configuration file. (see first command above)
* Modify configuration file to ensure appropriate setup.
* Install app with custom configuration onto a SLATE cluster. (see second command above)


## Configuration

The following table lists the configurable parameters of the Open OnDemand application and their default       values.

|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`Instance`| Optional string to differentiate SLATE experiment instances. |""|
|`replicaCount`| The number of replicas to create. |`1`|
|`SLATE.Cluster.DNSName`| DNS name of the cluster the application is deployed on. |`utah-dev.slateci.net`|
