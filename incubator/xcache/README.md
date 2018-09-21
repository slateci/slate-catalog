# XCache

## Introduction
XCache is a service that provides caching of data accessed using [xrootd protocol](http://xrootd.org/). It sits in between client and an upstream xrootd servers and can cache/prefetch full files or only blocks already requested. 

To run this chart one needs a k8s cluster with a node labeled: __xcache-capable: "true"__. This node will have at least 10Gbps connection and at least few TB local disk (preferably mounted at __/scratch__).

To set it up one needs to change values in values.yaml, all other variables have good default values:

```
SiteConfig:
  Name: MWT2

XCacheConfig:
  CacheDirectory: /scratch

Service:
  # External IP that may access the service
  ExternalIP: 192.170.227.151
```
  
XCache nodes should be tainted:
```
kubectl taint nodes "xcache nodename" special=true:PreferNoSchedule
```
and labeled:
```
kubectl label nodes <your-node-name> xcache-capable=true
```

## Prerequisites

- PV provisioner support in the underlying infrastructure

## Installing the Chart

To install the chart with the release name `test-release`:

```bash
$ helm install --name test-release xcache
```

The command deploys xcache on the Kubernetes cluster in the default configuration. 

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `test-release` deployment:

```bash
$ helm delete test-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.