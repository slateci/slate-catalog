# Telegraf SNMP Monitoring

Application Name (in catalog): `telegraf`

Application Version: `0.5.0`


## Description

This application uses Telegraf to pull [SNMP](http://www.net-snmp.org/) metrics from user-specifiable hosts.
Metrics are then pushed to a time-series database. This database endpoint can also be configured by the user.
Beyond general SNMP configuration options, this application also contains features to easily report a standard set of metrics to Indiana University's Global Research Network Operations Center ([GlobalNOC, or GRNOC](https://globalnoc.iu.edu/)).


## Installation

This application is quite simple to install. First, retrieve and locally store the default configuration file with this command: 

```bash
slate app get-conf telegraf > telegraf.yaml
```

Next, modify the configuration file with your preferred editor to ensure appropriate configuration. A guide to this can be found [here](https://slateci.io/blog/telegraf-monitoring.html).

Then, if you are writing to GlobalNOC's database, create a SLATE secret containing your database password.
This is done with the following command:
```bash
slate secret create --group <slate_group> --cluster <slate_cluster> --from-literal password=<your_password> <secret_name>
```

Finally, install the app with your custom configuration onto a SLATE cluster.
Use a command that looks something like this: 

```bash
slate app install telegraf --group <group_name> --cluster <cluster> --conf telegraf.yaml
```

*Note that this application does not make sense to deploy without SNMP-enabled hosts to monitor, and a database endpoint to send metrics to.*


## System Requirements

No special compute resources are required for this application.


## Network Requirements

This application will utilize ports 161 and 162 for SNMP messages.
Additionally, a user-configurable database output port will be exposed.

This service does not require its own IP or a load balancer.


## Storage Requirements

Telegraf on SLATE requires no persistent storage.
However, most use cases will require a separate database to send metrics to.


## Statefulness

This application operates without any state, and is not dependent on any other services within SLATE.


## Privilege Requirements

No special privilege requirements are necessary.


## Monitoring and Logging

There are no special monitoring considerations.


## Multiple Versions

It is not necessary to support multiple versions.


## Testing

No testing package is included.
However, [this post](https://slateci.io/blog/telegraf-monitoring.html) contains more information about ways to test the Telegraf application.


## Configurable Parameters

The following table lists the configurable parameters of the Telegraf monitoring application and their default values.

|           Parameter           |           Description           |           Default           |
|-------------------------------|---------------------------------|-----------------------------|
|`Instance`| Optional string to differentiate SLATE experiment instances |`""`|
|`writeToStdout`| Optionally write to stdout in container |`true`|
|`collectionInterval`| Data collection interval |`5s`|
|`collectionJitter`| Data jitter interval |`10s`|
|`flushInterval`| Output flush interval |`15s`|
|`flushJitter`| Output jitter interval |`10s`|
|`grnocOutput.enabled`| Whether to write to GlobalNOC database |`true`|
|`grnocOutput.hostname`| Database endpoint |`tsds.hostname.net`|
|`grnocOutput.username`| Database username |`tsds username`|
|`grnocOutput.passwordSecretName`| GlobalNOC database password secret name |`tsds-password-secret`|
|`targets.hostGroup.community`| Community string of `hostGroup` |`public`|
|`targets.hostGroup.timeout`| SNMP timeout length of `hostGroup` |`15s`|
|`targets.hostGroup.retries`| Number of retries to attempt for `hostGroup` |`2`|
|`targets.hostGroup.hosts`| Hosts to monitor |`127.0.0.1:161`|
|`targets.hostGroup.counter64bit`| Type of SNMP counter on host machine |`false`|
|`targets.hostGroup.oids`| SNMP OIDs to poll |*telegraf configuration monitoring system uptime*|
|`influxOutput.enabled`| Whether to write to InfluxDB |`true`|
|`influxOutput.endpoint`| Database endpoint |`http://127.0.0.1:9999`|
|`influxOutput.database`| Database name |`telegraf`|
|`influxOutput.httpBasicAuth.enabled`| Whether http basic authentication is enabled |`false`|
|`influxOutput.httpBasicAuth.username`| Database username |`telegraf`|
|`influxOutput.httpBasicAuth.password`| Database password |`metrics`|

