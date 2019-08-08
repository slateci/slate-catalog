# OSG Hosted Compute Element

This chart will install a Open Science Grid Hosted Compute Element (or HostedCE
for short) on a target cluster.  The HostedCE is a job gateway that allows the
OSG meta-scheduler to send pilot jobs to a target cluster via SSH. This
software enables a campus computing center to provide compute cycles (such as
extra cycles that would otherwise go wasted) to the Open Science Grid without
installing additional software at their site.

---
# Configuration
All of the following sections will need to be configured appropriately in your
HostedCE application. To download the configuration for this application:

```
slate app get-conf osg-hosted-ce > osg-hosted-ce.yaml
```

## Site
The Site section needs to have information that will correspond with what will
be registered in the OSG Topology site. For more information on topology please
visit here:
https://opensciencegrid.org/docs/common/registration/#registering-resources

## Cluster
The cluster section contains configuration parameters for BOSCO, specifically
the SSH configuration, whose private key must be stored as a SLATE secret and
selection of the remote batch system.

## Storage
This section contains a `GridDir` parameter, which describes the location on
the *remote* site where BLAHP/Glite binaries can be placed.  This section
additionally requires that the application administrator configure the
`WorkerNodeTemp` directory, which will be seen by jobs under the environment
variable `$OSG_WN_TEMP` for scratch space.

## Subcluster
This section defines the attributes of the remote cluster, including the
number of nodes, amount of memory per node, CPUs per node, etc. This also
configures VOs allowed to submit to the remote resource.

## Squid
This section informs the HostedCE of the Squid proxy cache closest to the
*remote* side, for job access.

---
# Usage
Once you have configured the HostedCE, you can install it in the following way:

```
slate app install osg-hosted-ce --conf osg-hosted-ce.yaml --cluster <your cluster> --group <your group> 
```

After registration, you'll need to send a mail to
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

# Table of Configuration Parameters
