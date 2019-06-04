# GridFTP - Secure, Robust, Fast, Efficient Data Transfer 

**NOTE**: This SLATE application requires Kubernetes secrets for both a user X509 certificate-key pair, as well as for a hostname IGTF server SSL cerficate-key pair. The default names for these secrets are "gridftp-user-secret" and "gridftp-host-secret", respectively.

This chart will install and configure a GridFTP front end, with the option of installing and configuring a data node for back end data striping.

---
## Usage:

```console
$ slate app get-conf gridftp > gridftp.yaml
$ slate app install --group <group-name> --cluster <cluster-name> gridftp.yaml
```
---
