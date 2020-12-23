# PostgreSQL

A minimalist installation of the PostgreSQL database.


## Installation:

`slate app get-conf postgresql > postgresql.yaml`
`slate app install postgresql --group <group name> --cluster <cluster> --conf postgresql.yaml`


## Usage:

* Retrieve default configuration file. (see first command above)
* Modify configuration file.
* Install app with custom configuration onto a SLATE cluster. (see second command above)


## Configuration

The following table lists the configurable parameters of the Telegraf monitoring application and their default values.


|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`Instance`| Optional string to differentiate SLATE experiment instances |""|
|`SLATE.Cluster.DNSName`| DNS name of the cluster that database is running on |`utah-dev.slateci.net`|
