# Monitoring Kubernetes in Check-mk
This project provides monitoring services for a kubernetes cluster with [SLATE](http://slateci.io/). It will also be beneficial to read over the [Checkmk-Official Guide](https://checkmk.com/cms.html) for reference to using the online dashboard.

## Minimum Requirements - - - - - I may need to update this based on slate application
- Linux (2 cores, 4GB memory, 15GB storage) or MacOS
- A publicly accessible IP address (port 6443 open)
- Python (3 or 2.7, 'python' must be in your PATH)
- [DockerCE](https://docs.docker.com/install/#supported-platforms)
- [Docker-Compose](https://github.com/docker/compose/releases) (installed with Docker for Mac)
-Possibly need to install helm and tiller(Refer back to this note) and SLATE application

On Linux, the user running SLATElite must be a member of the Docker group (or root).
Users can be added to the Docker group with: `sudo usermod -a -G docker <username>`

## Getting Started
After installing the dependency requirements and pulling the SLATElite repository:


//////////////////////////////////////////////////////////////////
////////Everything that is requires to get slate up and going///
//////////////////////////////////////////////////////////////////.

## Deploying Check-mk in your kubernetes cluster

Clone the [slateci/slate-catalog](https://github.com/slateci/slate-catalog) repository on the machine you are running your Kubernestes cluster on.

cd into your slate-catalog/incubator/check-mk/check-mk directory. At this point you will need to deploy the check-mk application within Kubernetes. To do this run `helm install check-mk`. Helm manages the deployement of check-mk.

Run `kubectl get pods` to ensure that the check-mk application is now running on your cluster. You should see a pod that has been deployed and is running check-mk.

In order to set up the dashboard that you will be running to monitor your cluster you need to run the following commands:

`export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services check-mk-global)`

`export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")`

`echo http://$NODE_IP:$NODE_PORT/cmk/check_mk`

Open the URL that is given to you in your default web browser which will lead you to the login for you check-mk dashboard.

To access the login information you will need to run the following commands:

`kubectl get pods`

Copy the name of the check-mk pod which will be in the form 'check-mk-global-ID'. An example is check-mk-global-4d2f86d99c-swdnt. With this information run the folloing command, pasting in the name you just received:

`kubectl logs <checkmk_pod_name>`

The logs provides the given username and password. Enter those into your dashboard in your web browser you opened up earlier and you will have access to start monitoring from the dashboard. Note that you have the abolity to change the password by following the instructions provided in the logs.

## Setting up Monitoring on your Kubernetes Cluster

Check-mk provides the necessary steps for setting up monitoring on your kubernetes cluster. There are some additional steps needed that aren't provided in check-mk's documentation so make sure to read the provided guidelines before starting because they work in tandem with check-mk's steps.


While logged into your cluster download the source code provided at [Check-mk Downloads](https://checkmk.com/download-source.php?). Make sure to download the most recent stable version. Also, make sure it is the complate source code of Check-mk with OMD. This will coincide with the version that is provided in Helm's earlier deployment and will help prevent further issues. Once the dowload is complete, extract all the files through the command:

`tar -zxvf <your_checkmk-rawedition-1.5.tar.gz>`

Now that you have downloaded the source code you are ready to start check-mk's walk through for [Monitoring Kubernetes](https://checkmk.com/cms_monitoring_kubernetes.html). Again, make sure to refer to the guidelines below to simplify the process.



## Additional guidelines for setting up Check-mk:

The rbac.yaml file with be found in the check-mk-raw-1.5.0p19.cre/doc/treasures/kubernetes directory. Not the one it lists on the walk-through.

In section 2.4. Adding a Kubernetes-Cluster to the Monitoring you will be putting in a password token. The documentation doesn't specify to to click the Port button, but it is necessary to do so, otherwise the cluster can not be accessed. Make sure to define the port as 6443.

After defining the port and saving the password token you need to add a host. You are going to be adding the kubernetes cluster to your monitoring topology. To accomplish this go to "WATO" in the left side bar and click "Hosts". Once there click "Create new host". The host name is the IP adress that the cluster is running on. you can get this information by running the command: `kubectl cluster-info`. Make sure to leave the port number off since it was already definied in the rule. In the "Data Sources" portion check the "Check_MK Agent". Now click "Save & go the Services" at the bottom of the page. At this point you will now recognize the services offered by check-mk on your cluster. 

Determine which services you would like to monitor and click the "Monitor" button at the top. The changes you have made have not been saved and applied to your monitoring topology as a whole. To do this you need to click the "changes" button at the top with a warning sign. It will indicate the number of changes you have made. it is important to click "Activate affected" or your changes will not be monitored.

