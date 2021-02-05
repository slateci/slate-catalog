# Open OnDemand Development Notes



## Questions

* Immediate vs. WaitForFirstConsumer SLATE volume bindings?
* If a container restarts, what all is preserved?
	* Are environment variables not declared in the deployment persisted?


## Notes

If the new image (jboss/keycloak) is used, the `admin` user's password will be set to a random value.
This password can be found by running `echo $KEYCLOAK_PASSWORD` inside the Keycloak container.
Because a persistent SLATE volume backs the Keycloak database, if the deployment or container is restarted, `$KEYCLOAK_PASSWORD` will no longer hold the proper admin password.
The password will still be the same from the first application install.
It would be good to figure out how to save this initial password. (SLATE secret?)




## TO-DO

* Figure out how to determine when Keycloak needs to be set up (identify first time application starts)
* Add fail-safe if script is inadvertently run twice? Check for prior existence of on-demand realm?
	* This is particularly important because Kubernetes may attempt to run post-start hooks twice.



## Volume Setup

`utah-dev` volume creation: `slate volume create --group slate-dev --cluster utah-dev --size 50M --storageClass local-path keycloak-db`

This will create the volume in the `slate-group-slate-dev` namespace. 
For the Keycloak container to properly claim the volume, it will need to be installed in the same group. 
If installing directly with Helm, use `-n slate-group-slate-dev`. 
Otherwise, as long as the volume and application are installed in the same SLATE group, the deployment will be able to properly claim its volume.

Consult individual cluster documentation for information about supported storage classes on a per-cluster basis. (`slate cluster info <cluster_name>`)


## Keycloak Setup:

**Old image:**
Default user: `admin`
Default password: `KEYCLOAKPASS`

**New image(jboss/keycloak):**
Default user: `admin`
Default password: `echo $KEYCLOAK_PASSWORD` (in Keycloak container)


## SLATE Setup:

`slate app get-conf open-ondemand > ood.yaml`

`slate volume create --group <group_name> --cluster <cluster> --size <volume_size> --storageClass <storage_class> volume-name

`slate app install open-ondemand --group <group_name> --cluster <cluster> --conf ood.yaml`



* Retrieve default configuration file. (see first command above)
* Create a SLATE volume to persist configuration. (see second command above)
* Modify configuration file to ensure appropriate setup.
	* Set the `SLATE.Cluster.DNSName` value to the DNS name of the cluster the application is being installed on
	* Set the `claimName` value to the name of the previously created SLATE volume.
* Install app with custom configuration onto a SLATE cluster. (see last command above)

