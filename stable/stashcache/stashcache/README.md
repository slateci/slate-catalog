# Open Science Grid StashCache

This chart installs the [StashCache](https://opensciencegrid.org/docs/data/stashcache/overview/) cache component. 

StashCache is an [XRootD](http://www.xrootd.org)-based caching framework. Data is exported by an origin server, and can be requested by end users through cache servers, which fetch it from the origin server and then retain copies locally to more rapidly serve repeated requests. This can greatly decrease the latency for batch jobs to fetch shared input files as well as reducing bandwidth used at the origin when the jobs' requests can be served by a local cache. 

Users can request data from the caching system using the [stashcp](https://support.opensciencegrid.org/support/solutions/articles/12000002775-transferring-data-with-stashcach) client program. 

# Installation

Settings for the cache can be customized using the standard Helm values mechanisms. Please see the `values.yaml` file for details of the supported settings. It is strongly recommended that the site name should be changed to a suitably specific value. 

###Deployment
```console
$ slate app get-conf stashcache > stashcache.yaml
$ slate app install stashchache --group <group-name> --cluster <cluster-name> stashcache.yaml
```

#Configuration and usage
For more information on using StaschCache please see this [documentation](https://opensciencegrid.org/docs/data/stashcache/overview/)
