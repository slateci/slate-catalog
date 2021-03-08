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
