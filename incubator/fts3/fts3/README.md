# FTS3 - Low-Level Data Movement Service from CERN

**NOTE**: This SLATE application requires Kubernetes secrets a hostname IGTF server SSL cerficate-key pair. The default name for this secret is "fts3-host-secret".

This chart will install and configure the FTS3 server. The user must supply a distinct database deployment. The user must supply configuration files which point the FTS3 deployment at the database.

---
## Usage:

```console
$ slate app get-conf --dev fts3 > fts3.yaml
$ slate app install --dev --group <group-name> --cluster <cluster-name> fts3
```
---

## Configuration options
| Parameter | Description | Default |
| --------  | ----------  | ------- |
| HostSecretName | The SLATE secret that contains the Host certificate and keys | `fts3-host-pems` |
| ConfigSecretName | The SLATE secret that contains the config files for fts3 | `fts3-configs` |
| DatabaseUpgrade | Whether or not to run the FTS3 database upgrade when FTS3 starts | `` |
| WebInterface | Whether or not to run the FTS3 web interface at container port 8449 | `` |
| RESTHost | The hostname to set in /etc/httpd/conf.d/fts3rest.conf | `` |
