# perfSONAR Checker

Runs perfSONAR tests from your SLATE cluster to central SLATE infrastructure servers. This will give you end-to-end network measurements to verify the network status and performance at the SLATE node you deploy this Checker to. 

# Installation

For all tests to run correctly, you must have proper NTP configuration on the target node that would host this perfSONAR Checker instance. This can be done by either running ntpd or chronyd on the host. For example, you can start the ntpd service by running:

`systemctl start ntpd`

Next, download the values configuration file as shown below:

`slate app get-conf --dev -o conf perfsonar-checker`

Edit that file as needed. For example, if you have a cluster node dedicated for running perfSONAR, you can specify it in the configuration file like:

```
# Default values for perfsonar-checker.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

Instance: ''

NodeSelection:  
  Hostname: workernode3.slateci.io
```
where `workernode3.slateci.io` is the node's DNS name, in this case.

###### Note: Please note that the node on which your instance will run must have no other perfSONAR instances running on it because perfSONAR uses host network mode. Running multiple perfSONAR applications on the same node will lead to unexpected app behavior.

If you would like to be able to see the full details of all the tests the Checker runs, you can enable the HTTPLogger in the configuration file like:

```
HTTPLogger: 
  Enabled: True
```
Then simply install the app.

`slate app install --dev perfsonar-checker --cluster <cluster name> --group <group name> --conf conf`

# Results
The tests run to three different destination servers so it could take some time, probably around 15-20 minutes, for all tests to finish. Each test will log its results to a log file when they're ready.

To see the summary results, you can run the the below command:

```
slate instance logs --max-lines 0 <instance-ID>
```

### HTTPLogger
If you enabled the HTTPLogger, then you can view the full results through a web browser. To do that, run the below command to get the URL address:

```
slate instance info <instance-ID>
```
and look for the URL address under the `Services` section

```
Services:
Name              Cluster IP   External IP   Ports          URL                
perfsonar-checker 10.233.29.42 155.XX..YY.ZZ 8080:30503/TCP 155.XX.YY.ZZ:30503

```

Then you would need to retrieve the username and randomly-generated password from the instance log which would look like:

```
Your randomly generated logger credentials are
**********************************************
username:080lo947nclu1vs6506
**********************************************
```
Once you have that, you can navigate to the URL from a web browser, use your credentials to log in, and view the content of the `checker.log` file.

# Configuration and usage 

This is the full user guide for perfSONAR:

http://docs.perfsonar.net/index.html#running-measurements-with-pscheduler

Additional tools reference:

http://docs.perfsonar.net/pscheduler_ref_tests_tools.html

