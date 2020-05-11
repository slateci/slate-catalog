# XRootD Data Server

This chart installs the [XRootD](http://xrootd.org/) data access service, configured as an origin server (rather than cache) mode. It supports the native xrootd protocol and plain http. 

# Installation

This SLATE application serves data from either an existing Kubernetes PersistentVolumeClaim or a directory mounted from the host node's filesystem (which might for example, be the mount point of a distributed filesystem). If using the latter, it may be necessary to coordinate with the administrators of the Kubernetes cluster to arrange for the node(s) which have the appropriate data/directory available to be marked with a label in Kubernetes to ensure that this application is scheduled on a node where it is present. 

The `Site.Name` value must be configured to a string which this server will use when reporting monitoring information. 

Details of XRootD itself can be configured with the settings in the `XRootD` section. `authfile` contains the access permissions; see the [authorization database documentation](https://xrootd.slac.stanford.edu/doc/dev49/sec_config.htm#_Toc517294132) for details of its syntax. The default value allows all users (including anonymous ones) to list and read all files within the directory being served (and its subdirectories, etc.). `ConfigFile` may be used to enter additional, arbitrary XRootD configuration that the server should use; see  the [configuration documentation](https://xrootd.slac.stanford.edu/doc/dev48/xrd_config.htm) for details. 

###Deployment
```console
$ slate app get-conf xrootd-server > xrootd.yaml
$ slate app install xrootd-server --group <group-name> --cluster <cluster-name> xrootd.yaml
```

## Configuration options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| Instance | A label for your application instance | "" |
| hostCertSecret | The name of a SLATE secret which contains a certificate this server should use to secure its communications | null |
| SystemConfig.HostDataDirectory | The path to a filesystem or portion thereof which the instance should mount as storage. Mutually exclusive with SystemConfig.PVCName | null |
| SystemConfig.PVCName | The name of an existing PersistentVolumeClaim which the instance should mount as storage. Mutually exclusive with SystemConfig.HostDataDirectory | null |
| SystemConfig.NodeSelector | An expression which should be used as a Kubernetes NodeSelector to restrict on which cluster nodes this instance may be scheduled. | null |
| XRootD.authfile | Contents of the 'authorization database' file XRootD should use to determine the authorization of all requests.| "u * / rl" |
| XRootD.gridmapSecret | Optional. The name of a secret containing a gridmap file XRootD should use to map users.| null |
| XRootD.vomsmapSecret | Optional. The name of a secret containing a vomsmap file XRootD should use to map users.| null |
| XRootD.ConfigFile | Optional. Contents of an additional configuration file which XRootD will read following all other configuration files.| null |
| Site.Name | A name that this server should use when reporting monitoring data. | null |
