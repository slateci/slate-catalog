# Monitoring Kubernetes in Check-mk
This project provides monitoring services for a kubernetes cluster within [SLATE](http://slateci.io/). It will also be beneficial to read over the [Checkmk-Official Guide](https://checkmk.com/cms.html) as a reference to using the online dashboard.

## Getting Started
Install the [SLATE CLI Client](https://slateci.io/docs/tools/#installing-the-slate-client)

## Deploying Check-mk through the SLATE CLI (Recommended)
If you wish to install an instance of check-mk manually through Helm skip down to the following header.

Otherwise, Make sure your [cluster is registered as part of SLATE](https://slateci.io/docs/cluster/index.html) before proceeding. You can confirm that your cluster is registered in SLATE by running `slate cluster list` through the SLATE client. Identify your cluster in the list. You also need to make sure you are part of a group in order to install check-mk.

To install check-mk in your cluster run the following command: 

`slate app install check-mk --dev --cluster <cluster_name> --group <group_name>`

You will need the instance number of the check-mk installation by running 

`slate instance list --cluster <cluster_name> --group <group_name>`

In order to get the URL of the dashboard for check-mk run the following commands:

`export NODE_IP=$(slate instance info <instance_ID> | grep 'Host IP: ' | awk -F '[ -]*' '$0=$NF')`

`export NODE_PORT=$(slate instance info <instance_ID> | grep -m 1 $NODE_IP | awk -F '[ -]*' '$0=$NF')`

`echo http://$NODE_PORT/cmk/check_mk`

Once opening the url in your browser you can find the username and password by running the command:

`slate instance logs <instance_ID>`

Continue to the header at 'Setting up Monitoring on your Kubernetes Cluster'



## Deploying Check-mk in your kubernetes cluster with helm and kubectl

This will allow you to install check-mk onto any Kubernetes cluster, even if it is not part of the SLATE federation. Clone the [slateci/slate-catalog](https://github.com/slateci/slate-catalog) repository on the machine you are running your Kubernestes cluster on.

cd into your slate-catalog/incubator/check-mk/check-mk directory. At this point you will need to deploy the check-mk application within Kubernetes. To do this run `helm install check-mk`. Helm manages the deployement of check-mk on kubernetes.

If you need to install helm refer to [Helm Installation](https://helm.sh/docs/intro/install/)

Run `kubectl get pods` to ensure that the check-mk application is now running on your cluster. You should see a pod that has been deployed and is running check-mk. If you have multiple namespaces and have install check-mk in to a different namespace other than default than you may need to run `kubectl get pods --all-namespaces` in order to find the check-mk deployment

In order to set up the dashboard that you will be running to monitor your cluster you need to run the following commands:

`export NODE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].nodePort}" services check-mk-global)`

`export NODE_IP=$(kubectl get nodes --namespace default -o jsonpath="{.items[0].status.addresses[0].address}")`

`echo http://$NODE_IP:$NODE_PORT/cmk/check_mk`

Open the URL that is given to you in your default web browser which will lead you to the login for you check-mk dashboard.

To access the login information you will need to run the following commands:

`kubectl get pods`

Copy the name of the check-mk pod which will be in the form 'check-mk-global-ID'. An example is check-mk-global-4d2f86d99c-swdnt. With this information run the following command, pasting in the name you just received:

`kubectl logs <checkmk_pod_name>`

The logs provides the given username and password. Enter those into your dashboard in your web browser you opened up earlier and you will have access to start monitoring from the dashboard. Note that you have the ability to change the password by following the instructions provided in the logs.

## Setting up Monitoring on your Kubernetes Cluster

Check-mk provides the necessary steps for setting up monitoring on your kubernetes cluster. There are some additional steps needed that aren't provided in check-mk's documentation so make sure to read the provided guidelines before starting because they work in tandem with check-mk's steps.


While logged into your cluster download the source code provided at [Check-mk Downloads](https://checkmk.com/download-source.php?). Make sure to download the most recent version. Also, make sure it is the complete source code of Check-mk with OMD. This will coincide with the version that is provided in Helm's earlier deployment and will help prevent further issues. Once the dowload is complete, extract all the files through the command:

`tar -zxvf <your_checkmk-rawedition-1.6.tar.gz>`

Now that you have downloaded the source code you are ready to start check-mk's walk through for [Monitoring Kubernetes](https://checkmk.com/cms_monitoring_kubernetes.html). Again, make sure to refer to the guidelines below to simplify the process.



## Additional guidelines for setting up Check-mk:

The rbac.yaml file will be found in the check-mk-raw-1.6.0p6.cre/doc/treasures/kubernetes directory. Not the path it lists on the walk-through.

In section 2.4. Adding a Kubernetes-Cluster to the Monitoring you will be putting in a password token. The documentation doesn't specify to to click the Port button, but it is necessary to do so, otherwise the cluster can not be accessed. Make sure to define the port as 6443.

In section 2.5 is mentions the new version of check-mk-1.6. The configuration looks different than they show in the walk-through. Simply put in the token received from the secrets into the token value. Click on the port button and make sure to spcify port 6443. Leave all the other boxes clear. Again, do not click the Custom URL prefix, the Custom path prefix, or Disable certificate verification. Those will only come in to play if you are monitoring multiple clusters from this same dashboard. The documentation on how to do that will be updated shortly.

After defining the port number and saving the password token you need to add a host, which will be the actual kubernetes cluster. You are going to be adding the kubernetes cluster to your monitoring topology. To accomplish this go to your dashboard, then to "WATO" in the left side bar and click "Hosts". Once there click "Create new host". The host name is the IP adress that the cluster is running on. You can get this information by running the command: `kubectl cluster-info`. It is the given IP address associated with the application running on port 6443. Make sure to leave the port number off since it was already definied in the data-source rule. In the "Data Sources" portion check the "Use Check-MK Agent or Data-Source  program". Now click "Save & go the Services" at the bottom of the page. At this point you will now recognize the services offered by check-mk on your cluster. 

Determine which services you would like to monitor and click the "Monitor" button at the top. The changes you have made have not been saved and applied to your monitoring topology as a whole. To do this you need to click the "changes" button at the top with a warning sign. It will indicate the number of changes you have made. it is important to click "Activate affected" or your changes will not be monitored.

