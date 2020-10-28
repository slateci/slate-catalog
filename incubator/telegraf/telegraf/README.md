# Telegraf Monitoring with Prometheus

Uses Telegraf to pull SNMP metrics from various hosts.
Pushes metrics to a user-specifiable TS-DB.


## Installation: 

`slate app get-conf telegraf > telegraf.yaml`

`slate app install telegraf --group <group_name> --cluster <cluster> --conf telegraf.yaml`


## Configuration and Usage:

* Retrieve default configuration file. (see first command above)
* Modify configuration file to ensure appropriate metrics are scraped.
* Modify configuration to send to proper database endpoint.
* Install app with custom configuration onto a SLATE cluster. (see second command above)
