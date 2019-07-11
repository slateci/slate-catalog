# perfSONAR Testpoint

Runs a perfSONAR Testpoint on your SLATE cluster. This provides a collection of open source software for performing and sharing end-to-end network measurements. This bundle includes everything from the perfsonar-tools bundle as well as the software required to:

            Automatically run tests on a regular schedule
            Participate in a centrally managed set of tests
            Publish the existence of a measurement node

## Installation

You must have a cluster node dedicated for running perfSONAR, this node needs to have the node label `perfsonar: true`.

You can manually label your node using this command:

`kubectl label nodes <node-name> perfsonar=true`

Additionally you must run the NTPD service on the perfSONAR node. You can start this by running:

`systemctl start ntpd`

Then simply install the application.

`slate app install perfsonar-testpoint --cluster <cluster name> --group <group name>`

## Usage and Documentation

This is the full user guide for the application.

http://docs.perfsonar.net/index.html#running-measurements-with-pscheduler

How to use pscheduler to run tasks

http://docs.perfsonar.net/pscheduler_client_tasks.html

Additional tools reference

http://docs.perfsonar.net/pscheduler_ref_tests_tools.html

