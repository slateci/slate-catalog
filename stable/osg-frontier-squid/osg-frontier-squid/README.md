# OSG Frontier Squid 

Frontier Squid is an HTTP cache, providing *quick access to recently downloaded data*.

The best use of this cache is to *use it as an HTTP Proxy*. You can set this within your local environment using `export http_proxy=http://[IP Address]:[Port Number]`, within your computer's global internet settings, or within an application that will utlize the cache.

Frontier Squid stores logs of activity within the container's `/var/log/squid/access.log` file, and logs of it's status and startup information within the container's `/var/log/squid/cache.log` file.

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
| CacheMem | The amount of memory that Squid may use for caching hot objects | `128 MB` |
| CacheSize | The amount of disk space that Squid may use for caching cold objects | `10000 MB` |
| IPRange | A space separated list of source address CIDRs that can access the cache. **NOTE** Incorrectly specifying this may lead to open proxies on your network! | `10.0.0.0/8 172.16.0.0/12 192.168.0.0/16` |  
| Hostname |FQDN for the cluster node you want this instance to schedule on | `null` |

&ast;```Hostname``` is nested under ```NodeSelection```:

```
NodeSelection:
  Hostname: null
```

### Usage
For more instructions on how to use OSG Frontier Squid please read this [documentation](https://opensciencegrid.org/docs/data/frontier-squid/)
