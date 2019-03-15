# Open Science Grid StashCache

This chart installs the [StashCache](https://opensciencegrid.org/docs/data/stashcache/overview/) cache component. 

## Application

StashCache is an [XRootD](http://www.xrootd.org)-based caching framework. Data is exported by an origin server, and can be requested by end users through cache servers, which fetch it from the origin server and then retain copies locally to more rapidly serve repeated requests. This can greatly decrease the latency for batch jobs to fetch shared input files as well as reducing bandwidth used at the origin when the jobs' requests can be served by a local cache. 

Users can request data from the caching system using the [stashcp](https://support.opensciencegrid.org/support/solutions/articles/12000002775-transferring-data-with-stashcach) client program. 

## Deployment

Settings for the cache can be customized using the standard Helm values mechanisms. Please see the `values.yaml` file for details of the supported settings. It is strongly recommended that the site name should be changed to a suitably specific value. 