# XCache

**NOTE**: This SLATE application requires a X509 certificate to be	
installed on the target cluster in order to successfully deploy. Click [here](https://portal.slateci.io/secrets) to add a secret in the SLATE portal.	

*Image source*: https://github.com/slateci/XCache	

## Usage	
```console	
$ slate app get-conf xcache > xcache.yaml	
$ slate app install --group <group-name> --cluster <cluster-name> xcache.yaml	
```	

## Introduction
XCache is a service that provides caching of data accessed using [xrootd protocol](http://xrootd.org/). It sits in between client and an upstream xrootd servers and can cache/prefetch full files or only blocks already requested. 

To run this chart one needs a k8s cluster with a node labeled: __xcache: "<Instance>"__. Instance is the same value as in values.yaml file. This node will have at least 10Gbps connection and at least few TB local disk (preferably mounted at __/scratch__).

To set it up one needs to change values in values.yaml, all other variables have good default values:

```
Instance: <Instance> # change only if you have more than one XCache server. 
SiteConfig:
  Name: MWT2
  CRICprotocolID: 433

XCacheConfig:
  CacheDirectories:
    - path: /scratch/1
    - path: /scratch/2
  MetaDirectory: /scratch/meta

Service:
  # External IP that may access the service
  ExternalIP: 192.170.227.151
```
  
XCache nodes should be tainted:
```
kubectl taint nodes "xcache nodename" xcache=true:PreferNoSchedule
```
and labeled:
```
kubectl label nodes <your-node-name> xcache=<Instance>
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
