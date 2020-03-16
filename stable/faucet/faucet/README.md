# Faucet SDN Controller

This chart contains a basic installation of Faucet packaged for SLATE. Facuet is an OpenFlow Controller designed to work with compliant switches. It needs to be configured with a set of OpenFlow rules that define the functions of the network, and these rules can be dynamically pushed on the controller, allowing the changes to automatically propagate to configred OpenFlow switches. This gives the user a granular level of control over their network.
# Installation

Faucet should be installed as a SLATE application. First you will need to describe the desired configuration of your network in faucet.yaml. 

Instructions for writing the faucet.yaml configuration can be found here.

https://docs.faucet.nz/en/latest/configuration.html

Once you have a configuration prepared you can use the SLATE client to set up your faucet instance as a SLATE app.

First fetch the configuration file.

`slate app get-conf faucet -o conf`

Next edit your configuration with your favorite text editor.

`vim conf`

You should specify an instance name, and replace faucet.yaml with your configuration at the end. Currently, the default faucet.yaml is based on the tutorial example found in the faucet documentation. You should replace the entire thing.

```
# Default values for faucet.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

# Instance name within SLATE
Instance: global

# Configuration data for faucet this is faucet.yaml
Configuration: |-
  # REPLACE WITH YOUR FAUCET.YAML
```

Now that you have your configuration the way you want it, you can set up your instance on a SLATE cluster. You will need to know the cluster name and group name you wish to deploy with.

`slate app install faucet --group <YOUR GROUP> --cluster <YOUR CLUSTER> --conf conf`

If the command executed properly, your faucet instance is now running!

# Usage

### Connecting an OpenFlow Switch

Now you will need the IP and NodePort for your faucet instance. You can use these to connect your switch. 

First get the instance ID of your faucet instance.

`slate instance list --cluster <YOUR CLUSTER> --group <YOUR GROUP>`

You should see some output like this:

```
Name                      Group     ID
condor-ce-default         slate-dev instance_nnqnaMF8e_Q
condor-ce-tenthirty       slate-dev instance_-npk7aLxiwc
gridftp-global            slate-dev instance_fUhW9buzFHM
osg-frontier-squid-cvmfs  slate-dev instance_js3-usm2paY
osg-frontier-squid-global slate-dev instance_vTb5dO1fuZA
```

You want to grab the instance ID which looks like `instance_nnqnaMF8e_Q`. Once you have the instance ID you can get the instance info including IP address and NodePort.

`slate instance info <YOUR INSTANCE ID>`

You should be able to simply point your switch at `NodeIP:NodePort`. The exact way this is done varies from switch to switch, but as an example in Open Virtual Switch you would feed it the command `ovs-vsctl set-controller <bridge name> tcp:NodeIP:NodePort` and your Faucet controller would begin giving instructions to the given OVS Switch.

### Configuration and Use

For configuration of Faucet visit

https://docs.faucet.nz/en/latest/configuration.html

Additional tutorials can be found at

https://docs.faucet.nz/en/latest/tutorials/index.html

Faucet is designed to work with a specific set of switches that can be found at

https://docs.faucet.nz/en/latest/vendors/index.html
