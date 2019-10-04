# SLATE Application Catalog

The SLATE Application Catalog is a [Helm](https://github.com/helm/helm) catalog focused on providing high-quality, secure packages for Scientific Computing applications. 

# How to use
We have designed the catalog to both be compatible with standard Helm clients, as well as the `slate` commandline interface and API used by the SLATE project. If you're already using [SLATE](http://slateci.io), then there's nothing additional that you need to do, just use the SLATE client. 

## Using the SLATE Catalog with Helm
Simply add the SLATE repository to your Helm configuration:
```
[17:00]:~ $ helm repo add slate http://jenkins.slateci.io/catalog/stable/
"slate" has been added to your repositories
```

You can then test to see if an application is available:
```
[17:00]:~ $ helm search condor
NAME          	CHART VERSION	APP VERSION	DESCRIPTION                                       
slate/htcondor	0.8.5        	8.6.13     	HTCondor distributed high-throughput computing ...
```

## Differences from other Helm packages
Applications running within SLATE operate under a more restrictive environment than typical Kubernetes applications. For instance, SLATE apps are not allowed to create namespaces, roles, storage classes, or install Operators on the user's behalf. Users within the SLATE system are typically external users to a cluster administered by someone else. 

# Contributing

## Repository layout

Example:

	stable/
		my_app/
			my_app/
				(chart sources)
			images/
				my_app/
					Dockerfile
					image_nametag
					(other container image source files)
				a_helper_image/
					Dockerfile
					image_nametag
					(other container image source files)

As for the [main kubernetes helm repository](https://github.com/kubernetes/charts), there are two repositories: stable and incubator. Stable holds applications that are fully vetted while incubator holds those that are still under development. Each application is a subdirectory within one of those two directories.

Each application subdirectory must contain another subdirectory _with the same name_ which contains the helm chart sources.
This enables including other data besides chart sources for an application, however, because helm requires a chart source directory to have a name matching the chart name nested directories with the same names are unavoidable.

Besides the subdirectory for the chart sources, an application's directory can contain a subdirectory named 'images', which contains further subdirectories for any container image sources, one per image. The image source directories may have any names. Each image source directory should contain the Dockerfile which defines the image, any supporting files, and one special file named 'image\_nametag' which contains the name and tag to be used for the image, like "my\_app:latest". 

## How to rebuild the packages

To rebuild all packages from sources:

```bash
> mkdir build
> cd build
> cmake ..
> make
```

CMake 3 is required, so on some systems it may be necessary to replace `cmake` above with `cmake3`.

### Known limitations

When a chart is added or a file is added to a chart the cmake scripts will not take notice until `make rebuild_cache` is run.  

### Incubator vs Stable

When a new application is packaged as a helm chart and is added to the SLATE catalog it is initially placed into the Incubator. It will stay in the incubator until it has been thouroughly tested to prove that the application works in SLATE the same way it is supposed to outside of SLATE. Once all parties involved agree that the application functions it will be moved to the Stable repository where it can be easily accessed from the portal and command line interface

### Chart Version

Whenever a change is made to a chart in any way, from templates to documentation, the version value in Chart.yaml must be incremented so that Helm will update the helm charts used by the API Server
