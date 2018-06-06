# OSG Frontier Squid for Helm #

## Deployment ##
The application is packaged as osg-frontier-squid.

Deployments of this package will be labeled as `osg-frontier-squid-[Tag]`, where Tag is a required field in the values.yaml file.

Customization options are provided in the values.yaml file and can be overwritten by adjusting a copy of this file, and running `helm install osg-frontier-squid --values [myvalues].yaml` where myvalues is the name of your file.  
Customization options include  
• Tag  
• Service Port  
• Service Type  
• Squid Cache Memory Usage Limit  
• Squid Cache Disk Usage Limit

This branch utilizes local storage as a persistent volume. **Please see the limitations section before attempting to deploy**.  
The node must have a local volume mounted before deployment. The helm release chart has an option `CacheMount` that must exactly match the path on the node where the volume will be mounted.  
This helm chart deploys a Persistent volume to be scheduled on a Node with the key `storage=local`, and a Persistent Volume Claim to bind the application to use that volume to store cache data.  
The persistent volume and persistent volume claim are templated to deploy at exactly the size requested for the disk usage of the cache, to minimize wasted disk space.

## Application ##
Frontier Squid is an HTTP cache, providing *quick access to recently downloaded data*.

The best use of this cache is to **use it as an HTTP Proxy**. You can set this within your local environment using `export http_proxy=http://[IP Address]:[Port Number]`, within your computer's global internet settings, or within an application that will utlize the cache.

Frontier Squid stores logs of activity within the container's `/var/log/squid/access.log` file, and logs of it's status and startup information within the container's `/var/log/squid/cache.log` file.

## Limitations ##

#### Persistent Volumes ####
1. For LocalVolumes, **the volume must already exist on the node**
  * As it stands, it is set up for a mount in minikube
  * Dynamic provisioning is in the works on kubernete's end
  * To create the mount in minikube that this defaults to:    
  ```bash
  minikube ssh  
  mkdir mnt/disks/vol1  
  sudo mount -t tmpfs vol1 mnt/disks/vol1  
  logout
  ```
g
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
     ```kubectl create -f https://raw.githubusercontent.com/mrbobbytables/k8s-intro-tutorials/master/core/manifests/metalLB.yaml```  
     before creating pods that utilize the LoadBalancer.
