# OSG Frontier Squid 

Frontier Squid is an HTTP cache, providing *quick access to recently downloaded data*.

The best use of this cache is to *use it as an HTTP Proxy*. You can set this within your local environment using `export http_proxy=http://[IP Address]:[Port Number]`, within your computer's global internet settings, or within an application that will utilize the cache.

By default, Frontier Squid stores logs of activity within the container's `/var/log/squid/access.log` file, and logs of its status and startup information within the container's `/var/log/squid/cache.log` file.

---
# Installation
```console
$ slate app get-conf osg-frontier-squid > squid.yaml
$ slate app install osg-frontier-squid --group <group-name> --cluster <cluster-name> --conf squid.yaml
```
---
# Configuration and usage
### Configuration options
| Parameter                       | Description                                   | Default                                                 |
|---------------------------------|-----------------------------------------------|---------------------------------------------------------|
| Port | Default port that the squid service will listen on | `3128` |
| ExternalVisibility | Controls whether or not Squid should be visible outside of the Kubernetes cluster | `NodePort` |
| NodePort | The NodePort that Kubernetes would open, if available, for the squid service external visibility | Not set which makes Kubernetes choose a random port from its NodePort range |
| MonitoringPort | The port the service will use for serving monitoring data | `3401` |
| MonitoringNodePort | The NodePort that Kubernetes would open, if available, for the squid monitoring data service | Not set which makes Kubernetes choose a random port from its NodePort range|
| CPU | The amount of CPU resources that Squid may use.  | `2` |
| CacheMem | The amount of memory that Squid may use for caching hot objects | `4096 MB` |
| MaximumObjectSizeInMemory | The maximum size in KB for individual objects stored in memory| `512 KB` |
| CacheSize | The amount of disk space that Squid may use for caching cold objects | `10000 MB` |
| CacheDirOnHost | If True, the application will expect a hostPath directory to be present and writeable on the host | `/var/cache/squid` |
| RequestEphemeralSize | The amount of disk space (in MiB ) that the Squid is requesting beyond CacheSize. The CacheSize is added to the request only when `CacheDirOnHost` is false.  | `7000 MiB` |
| LimitEphemeralSize | The maximum amount of disk space (in MiB ) that Squid may use beyond CacheSize The CacheSize is added to the limit only when `CacheDirOnHost` is false.| `12000 MiB` |
| IPRange | A space separated list of source address CIDRs that can access the cache. **NOTE** Incorrectly specifying this may lead to open proxies on your network! | `10.0.0.0/8 172.16.0.0/12 192.168.0.0/16` |
| RESTRICT_DEST | A regular expression to restrict outbound traffic | `null` |
| MonitoringIPRange | The range of IP addresses that will be allowed to query the service's monitoring data | `127.0.0.1/32` |
| LogToStdout | Writes all access_log messages to standard output where they can be viewed with the SLATE log mechanism | `True` |
| DisableLogging | Disables Squid logging | `False` |
| CleanLog | Truncates the Squid log file every 2 minutes | `False` |
| Workers | The number of cache processes to run concurrently | Not set which defaults to one worker\process |
| Cpu_Affinity_Map | Pins cache processes to CPU cores | Not set |
| Logfile_Rotate | Configures the number of names to use when rotating logfiles | `30` |
| MaxAccessLog | Sets the max size for the access log file | `20M` |
| UseHostpathLogDir | Allows the Squid to use local hostPath log directory at "/var/log/slate/hostPath/osg-frontier-squid" when the below `NodeSelection.Hostname` parameter is set| `Fasle` |
| NodeSelection.Hostname |FQDN for the cluster node you want this instance to schedule on | `null` |
| NodeSelection.OpenDefaultMonPort | Exposes default monitoring port(3401) on the host selected by `NodeSelection.Hostname` | `False` |
| NodeSelection.OpenDefaultSquidPort | Exposes default squid port(3128) on the host selected by `NodeSelection.Hostname` | `False` |
| Pod.UseHostTimezone | Allows the Squid appliction to use the host's timezone instead of UTC | `False` |

### Usage
For more instructions on how to use OSG Frontier Squid please read this [documentation](https://opensciencegrid.org/docs/data/frontier-squid/)
