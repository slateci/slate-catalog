Z# Open Science Grid StashCache

This chart installs the [StashCache](https://opensciencegrid.org/docs/data/stashcache/overview/) cache component. 

StashCache is an [XRootD](http://www.xrootd.org)-based caching framework. Data is exported by an origin server, and can be requested by end users through cache servers, which fetch it from the origin server and then retain copies locally to more rapidly serve repeated requests. This can greatly decrease the latency for batch jobs to fetch shared input files as well as reducing bandwidth used at the origin when the jobs' requests can be served by a local cache. 

Users can request data from the caching system using the [stashcp](https://support.opensciencegrid.org/support/solutions/articles/12000002775-transferring-data-with-stashcach) client program, with [xrdcp](https://xrootd.slac.stanford.edu), or with any HTTP client (e.g. `curl` or `wget`). 

# Installation

Settings for the cache can be customized using the standard Helm values mechanisms. Please see the `values.yaml` file for details of the supported settings. It is strongly recommended that the site name should be changed to a suitably specific value. 

###Deployment
```console
$ slate app get-conf stashcache > stashcache.yaml
$ slate app install stashchache --group <group-name> --cluster <cluster-name> --conf stashcache.yaml
```

### Usage

Use the `slate instance info` command to determine where your application is running:

	$ slate instance info instance_ZSUmFYupWb0
	Name       Started                  Group  Cluster  ID                  
	stashcache 2020-May-12 22:32:18 UTC group1 minikube instance_ZSUmFYupWb0

	Services:
	Name             Cluster IP     External IP    Ports          URL            
	stashcache-http  10.101.135.122 192.168.99.141 8000:32755/TCP 192.168.99.141:32389
	stashcache-xroot 10.101.135.122 192.168.99.141 1094:31128/TCP 192.168.99.141:32193
	
You should see two service entries, one for the http protocol, with internal port 8000, and one for the xroot protocol, whose internal port is 1094. The corresponding external ports must be used when communicating with the service, e.g. 32755 for the http protocol in the output above. 

To test HTTP transfers, you can request a test file through the cache using `curl` as follows:

	curl http://[external IP]:[external http port]/osgconnect/public/rynge/test.data

where `[external IP]` is the external address assigned to your service and `[external http port]` is the external port exposed by your service for http. If this is successful, the output should look something like:

	*   Trying 192.168.99.141...
	* TCP_NODELAY set
	* Connected to 192.168.99.141 (192.168.99.141) port 32287 (#0)
	> GET /osgconnect/public/rynge/test.data HTTP/1.1
	> Host: 192.168.99.141:32287
	> User-Agent: curl/7.54.0
	> Accept: */*
	> 
	< HTTP/1.1 200 OK
	< Connection: Keep-Alive
	< Content-Length: 13
	< 
	hello world!
	* Connection #0 to host 192.168.99.141 left intact

If you have the `xrdcp` tool you can also test transfers with the xroot protocol:

	xrdcp root://[external IP]:[external xrootd port]//osgconnect/public/rynge/test.data -

where `[external address]` is as for the HHTP example, and `[external xrootd port]` is the external port exposed by your service for xrootd. Successful output should look something like:

	hello world!
	[13B/13B][100%][==================================================][1B/s]

### Configuration Options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| Instance | A label for your application instance | "" |
| hostCertSecret | The name of a SLATE secret which contains a certificate this server should use to secure its communications | null |
| StashCache.CacheDirectory | A host directory which Stashcache should mount and use to write cached data. If unset, an ephemeral volume will be used. | null |
| StashCache.HighWaterMark | The maximum fraction of available cache storage which should be filled before the cache startes to delete the oldest data. | 0.95 |
| StashCache.LowWaterMark | The minimum fraction of available cache storage which should be sought when deleting old data. | 0.80 |
| StashCache.RamSize | The amount of RAM the cache is allowed to use. | 1g |
| StashCache.BlockSize | The minimum block size the cache will fetch and store. | 1M |
| StashCache.Prefecth | Whether the cache should attempt to prefetch blocks beyond what clients have explicitly requested. | 0 |
| StashCache.authfileNoAuth | Contents of the 'authorization database' file XRootD should use to determine the authorization of unauthenticated requests.| "u * / rl" |
| StashCache.authfileNoAuth | Contents of the 'authorization database' file XRootD should use to determine the authorization of authenticated requests.| "u * / rl" |
| StashCache.stashcacheRobots | Contents of the robots.txt file XRootD should serve. |  |
| Site.Name | A name that this server should use when reporting monitoring data. | null |

### In-depth Configuration
For more information on using StashCache please see the  [documentation](https://opensciencegrid.org/docs/data/stashcache/overview/). 
