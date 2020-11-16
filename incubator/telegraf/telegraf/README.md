# Telegraf SNMP Monitoring

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
* A more detailed tutorial on this application can be found [here](https://slateci.io/blog). 


## Configuration

The following table lists the configurable parameters of the Telegraf monitoring application and their default values.

|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`Instance`| Optional string to differentiate SLATE experiment instances |""|
|`writeToStdout`| Optionally write to stdout in container |`true`|
|`interval`| Data collection interval |`5s`|
|`flushInterval`| Output flush interval |`300s`|
|`grnocOutput.enabled`| Whether to write to GlobalNOC database |`true`|
|`grnocOutput.hostname`| Database endpoint |`tsds.hostname.net`|
|`grnocOutput.username`| Database username |`tsds username`|
|`grnocOutput.password`| Database password |`tsds password`|
|`targets.hostGroup.community`| Community string of `hostGroup` |`public`|
|`targets.hostGroup.hosts`| Hosts to monitor |`127.0.0.1:161`|
|`targets.hostGroup.counter64bit`| Type of SNMP counter on host machine |`false`|
|`targets.hostGroup.oids`| SNMP OIDs to poll |*telegraf configuration monitoring system uptime*|
|`influxOutput.enabled`| Whether to write to InfluxDB |`true`|
|`influxOutput.endpoint`| Database endpoint |`http://127.0.0.1:9999`|
|`influxOutput.database`| Database name |`telegraf`|
|`influxOutput.httpBasicAuth.enabled`| Whether http basic authentication is enabled |`false`|
|`influxOutput.httpBasicAuth.username`| Database username |`telegraf`|
|`influxOutput.httpBasicAuth.password`| Database password |`metrics`|
