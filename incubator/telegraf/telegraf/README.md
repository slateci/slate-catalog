# Telegraf Monitoring with Prometheus

Uses Telegraf to pull SNMP metrics from various hosts.
Pushes metrics to a user-specifiable TS-DB.


## Installation: 

`slate app get-conf telegraf > telegraf.yaml`

`slate app install telegraf --group <group_name> --cluster <cluster> --conf telegraf.yaml`


## Usage:

* Retrieve default configuration file. (see first command above)
* Modify configuration file to ensure appropriate metrics are scraped.
* Modify configuration to send to proper database endpoint.
* Install app with custom configuration onto a SLATE cluster. (see second command above)


## Configuration

The following table lists the configurable parameters of the Telegraf monitoring application and their default values.

|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`telegrafConfig.useCustomConfig`| Whether to use a custom configuration file. |`false`|
|`telegrafConfig.configPath`| Path to optional custom configuration file. |`files/telegraf.conf`|
|`targets.hostGroup.community`| Community string of `hostGroup` |`public`|
|`targets.hostGroup.hosts`| Target hosts list |`127.0.0.1:161`|
|`targets.hostGroup.oids`| SNMP OIDs to poll |*telegraf configuration monitoring system uptime*|
|`endpoint`| Database endpoint |`http://127.0.0.1:9999`|
|`database`| Database name |`telegraf`|
