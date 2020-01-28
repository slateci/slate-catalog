# OSG Hosted Compute Element

An OSG Compute Element (CE) is an application that allows a site to contribute HPC or HTC compute resources to the Open Science Grid. The CE is responsible for receiving jobs from the grid and routing them to your local cluster(s). Jobs from the Open Science Grid are preemptible, and can be configured to run only when resources would have otherwise been idle. Resource providers can use OSG to backfill their cluster(s) to efficiently utilize resources and contribute to the shared national cyberinfrastructure.

The simplest way to start contributing resources to the OSG, for many sites, is via the "Hosted" CE. In the hosted case, installation and setup of the Compute Element is done by the OSG team, usually on a machine outside of your cluster, and uses standard OpenSSH as a transport for submitting jobs to your resources. With SLATE, we have simplified Hosted CE installation and made a shared operations model possible. Now the Compute Element can be hosted on your Kubernetes infrastructure on-prem and cooperatively managed by OSG and your local team.

---
## Prerequisites
- You must have a functional Kubernetes cluster with SLATE ([Instructions]( https://slateci.io/docs/cluster/))

- You will need an external cluster with a functional batch system to connect with

- You must be able to add a user account and corresponding SSH key to the external cluster

- It is best to have a Squid Proxy for your CE to cache with. [You can deploy one through SLATE](https://portal.slateci.io/applications/osg-frontier-squid)

## Configuration

### Site
The Site section needs to have information that will correspond with what will
be registered in the OSG Topology site. For more information on topology please
visit here:
https://opensciencegrid.org/docs/common/registration/#registering-resources

### Cluster
The cluster section contains configuration parameters for BOSCO, specifically
the SSH configuration, whose private key must be stored as a SLATE secret and
selection of the remote batch system.

### Storage
This section contains a `GridDir` parameter, which describes the location on
the *remote* site where BLAHP/Glite binaries can be placed.  This section
additionally requires that the application administrator configure the
`WorkerNodeTemp` directory, which will be seen by jobs under the environment
variable `$OSG_WN_TEMP` for scratch space.

### Subcluster
This section defines the attributes of the remote cluster, including the
number of nodes, amount of memory per node, CPUs per node, etc. This also
configures VOs allowed to submit to the remote resource.

### Squid
This section informs the HostedCE of the Squid proxy cache closest to the
*remote* side, for job access.

---
## Installation
Once you have configured the HostedCE, you can install it in the following way:

```
slate app install osg-hosted-ce --conf osg-hosted-ce.yaml --cluster <your cluster> --group <your group> 
```

## Testing

## Registration with OSG

You'll need to send a mail to
`osg-gfactory-support@physics.ucsd.edu` with the following details regarding
your Hosted CE:
  - CE hostname
  - CE OS and Version
  - Details regarding: support for multicore, max wall time, max memory usage
  - GLIDEIN_Site (maps to ResourceGroup)
  - GLIDEIN_ResourceName (maps to Resource)
  - GLIDEIN_Supported_VOs (maps to AllowedVOs)

For more information please see here: https://opensciencegrid.org/docs/#verify-osg-software

---

## Table of Configuration Parameters
