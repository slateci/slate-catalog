# PostgreSQL

A minimalist installation of the PostgreSQL database.


## Installation:

`slate app get-conf postgresql > postgresql.yaml`

`slate volume create --group <group_name> --cluster <cluster> --size <volume_size> --storageClass <storage_class> volume-name

`slate app install postgresql --group <group name> --cluster <cluster> --conf postgresql.yaml`


## Usage:

* Retrieve default configuration file. (see first command above)
* Create a SLATE volume to store data on. (see second command above)
* Modify configuration file to ensure appropriate setup.
	* Set the `claimName` value to the name of the previously created SLATE volume.
	* Set the `SLATE.Cluster.DNSName` value to the DNS name of the cluster the application is being installed on
* Install app with custom configuration onto a SLATE cluster. (see third command above)


## Configuration

The following table lists the configurable parameters of the Telegraf monitoring application and their default values.


|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`Instance`| Optional string to differentiate SLATE experiment instances |""|
|`claimName`| The name of the SLATE volume to store data on. |`postgres-db`|
|`adminPassword`| The database administrator password. |`admin`|
|`SLATE.Cluster.DNSName`| DNS name of the cluster that database is running on |`utah-dev.slateci.net`|
