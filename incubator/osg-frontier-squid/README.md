# OSG Frontier Squid for Helm #

----
## Deployment
The application is packaged as osg-frontier-squid.

Deployments of this package will be labeled as `osg-frontier-squid-[Tag]`, where Tag is a required field in the values.yaml file.

Customization options are provided in the values.yaml file and can be overwritten by adjusting a copy of this file, and running `helm install osg-frontier-squid --values [myvalues].yaml` where myvalues is the name of your file.

For a comprehensive list of customization options and descriptions, please see the `values.yaml` file.

----
## Application
Frontier Squid is an HTTP cache, providing *quick access to recently downloaded data*.

The best use of this cache is to *use it as an HTTP Proxy*. You can set this within your local environment using `export http_proxy=http://[IP Address]:[Port Number]`, within your computer's global internet settings, or within an application that will utlize the cache.

Frontier Squid stores logs of activity within the container's `/var/log/squid/access.log` file, and logs of it's status and startup information within the container's `/var/log/squid/cache.log` file.

----
## Limitations
#### Release Names ####
1. Helm Charts **cannot overwrite release names**  
  * Overwriting release names can only be done from the command line using `--name` during helm install.
  * To acheive this, we would need to parse the tag from the values.yaml file used in deployment.

2. Release names must be **unique per Tiller instance**
  * By default, Helm utilizes one Tiller pod globally.
  * This restricts two pod deployments of the same name even across namespaces, unless settings are altered.

#### Accessing The Application ####
1. During installtion, Helm **does not know IP address or Port** that will be utilized  
  * There are bash commands provided in the `NOTES.txt` file that prints upon installation that users should be able to copy and paste for access to the host.
  * Context is not an accessible environment variable for me to print in the bash commands, so if this must be specified, a user has to add it.

2. The Service.Type field **defines the accessible scope of application**  
  * NodePort service type creates a pod that is visible only within the cluster.
  * LoadBalancer service type additionally assigns an external IP address and can be used internally or externally of the cluster.

#### Minikube ####
1. Minikube **does not support LoadBalancer** by default  
  * To utilize a LoadBalancer service type on minikube, run command  
     `kubectl create -f https://raw.githubusercontent.com/mrbobbytables/k8s-intro-tutorials/master/core/manifests/metalLB.yaml`  
     before creating pods that utilize the LoadBalancer.

----
## Future Work

### Persistent Volumes for Local Storage
  * Persistent volumes are an option for local storage allocation in the future
  * At the time of development, LocalVolumes do not have support for dynamic provisioning, causing multiple complications with allocation
    - Admins would have to manually provision and manage persistent volumes on nodes to be claimed
    - Persistent Volume Claims may bind to volumes larger than needed, wasting local storage

### Pod Presets for HTTP Proxy Name Injection

It is still an open problem to determine how the http proxy is injected in an appliation. Ideally, if the proxy is deployed then the http_proxy variable is set appropriately and if not the variable is left unset. Pod Presets allow in general to inject small modifications to a pod based on labels. We can imagine that, when the service is deployed, a PodPreset is also deployed such that if a pod has a well defined label (i.e. using-proxy = true) then the environment variable is set. There are the following caveats:
  * PodPresets are currently alpha. In some cases, they need to be added when building/configuring the cluster.
  * PodPresets only modify the Pod spec before deployment. Therefore if the squid proxy is installed after the installation of the application, or if it is removed after the application is already installed, the change is not picked up and the application will either not be using the proxy or trying to use a proxy that does not exist.
For these reasons, we left the issue open.
  
