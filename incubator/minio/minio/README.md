# MinIO

[MinIO](https://min.io) is a distributed object storage service for high performance, high scale data infrastructures. It is a drop in replacement for AWS S3 in your own environment. It uses erasure coding to provide highly resilient storage that can tolerate failures of upto n/2 nodes. It runs on cloud, container, kubernetes and bare-metal environments. It is simple enough to be deployed in seconds, and can scale to 100s of peta bytes. MinIO is suitable for storing objects such as photos, videos, log files, backups, VM and container images.

MinIO supports [distributed mode](https://docs.minio.io/docs/distributed-minio-quickstart-guide). In distributed mode, you can pool multiple drives (even on different machines) into a single object storage server.

## Installation
------------

Download the configuration file with SLATE. 

`slate app get-conf minio --dev -o minio.yaml`

At a minimum you should configure the `Instance` tag, the service, and authentication. By default the service does not expose MinIO outside the cluster.

Authentication is configured by default to use an access key and a secret key. A default key has been written into the configuration file, which you may use. It is reccomended to provide the keys to your cluster as a secret using `slate secret create`, then configure MinIO to use the secret with the `existingSecret` value. It is also possible to configure MinIO to use TLS (https://github.com/minio/minio/tree/master/docs/tls/kubernetes#2-create-kubernetes-secret).

Once you have saved the desired configuration, install your MinIO SLATE instance:

`slate app install minio --cluster <YOUR CLUSTER> --group <YOUR GROUP> --conf minio.yaml --dev`

Then run `slate instance info <INSTANCE ID>` to see information about your MinIO instance, including the endpoint which you will need to connect to later.


## Configuration
-------------

The following table lists the configurable parameters of the MinIO chart and their default values.

| Parameter                                 | Description                                                                                                                             | Default                                    |
|:------------------------------------------|:----------------------------------------------------------------------------------------------------------------------------------------|:-------------------------------------------|
| `image.repository`                        | Image repository                                                                                                                        | `minio/minio`                              |
| `image.tag`                               | MinIO image tag. Possible values listed [here](https://hub.docker.com/r/minio/minio/tags/).                                             | `RELEASE.2019-08-07T01-59-21Z`             |
| `image.pullPolicy`                        | Image pull policy                                                                                                                       | `IfNotPresent`                             |
| `mcImage.repository`                      | Client image repository                                                                                                                 | `minio/mc`                                 |
| `mcImage.tag`                             | mc image tag. Possible values listed [here](https://hub.docker.com/r/minio/mc/tags/).                                                   | `RELEASE.2019-08-07T23-14-43Z`             |
| `mcImage.pullPolicy`                      | mc Image pull policy                                                                                                                    | `IfNotPresent`                             |
| `ingress.enabled`                         | Enables Ingress                                                                                                                         | `false`                                    |
| `ingress.annotations`                     | Ingress annotations                                                                                                                     | `{}`                                       |
| `ingress.hosts`                           | Ingress accepted hostnames                                                                                                              | `[]`                                       |
| `ingress.tls`                             | Ingress TLS configuration                                                                                                               | `[]`                                       |
| `mode`                                    | MinIO server mode (`standalone` or `distributed`)                                                                                       | `standalone`                               |
| `replicas`                                | Number of nodes (applicable only for MinIO distributed mode). Should be 4 <= x <= 32                                                    | `4`                                        |
| `existingSecret`                          | Name of existing secret with access and secret key.                                                                                     | `""`                                       |
| `accessKey`                               | Default access key (5 to 20 characters)                                                                                                 | `AKIAIOSFODNN7EXAMPLE`                     |
| `secretKey`                               | Default secret key (8 to 40 characters)                                                                                                 | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `configPath`                              | Default config file location                                                                                                            | `~/.minio`                                 |
| `configPathmc`                            | Default config file location for MinIO client - mc                                                                                      | `~/.mc`                                    |
| `mountPath`                               | Default mount location for persistent drive                                                                                             | `/export`                                  |
| `clusterDomain`                           | domain name of kubernetes cluster where pod is running.                                                                                 | `cluster.local`                            |
| `service.type`                            | Kubernetes service type                                                                                                                 | `ClusterIP`                                |
| `service.port`                            | Kubernetes port where service is exposed                                                                                                | `9000`                                     |
| `service.externalIPs`                     | service external IP addresses                                                                                                           | `nil`                                      |
| `service.annotations`                     | Service annotations                                                                                                                     | `{}`                                       |
| `serviceAccount.create`                   | Toggle creation of new service account                                                                                                  | `true`                                     |
| `serviceAccount.name`                     | Name of service account to create and/or use                                                                                            | `""`                                       |
| `persistence.enabled`                     | Use persistent volume to store data                                                                                                     | `true`                                     |
| `persistence.size`                        | Size of persistent volume claim                                                                                                         | `10Gi`                                     |
| `persistence.existingClaim`               | Use an existing PVC to persist data                                                                                                     | `nil`                                      |
| `persistence.storageClass`                | Storage class name of PVC                                                                                                               | `nil`                                      |
| `persistence.accessMode`                  | ReadWriteOnce or ReadOnly                                                                                                               | `ReadWriteOnce`                            |
| `persistence.subPath`                     | Mount a sub directory of the persistent volume if set                                                                                   | `""`                                       |
| `resources`                               | CPU/Memory resource requests/limits                                                                                                     | Memory: `256Mi`, CPU: `100m`               |
| `priorityClassName`                       | Pod priority settings                                                                                                                   | `""`                                       |
| `nodeSelector`                            | Node labels for pod assignment                                                                                                          | `{}`                                       |
| `affinity`                                | Affinity settings for pod assignment                                                                                                    | `{}`                                       |
| `tolerations`                             | Toleration labels for pod assignment                                                                                                    | `[]`                                       |
| `podAnnotations`                          | Pod annotations                                                                                                                         | `{}`                                       |
| `podLabels`                               | Pod Labels                                                                                                                              | `{}`                                       |
| `tls.enabled`                             | Enable TLS for MinIO server                                                                                                             | `false`                                    |
| `tls.certSecret`                          | Kubernetes Secret with `public.crt` and `private.key` files.                                                                            | `""`                                       |
| `livenessProbe.initialDelaySeconds`       | Delay before liveness probe is initiated                                                                                                | `5`                                        |
| `livenessProbe.periodSeconds`             | How often to perform the probe                                                                                                          | `30`                                       |
| `livenessProbe.timeoutSeconds`            | When the probe times out                                                                                                                | `1`                                        |
| `livenessProbe.successThreshold`          | Minimum consecutive successes for the probe to be considered successful after having failed.                                            | `1`                                        |
| `livenessProbe.failureThreshold`          | Minimum consecutive failures for the probe to be considered failed after having succeeded.                                              | `3`                                        |
| `readinessProbe.initialDelaySeconds`      | Delay before readiness probe is initiated                                                                                               | `5`                                        |
| `readinessProbe.periodSeconds`            | How often to perform the probe                                                                                                          | `15`                                       |
| `readinessProbe.timeoutSeconds`           | When the probe times out                                                                                                                | `1`                                        |
| `readinessProbe.successThreshold`         | Minimum consecutive successes for the probe to be considered successful after having failed.                                            | `1`                                        |
| `readinessProbe.failureThreshold`         | Minimum consecutive failures for the probe to be considered failed after having succeeded.                                              | `3`                                        |
| `defaultBucket.enabled`                   | If set to true, a bucket will be created after MinIO install                                                                            | `false`                                    |
| `defaultBucket.name`                      | Bucket name                                                                                                                             | `bucket`                                   |
| `defaultBucket.policy`                    | Bucket policy                                                                                                                           | `none`                                     |
| `defaultBucket.purge`                     | Purge the bucket if already exists                                                                                                      | `false`                                    |
| `buckets`                                 | List of buckets to create after MinIO install                                                                                           | `[]`                                       |
| `s3gateway.enabled`                       | Use MinIO as a [s3 gateway](https://github.com/minio/minio/blob/master/docs/gateway/s3.md)                                              | `false`                                    |
| `s3gateway.replicas`                      | Number of s3 gateway instances to run in parallel                                                                                       | `4`                                        |
| `s3gateway.serviceEndpoint`               | Endpoint to the S3 compatible service                                                                                                   | `""`                                       |
| `azuregateway.enabled`                    | Use MinIO as an [azure gateway](https://docs.minio.io/docs/minio-gateway-for-azure)                                                     | `false`                                    |
| `azuregateway.replicas`                   | Number of azure gateway instances to run in parallel                                                                                    | `4`                                        |
| `gcsgateway.enabled`                      | Use MinIO as a [Google Cloud Storage gateway](https://docs.minio.io/docs/minio-gateway-for-gcs)                                         | `false`                                    |
| `gcsgateway.gcsKeyJson`                   | credential json file of service account key                                                                                             | `""`                                       |
| `gcsgateway.projectId`                    | Google cloud project id                                                                                                                 | `""`                                       |
| `ossgateway.enabled`                      | Use MinIO as an [Alibaba Cloud Object Storage Service gateway](https://github.com/minio/minio/blob/master/docs/gateway/oss.md)          | `false`                                    |
| `ossgateway.replicas`                     | Number of oss gateway instances to run in parallel                                                                                      | `4`                                        |
| `ossgateway.endpointURL`                  | OSS server endpoint.                                                                                                                    | `""`                                       |
| `nasgateway.enabled`                      | Use MinIO as a [NAS gateway](https://docs.MinIO.io/docs/minio-gateway-for-nas)                                                          | `false`                                    |
| `nasgateway.replicas`                     | Number of NAS gateway instances to be run in parallel on a PV                                                                           | `4`                                        |
| `environment`                             | Set MinIO server relevant environment variables in `values.yaml` file. MinIO containers will be passed these variables when they start. | `MINIO_BROWSER: "on"`                      |
| `metrics.serviceMonitor.enabled`          | Set this to `true` to create ServiceMonitor for Prometheus operator                                                                     | `false`                                    |
| `metrics.serviceMonitor.additionalLabels` | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus                                                   | `{}`                                       |
| `metrics.serviceMonitor.namespace`        | Optional namespace in which to create ServiceMonitor                                                                                    | `nil`                                      |
| `metrics.serviceMonitor.interval`         | Scrape interval. If not set, the Prometheus default scrape interval is used                                                             | `nil`                                      |
| `metrics.serviceMonitor.scrapeTimeout`    | Scrape timeout. If not set, the Prometheus default scrape timeout is used                                                               | `nil`                                      |

Some of the parameters above map to the env variables defined in the [MinIO DockerHub image](https://hub.docker.com/r/minio/minio/).


## Distributed MinIO
-----------

This chart provisions a MinIO server in standalone mode, by default. To provision MinIO server in [distributed mode](https://docs.minio.io/docs/distributed-minio-quickstart-guide), set the `mode` field to `distributed`,

This provisions MinIO server in distributed mode with 4 nodes. To change the number of nodes in your distributed MinIO server, set the `replicas` field,

Note that the `replicas` value should be an integer between 4 and 16 (inclusive).

## Usage 

This application deploys the MinIO Server component. In order to create buckets and interact with the storage you will need to deploy the MinIO client somewhere. This section will detail the proccess of deploy a test client and connecting it to your SLATE MinIO Server instance. 

The easiest way to install and use the client is through Docker. Other installation options can be found at:

 https://docs.min.io/docs/minio-client-complete-guide

To start the client in a docker container on your machine run:

`docker run -it --entrypoint=/bin/sh minio/mc`

This command will drop you into the shell for your MinIO Client container. Run `mc --help` to see more information about the client.

To connect the client to your MinIO SLATE Server instance use `mc config host add <ALIAS> <YOUR-ENDPOINT> <YOUR-ACCESS-KEY> <YOUR-SECRET-KEY>`

Example: `mc config host add myMinio http://192.168.254.143:9000 AKIAIOSFODNN7EXAMPLE wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`

The keys in the command above will work for you if you've left the default key configuration when you installed the server with SLATE. The endpoint will need to match the endpoint for your instance. Running `slate instance info <INSTANCE ID>` will retrieve information about your MinIO Server Instance. 

Once you are configured to use your SLATE MinIO instance you can create a bucket.

`mc mb myMinio/testBucket`

Then create a file and copy it into the new bucket.

`echo "some content" > myFile.txt && mc cp myFile.txt myMinio/testBucket`

You should be able to see your file in the new bucket.

`mc ls myMinio/testBucket`

This is a simple excercise to test your MinIO deployment. Complete documentation and usage can be found at:

https://docs.min.io/docs/minio-client-complete-guide

and

https://docs.min.io/docs/minio-server-configuration-guide.html


### StatefulSet [limitations](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/#limitations) applicable to distributed MinIO

1. StatefulSets need persistent storage, so the `persistence.enabled` flag is ignored when `mode` is set to `distributed`.
2. When uninstalling a distributed MinIO release, you'll need to manually delete volumes associated with the StatefulSet.