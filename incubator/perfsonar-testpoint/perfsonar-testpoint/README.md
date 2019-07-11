# perfSONAR Testpoint

Runs a perfSONAR Testpoint on your SLATE cluster. This provides a collection of open source software for performing and sharing end-to-end network measurements. This bundle includes everything from the perfsonar-tools bundle as well as the software required to:

            Automatically run tests on a regular schedule
            Participate in a centrally managed set of tests
            Publish the existence of a measurement node

## Installation

You must have a cluster node dedicated for running perfSONAR, this node needs to have the node label `perfsonar: true`.

You can manually label your node using this command:

`kubectl label nodes <node-name> perfsonar=true`

