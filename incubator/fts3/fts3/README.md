# FTS3 - Low-Level Data Movement Service from CERN

**NOTE**: This SLATE application requires Kubernetes secrets for a user X509 certificate-key pair, as well as for a hostname IGTF server SSL cerficate-key pair. The default names for these secrets are "fts3-user-secret" and "fts3-host-secret", respectively.

This chart will install and configure the FTS3 server. The user must supply a distinct database deployment and ActiveMQ (or other STOMP protocol) messaging queue deployment. The user must supply configuration files which point the FTS3 deployment at the database and queue deployment.

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
| HostNetwork | Whether to use the Kubernetes HostNetwork interface | `true` |
| HostSecretName | The SLATE secret that contains the Host certificate and keys | `fts3-host-pems` |
| UserSecretName | The SLATE secret that contains the User X509 credentials for FTS3 transfers between GridFTP servers | `fts3-user-pems` |
