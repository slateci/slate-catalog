# Grafana

* Installs the web dashboarding system [Grafana](http://grafana.org/)
* Image source: https://hub.docker.com/r/grafana/grafana

# Installation:

```console
$ slate app get-conf grafana > grafana.yaml
$ slate app install --group <group-name> --cluster <cluster-name> grafana.yaml
```

# Configuration and use:

###Values Configuration
These are options that may be configured in Grafana's `values.yaml` and/or `deployment.yaml` if desired.


| Parameter                       | Description                                   | Default                                                 |
|---------------------------------|-----------------------------------------------|---------------------------------------------------------|
| `replicas`                      | Number of nodes                               | `1`                                                     |
| `deploymentStrategy`            | Deployment strategy                           | `RollingUpdate`                                         |
| `securityContext`               | Deployment securityContext                    | `{"runAsUser": 472, "fsGroup": 472}`                    |
| `image.repository`              | Image repository                              | `grafana/grafana`                                       |
| `image.tag`                     | Image tag. (`Must be >= 5.0.0`)               | `5.2.3`                                                 |
| `image.pullPolicy`              | Image pull policy                             | `IfNotPresent`                                          |
| `service.type`                  | Kubernetes service type                       | `ClusterIP`                                             |
| `service.port`                  | Kubernetes port where service is exposed      | `9000`                                                  |
| `service.annotations`           | Service annotations                           | `80`                                                    |
| `service.labels`                | Custom labels                                 | `{}`                                                    |
| `ingress.enabled`               | Enables Ingress                               | `false`                                                 |
| `ingress.annotations`           | Ingress annotations                           | `{}`                                                    |
| `ingress.labels`                | Custom labels                                 | `{}`                                                    |
| `ingress.hosts`                 | Ingress accepted hostnames                    | `[]`                                                    |
| `ingress.tls`                   | Ingress TLS configuration                     | `[]`                                                    |
| `resources`                     | CPU/Memory resource requests/limits           | `{}`                                                    |
| `nodeSelector`                  | Node labels for pod assignment                | `{}`                                                    |
| `tolerations`                   | Toleration labels for pod assignment          | `[]`                                                    |
| `affinity`                      | Affinity settings for pod assignment          | `{}`                                                    |
| `persistence.enabled`           | Use persistent volume to store data           | `false`                                                 |
| `persistence.size`              | Size of persistent volume claim               | `10Gi`                                                  |
| `persistence.existingClaim`     | Use an existing PVC to persist data           | `nil`                                                   |
| `persistence.storageClassName`  | Type of persistent volume claim               | `nil`                                                   |
| `persistence.accessModes`       | Persistence access modes                      | `[]`                                                    |
| `persistence.subPath`           | Mount a sub dir of the persistent volume      | `""`                                                    |
| `schedulerName`                 | Alternate scheduler name                      | `nil`                                                   |
| `env`                           | Extra environment variables passed to pods    | `{}`                                                    |
| `envFromSecret`                 | Name of a Kubenretes secret (must be manually created in the same namespace) containing values to be added to the environment | `""` |
| `extraSecretMounts`             | Additional grafana server secret mounts       | `[]`                                                    |
| `datasources`                   | Configure grafana datasources                 | `{}`                                                    |
| `dashboardProviders`            | Configure grafana dashboard providers         | `{}`                                                    |
| `dashboards`                    | Dashboards to import                          | `{}`                                                    |
| `dashboardsConfigMaps`          | ConfigMaps reference that contains dashboards | `{}`                                                    |
| `grafana.ini`                   | Grafana's primary configuration               | `{}`                                                    |
| `ldap.existingSecret`           | The name of an existing secret containing the `ldap.toml` file, this must have the key `ldap-toml`. | `""` |
| `ldap.config  `                 | Grafana's LDAP configuration                  | `""`                                                    |
| `annotations`                   | Deployment annotations                        | `{}`                                                    |
| `podAnnotations`                | Pod annotations                               | `{}`                                                    |
| `sidecar.dashboards.enabled`    | Enabled the cluster wide search for dashboards and adds/updates/deletes them in grafana | `false`       |
| `sidecar.dashboards.label`      | Label that config maps with dashboards should have to be added | `false`                                |
| `sidecar.datasources.enabled`   | Enabled the cluster wide search for datasources and adds/updates/deletes them in grafana |`false`       |
| `sidecar.datasources.label`     | Label that config maps with datasources should have to be added | `false`                               |
| `smtp.existingSecret`           | The name of an existing secret containing the SMTP credentials, this must have the keys `user` and `password`. | `""` |

###Accessing the web portal
The `adminuser` and `adminPassword` fields in Grafana's `values.yaml` file (lines 23 & 24) are the username and password for the admin account created to login to the instance of Grafana that is installed. These should be changed from their defaults.

After installing the app, use `slate instance info <instance-id>` to get the IP Address where Grafana may be accessed at. 

After the instance has been set up you can log in via the IP address provided using the credentials set up under `adminuser` and `adminPassword`. This will take you to a web portal were you can set up all your data sources and prefered visualization settings.

For the grafana instance set up through SLATE all of the data source and visualization settings are ephemaral by nature. If the instance gets blown away those settings will all be lost and even if a new instance is set up with the same grafana.yaml file these settings will need to be reset.
